# Adaptive Bootstrap — 5 Phase 상세

CGE 부착 시 발동하는 5단계 적응 워크플로우. 정식 정책: [`core/policies/_bootstrap_policy.md`](../core/policies/_bootstrap_policy.md).

## 시각화

```
[부착 또는 /cge bootstrap]
        │
        ▼
┌───────────────────────┐
│ Phase 0: Discovery    │  자동 — 시그널 카탈로그 기반 스캔
│ - 디렉토리 구조        │
│ - 빌드 매니페스트      │
│ - 언어 분포            │
│ - 문서 발견            │
│ - git 활동             │
└───────────┬───────────┘
            ▼
┌───────────────────────┐
│ Phase 1: Analysis     │  자동 — project-analyst 에이전트
│ - README 정독          │  (LLM이 직접 읽음)
│ - PRD/GDD/RFC 정독     │
│ - 정체성 추출          │
│ - 도메인 분류          │
└───────────┬───────────┘
            ▼
┌───────────────────────┐
│ Phase 2: Mapping      │  자동 — 두 에이전트 병렬
│ ├─ engineering-selector│
│ └─ pack-matcher        │
│ (충돌 시 conflict-resolver)│
└───────────┬───────────┘
            ▼
┌───────────────────────┐
│ Phase 3: Synthesis    │  사용자 검토 (AskUserQuestion)
│ - 권장 자산 표          │
│ - 누락 도메인 큐        │
│ - 정책 매개변수 권장    │
│ - 사용자 결정 ⏸         │
└───────────┬───────────┘
            ▼ (승인)
┌───────────────────────┐
│ Phase 4: Activation   │  installer 에이전트
│ - .claude/ 백업         │
│ - 자산 복사 + 변수 치환 │
│ - profile 저장          │
│ - harness-audit 검증    │
└───────────────────────┘
```

## 모드

| 모드 | Phase 0~3 | Phase 4 |
|------|-----------|---------|
| **첫 부착 (자동)** | 자동 진행 | 사용자 승인 필수 |
| **재실행 (수동)** `/cge rebootstrap` | drift만 감지 | 변경 분 사용자 승인 |
| **수동 모드** `/cge bootstrap --manual` | 단계마다 사용자 확인 | 사용자 승인 |

## Phase 0: Discovery (시그널 카탈로그)

`core/signals/*.json`이 무엇을 보는지 정의:

| 시그널 | 출처 |
|--------|------|
| 언어 분포 | `languages.json` (확장자별 카운트) |
| 빌드 시스템 | `build_systems.json` (uproject/package.json/pyproject.toml/...) |
| 프레임워크 | `frameworks.json` (UE5/React/Django/PyTorch/...) |
| 문서 타입 | `document_types.json` (README/PRD/GDD/RFC/...) |

시그널 카탈로그는 **확장 가능**. 사용자가 자기 시그널 추가 가능.

## Phase 1: Analysis (project-analyst의 정독)

다음 우선순위로 문서 정독:

1. README — 1줄 요약·언어·핵심 주제
2. ARCHITECTURE — 기술 스택·시스템 구조
3. CLAUDE.md — 사용자 컨벤션·기존 결정
4. PRD/GDD — 도메인·우선순위·기능
5. Phase 문서 — 단계적 계획
6. RFC — 설계 결정 이력
7. SESSION_HANDOFF — 직전 세션 상태

추출 결과 → `_project_profile.json` 초안:
- project_type / subtype
- languages / frameworks
- domains_detected (high/medium/optional)
- conventions
- constraints

## Phase 2: Mapping (점수 기반)

### 2a. Engineering Selector
- `compatible_project_types` 호환 검사
- `activation_signals` 매칭 점수
- `exclusive_with` 충돌 검사

### 2b. Pack Matcher
- `activation_criteria.json` 평가:
  - ≥80%: 자동 권장
  - 50~80%: 사용자 질의
  - <50%: 무권장 (조용)

### 누락 도메인 검출
`profile.domains_detected` ∖ `covered_by_packs` = `missing_domains_queue`
→ `_meta/pack-requests.md` 큐 등록

## Phase 3: Synthesis (사용자 검토)

```markdown
# CGE Bootstrap Proposal

## Project Profile
- Type: ${PROJECT_TYPE}
- Domains: ${DOMAINS}

## Recommended Engineerings
- ✅ harness (auto)

## Recommended Packs (≥80%)
- ✅ unreal (95%)
- ✅ game-dev (88%)

## User Decisions (50~80%)
- ⚠️ horror-pack (65%) — Activate? Y/N

## Missing Domains
- payment-team → _meta/pack-requests.md

## Approve? [Y/N/modify]
```

## Phase 4: Activation (installer)

1. `.claude/_backup/<timestamp>/` 자동 백업
2. core 자산 항상 부착
3. 활성 엔지니어링 자산 복사
4. 활성 팩 자산 복사
5. `team-templates/*.md` 변수 치환 후 복사
6. `core/templates/*` → `.claude/`에 부착 (HARNESS·CLAUDE·settings)
7. `_project_profile.json` 저장
8. Change Log 갱신
9. `harness-audit` 검증

## 변수 치환 표

| 변수 | 출처 |
|------|------|
| `${PROJECT_ROOT}` | Phase 0 |
| `${PROJECT_NAME}` | Phase 1 |
| `${LANGUAGE}` | Phase 1 |
| `${BUILD_SYSTEM}` | Phase 1 |
| `${GDD_PATH}` | Phase 1 |
| `${PHASE_DOC_PATH}` | Phase 1 |
| `${MAX_RETRY}` | Phase 3 |
| `${MAX_THINKING_TOKENS}` | Phase 3 |
| `${BOOTSTRAP_TIMESTAMP}` | Phase 4 |
| `${ACTIVE_ENGINEERINGS}` | Phase 4 |
| `${ACTIVE_PACKS}` | Phase 4 |

## 실패 처리

| 단계 | 실패 시 |
|------|---------|
| Phase 0 | 빈 프로젝트 → core만 + 사용자 입력 요청 |
| Phase 1 | 문서 0건 → "프로젝트 컨텍스트 입력 요청" |
| Phase 2 | 매칭 0건 → core only + sync-lessons 권장 |
| Phase 3 | 사용자 거부 → HISTORY 기록 후 종료 |
| Phase 4 | 부착 충돌 → `_backup/`에서 롤백 |
