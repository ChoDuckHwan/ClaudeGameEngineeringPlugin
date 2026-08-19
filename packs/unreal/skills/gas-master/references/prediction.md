# Prediction

`GameplayPrediction.h` in the plugin source is the authority. This is a map of it.

Client-side prediction means the client does not wait for permission. It activates the ability,
applies effects, and assumes the server will agree. Network-latency later the server runs the
same ability and tells the client whether it was right. Wrong guesses are rolled back.

**Epic's own stance is to predict as little as you can get away with.** Paragon and Fortnite do
not predict damage.

> ... we are also not all in on a "predict everything: seamlessly and automatically" solution.
> We still feel player prediction is best kept to a minimum (meaning: predict the minimum
> amount of stuff you can get away with).
>
> *Dave Ratti, Epic*

## What is and is not predicted

**Predicted:**
- Ability activation
- Triggered events
- GE application — attribute modifiers and tag changes
- Gameplay cues (from a predicted GE or standalone)
- Animation montages
- Movement (via `UCharacterMovementComponent`)

**Not predicted:**
- **GE removal**
- **Periodic GE ticks (DoTs)**
- Executions — `ExecCalc`s never predict; only plain modifiers do

The two negatives drive most design decisions below.

## The prediction key

An integer the client mints on activation.

```
CLIENT                                       SERVER
generate Activation Prediction Key
add key to every GE it applies
send key ─────────────────────────────────>  receive key
                                             add key to every GE it applies
                                             replicate key back ───────┐
key falls out of scope                                                 │
   (further prediction needs a new window)                             │
                                                                       ▼
receive server's GEs tagged with the key  <────────────────  Replicated Prediction Key
   ── matching pairs = predicted correctly (both exist briefly)
   ── key now stale
remove ALL local GEs created with that key
   ── server's persist; unmatched local ones were mispredictions
```

**A key is valid only for one atomic block — effectively one frame.** After any latent ability
task the key is stale unless the task creates a new window.

## New prediction windows

Some tasks create one automatically. **All the input tasks do** — `WaitInputPress`,
`WaitInputRelease`, `WaitConfirm`, ... So code in an input callback has a valid key.

Tasks like `WaitDelay` do **not**. To predict after one, insert a sync point:

```cpp
UAbilityTask_NetworkSyncPoint* Sync =
    UAbilityTask_NetworkSyncPoint::WaitNetSync(this, EAbilityTaskNetSyncType::OnlyServerWait);
```

With `OnlyServerWait`: the client mints a new scoped key, RPCs it, and applies it to new GEs;
the server **blocks** until it arrives.

That block is the cost. A malicious client can stall the server's ability by delaying the key.
Epic uses `WaitNetSync` sparingly and suggests building a variant with a timeout that proceeds
without the client if this matters to you.

You can open as many windows as you need. To add sync-point behaviour to your own task, copy
what the input tasks do — they inline the `WaitNetSync` logic.

## "My predicted effect fires twice"

**A stale prediction key.** This is the "redo" problem from `GameplayPrediction.h`: the client's
effect was applied outside a valid window, so it does not match the server's replicated copy and
neither is removed.

Fix: put a `WaitNetSync` with `OnlyServerWait` immediately before applying the effect.

## The instant-GE blip

Predicted `Instant` GEs are internally treated as `Infinite` so they can be rolled back. So for
a moment there can be **two copies** — the predicted one and the server's — and the modifier
applies twice, or neither. It self-corrects.

On yourself this is invisible. **On another character it shows** as a visible flicker in their
attributes. This is a large part of why predicting damage on others is a bad idea.

## Why cooldowns cannot be predicted

Because GE *removal* cannot be predicted, and unlike other cases there is no workaround.

The server's cooldown GE replicates to the client and any attempt to dodge it (e.g. `Minimal`
replication) is rejected by the server. So:

- Higher latency → longer to tell the server to start the cooldown, and longer to receive its
  removal
- **Higher-latency players get a lower rate of fire on short-cooldown abilities**

Fortnite avoids it with custom bookkeeping rather than cooldown GEs. Epic wants to fix the
latency reconciliation someday.

For UI, gray the icon on the predicted cooldown and start the real timer when the server's
corrected GE arrives.

## Predicting removal, sort of

You cannot remove a GE predictively, but you can **apply its inverse**:

```
predicted 40% slow  ──>  to "remove" it, apply a predicted 40% speed buff
                         then remove both for real when the server confirms
```

Crude, not always applicable, and it does not work for cooldowns. Support for real predicted
removal is on Epic's wish list.

## On predicting damage

Most people try it first. Recommendation: don't.

- Mispredicted damage makes an enemy's health jump **back up**
- Mispredicted **death** is worse: a character starts ragdolling, then stops and resumes
  shooting at you
- Damage usually needs an `ExecCalc` anyway, which cannot predict

If you do it, keep death server-authoritative.

## Predictively spawning actors

Not supported out of the box — `SpawnActor` task is server-only. The approach is to spawn a
replicated actor on **both** sides and keep the server from replicating its copy to the owner:

```cpp
bool AMyActor::IsNetRelevantFor(const AActor* RealViewer, const AActor* ViewTarget,
                               const FVector& SrcLocation) const
{
    return !IsOwnedBy(ViewTarget);
}
```

Fine for cosmetics. For a projectile that must deal damage you need a dummy-projectile
reconciliation scheme — Unreal Tournament's source on Epic's GitHub is the reference.

## The six problems prediction is solving

Useful for judging whether a design fits the system at all:

1. **"Can I do this?"** — the basic protocol
2. **"Undo"** — reverting side effects on misprediction
3. **"Redo"** — not replaying what the server also replicates
4. **"Completeness"** — being sure all side effects were caught
5. **"Dependencies"** — chains of dependent predicted events
6. **"Override"** — predictively overriding server-owned state

## Three lessons from a listen-server project

Measured on a Lyra + Game Animation Sample project, server-authoritative with client prediction.
None of these are in the source documentation.

**Prefer a replicated tag over a predicted number.** A tag replicates, and both machines derive
the same behaviour from it locally — nobody predicts the number, so there is nothing to
reconcile. This is where the Game Animation Sample fails in multiplayer: it recomputes
`MaxWalkSpeed` every tick from `Gait` and `WantsToSprint`, neither of which is replicated, so the
server simulates a guest at a different speed and the movement component rejects the guest's
moves. The guest cannot move at all. Reading the speed off a replicated tag instead fixes it
outright.

**Animation root motion is compared for exact equality, so "nearly the same" never converges.**
`ClientAdjustRootMotionPosition` checks
`ServerMontageTrackPosition != LastAckedMove->RootMotionTrackPosition` and calls `SetPosition()`
on any mismatch. Two machines independently running motion matching pick poses 0.03–0.04s apart,
which is a permanent mismatch — the visible symptom is a rubber-band every time the ability
plays. The fix is to **replicate the decision** (which montage, start time, play rate) as target
data and have the server replay it, rather than letting each side compute its own. See
`targeting.md` for the mechanism.

**A listen-server host is both the server and a local client.** Anything gated on
`HasAuthority()` alone also runs for every *guest's* action. Camera effects, local UI, and local
sounds need `IsLocalPlayerController()` as well, or the host gets shaken by everyone else's
abilities.
