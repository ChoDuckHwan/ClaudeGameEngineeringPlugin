---
name: gas-reference
description: Use when working with Unreal's Gameplay Ability System - attributes, attribute sets, gameplay effects, abilities, ability tasks, gameplay cues, prediction, targeting, or debugging why a GAS thing does not fire, does not replicate, or fires twice. Covers UE 5.8 API, where it diverges from older GAS tutorials, and what Lyra already provides.
---

# Gameplay Ability System

GAS's own source is the authority; this skill is a map of it plus the corrections that
tutorials predating UE 5.5 get wrong.

## Before writing any GAS code

**Two failure modes dominate, and both are avoidable by reading first.**

**1. The API moved.** Nearly every GAS tutorial, video, and Stack Overflow answer online
predates UE 5.5. Between 5.3 and 5.8 the plugin deprecated a lot of what those tutorials
teach as current: `AbilityTags` assignment, `EGameplayModOp::Multiplicitive`, every tag
container on `UGameplayEffect`, `NonInstanced` abilities, `NetUpdateFrequency`. Code copied
from them compiles with warnings, or silently reads a deprecated field nothing writes.

→ **Read `references/ue58-deltas.md` first.** It lists what changed with the verified 5.8
replacement. It is the shortest file here and it saves the most time.

**2. Lyra already did it.** Lyra ships an ASC, a base attribute set, a base ability, ability
sets, ASC initialization on both server and client, Mixed replication mode, and native tags.
A tutorial telling you to write `AGDPlayerState::AGDPlayerState()` and call
`CreateDefaultSubobject<UAbilitySystemComponent>` describes work Lyra finished.

→ **Read `references/lyra-notes.md` before adding anything.** It divides the surface into
"Lyra provides", "you subclass", and "you cannot touch".

## Reference files

Load the one that matches the task. They are independent.

| File | Read it when |
|------|--------------|
| `references/ue58-deltas.md` | **Always, first.** What changed from 5.3-era docs, with verified 5.8 replacements |
| `references/lyra-notes.md` | **Always, second.** What Lyra provides vs. what you write; which classes are subclassable |
| `references/attributes.md` | Adding an attribute or attribute set; clamping; reacting to a value change; meta attributes |
| `references/effects.md` | Applying a GE; duration/period/stacking; modifiers; MMC vs ExecCalc; cost and cooldown |
| `references/abilities.md` | Writing an ability; activation policy; instancing; tags; passing data in; canceling |
| `references/tasks-cues.md` | Anything that happens over time; montages; sounds and particles; input release |
| `references/prediction.md` | Multiplayer. What is predicted, what is not, prediction keys, why something fires twice |
| `references/targeting.md` | Target data, target actors, reticles; passing a struct client→server |
| `references/debugging.md` | Something does not fire, does not replicate, fires twice, or you need to see live state |

## The shape of the system

```
   Actor  ──has──>  ASC  ──owns──>  AttributeSets   (float state: Health, Stamina)
                     │              GameplayTags    (boolean state: Stunned, Running)
                     │              GameplayEffects (what changes attributes and tags)
                     │              AbilitySpecs    (what the actor can do)
                     │
   Input ──────────> Ability ──uses──> AbilityTask  (anything spanning >1 frame)
                        │
                        ├──applies──> GameplayEffect ──changes──> Attribute / Tag
                        └──triggers─> GameplayCue    ──plays────> sound, particle, shake
```

Two rules follow from that picture and they explain most GAS design decisions:

**Attributes change through GameplayEffects, not setters.** Only a GE carries a prediction
key, so only a GE can be rolled back when the server disagrees. Calling `SetStamina()`
directly works in single player and desyncs in multiplayer.

**State the game reads is a tag, not a bool.** Tags replicate, abilities can require and
block on them, and effects can grant them. A `bool bIsRunning` on the character does none
of that. See `references/abilities.md` for the ownership rules.

## When something is wrong

Go to `references/debugging.md` — it is organized by symptom, not by feature. `showdebug
abilitysystem` answers "what attributes / tags / effects / abilities do I have right now"
in one keystroke and is almost always faster than adding logs.

Two symptoms worth knowing without opening the file, because their causes are unintuitive:

- **Fires twice on the owning client** → stale prediction key, not duplicate code. See
  `references/prediction.md`.
- **`Can't activate LocalOnly or LocalPredicted ability when not local!`** → the ASC was
  never initialized on the client. In Lyra this means the pawn extension component did not
  run, not that you need to write init code.

## Provenance and verification

Derived from [tranek/GASDocumentation](https://github.com/tranek/GASDocumentation) (MIT), which
documents GAS as of **UE 5.3**, then re-verified against the **UE 5.8** plugin source.

Nothing was carried over on trust. Every API claim was checked against
`Engine/Plugins/Runtime/GameplayAbilities/Source/GameplayAbilities/`, and every claim about Lyra
against `LyraStarterGame/Source/LyraGame/`. Where the source and the original documentation
disagree, the file **says so explicitly** rather than quietly correcting it — the disagreement is
the useful part, because it tells you which tutorials to distrust.

If you are on an engine version other than 5.8, treat `ue58-deltas.md` as a list of things to
re-check rather than as ground truth, and read the plugin source when a claim matters.
