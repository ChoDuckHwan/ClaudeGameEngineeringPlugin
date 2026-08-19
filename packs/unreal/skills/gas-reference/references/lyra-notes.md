# GAS on Lyra: what already exists, what you write

Verified against `LyraStarterGame/Source/LyraGame/`.

The single most common wasted effort when following a GAS tutorial on a Lyra project is
rebuilding the plumbing. Chapters 3, 4.1, 4.1.1, 4.1.2, and 4.6.2 of GASDocumentation
describe work Lyra has finished. Read this file before writing a line.

---

## What Lyra provides

| Concern | Lyra's answer | Where |
|---|---|---|
| ASC subclass | `ULyraAbilitySystemComponent` | `AbilitySystem/` |
| ASC location | On `ALyraPlayerState` for players; on the pawn for `ALyraCharacterWithAbilities` | `Player/LyraPlayerState.cpp:36` |
| Replication mode | **`Mixed`**, already set | `LyraPlayerState.cpp:36`, `LyraGameState.cpp:30` |
| `NetUpdateFrequency` | **100.0f**, already raised | `LyraPlayerState.cpp:43` |
| ASC init, server + client | `ULyraPawnExtensionComponent` handles both | `LyraPawnExtensionComponent.cpp:142` |
| Base attribute set | `ULyraAttributeSet` (+ `GetLyraAbilitySystemComponent()`, `GetWorld()`) | `AbilitySystem/Attributes/` |
| `ATTRIBUTE_ACCESSORS` macro | Defined by Lyra | `LyraAttributeSet.h:29` |
| Health / damage / healing | `ULyraHealthSet` — full meta-attribute pipeline | `Attributes/LyraHealthSet.h` |
| Base ability | `ULyraGameplayAbility` (+ activation policy, activation group, failure messages) | `Abilities/` |
| Granting abilities/effects/sets | `ULyraAbilitySet` data asset | `AbilitySystem/LyraAbilitySet.h` |
| Input → ability | Enhanced Input → `InputTag` → `ULyraInputConfig` → ability set | `Input/`, `Character/LyraHeroComponent.cpp` |
| Native tag declaration | `UE_DECLARE_GAMEPLAY_TAG_EXTERN` / `UE_DEFINE_GAMEPLAY_TAG` | `LyraGameplayTags.h` |

**Consequences.** You never write an ASC constructor, never call `InitAbilityActorInfo`,
never call `SetReplicationMode`, and never call
`BindAbilityActivationToInputComponent` — Lyra replaced the enum-to-byte input binding the
docs describe (§4.6.2) with gameplay-tag-keyed Enhanced Input. The
`EGDAbilityInputID`-style enum has no place in a Lyra project.

Lyra does **not** call `UAbilitySystemGlobals::InitGlobalData()` anywhere, which is correct —
5.3+ calls it automatically. See `ue58-deltas.md` §5.

---

## Which Lyra classes you can subclass in C++

This is the part most likely to be stale in project notes, because **UE 5.5 changed Lyra's
export pattern**. Classes now use `UCLASS(MinimalAPI)` with `#define UE_API LYRAGAME_API` and
per-member `UE_API`, which does export them across modules.

Verified by reading each header:

| Class | C++ subclassable | Pattern |
|---|---|---|
| `ULyraGameplayAbility` | **Yes** | `MinimalAPI` + `UE_API` |
| `ULyraAbilitySystemComponent` | **Yes** | `MinimalAPI` + `UE_API` |
| `ULyraAttributeSet` | **Yes** | `MinimalAPI` + `UE_API` |
| `ULyraHealthSet` | **Yes** | `MinimalAPI` + `UE_API` |
| `ALyraCharacter` | **Yes** | `MinimalAPI` + `UE_API` |
| `ALyraPlayerState` | **Yes** | `MinimalAPI` + `UE_API` |
| `ULyraCharacterMovementComponent` | **Yes** | `MinimalAPI` + `UE_API` |
| `ULyraHeroComponent` | **Yes** | `MinimalAPI` + `UE_API` |
| `ULyraPawnExtensionComponent` | **Yes** | `MinimalAPI` + `UE_API` |
| `ULyraAbilitySet` | **No** | no `UE_API`, unexported |
| `ULyraCombatSet` | **No** | no `UE_API`, unexported |
| `ULyraAnimInstance` | **No** — see below | old-style, unexported |

