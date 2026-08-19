# Targeting

`FGameplayAbilityTargetData` is a generic struct designed to cross the network. Its stated
purpose is targeting information — actor references, hit results, locations — but it is also
**the standard way to pass arbitrary structured data from client to server inside an ability**,
which is often why you reach for it.

The base struct is never used directly; subclass it.

## Target data handles

You pass `FGameplayAbilityTargetDataHandle`, not the data. The handle holds a `TArray` of
pointers, which is what gives you polymorphism across the wire.

```cpp
USTRUCT(BlueprintType)
struct MYGAME_API FMyTargetData : public FGameplayAbilityTargetData
{
    GENERATED_BODY()

    UPROPERTY() FName CoolName = NAME_None;
    UPROPERTY() FPredictionKey MyKey;

    // Both of these are REQUIRED on every subclass
    virtual UScriptStruct* GetScriptStruct() const override
    { return FMyTargetData::StaticStruct(); }

    bool NetSerialize(FArchive& Ar, class UPackageMap* Map, bool& bOutSuccess)
    {
        CoolName.NetSerialize(Ar, Map, bOutSuccess);
        MyKey.NetSerialize(Ar, Map, bOutSuccess);
        bOutSuccess = true;
        return true;
    }
};

template<>
struct TStructOpsTypeTraits<FMyTargetData> : public TStructOpsTypeTraitsBase2<FMyTargetData>
{
    enum { WithNetSerializer = true };   // REQUIRED or handle serialization silently fails
};
```

Three requirements, all easy to miss and all producing confusing failures:

1. **`GetScriptStruct()`** — without it, type checking on receipt is impossible
2. **`NetSerialize()`** — without it, your fields do not cross
3. **`WithNetSerializer = true`** — without it, the *handle* does not serialize your struct at
   all, even though the struct itself has `NetSerialize`

If a compile error mentions `GOTCHARUNTIME_API` on a member of an already-exported struct: do
not put the module macro on `NetSerialize` — the struct is already exported.

## Creating and adding

```cpp
FMyTargetData* Data = new FMyTargetData();   // raw new is correct here
Data->CoolName = Name;

FGameplayAbilityTargetDataHandle Handle;
Handle.Add(Data);        // the handle now owns it and deletes it
return Handle;
```

**The `new` is deliberate.** The handle takes ownership and cleans up on destruction. Add it to
a handle in the same frame or you leak.

## Reading it back — type-check first

```cpp
FGameplayAbilityTargetData* Data = Handle.Get(Index);   // index-checked for you
if (!Data) { return NAME_None; }

// static_cast is NOT type-safe: without this check you get object slicing or a crash
if (Data->GetScriptStruct() == FMyTargetData::StaticStruct())
{
    FMyTargetData* Mine = static_cast<FMyTargetData*>(Data);
    return Mine->CoolName;
}
```

`Get(int32)` has const and non-const overloads — const for reading, non-const for modifying.

The alternative to comparing script structs is giving your subclasses gameplay tags and
branching on those. Struct comparison is more precise; tags scale better across a hierarchy.

## Sending it to the server

Inside an ability, the standard path:

```cpp
// client
FScopedPredictionWindow Window(ASC, ActivationInfo.GetActivationPredictionKey());
ASC->CallServerSetReplicatedTargetData(Handle, ActivationInfo.GetActivationPredictionKey(),
                                       TargetDataHandle, ApplicationTag, PredictionKey);

// server
ASC->AbilityTargetDataSetDelegate(Handle, PredictionKey).AddUObject(this, &UMy::OnDataReceived);
ASC->CallReplicatedTargetDataDelegatesIfSet(Handle, PredictionKey);
```

The second call matters: the data may have **already arrived** before you bound the delegate.
Without it you wait forever for something that is already sitting there.

This is the mechanism for replicating a client-side decision the server must not recompute — the
motion-matching case in `prediction.md` is exactly this. Sending the *decision* rather than the
inputs to it is what stops the two machines from disagreeing.

**Validate on the server.** The client authored this struct and can lie. A distance or
plausibility check is cheap; the traversal ability uses a slack radius on the reported ledge
position.

## Target actors

`AGameplayAbilityTargetActor` spawned by the `WaitTargetData` task, to visualise and capture
targeting from the world. They are `AActor`s, so they can carry meshes and decals — a
ground-decal AoE indicator, a placement preview for a building.

