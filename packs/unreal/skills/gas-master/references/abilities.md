# Gameplay Abilities

An ability is anything an actor *does*: jumping, sprinting, firing, opening a door, placing a
building. More than one can be active at once.

Not abilities: basic movement input, UI interactions. Those are guidelines, not rules — but a
store purchase implemented as an ability is a bad time.

**Abilities never run on simulated proxies.** The server runs it; anything other clients need
to *see* travels via ability tasks (montages) or gameplay cues (sounds, particles). This one
fact explains most of the design.

## Instancing policy

| Policy | State between activations | Notes |
|---|---|---|
| `InstancedPerActor` | Kept — reset it yourself | **The default. Use this.** |
| `InstancedPerExecution` | Fresh every activation | New object per activation |
| `NonInstanced` | **Removed in 5.5** | Editor validation *error*; Lyra asserts against it |

Older docs recommend `NonInstanced` for cheap frequently-used abilities. That advice is dead —
see `ue58-deltas.md` §4. Every CDO-context accessor now ensures against CDO use.

## Net execution policy

| Policy | Runs on | Use for |
|---|---|---|
| `LocalOnly` | owning client only | Purely cosmetic local changes |
| `LocalPredicted` | client first, then server corrects | Most player abilities |
| `ServerOnly` | server only | Passives; single-player |
| `ServerInitiated` | server first, then owning client | Rare |

`LocalPredicted` activation order:

```
CLIENT                                     SERVER
TryActivateAbility()
  InternalTryActivateAbility()
    CanActivateAbility()   ── tags, cost, cooldown, no other instance
    CallServerTryActivateAbility(PredKey) ──────>  ServerTryActivateAbility()
    CallActivateAbility()                           InternalTryActivateAbility()
      PreActivate()                                   CanActivateAbility()
      ActivateAbility()   <── your code               ClientActivateAbilitySucceed() ──> client
                                                    CallActivateAbility()
                                                      PreActivate()
                                                      ActivateAbility()
```

If the server refuses at any point it calls `ClientActivateAbilityFailed()`, which kills the
client's ability and rolls back everything it predicted.

## Ability tags — ten containers, none replicated

| Container | Effect |
|---|---|
| **Asset Tags** (was `AbilityTags`) | Describes this ability. Other containers match against it |
| Cancel Abilities with Tag | Abilities whose asset tags match are canceled when this activates |
| Block Abilities with Tag | Abilities whose asset tags match cannot activate while this runs |
| **Activation Owned Tags** | Granted to the owner **while active**. The main way an ability expresses state |
| Activation Required Tags | Owner must have **all** |
| Activation Blocked Tags | Owner must have **none** |
| Source Required / Blocked | Only set when triggered by an event |
| Target Required / Blocked | Only set when triggered by an event |

Asset tags are set with `SetAssetTags()` in the constructor now — `ue58-deltas.md` §1.

**Two containers are commonly confused, and the difference is the design:**

- **Activation Owned Tags** — the ability *holds* this tag while running. This is how
  "sprinting" becomes state the ability system owns, replicated with the activation, rather
  than a bool somewhere.
- **Asset Tags** — the ability's *name* for cancellation and blocking. Give one to anything
  that something else must be able to cancel.

You usually need both. Blocking activation alone does not stop an ability already running:
someone who was already sprinting when stamina hit zero keeps going until they release the
key. To actually stop them you need an asset tag to cancel by.

## Activating

Automatic if bound to input and tag requirements pass. Otherwise:

```cpp
ASC->TryActivateAbilitiesByTag(TagContainer, bAllowRemoteActivation = true);
ASC->TryActivateAbilityByClass(Class, bAllowRemoteActivation = true);
ASC->TryActivateAbility(SpecHandle, bAllowRemoteActivation = true);
ASC->TriggerAbilityFromGameplayEvent(Handle, ActorInfo, Tag, &Payload, Component);
ASC->GiveAbilityAndActivateOnce(Spec, &EventData);
```

Event activation needs a `Trigger` configured on the ability (a tag + a `GameplayEvent`
option), then:

```cpp
UAbilitySystemBlueprintLibrary::SendGameplayEventToActor(Actor, EventTag, Payload);
```

Triggers can also fire on a tag being **added or removed**, which is a clean way to react to
state without polling.

In Blueprint use the `ActivateAbilityFromEvent` node, not `ActivateAbility`. As of 5.3 both
nodes may coexist in one graph.

**Call `EndAbility()`.** The only abilities that legitimately never end are passives.

## Passive abilities

The generic answer is override `OnAvatarSet()` and call `TryActivateAbility()`, typically with
`ServerOnly`. As of 5.3 `OnAvatarSet` is called on the primary instance rather than the CDO.

**On Lyra, set `ActivationPolicy = OnSpawn` instead** — `ULyraGameplayAbility::OnPawnAvatarSet`
already does the work. See `lyra-notes.md`.

## Canceling

```cpp
CancelAbility(...)                      // from inside; EndAbility with bWasCancelled = true
ASC->CancelAbility(UGameplayAbility*)   // by CDO
ASC->CancelAbilityHandle(Handle)
ASC->CancelAbilities(WithTags, WithoutTags, Ignore)   // by asset tag — prefer this
ASC->CancelAllAbilities(Ignore)
ASC->DestroyActiveState()
```

`CancelAbilities` by tag is the one to reach for; it needs the target ability to carry an asset
tag naming it.

