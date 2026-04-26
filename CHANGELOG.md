# Changelog

본 플러그인 자체의 골격·자산 변경 이력. 사용자 프로젝트의 변경은 각 프로젝트의 `CLAUDE.md ## Change Log`로.

## [Unreleased] — W12 전 수정

### Added
- `engineerings/_user/README.md` + `packs/_user/README.md` — 사용자 자작 자산 격리 영역 가이드
- `CONTRIBUTING.md` — 7 종 기여 종류 + PR 형식 + 명명 규칙

### Changed
- `plugin.json` — `_user/` 디렉토리를 components에 등록, schema URL placeholder 명시 (v2 공식 스펙 확정 시 갱신)
- `plugin.json` — contributing/changelog 필드 추가

### Skeleton Files (W1~W11)
- Repo 골격 (`core/`, `engineerings/`, `packs/`, `docs/`, `_meta/`, `.claude-plugin/`)
- README.md / README_EN.md / LICENSE / INSTALL.md / .gitignore
- core/ — 8 skills + 5 agents + 3 policies + 4 signals + 6 hooks + 5 templates
- engineerings/harness/ — 10 skills + 3 agents + 4 policies + teammaker(9) + 4 docs + engineering.json
- packs/unreal/ — 6 skills + 5 agents + manifest + activation_criteria + post-edit-map
- packs/game-dev/ — 5 skills + 13 team templates + manifest
- docs/ — 8 문서 (philosophy, bootstrap, slot guides, lifecycle, ecosystem, extending, projectfib)
- _meta/ — 6 파일 (HISTORY, adopters, lessons, pack-requests, engineering-requests, promotions)
- .claude-plugin/plugin.json — Claude Code 마켓플레이스 호환 매니페스트

## [1.0.0] — TBD (W14 push 시점)

### Added
- Core meta-agent (project-analyst, engineering-selector, pack-matcher, conflict-resolver, installer)
- Core meta-skills (cge-bootstrap, rebootstrap, install, uninstall, replace, list, mine-pattern, sync-lessons)
- 5-Phase Bootstrap 워크플로우
- Slot 스펙 (`engineering.json`, `pack.json`)
- 첫 엔지니어링: harness (ProjectFIB 추출)
- 첫 팩: unreal, game-dev
- 일반화된 훅 (Stop / UserPromptSubmit / PostToolUse)
- 사용자 노하우 누적 메커니즘 (`_meta/lessons.md`, `engineering-requests.md`)
