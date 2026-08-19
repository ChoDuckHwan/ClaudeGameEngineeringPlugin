# What changed between 5.3-era GAS docs and UE 5.8

Every entry below was verified against the 5.8 plugin source. Paths are relative to
`Engine/Plugins/Runtime/GameplayAbilities/Source/GameplayAbilities/`.

The reason this file exists: the deprecations are mostly **soft**. The old field still
exists, still compiles, and still shows in the editor under a "Deprecated" category. It just
isn't what the system reads anymore. So the failure is silent — you set
`InheritableOwnedTagsContainer` and no tag is ever granted.

---

## 1. Ability tags: assignment → `SetAssetTags()`

`UGameplayAbility::AbilityTags` is deprecated as of **5.5** and will become private.

```cpp
// 5.3 era — deprecation warning in 5.8
AbilityTags.AddTag(MyTag);

// 5.8
SetAssetTags(FGameplayTagContainer(MyTag));   // constructor only
const FGameplayTagContainer& Tags = GetAssetTags();
```

`SetAssetTags()` is **protected and constructor-only**. To add tags to an already-populated
container, build the container first and set it once. Reading at runtime is `GetAssetTags()`.

> `Public/Abilities/GameplayAbility.h:474` — *"Use GetAssetTags(). This is being made
> non-mutable, private and renamed to AssetTags in the future. Use SetAssetTags to set
> defaults (in constructor only)."*

Note the rename direction: what the docs call "AbilityTags" the engine now calls **asset
tags**, matching the term GEs already used. `EditorGetAssetTags()` exists for editor-only
mutation.

---

## 2. `EGameplayModOp`: the whole enum was reworked

This is the largest change and the one most likely to produce wrong numbers rather than a
compile error, because the old names still resolve.

| 5.3 name | 5.8 name | Value |
|---|---|---|
| `Additive` | `AddBase` | 0 |
| `Multiplicitive` | `MultiplyAdditive` | 1 |
| `Division` | `DivideAdditive` | 2 |
| `Override` | `Override` | 3 |
| — | `MultiplyCompound` | 4 (new) |
| — | `AddFinal` | 5 (new) |

The old names survive as hidden backwards-compatible aliases, so `EGameplayModOp::Additive`
compiles and means `AddBase`. Prefer the new names in new code; the old ones read as if you
expect the old two-op formula.

**The aggregation formula changed:**

```
5.3:  ((BaseValue + Additive) * Multiplicitive) / Division
5.8:  ((BaseValue + AddBase) * MultiplyAdditive / DivideAdditive * MultiplyCompound) + AddFinal
```

**`MultiplyCompound` makes an engine modification obsolete.** GASDocumentation §4.5.4.1
walks through why `Multiply` modifiers *add* instead of multiplying (two 1.5× mods give 2.0×,
not 2.25×) and instructs you to **edit `FAggregatorModChannel::EvaluateWithBase()` in the
engine** to fix it. Do not do this. 5.8 ships both behaviours:

- `MultiplyAdditive` — the old additive-then-multiply behaviour, kept for compatibility
- `MultiplyCompound` — true compounding, `1.5 * 1.5 = 2.25`, via
  `UE::AbilitySystem::Private::MultiplyMods()` at `Private/GameplayEffectAggregator.cpp:12`

`AddFinal` is also new and useful: it applies *after* all multiplication, which is what you
want for a flat bonus that percentage buffs should not scale.

The strange `Bias` arithmetic the docs describe (`1 + (Mod1 - 1) + (Mod2 - 1)`) is still
exactly how `MultiplyAdditive` and `DivideAdditive` work — `SumMods()` at
`Private/GameplayEffectAggregator.cpp:216` is unchanged. Its documented restrictions still
apply to those two ops. Reach for `MultiplyCompound` and they stop mattering.

---

## 3. GameplayEffect: everything configurable moved to components

**5.3 deprecated every tag container and most behaviour flags on `UGameplayEffect`** in
favour of `UGameplayEffectComponent` objects in a `GEComponents` array. The old fields remain
as `UPROPERTY(BlueprintReadOnly, Category = Deprecated, meta=(DeprecatedProperty))` — they
are visible, settable, and ignored.

