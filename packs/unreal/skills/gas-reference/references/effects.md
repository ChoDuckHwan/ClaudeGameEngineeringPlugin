# Gameplay Effects

A `UGameplayEffect` is the only sanctioned way to change an attribute or grant a tag, because
it is the only thing that carries a prediction key. It is a **data-only** class — put no logic
in it. Designers subclass it in Blueprint; calculations go in separate MMC/ExecCalc classes.

> **Read `ue58-deltas.md` §3 before authoring a GE.** In 5.3+ every tag container and most
> behaviour flags moved to `UGameplayEffectComponent` objects. The old fields are still
> visible in the editor under "Deprecated" and are **silently ignored**.

## The three durations

| Duration | Changes | GameplayCue event | Tags granted |
|---|---|---|---|
| `Instant` | `BaseValue`, permanently | `Execute` | **Never** — not even for one frame |
| `Duration` | `CurrentValue`, reverts on expiry | `Add` + `Remove` | Yes |
| `Infinite` | `CurrentValue`, reverts on removal | `Add` + `Remove` | Yes |

`Duration` and `Infinite` can be **periodic**: modifiers and executions re-run every `Period`
seconds. A periodic tick behaves exactly like an `Instant` — it changes `BaseValue` and
`Execute`s cues.

**Periodic effects cannot be predicted.** If you need a predicted repeating cost, drive it
from the ability with a new prediction window each time instead (`prediction.md`).

`Duration`/`Infinite` effects can be toggled off and on without being removed, via ongoing
tag requirements. Off means modifiers and granted tags are withdrawn but the effect is still
applied and will reapply them when requirements are met again.

## Applying and removing

Everything funnels to `UAbilitySystemComponent::ApplyGameplayEffectSpecToSelf()` on the
target. From an ability use the ability's helpers; from outside (a projectile, a volume) get
the target's ASC and call `ApplyGameplayEffectToSelf`.

```cpp
ASC->OnActiveGameplayEffectAddedDelegateToSelf.AddUObject(this, &AFoo::OnAdded);
ASC->OnAnyGameplayEffectRemovedDelegate().AddUObject(this, &AFoo::OnRemoved);
```

**Who sees these callbacks depends on replication mode**, and this catches people:

| Role | `Full` | `Mixed` | `Minimal` |
|---|---|---|---|
| Server | yes | yes | yes |
| Autonomous proxy (owning client) | yes | yes | **no** |
| Simulated proxy (other clients) | yes | **no** | **no** |

Lyra uses `Mixed`. So a client can see effects applied to *itself* but not to other players.
Any client-side logic that watches other actors' effects is broken by design — watch tags
instead, which always replicate.

## Modifiers

A modifier changes exactly one attribute by one operation. Four ways to produce the number:

| Type | Use when | Predictable |
|---|---|---|
| `Scalable Float` | A constant, or a curve-table lookup by level | Yes |
| `Attribute Based` | Derived from another attribute on source or target | Yes |
| `Custom Calculation Class` (MMC) | Complex formula, multiple captures | Yes |
| `Set By Caller` | Value computed at runtime by the ability | Yes |

Operations and the aggregation formula changed in 5.5 — see `ue58-deltas.md` §2. Short
version: use `AddBase`, `MultiplyCompound` (true multiplication), `AddFinal` (applies after
multiplication), and `Override`.

For a percentage change use a multiply op, not add, so it lands after addition. Note that
**prediction handles percentage changes badly** — the client and server can disagree on the
order modifiers arrive.

`SetByCaller` is a `TMap<FGameplayTag, float>` on the spec:

```cpp
Spec->SetSetByCallerMagnitude(TAG_Data_Damage, 42.f);
float V = Spec.GetSetByCallerMagnitude(TAG_Data_Damage, /*bWarnIfNotFound=*/false, /*Default=*/0.f);
```

**A modifier set to `SetByCaller` whose tag is missing on the spec throws a runtime error and
returns 0.** With a divide op that is a divide-by-zero. Prefer the tag version over the
`FName` version — it is typo-proof in Blueprint.

## Stacking

Only for `Duration` and `Infinite`. Default is no stacking: each application is a separate
instance that neither knows nor cares about the others.

| Type | Meaning |
|---|---|
| Aggregate by Source | Separate stack count per source ASC on the target |
| Aggregate by Target | One shared stack count regardless of source |

Expiration, duration-refresh, and period-reset policies each have editor tooltips worth
reading. `StackingType` is private as of 5.7 — read it with `GetStackingType()`.

## Tags on an effect

Five categories, all now configured through components (`ue58-deltas.md` §3):

| Category | What it does |
|---|---|
| Asset Tags | Describe the effect. No behaviour — for querying and filtering |
| Granted Tags | Given to the target ASC while applied. `Duration`/`Infinite` only |
| Ongoing Tag Requirements | Toggle the effect off/on after application |
| Application Tag Requirements | Whether it can be applied at all |
| Remove Effects with Tags | On success, removes target effects carrying these tags |

