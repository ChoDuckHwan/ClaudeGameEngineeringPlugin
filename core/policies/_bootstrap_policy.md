# Bootstrap Policy — 5 Phase 표준

플러그인 부착 시 또는 `/cge bootstrap` 호출 시 발동하는 적응 워크플로우.

## 모드

| 시점 | Phase 0~3 | Phase 4 (Activation) |
|------|-----------|----------------------|
| **첫 부착** (자동 모드) | 자동 | 사용자 승인 필수 |
| **재실행** (`/cge rebootstrap`) | 자동 | drift만 감지, 변경 사용자 승인 |
| **수동 호출** (`/cge bootstrap --manual`) | 단계마다 사용자 확인 | 사용자 승인 |

## Phase 0 · Discovery

목적: 프로젝트 구조·자산·이력을 자동 감지.

### 감지 항목

| 카테고리 | 검사 방법 | 출처 |
|----------|-----------|------|
| 디렉토리 | `Glob` | `core/signals/build_systems.json` |
| 빌드 매니페스트 | `Glob` | uproject/package.json/pyproject.toml/Cargo.toml/CMakeLists.txt/Makefile |
| 언어 분포 | `Glob` 확장자별 카운트 | `core/signals/languages.json` |
| 프레임워크 | manifest 의존성 분석 | `core/signals/frameworks.json` |
| 기획·문서 | `Glob` | `core/signals/document_types.json` |
| 기존 `.claude/` | `Glob`+`Read` | 충돌 방지 |
| git 활동 | `git log --stat` | 최근 30 커밋 |

### 출력
`Discovery Report` (사용자에게 출력 X, 다음 Phase 입력으로만 사용)

## Phase 1 · Analysis

목적: 메타-에이전트가 기획·문서를 정독해 프로젝트 정체성 파악.

### 절차
1. `project-analyst` 에이전트 호출
2. Phase 0 결과 + 감지된 README/PRD/GDD/RFC/ARCHITECTURE 문서 입력
3. 출력: `_project_profile.json` 초안

### `_project_profile.json` 추출 항목

```json
{
  "project_type": "<game|web|cli|library|research|ml>",
  "subtype": "<co-op-horror|saas-backend|...>",
  "languages": ["cpp", "blueprint"],
  "frameworks": ["UE5", "GAS"],
  "build_system": "uproject",

  "domains_detected": ["combat", "ui", "interaction", "audio", "ai"],
  "domains_high_priority": ["combat", "interaction"],
  "domains_optional": ["audio"],

  "conventions": {
    "naming": "FIB prefix",
    "language_style": "Korean comments allowed",
    "test_policy": "RuntimeTests + Functional"
  },

  "constraints": {
    "realtime": true,
    "multiplayer": "listen-server",
    "platform": ["Win64"]
  },

  "team_size": 1,
  "stage": "active-development",

  "existing_claude_assets": {
    "skills": [],
    "agents": [],
    "teams": []
  }
}
```

## Phase 2 · Mapping

목적: 활성화할 자산 결정.

### 2a. Engineering Selector
1. `engineerings/*/engineering.json` 읽기
2. 각 엔지니어링의 `activation_signals` vs Phase 0 시그널 매칭
3. `compatible_project_types`로 필터
4. `exclusive_with` 충돌 검사 → `conflict-resolver` 에이전트
5. 출력: 활성 엔지니어링 후보 목록

### 2b. Pack Matcher
1. `packs/*/activation_criteria.json` 읽기
2. 각 팩에 점수 매김 (Phase 0 시그널 기반)
3. ≥80%: 자동 권장 / 50~80%: 사용자 질의 / <50%: 무권장
4. 출력: 팩 후보 + confidence

## Phase 3 · Synthesis

목적: 사용자에게 제안서 + 검토.

### 제안서 형식

```markdown
# CGE Bootstrap Proposal — <project-name>

## Project Profile
- Type: <type>
- Domains: <list>
- Stage: <stage>

## Recommended Engineerings
- ✅ harness (auto: always-on)
- ⏳ ecc (suggested — TS/Python detected)

## Recommended Packs (≥80%)
- ✅ unreal (95%) — *.uproject + GameplayAbilities
- ✅ game-dev (88%) — GDD documents + game project type

## User Decisions Required (50~80%)
- ⚠️ horror-direction-pack (65%) — keyword matched but uncertain
  → Activate? Y/N

## Missing Domains (no matching pack)
- payment-team — would queue to _meta/pack-requests.md
- voice-chat-team — same

## Policy Recommendations
- max_retry: 2 (default)
- max_thinking_tokens: 10000 (complex domain)

## Conflicts
(none)

## Approve? [Y/N/modify]
```

### 사용자 입력
`AskUserQuestion`으로 결정 받음.

## Phase 4 · Activation

목적: 승인된 자산을 `.claude/`에 부착.

### 절차 (`installer` 에이전트)
1. core 자산 항상 부착
2. 승인 엔지니어링 → `.claude/`에 복사 또는 심볼릭 링크
3. 승인 팩 → 동일
4. 활성 엔지니어링의 정책(`_patterns.md` 등) → `.claude/team/`로 복사
5. 활성 팩의 `team-templates/` → `.claude/team/<도메인>/README.md`로 변수 치환 후 복사
6. `core/templates/` → `.claude/`에 부착 (`HARNESS.md`, `CLAUDE.md` 골격, `settings.local.json`)
7. `.claude/_project_profile.json` 저장
8. 누락 도메인 → `_meta/pack-requests.md` 큐 등록
9. 첫 `harness-audit` 실행 → 부착 결과 검증

### 부착 후 출력
```
✅ CGE Bootstrap Complete

Active engineerings: harness
Active packs: unreal, game-dev
Active skills: 22 (.claude/skills/)
Active agents: 8 (.claude/agents/)
Active teams: 13 (.claude/team/)

Next steps:
- /harness-audit         (정합성 점검)
- /progress-check         (현재 진행도)
- /next-task              (다음 작업 추천)
```

## 변수 치환 표

`team-templates/`의 README.md에 사용된 변수가 부착 시 다음으로 치환:

| 변수 | 출처 | 예 |
|------|------|-----|
| `${PROJECT_ROOT}` | Phase 0 | `i:\FixItBots\ProjectFIB` |
| `${PROJECT_NAME}` | Phase 1 | `ProjectFIB` |
| `${LANGUAGE}` | Phase 1 | `cpp` |
| `${BUILD_SYSTEM}` | Phase 1 | `uproject` |
| `${GDD_PATH}` | Phase 1 | `.claude/GDD_*.md` |
| `${PHASE_DOC_PATH}` | Phase 1 | `.claude/Phase*.md` |
| `${MAX_RETRY}` | Phase 3 | `2` |
| `${MAX_THINKING_TOKENS}` | Phase 3 | `10000` |

## 실패 처리

| 단계 | 실패 시 |
|------|---------|
| Phase 0 | 빈 디렉토리면 `_meta/pack-requests.md`에 "blank project" 등록 후 core만 활성 |
| Phase 1 | 문서 0건이면 사용자에게 "프로젝트 컨텍스트 입력 요청" |
| Phase 2 | 매칭 0건 → core만 활성 + sync-lessons 권장 |
| Phase 3 | 사용자 거부 → `_meta/HISTORY.md`에 사유 기록, 종료 |
| Phase 4 | 부착 충돌 → rollback (이전 `.claude/` 백업 복원) |
