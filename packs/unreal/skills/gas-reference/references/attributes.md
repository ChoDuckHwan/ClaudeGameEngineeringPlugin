# Attributes and Attribute Sets

An attribute is a replicated float that gameplay effects can modify and roll back. If a
numeric value belongs to an actor and abilities or effects should change it, it is an
attribute. If nothing in GAS needs to touch it, a plain replicated float is cheaper and
simpler.

## BaseValue vs CurrentValue

Every attribute is an `FGameplayAttributeData` holding two numbers.

```
CurrentValue = BaseValue + (all active modifiers from Duration/Infinite GEs)
```

| Changed by | Which value |
|---|---|
| `Instant` GE | `BaseValue` — permanent |
| `Periodic` GE tick | `BaseValue` — permanent, treated exactly like Instant |
| `Duration` GE | `CurrentValue` — reverts on expiry |
| `Infinite` GE | `CurrentValue` — reverts on removal |
| Attribute setter (`SetHealth()`) | `BaseValue`, bypassing prediction — avoid |

**`BaseValue` is not a maximum.** This is the most common beginner error. A max is a separate
attribute (`MaxHealth`) if anything reads or modifies it, or a hardcoded float in the set if
it exists only to clamp.

## Defining one

Attributes can only be defined in C++, in the set's header.

```cpp
// header
UPROPERTY(BlueprintReadOnly, ReplicatedUsing = OnRep_Stamina, Category = "MyGame|Movement",
          Meta = (AllowPrivateAccess = true))
FGameplayAttributeData Stamina;
ATTRIBUTE_ACCESSORS(UMyMovementSet, Stamina);

UFUNCTION()
void OnRep_Stamina(const FGameplayAttributeData& OldValue);
```

```cpp
// cpp
void UMyMovementSet::OnRep_Stamina(const FGameplayAttributeData& OldValue)
{
    GAMEPLAYATTRIBUTE_REPNOTIFY(UMyMovementSet, Stamina, OldValue);
}

void UMyMovementSet::GetLifetimeReplicatedProps(TArray<FLifetimeProperty>& Out) const
{
    Super::GetLifetimeReplicatedProps(Out);
    DOREPLIFETIME_CONDITION_NOTIFY(UMyMovementSet, Stamina, COND_None, REPNOTIFY_Always);
}
```

`ATTRIBUTE_ACCESSORS` generates `GetStaminaAttribute()`, `GetStamina()`, `SetStamina()`,
`InitStamina()`. On a Lyra project use Lyra's macro from `LyraAttributeSet.h`; the engine's
equivalent is `ATTRIBUTE_ACCESSORS_BASIC` (see `ue58-deltas.md` §6).

**`REPNOTIFY_Always` is not optional.** By default a repnotify is skipped when the incoming
value equals the local one. Under prediction the client has usually *already* arrived at the
server's value, so the notify would be skipped exactly when the prediction system needs it to
fire and reconcile.

Non-replicated attributes (meta attributes) skip both the `OnRep` and the
`GetLifetimeReplicatedProps` entry.

Two useful `Meta` specifiers:
- `HideInDetailsView` — keep it out of the editor's attribute picker
- `HideFromModifiers` — a plain GE modifier cannot touch it; only executions can. This is how
  you *enforce* that damage routes through a meta attribute instead of hitting health directly

## The five hooks, and which to use

```
GE applied
    │
    ├─ PreGameplayEffectExecute(Data) ──> return false to reject the whole thing
    │
    ├─ PreAttributeBaseChange(Attr, NewValue)   [const]  ── clamp the BaseValue
    ├─ PreAttributeChange(Attr, NewValue)                ── clamp the CurrentValue
    │
    ├─ (value changes)
    │
    ├─ PostGameplayEffectExecute(Data)          ── instant/periodic only; react, distribute
    └─ PostAttributeChange(Attr, Old, New)      ── cross-attribute correction
```

| Hook | Use it for | Do not use it for |
|---|---|---|
| `PreAttributeChange` | Clamping `CurrentValue` | Gameplay events (Epic says so explicitly) |
| `PreAttributeBaseChange` | Clamping `BaseValue` | Anything stateful — it is `const` |
| `PreGameplayEffectExecute` | Rejecting an effect outright | Modifying values |
| `PostGameplayEffectExecute` | Meta-attribute distribution, death checks, hit reacts | Clamping `CurrentValue` |
| `PostAttributeChange` | "MaxHealth dropped below Health, fix Health" | Clamping — too late |

**Clamp in both `Pre` hooks or you have a hole.** `PreAttributeChange` fires for
`CurrentValue`; an instant GE writes `BaseValue` and only `PreAttributeBaseChange` sees it.
Lyra factors this into one `ClampAttribute()` called from both — copy that.

**Clamping in `PreAttributeChange` does not change the stored modifier.** It changes only the
value returned by the query. So an `MMC` or `ExecCalc` that recaptures the attribute
recomputes from raw modifiers and **skips your clamp entirely** — clamp again inside the
calculation. This catches people repeatedly.

`PostGameplayEffectExecute` runs **before** replication, so clamping there costs one network
update rather than two. Clients only ever see the clamped value.

## Meta attributes

A meta attribute is a non-replicated placeholder that exists to be consumed in the same frame
it is written.

