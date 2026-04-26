# Claude Game Engineering Plugin (CGE)

> A **meta-agent plugin** that reads each project and reconfigures itself.
> Harness Engineering is just the **first installed engineering slot** inside it.

English · [한국어](README.md)

---

## What's Different

Existing harness plugins (Harness, ECC, Archon) provide **fixed workflows and assets**. CGE is different:

1. **Analyzes projects on attach** — reads directories, docs, and git to identify project type, domains, priorities
2. **Engineering as plugin slot** — `engineerings/<name>/` modular slots; add, remove, swap freely
3. **Accumulates user know-how** — pattern mining produces new engineering candidates over time
4. **Claude Code plugin compliant** — `/plugin install` compatible

## Structure at a Glance

```
core/         — Meta-agents (engineering-agnostic)
engineerings/ — Engineering slots (harness, ecc, archon, _user/...)
packs/        — Domain packs (unreal, game-dev, web, python, ...)
docs/         — Philosophy, 5 Phases, extension guide
_meta/        — Plugin's own learning loop
```

## Quick Start

```bash
# 1. Install via Claude Code marketplace
/plugin install ClaudeGameEngineeringPlugin@ChoDuckHwan

# 2. Attach to project (auto 5-Phase Bootstrap)
/cge bootstrap

# 3. List active assets
/cge list
```

## 5-Phase Bootstrap

```
Phase 0: Discovery     → Auto-detect dirs, manifests, docs
Phase 1: Analysis      → project-analyst reads plans → profile
Phase 2: Mapping       → Decide which engineerings/packs to activate
Phase 3: Synthesis     → Present proposal + user review
Phase 4: Activation    → Attach only approved assets to .claude/
```

## Lifecycle Commands

```bash
/cge install engineering harness
/cge install pack unreal
/cge install skill <git-url>
/cge uninstall engineering harness
/cge replace engineering harness@1.0 with harness@2.0
/cge list
/cge mine-pattern
/cge sync-lessons
```

## First Engineering: harness

Extracted from ProjectFIB (UE5 co-op horror game). Includes 6 design patterns (Pipeline / Fan-out·Fan-in / Expert Pool / Producer-Reviewer / Supervisor / Hierarchical Delegation), retry caps, self-improvement policy, token optimization policy.

Details: [engineerings/harness/README.md](engineerings/harness/README.md)

## License

MIT (Apache 2.0 attribution where revfactory/harness patterns absorbed)

## Contributing

PRs for new engineerings/packs welcome. See [docs/engineering-slot-guide.md](docs/engineering-slot-guide.md).