`Added` / `Removed` / `Combined` in the editor is inheritance bookkeeping: `Added` are new in
this subclass, `Removed` are ones the parent had that this one drops, `Combined` is the
computed result. As of 5.3 `Combined` updates immediately rather than on save.

Modifiers can carry their own `SourceTags`/`TargetTags`, evaluated **only at application**.
On a periodic effect they are checked on the first application and never again.

## Immunity

`UImmunityGameplayEffectComponent`. Functionally similar to application tag requirements, but
it gives you a delegate for the block:

```cpp
ASC->OnImmunityBlockGameplayEffectDelegate
```

Tag-based immunity checks the **source** ASC's tags (including the source ability's asset
tags). Query-based immunity inspects the incoming spec.

## Spec vs effect

The `UGameplayEffect` is the archetype; `FGameplayEffectSpec` is the instantiation. Only the
spec is mutable at runtime.

```cpp
FGameplayEffectSpecHandle Handle = ASC->MakeOutgoingSpec(GEClass, Level, Context);
Handle.Data->SetSetByCallerMagnitude(Tag, Value);
Handle.Data->DynamicGrantedTags.AddTag(ExtraTag);
```

A spec need not be applied immediately — passing one to a projectile to apply on impact is the
canonical use. The spec carries: the GE class, level, duration, period, stack count, the
effect context, snapshotted attributes, dynamic granted/asset tags, and the SetByCaller maps.

## MMC vs ExecCalc

Both capture attributes; that is where the similarity ends.

| | `MMC` | `ExecCalc` |
|---|---|---|
| Returns | one float | changes anything it likes |
| **Predictable** | **yes** | **no** |
| Language | C++ or Blueprint | **C++ only** |
| Works with | Instant, Duration, Infinite, Periodic | **Instant and Periodic only** |
| Runs on | client and server (if predicted) | **server only** for LocalPredicted / ServerOnly / ServerInitiated abilities |

**Choose MMC unless you need to change more than one attribute.** Cost and cooldown effects
in particular should stay predictable, which rules out ExecCalcs there.

```cpp
// MMC: declare captures in the constructor or capture fails with a "missing Spec" error
ManaDef.AttributeToCapture = UMySet::GetManaAttribute();
ManaDef.AttributeSource    = EGameplayEffectAttributeCaptureSource::Target;
ManaDef.bSnapshot          = false;
RelevantAttributesToCapture.Add(ManaDef);

float UMyMMC::CalculateBaseMagnitude_Implementation(const FGameplayEffectSpec& Spec) const
{
    FAggregatorEvaluateParameters Params;
    Params.SourceTags = Spec.CapturedSourceTags.GetAggregatedTags();
    Params.TargetTags = Spec.CapturedTargetTags.GetAggregatedTags();

    float Mana = 0.f;
    GetCapturedAttributeMagnitude(ManaDef, Spec, Params, Mana);
    // ... clamp again here; PreAttributeChange did not run on this capture
}
```

### Snapshot semantics

| Snapshot | Source/Target | Captured at | Auto-updates on change |
|---|---|---|---|
| Yes | Source | spec **creation** | No |
| Yes | Target | spec application | No |
| No | Source | spec application | Yes (Duration/Infinite) |
| No | Target | spec application | Yes (Duration/Infinite) |

Only the source-snapshot row differs in *when*; the rest differ in whether they track.

**Capturing recomputes `CurrentValue` from raw modifiers and does not run
`PreAttributeChange`.** Every clamp must be repeated inside the calculation. Same trap as in
`attributes.md`.

### Getting data into an ExecCalc

Four routes, in rough order of preference:

1. **SetByCaller** on the spec — `Spec.GetSetByCallerMagnitude(Tag, false, -1.f)`
2. **Transient aggregator** ("Temporary Variable" in the editor) — register the tag in the
   constructor via `ValidTransientAggregatorIdentifiers.AddTag(...)`, read with
   `AttemptCalculateTransientAggregatorMagnitude`
3. **Backing data attribute** — a calculation modifier over a captured attribute
4. **Custom effect context** — subclass `FGameplayEffectContext` for arbitrary payloads

Each `ExecCalc` needs its own capture struct, and **the struct names share one namespace** —
two `ExecCalc`s with identically named capture structs silently capture each other's
attributes. This produces baffling wrong-attribute bugs.

Modifying the spec from inside an ExecCalc via `GetOwningSpecForPreExecuteMod()` is possible
and the engine comment says be careful; changing it after attribute capture means the capture
no longer matches the spec.

## Cost and cooldown

Both are ordinary GEs with a designated role on the ability.

**Cost** — `Instant`, modifiers that subtract. `CanActivateAbility` calls `CheckCost`;
`CommitAbility` calls `CommitCost` and re-checks. Keep it predictable: MMCs yes, ExecCalcs no.

**Cooldown** — `Duration`, **no modifiers**, one unique tag in granted tags. The ability
checks for the *tag*, not the effect. One cooldown GE per ability to start with.