| Deprecated field | Add this component instead | Read it with |
|---|---|---|
| `InheritableGameplayEffectTags` | `UAssetTagsGameplayEffectComponent` | `GetAssetTags()` |
| `InheritableOwnedTagsContainer` | `UTargetTagsGameplayEffectComponent` | `GetGrantedTags()` |
| `InheritableBlockedAbilityTagsContainer` | `UTargetTagsGameplayEffectComponent` | `GetBlockedAbilityTags()` |
| `OngoingTagRequirements` | `UTargetTagRequirementsGameplayEffectComponent` | on the component |
| `ApplicationTagRequirements` | `UTargetTagRequirementsGameplayEffectComponent` | on the component |
| `RemoveGameplayEffectsWithTags` | `UTargetTagRequirementsGameplayEffectComponent` | on the component |
| `RemovalTagRequirements` | `URemoveOtherGameplayEffectComponent` | on the component |
| `GrantedApplicationImmunityTags` | `UImmunityGameplayEffectComponent` | on the component |
| `GrantedApplicationImmunityQuery` | `UImmunityGameplayEffectComponent` | on the component |
| `RemoveGameplayEffectQuery` | `URemoveOtherGameplayEffectComponent` | on the component |
| `GrantedAbilities` | `UAbilitiesGameplayEffectComponent` | on the component |
| `ChanceToApplyToTarget` | `UChanceToApplyGameplayEffectComponent` | on the component |
| `ApplicationRequirements` | `UCustomCanApplyGameplayEffectComponent` | on the component |
| `ConditionalGameplayEffects` | `UAdditionalEffectsGameplayEffectComponent` | on the component |
| `PrematureExpirationEffectClasses` | `UAdditionalEffectsGameplayEffectComponent` | on the component |
| `RoutineExpirationEffectClasses` | `UAdditionalEffectsGameplayEffectComponent` | on the component |
| `TargetEffectSpecs` | `UAdditionalEffectsGameplayEffectComponent` | on the component |
| `UIData` | `UGameplayEffectUIData` (now a component) | `FindComponent<UGameplayEffectUIData>()` |

Headers live in `Public/GameplayEffectComponents/`. Also deprecated in 5.3: four
`UGameplayEffect` methods whose names lied about what they did —
`GetOwnedGameplayTags`/`HasMatchingGameplayTag`/`HasAllMatchingGameplayTags`/`HasAnyMatchingGameplayTags`
→ use `GetGrantedTags()` and query the container.

**What did NOT move**, and is still set directly on the GE: `DurationPolicy`,
`DurationMagnitude`, `Period`, `Modifiers`, `Executions`, `StackingType` (private in 5.7,
use `GetStackingType()`), `StackLimitCount`, `GameplayCues`.

**Existing assets are migrated automatically** in `PostCDOCompiled` — a GE authored in 5.2
opens in 5.8 with the right components. The migration is one-way and only runs for saved
assets; C++ that writes a deprecated field is not migrated.

---

## 4. `NonInstanced` abilities are gone

`EGameplayAbilityInstancingPolicy::NonInstanced` is `UE_DEPRECATED_FORGAME(5.5)` and
functionally **removed in 5.5**. GASDocumentation §4.6.7 recommends it as the
best-performing option for simple frequently-used abilities. That advice is dead.

- The editor raises a **validation error**, not a warning, on a NonInstanced ability.
- `AbilitySystem.Fix.AllowNonInstancedAbilities` is a temporary CVar for fixup only.
- Every CDO-context accessor now ensures against being called on the CDO —
  `GetAvatarActorFromActorInfo`, `GetCurrentActorInfo`, `SetCurrentMontage`, and ~8 others.
- **Lyra actively asserts against it** in `ULyraAbilitySystemComponent::InitAbilityActorInfo`.

Use `InstancedPerActor`. It is the default and the only one worth choosing unless you
specifically need no state carried between activations, in which case
`InstancedPerExecution` is still supported.

---

## 5. `InitGlobalData()` is called for you

GASDocumentation §4.9.1 and §9.2 tell you this is mandatory boilerplate and that skipping it
causes `ScriptStructCache` errors and client disconnects. As of **5.3 the engine calls it
automatically**, and the function early-returns if already initialized:

```cpp
void UAbilitySystemGlobals::InitGlobalData()
{
    // Make sure the user didn't try to initialize the system again (we call InitGlobalData automatically in UE5.3+).
    if (IsAbilitySystemGlobalsInitialized()) { return; }
    // ...
}
```
> `Private/AbilitySystemGlobals.cpp:63`

Calling it yourself is harmless but unnecessary. It still matters for one case the comment
does not cover: if you use `GlobalAttributeSetDefaultsTableNames`, you may need it to run
*later* than the automatic call — Fortnite does this from the asset manager.

---

## 6. `ATTRIBUTE_ACCESSORS` ships in the engine

The doc's "add this block of macros to the top of every AttributeSet header" is no longer
necessary. `AttributeSet.h:465` defines `ATTRIBUTE_ACCESSORS_BASIC(ClassName, PropertyName)`
with exactly the same four macros.

