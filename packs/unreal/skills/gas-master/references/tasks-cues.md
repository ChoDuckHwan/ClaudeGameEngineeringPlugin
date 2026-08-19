# Ability Tasks and Gameplay Cues

Two different jobs that are easy to confuse:

- **Ability tasks** make an ability last longer than one frame. They are gameplay.
- **Gameplay cues** play sounds, particles, and camera effects. They are **not** gameplay and
  must never be relied on for it.

---

# Ability Tasks

`ActivateAbility()` runs in a single frame. Anything that waits — for input, for a montage, for
an attribute, for time — is an ability task.

## Using one

```cpp
UAbilityTask_PlayMontageAndWait* Task =
    UAbilityTask_PlayMontageAndWait::CreatePlayMontageAndWaitProxy(this, NAME_None, Montage, Rate);
Task->OnCompleted.AddDynamic(this, &UMyAbility::OnDone);
Task->OnInterrupted.AddDynamic(this, &UMyAbility::OnCancelled);
Task->ReadyForActivation();          // C++ must call this — Blueprint does it for you
```

In Blueprint, `K2Node_LatentGameplayTaskCall` calls `ReadyForActivation()`,
`BeginSpawningActor()`, and `FinishSpawningActor()` automatically. **In C++ none of that
happens.** A task that seems to do nothing is usually a missing `ReadyForActivation()`.

Cancel with `EndTask()`.

## What ships with the engine

- **Input**: `WaitInputPress`, `WaitInputRelease`, `WaitConfirm`, `WaitCancel`,
  `WaitConfirmCancel`
- **Montages**: `PlayMontageAndWait`
- **Attributes**: `WaitAttributeChange`, `WaitAttributeChangeThreshold`, ...
- **Effects/tags**: `WaitGameplayEffectApplied`, `WaitGameplayTagAdded/Removed`,
  `WaitGameplayTagQuery` (5.1)
- **Events**: `WaitGameplayEvent`
- **Timing**: `WaitDelay`, `NetworkSyncPoint`
- **Movement**: the `RootMotionSource` family — `ApplyRootMotionMoveToForce`,
  `ApplyRootMotionConstantForce`, `ApplyRootMotionJumpForce`, `MoveToLocation`, ...
- **Targeting**: `WaitTargetData`, `WaitTargetDataUsingActor`

There is a hardcoded **game-wide limit of 1000 concurrent tasks**. Relevant for RTS-scale games.

## Input release: the case that bites

`WhileInputActive` (Lyra) and the equivalent elsewhere only govern *activation*. Releasing the
key fires a replicated input event and **does not end the ability**. Without a listener, one
tap leaves the ability on forever.

```cpp
UAbilityTask_WaitInputRelease* Task =
    UAbilityTask_WaitInputRelease::WaitInputRelease(this, /*bTestAlreadyReleased=*/true);
Task->OnRelease.AddDynamic(this, &UMyAbility::OnReleased);
Task->ReadyForActivation();
```

**`bTestAlreadyReleased = true` is not optional for tap-friendly abilities.** On a quick tap the
key can be up before activation completes; without it that release already passed unheard and
the ability never ends.

The input tasks also **create a new prediction window** in their callbacks — one of the few
task families that do. See `prediction.md`.

## Writing one

```
static factory function        ── creates the instance
delegates                      ── broadcast on completion
Activate()                     ── start work, bind external delegates
OnDestroy(bInOwnerFinished)    ── cleanup, unbind
callbacks                      ── for whatever you bound to
```

Three rules that are not obvious:

**A task may declare only one delegate *type*.** Every output delegate must be that type, even
if some outputs ignore half the parameters. Pass defaults for the unused ones.

**In `OnDestroy`, touch `Ability` before `Super::OnDestroy()`.** Since 5.1 the base nulls the
pointer.

**Tasks run only where the owning ability runs.** To run on simulated proxies: set
`bSimulatedTask = true` in the constructor, override `InitSimulatedTask()`, and replicate your
members. The `RootMotionSource` tasks all do this — that is how movement simulates on other
clients without replicating every position. `AbilityTask_MoveToLocation` is the reference.

Ticking: `bTickingTask = true` and override `TickTask(float DeltaTime)`. For smooth
interpolation across frames.

## Root motion source tasks

For knockbacks, dashes, pulls, complex jumps — movement over time that hooks into the CMC and
is predicted.

**One conflict worth knowing before you reach for them:** animation root motion overrides
velocity and does not coexist with root motion sources. The engine comment in
`CharacterMovementComponent` is explicit. If a montage drives movement, an RMS task fighting it
will not work — pick one.

Prediction for these was broken in 4.20–4.24 and works in 4.19 and 4.25+.

---

# Gameplay Cues

A cue plays a sound, spawns a particle, shakes the camera. It carries no gameplay meaning.

Triggered by sending a tag **under the mandatory `GameplayCue.` parent** plus an event type to
the cue manager.

```
GameplayCue.Character.Land        ✓
Character.Land                    ✗  never fires
```

## Two classes

| Class | Event | Triggered by | Use for |
|---|---|---|---|
| `GameplayCueNotify_Static` | `Execute` | `Instant` / `Periodic` GE | One-off impacts. Runs on the CDO, no instance |
| `GameplayCueNotify_Actor` | `Add` / `Remove` | `Duration` / `Infinite` GE | Looping effects. Spawns an instance |

**On `GameplayCueNotify_Actor`, check `Auto Destroy on Remove`** or later `Add`s of that tag
silently do nothing.

