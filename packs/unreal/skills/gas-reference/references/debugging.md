# Debugging GAS

Organized by symptom. GAS fails silently more often than it crashes, so the first move is
almost always to *look at live state* rather than to add logs.

---

## Start here: `showdebug abilitysystem`

One console command answers "what attributes / tags / effects / abilities do I have right now".

```
showdebug abilitysystem
AbilitySystem.Debug.NextCategory     ── cycle the three pages
```

| Page | Shows |
|---|---|
| 1 | `CurrentValue` of every attribute |
| 2 | Every `Duration`/`Infinite` effect: stacks, granted tags, modifiers |
| 3 | Every granted ability: running, blocked, and live ability-task status |

All three pages always show your current gameplay tags.

Cycle targets with `PageUp`/`PageDown` or `NextDebugTarget`/`PreviousDebugTarget`.

**Two prerequisites, both of which cause "Unknown Command" or a frozen display:**

```ini
[/Script/GameplayAbilities.AbilitySystemGlobals]
bUseDebugTargetFromHud=true          ; without this, target switching does not update the display
```

and **the GameMode must have an actual HUD class set**, or the command does not exist.

## Gameplay Debugger — for *other* characters

Apostrophe (`'`) to open, numpad `3` for the Abilities category (the number varies with
installed plugins; rebindable in project settings).

Shows tags, effects, and abilities on whatever character is centred on screen. **It does not
show their attribute values** — that is `showdebug`'s job, on a switched target.

## Logging

```
log LogAbilitySystem VeryVerbose      ; turn on ABILITY_LOG()
log LogAbilitySystem Display          ; back to default
log list
```

| Category | Default |
|---|---|
| `LogAbilitySystem` | Display |
| `LogAbilitySystemComponent` | Log |
| `LogGameplayEffects` | Display |
| `LogGameplayEffectDetails` | Log |
| `LogGameplayCueDetails` | Log |
| `LogGameplayCueTranslator` | Display |
| `LogGameplayTags` | Log |
| `LogGameplayTasks` | Log |
| `VLogAbilitySystem` | Display |

**Tag your own logs with the net role.** In listen-server testing both machines write to the same
log and it is impossible to tell whose line is whose. Guessing costs hours:

```cpp
static const TCHAR* RoleTag(const AActor* A)
{
    if (!A || !A->GetWorld()) { return TEXT("?"); }
    switch (A->GetWorld()->GetNetMode())
    {
    case NM_Standalone:     return TEXT("STANDALONE");
    case NM_ListenServer:   return A->HasAuthority() ? TEXT("SERVER") : TEXT("SIMPROXY");
    case NM_Client:         return TEXT("CLIENT");
    default:                return TEXT("?");
    }
}
UE_LOG(LogTemp, Log, TEXT("[MySystem][%s] ..."), RoleTag(Avatar));
```

## Ability task debugging

Since 5.1, on by default in non-shipping builds:

```
AbilitySystem.AbilityTask.Debug.RecordingEnabled 0|1|2
AbilitySystem.AbilityTask.Debug.AbilityTaskDebugPrintTopNResults N
AbilitySystem.ServerRPCBatching.Log 1
```

## Stepping through optimized code

The engine optimizes aggressively and `DebugGame Editor` is not always enough:

```cpp
UE_DISABLE_OPTIMIZATION
void UMyClass::MyFunction() { }
UE_ENABLE_OPTIMIZATION
```

Does not work on plugin code unless you rebuild the plugin from source. **Remove these when
done** — they are easy to forget and they cost real performance.

---

# By symptom

## Nothing happens when I press the key

Work outward from the input:

1. **Is the ability granted?** `showdebug abilitysystem` page 3. If it is not listed, the
   grant did not happen — on Lyra check the ability set and the pawn data.
2. **Is it blocked?** Page 3 says so. A blocked ability is usually an activation-blocked tag or
   an activation group conflict.
3. **Turn on activation failure tags** (below). This converts a silent failure into a named
   reason and is the highest-value 5 minutes in GAS debugging.
4. **Is the input reaching the ASC at all?** On Lyra, is the `InputTag` in the input config and
   is the IMC actually added to the player? An `IA_*` asset with only a `Pressed` trigger fires
   for one frame and immediately reports `Completed` — see below.

### Activation failure tags