**`ULyraAnimInstance` is the exception that proves the rule.** It still uses the old whole-class
`class LYRAGAME_API ULyraAnimInstance` form, *without* the export — so it cannot be inherited
across modules. Do not assume a file follows the 5.5 pattern because its neighbours do; check for
`#define UE_API` at the top of the header.

If you need what it provides, the options in order are: **reparent your AnimBP** to
`ULyraAnimInstance` in the editor (reflection-based reparenting does not link, so no export is
needed — this is enough for most cases), **copy the piece you need** into a class based on
`UAnimInstance` (its `FGameplayTagBlueprintPropertyMap` handling depends only on GAS, which *is*
exported), or add the export to Lyra and accept that you now maintain a patch.

Unexported classes (`ULyraAbilitySet`, `ULyraCombatSet`) are still perfectly usable — you
just consume them rather than derive from them. An ability set is a data asset you fill in;
there is rarely a reason to subclass it.

---

## Lyra's activation policy, and the trap in it

`ULyraGameplayAbility` adds `ELyraAbilityActivationPolicy`:

| Policy | Meaning |
|---|---|
| `OnInputTriggered` | Activate once when the input fires |
| `WhileInputActive` | Keep trying to activate while the input is held |
| `OnSpawn` | Activate when an avatar is assigned (Lyra's passive-ability path) |

**`WhileInputActive` only governs activation. It does not end the ability on release.**

`ULyraAbilitySystemComponent::AbilitySpecInputReleased` calls
`InvokeReplicatedEvent(EAbilityGenericReplicatedEvent::InputReleased, ...)` and stops there —
`LyraAbilitySystemComponent.cpp:168`. The engine's own comment explains why: Lyra does not
support `bReplicateInputDirectly`, so release arrives as a replicated *event* that something
must be listening for.

That listener is your job:

```cpp
UAbilityTask_WaitInputRelease* Task =
    UAbilityTask_WaitInputRelease::WaitInputRelease(this, /*bTestAlreadyReleased=*/true);
Task->OnRelease.AddDynamic(this, &UMyAbility::OnReleased);
Task->ReadyForActivation();
```

`bTestAlreadyReleased = true` matters: on a quick tap the key can be up before activation
finishes, and without it that release is never heard — the ability stays on forever.

Also note `OnSpawn` exists. GASDocumentation §4.6.4.1 tells you to override `OnAvatarSet()`
and call `TryActivateAbility()` for passive abilities. In Lyra, set the activation policy
instead; `ULyraGameplayAbility::OnPawnAvatarSet()` already does it.

---

## Activation groups — a Lyra concept with no GAS equivalent

`ELyraAbilityActivationGroup` sits alongside the tag-based blocking the docs describe:

| Group | Meaning |
|---|---|
| `Independent` | Runs alongside anything |
| `Exclusive_Replaceable` | Canceled and replaced by another exclusive ability |
| `Exclusive_Blocking` | Blocks all other exclusive abilities |

Use this instead of hand-rolling `Block Abilities with Tag` chains for "only one of these at
a time" abilities. It is also runtime-changeable via `ChangeActivationGroup()`, which tag
containers are not.

---

## Copy Lyra's attribute set pattern, not the documentation's

`ULyraHealthSet` is a working reference for everything `attributes.md` describes and it
differs from the doc in three deliberate ways worth imitating:

**1. Attributes are `private` with `AllowPrivateAccess`.** Access goes through the macro
accessors, not the field.

```cpp
UPROPERTY(BlueprintReadOnly, ReplicatedUsing = OnRep_Health, Category = "Lyra|Health",
          Meta = (HideFromModifiers, AllowPrivateAccess = true))
FGameplayAttributeData Health;
```

**2. `HideFromModifiers` on anything only executions should touch.** Health carries it, so a
GE cannot add to health with a plain modifier — damage has to route through the `Damage` meta
attribute. This is how the doc's meta-attribute pattern is *enforced* rather than merely
recommended.

**3. Clamping is factored into one `ClampAttribute()` called from both hooks.**

```cpp
void ULyraHealthSet::PreAttributeBaseChange(const FGameplayAttribute& Attr, float& NewValue) const
{ Super::PreAttributeBaseChange(Attr, NewValue); ClampAttribute(Attr, NewValue); }

void ULyraHealthSet::PreAttributeChange(const FGameplayAttribute& Attr, float& NewValue)
{ Super::PreAttributeChange(Attr, NewValue); ClampAttribute(Attr, NewValue); }
```

`PreAttributeChange` guards the `CurrentValue`; `PreAttributeBaseChange` guards the
`BaseValue`. The doc only discusses the former — override both or an instant GE writes an
unclamped base value.

**4. Cross-attribute correction goes in `PostAttributeChange`, through the ASC:**

```cpp
if (Attribute == GetMaxHealthAttribute() && GetHealth() > NewValue)
{
    LyraASC->ApplyModToAttribute(GetHealthAttribute(), EGameplayModOp::Override, NewValue);
}
```

`ApplyModToAttribute` is server-only. That is intentional — the correction is authoritative.
Do not reach for `ApplyModToAttributeUnsafe` to "fix" it running only on the server.

**5. Delegates are declared `mutable` on the set** (`FLyraAttributeEvent`, six params), so
`const` hooks can broadcast. Broadcast from both `PostGameplayEffectExecute` (server, full
info) and `OnRep_` (client, instigator null). The doc's §4.3.4
`GetGameplayAttributeValueChangeDelegate` still works and is the right choice for UI; Lyra's
own delegates carry more context for gameplay reactions.

---

## Adding a new attribute set to a Lyra project

1. Subclass `ULyraAttributeSet` (exported — this works).
2. Use `ATTRIBUTE_ACCESSORS` from `LyraAttributeSet.h`.
3. `GetLifetimeReplicatedProps` with `DOREPLIFETIME_CONDITION_NOTIFY(..., COND_None,
   REPNOTIFY_Always)`.
4. Clamp in both `PreAttributeChange` and `PreAttributeBaseChange`.
5. **Grant it through the ability set**, not a constructor `CreateDefaultSubobject`. A
   `ULyraAbilitySet` has a `GrantedAttributes` array. This also sidesteps the duplicated-BP
   nullptr bug in §9.4 of the doc, because there is no bespoke pointer to null out.

Step 5 is where the documentation and Lyra diverge most sharply. The doc constructs
attribute sets in the owner's constructor; Lyra grants them as data, which is what makes them
composable per-experience.

---

## Building in a GameFeature plugin without modifying Lyra

A common arrangement is to keep all your work inside a GameFeature plugin and leave Lyra's
`Source/` and `Content/` untouched, so Lyra can be restored from the Launcher on any machine. For
GAS work that constraint plays out as:

- **New tags** go in your plugin's own native tag file, never appended to `LyraGameplayTags.h`.
- **Abilities, effects, and attribute sets subclass cleanly** into the plugin, because the base
  classes are exported (see the table above). This is the part that surprises people who read
  older notes saying Lyra can't be inherited from.
- **Ability sets and input configs get duplicated** into the plugin and edited there. They are
  data assets, so a copy is as good as the original and Lyra's defaults stay intact.
- **Project-wide tag settings have no plugin-local home.** Tag redirects and the
  `ActivateFail*` names in `[/Script/GameplayAbilities.AbilitySystemGlobals]` are project config;
  a plugin cannot declare them. They must go in the project's `Config/` directory, so if you are
  tracking a subset of the project in version control, whitelist `Config/` too.

  A plugin *can* ship its own tags — `UGameplayTagsManager::Get().AddTagIniSearchPath(...)` from
  `StartupModule()`, as the CommonConversation plugin does — but that only *adds* tags. It cannot
  redirect them.