## The four events

| Event | When |
|---|---|
| `OnActive` | Cue added. Late joiners miss it |
| `WhileActive` | Cue is active — **also fires for late joiners and on entering relevancy**. Not a tick |
| `Removed` | Cue removed, or the actor left relevancy |
| `Executed` | Instant effect or periodic tick |

The split matters: a tower explosion puts the blast in `OnActive` and the lingering fire in
`WhileActive`, so someone joining later sees the fire but not a replayed explosion. `OnRemove`
cleans up both.

Note `WhileActive`/`Removed` fire on **every relevancy transition**, not just once.

## Triggering

From a GE: fill in the cue tags. From an ability: the Execute/Add/Remove Blueprint nodes. From
C++:

```cpp
ASC->ExecuteGameplayCue(Tag, Context);
ASC->AddGameplayCue(Tag, Context);
ASC->RemoveGameplayCue(Tag);
ASC->RemoveAllGameplayCues();
```

All of these are **replicated multicast RPCs**, and GAS caps the same cue at **two RPCs per net
update**.

## Local cues

For anything each client can decide for itself — projectile impacts, melee hits, cues fired
from anim notifies — skip the RPC:

```cpp
void UMyASC::ExecuteGameplayCueLocal(const FGameplayTag Tag, const FGameplayCueParameters& P)
{
    UAbilitySystemGlobals::Get().GetGameplayCueManager()
        ->HandleGameplayCue(GetOwner(), Tag, EGameplayCueEvent::Type::Executed, P);
}
// Add = OnActive + WhileActive;  Remove = Removed
```

**Added locally must be removed locally; added by replication must be removed by replication.**
Mixing them leaks the cue.

## Reliability — read before depending on a cue

Cues are **unreliable**. This is the reason cues must not carry gameplay.

| Case | Autonomous proxy | Simulated proxy |
|---|---|---|
| `Execute`d cue | unreliable | unreliable |
| Cue from a GE | reliable: `OnActive`, `WhileActive`, `OnRemove` | reliable: `WhileActive`, `OnRemove` |
| Cue without a GE | reliable: `OnRemove` only | reliable: `WhileActive`, `OnRemove` |

**If a cue must arrive, apply it from a GE and put the effect in `WhileActive` with teardown in
`OnRemove`.** `OnActive` is never reliable for simulated proxies.

## Listen server double-fire

Under `Mixed` or `Minimal` replication, `Add` and `Remove` fire **twice** on a listen-server
host: once for the GE application and once from the minimal-replication multicast.
`WhileActive` fires once. Clients see everything once.

Lyra uses `Mixed`, so any listen-server host hits this. If a cue must run exactly once, hang it
off `WhileActive`.

## The cue manager and load cost

By default the manager scans the whole game directory and async-loads **every** cue notify and
everything it references at startup. On a large project that is hundreds of megabytes of
assets that may never be used, plus startup hitches.

Narrow the scan:

```ini
[/Script/GameplayAbilities.AbilitySystemGlobals]
GameplayCueNotifyPaths="/Game/YourProject/Characters"
```

Or load on demand — subclass `UGameplayCueManager`, point `GlobalGameplayCueManagerClass` at
it, and:

```cpp
virtual bool ShouldAsyncLoadRuntimeObjectLibraries() const override { return false; }
```

Cost: a possible hitch the first time each cue plays. Negligible on SSD; in-editor you may see
a stall while particle systems compile, which does not happen in a cooked build.

## Suppressing cues

From inside an `ExecCalc` — e.g. an attack was blocked and should not play the hit impact:

```cpp
OutExecutionOutput.MarkGameplayCuesHandledManually();
// then send whatever cue you actually want
```

Whole-ASC suppression: `ASC->bSuppressGameplayCues = true;`

## Cue parameters

A GE-triggered cue gets these filled in automatically: `AggregatedSourceTags`,
`AggregatedTargetTags`, `GameplayEffectLevel`, `AbilityLevel`, `EffectContext`, and `Magnitude`
(if the GE names an attribute for magnitude and has a modifier affecting it).

A manually triggered cue gets nothing you do not fill in yourself.

`SourceObject` is the loose slot for arbitrary data. The `EffectContext` often already carries
the instigator and a `FHitResult` for placement — subclassing the context is the cleaner route
for anything structured (`effects.md`).

To auto-populate more, override the three `InitGameplayCueParameters*` virtuals on
`UAbilitySystemGlobals`.

## Cue batching

A shotgun firing eight pellets is eight cue RPCs. Two ways to condense:

**Multiple cues on one GE** are already one RPC. By default that RPC carries the whole
`FGameplayEffectSpecForRPC`, which can be large. `AbilitySystem.AlwaysConvertGESpecToGCParams 1`
sends `FGameplayCueParameters` instead — less bandwidth, less information.

**Manual batching** for the rest:

1. Declare `FScopedGameplayCueSendContext` — suppresses `FlushPendingCues()` until it leaves
   scope, so cues queue up
2. Override `UGameplayCueManager::FlushPendingCues()` to merge batchable cues into a custom
   struct and RPC that
3. Clients unpack it into locally executed cues

GASShooter's lazy version stuffs traces into the effect context as target data: eight RPCs → 1,
but ~500 bytes. Encoding hit locations compactly, or sending a seed to recreate them, is the
optimised form. This is also the escape hatch when you need cue parameters that
`FGameplayCueParameters` does not have and you do not want them in the context — damage
numbers, crit flags, was-fatal indicators.