```ini
[/Script/GameplayAbilities.AbilitySystemGlobals]
ActivateFailIsDeadName=Activation.Fail.IsDead
ActivateFailCooldownName=Activation.Fail.OnCooldown
ActivateFailCostName=Activation.Fail.CantAffordCost
ActivateFailTagsBlockedName=Activation.Fail.BlockedByTags
ActivateFailTagsMissingName=Activation.Fail.MissingTags
ActivateFailNetworkingName=Activation.Fail.Networking
```

Declare the tags too. Then:

```
LogAbilitySystem: Display: InternalServerTryActivateAbility. Rejecting ClientActivation of
Default__GA_FireGun_C. InternalTryActivateAbility failed: Activation.Fail.BlockedByTags
```

They also appear on the `showdebug` HUD.

## `Can't activate LocalOnly or LocalPredicted ability %s when not local!`

**The ASC was never initialized on the client.** `InitAbilityActorInfo` ran on the server only.

On Lyra this is not your code — the pawn extension component handles both sides. If you see it,
something upstream failed: the pawn data did not resolve, the experience did not load, or the
ASC's owner is not what you think. Check whether the player state exists on the client at the
time you looked.

## The ability turns on and never turns off

`WhileInputActive` (and its equivalents) only govern *activation*. Release fires a replicated
input event; **nothing ends the ability unless you listen**.

```cpp
UAbilityTask_WaitInputRelease::WaitInputRelease(this, /*bTestAlreadyReleased=*/true);
```

Without `bTestAlreadyReleased`, a quick tap releases before activation finishes and the release
is never heard — permanently on.

## It toggles on and off every frame instead of staying held

**Check the input action's triggers, not your code.** An `InputAction` with only an
`InputTriggerPressed` fires `Triggered` on the press frame and returns to `None`, which Enhanced
Input reports as `Completed` — read as "key released" even while held.

For hold input, **leave the trigger list empty**. Enhanced Input falls back to a plain down
check: `Triggered` while held, `Completed` on release. This is what Lyra's own actions do.

Symptom in a log: the state appears and disappears one frame apart, repeatedly.

## A predicted effect applies twice on the owning client

Stale prediction key — the "redo" problem. Insert a `WaitNetSync` with `OnlyServerWait`
immediately before applying. See `prediction.md`.

## An attribute change is ignored, or reverts

- **Clamping in `PreAttributeChange` does not change the stored modifier.** Anything that
  recaptures the attribute (`MMC`, `ExecCalc`) recomputes from raw modifiers and skips your
  clamp. Clamp again inside the calculation.
- **Two clamp hooks, not one.** `PreAttributeChange` guards `CurrentValue`;
  `PreAttributeBaseChange` guards `BaseValue`. An instant GE only hits the second.
- **`HideFromModifiers`** on the attribute means plain modifiers cannot touch it by design —
  only executions can.
- **A second attribute set of the same class** on the ASC is silently ignored. Lookups take the
  first.

## A GE's tags do nothing

**You almost certainly set a deprecated field.** In 5.3+ every tag container moved to a
`UGameplayEffectComponent`; the old fields are still visible in the editor under a "Deprecated"
category and are ignored. See `ue58-deltas.md` §3.

Add `UTargetTagsGameplayEffectComponent` (granted tags),
`UAssetTagsGameplayEffectComponent` (asset tags), or
`UTargetTagRequirementsGameplayEffectComponent` (requirements).

## A modifier produces the wrong number

Two candidates:

1. **`EGameplayModOp` changed in 5.5.** `Multiplicitive` is now `MultiplyAdditive` and *adds*
   rather than multiplies: two 1.5× mods give 2.0×, not 2.25×. If you want real multiplication
   use **`MultiplyCompound`**. Full formula in `ue58-deltas.md` §2.
2. **Two `ExecCalc`s with identically named capture structs.** They share one namespace, so
   they capture each other's attributes. Rename one.

## A montage does not play on other clients

Use the `PlayMontageAndWait` **ability task**, not the `PlayMontage` node. The task replicates
through the ASC; the plain node does not.

## `ScriptStructCache` errors / clients get disconnected

Historically meant `InitGlobalData()` was never called. **In 5.3+ the engine calls it
automatically**, so on 5.8 look elsewhere first — usually a target data subclass missing
`WithNetSerializer = true` in its `TStructOpsTypeTraits`. See `targeting.md`.

## `unresolved external symbol UEPushModelPrivate::MarkPropertyDirty`