The deliberately different name avoids colliding with projects that already pasted their own
`ATTRIBUTE_ACCESSORS`. **Lyra is one of them** — it defines its own at
`AbilitySystem/Attributes/LyraAttributeSet.h:29`, identical in content. Any attribute set
deriving from `ULyraAttributeSet` gets `ATTRIBUTE_ACCESSORS` for free by including that
header; use it rather than the engine's, for consistency with Lyra's own sets.

---

## 7. `NetUpdateFrequency` is private

Deprecated in **5.5** (`Actor.h:903`).

```cpp
NetUpdateFrequency = 100.0f;          // 5.4 and earlier
SetNetUpdateFrequency(100.0f);        // 5.5+
GetNetUpdateFrequency();
```

Same for `MinNetUpdateFrequency` → `SetMinNetUpdateFrequency()`.

This matters because §4.1 of the doc specifically tells you to raise `NetUpdateFrequency` on
a PlayerState holding an ASC. **Lyra already does** — `LyraPlayerState.cpp:43` calls
`SetNetUpdateFrequency(100.0f)`, as does `LyraCharacterWithAbilities.cpp:24`.

---

## 8. `UAbilityAsync` — a second way to bind Blueprint to ASC delegates

GASDocumentation §8.2 recommends hand-writing `UBlueprintAsyncActionBase` subclasses so UMG
graphs can bind to ASC delegates, and notes they leak unless you call `EndTask()` manually.
Since 5.1 the plugin ships a purpose-built base with lifetime handling, plus ready-made
nodes:

```
Public/Abilities/Async/AbilityAsync.h
    AbilityAsync_WaitAttributeChanged.h
    AbilityAsync_WaitGameplayEffectApplied.h
    AbilityAsync_WaitGameplayEvent.h
    AbilityAsync_WaitGameplayTag.h
    AbilityAsync_WaitGameplayTagCountChanged.h
    AbilityAsync_WaitGameplayTagQuery.h
```

Prefer these to hand-rolled async tasks. Write your own only for a delegate they do not
cover, and subclass `UAbilityAsync` when you do.

---

## 9. Smaller items worth knowing

- **`Super::ActivateAbility()` is safe to call** as of 5.3. It used to call `CommitAbility()`
  as a side effect, which is why older code carefully avoided it.
- **`FGameplayAttribute` respects Core Redirects** (5.2). You can rename an attribute set or
  attribute in C++ and add a redirect to `DefaultEngine.ini` instead of re-authoring assets.
- **`FGameplayTagRequirements` has a `TagQuery` field** (5.3) for requirements that
  all/any/none cannot express.
- **`FGameplayTagQuery::Matches` returns false for an empty query** (5.3, behaviour change).
- **`FNativeGameplayTag` / `UE_DEFINE_GAMEPLAY_TAG`** (4.27) is how you declare tags in C++
  now. Registered and unregistered with the module, no `.ini` entry needed. Lyra uses this.
- **`AbilityTask::OnDestroy`** — do everything needing the `Ability` pointer *before*
  `Super::OnDestroy()`; it nulls the pointer (5.1 change).
- **Gameplay Targeting System** (5.2) is a separate, newer, data-driven targeting subsystem.
  Not a replacement for `TargetActors`; a different approach with its own docs.
- **`FGameplayAbilitySpec::SourceObject` is a weak reference** (5.1). Null-check it.
- **`ApplyModToAttribute` is server-only**; `ApplyModToAttributeUnsafe` runs anywhere. The
  name is the warning. Lyra uses the former in `PostAttributeChange`.

---

## What did *not* change

Useful to know so you do not go looking:

- `UAttributeSet` hook signatures are all identical: `PreAttributeChange`,
  `PostAttributeChange`, `PreAttributeBaseChange`, `PreGameplayEffectExecute`,
  `PostGameplayEffectExecute`, `OnAttributeAggregatorCreated`.
- `GAMEPLAYATTRIBUTE_REPNOTIFY` and the `DOREPLIFETIME_CONDITION_NOTIFY(..., COND_None,
  REPNOTIFY_Always)` requirement.
- `EGameplayEffectReplicationMode` — `Full` / `Mixed` / `Minimal`, same semantics.
- `EGameplayAbilityNetExecutionPolicy` — `LocalOnly` / `LocalPredicted` / `ServerOnly` /
  `ServerInitiated`.
- Prediction: keys, windows, `AbilityTask_NetworkSyncPoint.h` still present, and the same
  list of what is and is not predicted.
- `FGameplayAbilityTargetData` subclassing, including the `TStructOpsTypeTraits` +
  `WithNetSerializer` requirement.
- `showdebug abilitysystem` and its three pages.