## Getting "the active ability"

There isn't one — several can be active. Search the ASC's list:

```cpp
TArray<FGameplayAbilitySpec>& Specs = ASC->GetActivatableAbilities();

ASC->GetActivatableGameplayAbilitySpecsByAllMatchingTags(
    TagContainer, MatchingSpecs, /*bOnlyAbilitiesThatSatisfyTagRequirements=*/true);
```

Then `Spec.IsActive()`.

**Any manual iteration of `ActivatableAbilities.Items` needs a scope lock:**

```cpp
ABILITYLIST_SCOPE_LOCK();
for (FGameplayAbilitySpec& Spec : ASC->ActivatableAbilities.Items) { ... }
```

Do not remove an ability inside that scope. The clear functions check the lock count and will
refuse.

## Passing data in

| Method | Trade-off |
|---|---|
| Activate by event with a payload | Replicated client→server for LocalPredicted. **Blocks input-bind activation** |
| `WaitGameplayEvent` task | Simple, but **not replicated** — LocalOnly/ServerOnly only |
| Custom `TargetData` | The right answer for arbitrary client→server data. See `targeting.md` |
| Replicated variable on owner/avatar | Most flexible, works with input binds. **No ordering guarantee** — set-then-activate can arrive in either order |

The last one's caveat is real and hard to debug. If the ability must see the value, put it in
the payload or in target data.

## Cost and cooldown

`CanActivateAbility()` runs `CheckCost()` and `CheckCooldown()` before `ActivateAbility()`.
After activating, `CommitAbility()` runs `CommitCost()` + `CommitCooldown()`, re-checking both
— the last chance to fail, since attributes can change between activation and commit. Commit
them separately if they should not happen together.

Committing is predicted **only if the prediction key is still valid at commit time**. After any
latent ability task it is not — see `prediction.md`.

Details in `effects.md`.

## Activation failure tags

Off by default. Declare the tags, then map them in `DefaultGame.ini`:

```ini
[/Script/GameplayAbilities.AbilitySystemGlobals]
ActivateFailIsDeadName=Activation.Fail.IsDead
ActivateFailCooldownName=Activation.Fail.OnCooldown
ActivateFailCostName=Activation.Fail.CantAffordCost
ActivateFailTagsBlockedName=Activation.Fail.BlockedByTags
ActivateFailTagsMissingName=Activation.Fail.MissingTags
ActivateFailNetworkingName=Activation.Fail.Networking
```

Then a rejection tells you *why* instead of just failing:

```
LogAbilitySystem: Display: InternalServerTryActivateAbility. Rejecting ClientActivation of
Default__GA_FireGun_C. InternalTryActivateAbility failed: Activation.Fail.BlockedByTags
```

Cheap to set up and it turns the most opaque class of GAS bug into a one-line answer. Lyra also
has `FailureTagToUserFacingMessages` on `ULyraGameplayAbility` for surfacing these in UI.

## Three options to leave alone

- **Replication Policy** — misleadingly named and unnecessary. Specs already replicate to the
  owning client; abilities never run on simulated proxies. Epic wants to remove it.
- **Server Respects Remote Ability Cancellation** — the client ending forces the server to
  end, whether the server finished or not. Bad for high-latency players. Leave off.
- **Replicate Input Directly** — Epic recommends the generic replicated events used by the
  input ability tasks instead. Lyra explicitly does not support it.

## Net security policy

Protection against clients requesting abilities they should not.

| Policy | Client may request |
|---|---|
| `ClientOrServer` | execution and termination |
| `ServerOnlyExecution` | termination only |
| `ServerOnlyTermination` | execution only |
| `ServerOnly` | neither |

## Ability batching

A normal ability lifecycle costs two or three RPCs: `CallServerTryActivateAbility`,
optionally `ServerSetReplicatedTargetData`, and `ServerEndAbility`. If all of it happens in
one frame, they can be combined into one.

```cpp
virtual bool ShouldDoServerAbilityRPCBatch() const override { return true; }

// then, at the call site:
FScopedServerAbilityRPCBatcher Batcher(this, Handle);
bool bActivated = TryActivateAbility(Handle, true);
if (EndImmediately) { /* find spec, GetPrimaryInstance(), ExternalEndAbility() */ }
```

Everything must occur inside the batcher's scope. C++ only, and only by
`FGameplayAbilitySpecHandle`.

Best case (semi-auto gun): 3 RPCs → 1. Worst case (full-auto): saves one RPC on the first
bullet only. Debug with `AbilitySystem.ServerRPCBatching.Log 1` or a breakpoint in
`ServerAbilityRPCBatch_Internal`.

## Leveling

| Method | Active ability |
|---|---|
| Remove and re-grant at the new level | **Terminated** |
| Increase `FGameplayAbilitySpec::Level` on the server and mark dirty | Keeps running |

You will want both eventually; a bool on your ability subclass picks per-ability.

## Granting

Server only; the spec replicates to the owning client automatically. Other clients get nothing.

```cpp
ASC->GiveAbility(FGameplayAbilitySpec(AbilityClass, Level, InputID, SourceObject));
```

`SourceObject` answers "who gave me this" and is a **weak** reference since 5.1 — null-check
it. Making a weapon the source object is how an ability reads the weapon that granted it.

**On Lyra, use `ULyraAbilitySet` instead.** It grants abilities, effects, and attribute sets
together as data, and returns handles for taking them all back.