Add **`NetCore`** to `PublicDependencyModuleNames` in your `Build.cs`. Caused by calling
`MarkItemDirty()` on a fast array serializer — e.g. editing an active GE's duration.
`WITH_PUSH_MODEL` ends up defined inconsistently across translation units.

Also add `NetCore` if you use `FVector_NetQuantize100` / `FVector_NetQuantizeNormal` in a
replicated struct, for the same class of reason.

## AttributeSet pointers are null on a duplicated Blueprint

An engine bug (UE-81109) affecting Blueprint actor classes duplicated from other Blueprint
actor classes. Workaround: do not hold a bespoke pointer at all.

```cpp
void AMyPlayerState::PostInitializeComponents()
{
    Super::PostInitializeComponents();
    if (AbilitySystemComponent) { AbilitySystemComponent->AddSet<UMyAttributeSet>(); }
}
```

Then read and write through the ASC:

```cpp
ASC->GetNumericAttribute(UMyAttributeSet::GetHealthAttribute());
ASC->SetNumericAttributeBase(UMyAttributeSet::GetHealthAttribute(), NewValue);
```

On Lyra, granting sets through `ULyraAbilitySet::GrantedAttributes` avoids this entirely.

## `Enum names are now represented by path names` warning

5.1 deprecated the `FString` constructor of `FGameplayAbilityInputBinds`:

```cpp
FTopLevelAssetPath Path(FName("/Script/MyGame"), FName("EMyAbilityInputID"));
ASC->BindAbilityActivationToInputComponent(InputComponent,
    FGameplayAbilityInputBinds(FString("ConfirmTarget"), FString("CancelTarget"), Path,
        static_cast<int32>(EMyAbilityInputID::Confirm),
        static_cast<int32>(EMyAbilityInputID::Cancel)));
```

**On a Lyra project you should not hit this at all** — Lyra binds input by gameplay tag through
`ULyraInputConfig`. If you are writing an `EMyAbilityInputID` enum on Lyra, you are following a
tutorial that predates the project's input system.

## A cue fires twice on the listen-server host

Expected under `Mixed`/`Minimal` replication: once for the GE application, once from the
minimal-replication multicast. `WhileActive` fires once; `Add`/`Remove` fire twice. Lyra uses
`Mixed`, so this affects any listen-server host.

Put anything that must run exactly once in `WhileActive`.

## A cue never fires

- **Missing the `GameplayCue.` parent tag.** `Character.Land` never fires; only
  `GameplayCue.Character.Land` does.
- **`GameplayCueNotify_Actor` without `Auto Destroy on Remove`** — the first `Add` works and
  every later one silently does nothing.
- **Scan path too narrow.** `GameplayCueNotifyPaths` in `DefaultGame.ini` limits where the
  manager looks.
- **It is unreliable and was dropped.** Cues are unreliable multicasts by design. If it must
  arrive, apply it from a GE and use `WhileActive` + `OnRemove`. See `tasks-cues.md`.

## A custom ability task appears to do nothing

**`ReadyForActivation()` was not called.** Blueprint calls it for you via
`K2Node_LatentGameplayTaskCall`; C++ does not. Same for `BeginSpawningActor()` /
`FinishSpawningActor()`.

## Two abilities cancel each other unexpectedly

Check `Cancel Abilities with Tag` and `Block Abilities with Tag` — they match against the other
ability's **asset tags**, not its granted or activation-owned tags. On Lyra also check
`ELyraAbilityActivationGroup`: two `Exclusive_*` abilities interact by design.

## Derived attributes do not update on clients past the first

Disable **`Run Under One Process`** in Editor Preferences. A PIE artifact, not a bug in your
code.

---

## Sanity checklist for a new GAS feature

- [ ] Attributes clamped in **both** `PreAttributeChange` and `PreAttributeBaseChange`
- [ ] `REPNOTIFY_Always` on every replicated attribute
- [ ] GE tags configured on **components**, not the deprecated fields
- [ ] Modifier ops use the 5.5 names; `MultiplyCompound` where real multiplication is meant
- [ ] Ability is `InstancedPerActor` (not `NonInstanced` — removed)
- [ ] Asset tags set via `SetAssetTags()` in the constructor
- [ ] Held input has a `WaitInputRelease` task with `bTestAlreadyReleased = true`
- [ ] Input action's trigger list is empty for hold behaviour
- [ ] Activation failure tags configured in `DefaultGame.ini`
- [ ] Logs tagged with net role
- [ ] Tested on a listen server, not just standalone