```
GE (damage 50) ──> ExecCalc (armour mitigates to 30) ──> Damage meta attribute
                                                              │
                              PostGameplayEffectExecute ───────┤
                                                              ├──> Shield  -30 (if any left)
                                                              └──> Health  -remainder
```

The separation is between *"how much?"* (the effect and its calculation) and *"what do we do
with it?"* (the attribute set). It pays off when different characters distribute the same
damage differently — one has a shield attribute, one does not — because the GE does not need
to know.

Lyra's `Damage` and `Healing` in `ULyraHealthSet` are exactly this. Both carry
`HideFromModifiers` so nothing can bypass the pipeline.

Meta attributes are not mandatory. One `ExecCalc` and one attribute set shared by every actor
means you can distribute inside the calculation and skip the indirection; you lose only
flexibility.

## Reacting to a change

```cpp
ASC->GetGameplayAttributeValueChangeDelegate(USet::GetStaminaAttribute())
   .AddUObject(this, &AMyClass::StaminaChanged);

void AMyClass::StaminaChanged(const FOnAttributeChangeData& Data);   // NewValue, OldValue, ...
```

`Data.GEModData` is **server-only**. Client-side code reading it gets null.

This is the recommended place for gameplay reactions, not `PreAttributeChange`. For UMG, the
engine ships `UAbilityAsync_WaitAttributeChanged` — use it rather than hand-writing an async
task (`ue58-deltas.md` §8).

## Attribute set design

- One set or many is an organisational choice; sets cost almost nothing in memory.
- **Never two instances of the same set class on one ASC.** Lookups find the first and ignore
  the rest — the second set silently does nothing.
- Subclassing prefixes attributes with the *parent* class name. `AttributeSetClassName.AttributeName`
  is the internal identity, so a subclass's inherited attributes keep the base's prefix.
- **Removing a set at runtime is dangerous.** If a client removes it before the server, an
  incoming attribute replication cannot find its set and crashes. GASShooter hit this exact
  crash with a rocket launcher removed on self-kill.

```cpp
// add / remove at runtime, if you must
ASC->GetSpawnedAttributes_Mutable().AddUnique(SetPtr);
ASC->ForceReplication();
```

**On a Lyra project, grant sets through `ULyraAbilitySet::GrantedAttributes` instead.** It is
data-driven, per-experience, and avoids the duplicated-Blueprint nullptr bug entirely.

## Item attributes (ammo, durability)

Three options; the recommendation is the first.

**1. Plain floats on the item (recommended).** What Fortnite and GASShooter do for ammo.
Replicate `COND_OwnerOnly`. You override `UGameplayAbility::CheckCost`/`ApplyCost` to charge
against the float instead of an attribute. Suppress replication while firing so the server
does not clobber the local count mid-burst:

```cpp
DOREPLIFETIME_ACTIVE_OVERRIDE(AWeapon, ClipAmmo,
    IsValid(ASC) && !ASC->HasMatchingGameplayTag(FiringTag));
```

**2. A separate attribute set on the item.** Works, but you need one set class per weapon
type (one instance per class limit), so one weapon of each type per inventory, and removal
can crash. Construct it in `BeginPlay()`, not the constructor, and implement
`IAbilitySystemInterface` on the item.

**3. A whole ASC on the item.** Dave Ratti's answer amounts to "probably don't" — you would
have to decide which ASC is authoritative for an incoming GE.

## Derived attributes

An `Infinite` GE with `Attribute Based` or `MMC` modifiers. It recalculates automatically when
a backing attribute changes.

```
((CurrentValue + AddBase) * MultiplyAdditive / DivideAdditive * MultiplyCompound) + AddFinal
```

Order within a category is not controllable — if you need a specific order of operations, do
the whole thing in one `MMC`.

Testing with multiple PIE clients: **disable `Run Under One Process`**, or derived attributes
fail to update on any client past the first.

## Non-stacking, greatest-magnitude-only

Paragon's slows: many applied, only the strongest counted. Built in via
`OnAttributeAggregatorCreated`:

```cpp
void UMySet::OnAttributeAggregatorCreated(const FGameplayAttribute& Attribute,
                                          FAggregator* NewAggregator) const
{
    Super::OnAttributeAggregatorCreated(Attribute, NewAggregator);
    if (NewAggregator && Attribute == GetMoveSpeedAttribute())
    {
        NewAggregator->EvaluationMetaData =
            &FAggregatorEvaluateMetaDataLibrary::MostNegativeMod_AllPositiveMods;
    }
}
```

Disqualified modifiers still exist on the ASC and can qualify later — when the strongest slow
expires, the next takes over automatically. Add custom qualifiers as statics on
`FAggregatorEvaluateMetaDataLibrary`.

## Initializing

Epic recommends an instant GE, which is what Lyra does and what keeps initialization
data-driven. Direct alternative when you need it:

```cpp
Set->InitStamina(100.0f);                                    // generated by the macro
ASC->SetNumericAttributeBase(USet::GetStaminaAttribute(), 100.f);   // no bespoke pointer needed
```

The second form is also the workaround for the duplicated-Blueprint-nullptr bug: add sets via
`ASC->AddSet<T>()` in `PostInitializeComponents()` and never hold a pointer to them.