Sharing one cooldown GE across abilities (instanced abilities only) needs three overrides:

```cpp
const FGameplayTagContainer* UMyAbility::GetCooldownTags() const
{
    FGameplayTagContainer* Mutable = const_cast<FGameplayTagContainer*>(&TempCooldownTags);
    Mutable->Reset();                       // written on the CDO — must clear
    if (const FGameplayTagContainer* Parent = Super::GetCooldownTags())
        Mutable->AppendTags(*Parent);
    Mutable->AppendTags(CooldownTags);
    return Mutable;
}

void UMyAbility::ApplyCooldown(...) const
{
    FGameplayEffectSpecHandle H = MakeOutgoingGameplayEffectSpec(CooldownGE->GetClass(), GetAbilityLevel());
    H.Data->DynamicGrantedTags.AppendTags(CooldownTags);
    H.Data->SetSetByCallerMagnitude(TAG_Data_Cooldown, CooldownDuration.GetValueAtLevel(GetAbilityLevel()));
    ApplyGameplayEffectSpecToOwner(Handle, ActorInfo, ActivationInfo, H);
}
```

`TempCooldownTags` lives on the CDO, hence the `Reset()`. An MMC reading
`Spec.GetContext().GetAbilityInstance_NotReplicated()` is the alternative to the SetByCaller.

### Cooldowns cannot be predicted

Removal of a GE is not predictable, so the server's cooldown is authoritative and there is no
inverse-effect workaround. **Players with higher latency get a lower rate of fire on
short-cooldown abilities.** Fortnite sidesteps this entirely with custom bookkeeping instead
of cooldown GEs.

For UI, listen for the cooldown **GE added** (you also get the spec, so you can tell the
predicted one from the server's) but the cooldown **tag removed** (the server's corrected GE
removes your predicted one, firing the removal delegate while you are still on cooldown; the
tag does not flicker).

Reading time remaining:

```cpp
FGameplayEffectQuery Q = FGameplayEffectQuery::MakeQuery_MatchAnyOwningTags(CooldownTags);
TArray<TPair<float,float>> Times = ASC->GetActiveEffectsTimeRemainingAndDuration(Q);
```

Requires the client to receive replicated GEs — so under `Mixed` this works for your own
cooldowns and not for anyone else's.

## Changing an active effect's duration

There is no official API. This works:

```cpp
FActiveGameplayEffect* AGE = const_cast<FActiveGameplayEffect*>(GetActiveGameplayEffect(Handle));
AGE->Spec.Duration = FMath::Max(NewDuration, 0.01f);
AGE->StartServerWorldTime = ActiveGameplayEffects.GetServerWorldTime();
AGE->CachedStartServerWorldTime = AGE->StartServerWorldTime;
AGE->StartWorldTime = ActiveGameplayEffects.GetWorldTime();
ActiveGameplayEffects.MarkItemDirty(*AGE);
ActiveGameplayEffects.CheckDuration(Handle);
```

All five fields matter; skip one and the client and server disagree about when it ends. Do it
on the server. `MarkItemDirty` on a fast array needs `NetCore` in
`PublicDependencyModuleNames` or you get an unresolved `MarkPropertyDirty` at link time.

## Runtime-created effects

**Only `Instant` effects can be created from scratch at runtime.** `Duration` and `Infinite`
look for a class definition when they replicate, and a transient one does not exist.

```cpp
UGameplayEffect* GE = NewObject<UGameplayEffect>(GetTransientPackage(), FName("Bounty"));
GE->DurationPolicy = EGameplayEffectDurationType::Instant;

int32 Idx = GE->Modifiers.Num();
GE->Modifiers.SetNum(Idx + 1);
FGameplayModifierInfo& Info = GE->Modifiers[Idx];
Info.Attribute         = UMySet::GetXPAttribute();
Info.ModifierOp        = EGameplayModOp::AddBase;
Info.ModifierMagnitude = FScalableFloat(Amount);

ASC->ApplyGameplayEffectToSelf(GE, 1.f, ASC->MakeEffectContext());
```

For a runtime-customised `Duration`/`Infinite` effect, author an archetype GE in the editor
and customise the **spec** instead. That is what specs are for.

## Effect containers

`FGameplayEffectContainer` from Epic's Action RPG sample — not part of vanilla GAS. Bundles
specs, target data, and simple targeting into one struct. Worth adopting if you pass effects
to projectiles often; it removes a lot of `MakeOutgoingSpec` boilerplate.

## Effect context

`FGameplayEffectContext` carries the instigator and target data, and is a good subclass point
for arbitrary data that must reach MMCs, ExecCalcs, attribute sets, and cues. Subclassing
requires six steps: derive, override `GetScriptStruct()`, override `Duplicate()`, override
`NetSerialize()` if replicated, add `TStructOpsTypeTraits`, and override
`AllocGameplayEffectContext()` on your `AbilitySystemGlobals` subclass. As of 5.2/5.3 derived
context types replicate correctly.