Confirmation modes:

| Mode | Confirmed when |
|---|---|
| `Instant` | Immediately. Spawns, produces data, destroys. **`Tick()` never runs** |
| `UserConfirmed` | Bound `Confirm` input, or `ASC->TargetConfirm()` |
| `Custom` | Ability calls `ConfirmTaskByInstanceName()` |
| `CustomMulti` | Same, but the task does not end on producing data |

Not every target actor supports every mode — `GroundTrace` does not support `Instant`.

**Non-`Instant` target actors trace on `Tick()`.** Usually fine — not replicated, rarely more
than one — but the debug draw also happens every tick, and a complex target actor can do real
work there. Lower the tick rate if it costs too much.

Common spawn parameters: `Debug`, `Filter`, `Reticle Class`, `Reticle Parameters`,
`Start Location`.

### Where the data is produced

`ShouldProduceTargetDataOnServer` decides, and the choice is a real trade-off:

| Value | Behaviour | Trade-off |
|---|---|---|
| `false` | Client traces, RPCs data via `CallServerSetReplicatedTargetData()` | Responsive; **must validate against cheating** |
| `true` | Client sends a generic confirm; server traces | No trust needed; **the owning client can mispredict** |

Cancellation sends `EAbilityGenericReplicatedEvent::GenericCancel`.

### The efficiency problem

`WaitTargetData` spawns a target actor per activation; `WaitTargetDataUsingActor` takes a
pre-spawned one but still destroys it. Both are fine for prototyping and wasteful for anything
producing data continuously, like automatic fire. GASShooter wrote a reusable target actor plus
a `WaitTargetDataWithReusableActor` task from scratch for this.

### Persistent targets

Default target actors consider an actor valid **only while it is in the trace**. Look away and
it is gone. "Remember the last valid target" is not built in — subclass and add it. GASShooter
does this for homing-rocket lock-on.

## Target data filters

`Make GameplayTargetDataFilter` + `Make Filter Handle` handles the common cases (exclude self,
require a class). For more:

```cpp
USTRUCT(BlueprintType)
struct MYGAME_API FMyFilter : public FGameplayTargetDataFilter
{
    GENERATED_BODY()
    virtual bool FilterPassesForActor(const AActor* ActorToBeFiltered) const override;
};
```

`WaitTargetData` wants a `FGameplayTargetDataFilterHandle`, so you also need a factory:

```cpp
FGameplayTargetDataFilterHandle UMyLib::MakeMyFilterHandle(FMyFilter Filter, AActor* FilterActor)
{
    FGameplayTargetDataFilter* New = new FMyFilter(Filter);
    New->InitializeFilterContext(FilterActor);
    FGameplayTargetDataFilterHandle H;
    H.Filter = TSharedPtr<FGameplayTargetDataFilter>(New);
    return H;
}
```

## Reticles

`AGameplayAbilityWorldReticle` shows **who** you are targeting, as opposed to the target actor
showing **where**. The target actor owns their spawn and destruction, and typically moves them
to the target each tick.

They are actors, so a `WidgetComponent` displaying a UMG widget in screen space is the usual
implementation (GASShooter).

Blueprint events: `OnValidTargetChanged`, `OnTargetingAnActor`, `OnParametersInitialized`,
`SetReticleMaterialParamFloat`, `SetReticleMaterialParamVector`.

Two limitations: a reticle **does not know which actor it is on** (add that in a custom target
actor if you need it), and `FWorldReticleParameters` is technically subclassable but default
target actors only accept the base struct — you need a custom target actor to pass a subclass
through.

Reticles and target actors are both unreplicated by default; either can be made replicated if
showing other players' aim makes sense in your game.

## Effect container targeting

`FGameplayEffectContainer` (Action RPG sample) carries an optional lightweight targeting mode.
It runs on the CDO — no actor spawn or destroy — and executes instantly on client and server
when the container is applied.

Cheaper than a target actor, but: no player input, no confirmation, cannot be canceled, and
**cannot send data client→server** (both sides produce their own). Good for instant traces and
overlaps. Subclass the target type in C++ or Blueprint.

## The Gameplay Targeting System (5.2+)

A separate, newer, data-driven targeting subsystem added in 5.2. Not a replacement for target
actors and not covered by pre-5.2 documentation. If you are choosing targeting infrastructure
from scratch, evaluate it before committing to `TargetActors`.
