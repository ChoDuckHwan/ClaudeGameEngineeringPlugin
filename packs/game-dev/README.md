# Game Development Pack

엔진 무관 게임 개발 도메인 자산.

## What

UE/Unity/Custom 어떤 엔진이든 게임 프로젝트에 공통적으로 필요한 자산:
- GDD↔코드 갭 분석
- 진행도 스캔
- Phase 리뷰
- 다음 작업 추천
- 게임 디자인 이론 (MDA·8 kinds of fun)
- 13 도메인 팀 템플릿 (combat / ai / audio / horror / mission / balance / player / interaction / ui / network / animation / skill / 추가)

## When

GDD 문서 또는 게임 엔진 시그널 감지 시 권장 (≥80%).

## Provides

### Skills (10)

**프로젝트 전체 관리 (5)**
- `gap-analysis` — GDD↔구현 갭
- `phase-review` — Phase 완료 조건 점검
- `progress-check` — 시스템별 진행도
- `next-task` — 우선순위 작업 추천
- `game-design-core` — 디자인 이론

**레벨 단위 관리 (5, v1.1.0 신규)**
- `level-init <Name>` — 표준 템플릿으로 레벨 마스터 문서 신규 생성
- `level-status [Name]` — 전체/단일 레벨 진행도 조회
- `level-update <Name> "보고"` — 사용자 작업 결과 체크리스트 갱신
- `level-next [Name]` — 다음 우선 작업 추천 (의존성 그래프 + Cross-Team)
- `level-review <Name>` — Phase 완료 게이트 검토

### Templates (1)
- `_LEVEL_TEMPLATE.md` — 13 섹션 레벨 마스터 문서 표준 (시설/모듈/몬스터/인터랙션/진행도)

### Team Templates (13)
각 도메인의 README.md 템플릿. teammaker가 부착 후 사용자 프로젝트에 맞게 단계 에이전트를 생성.

부착 시 `.claude/team/<도메인>/README.md`로 변수 치환 후 복사:
- `${PROJECT_NAME}` ← 사용자 프로젝트 이름
- `${GDD_PATH}` ← 사용자 GDD 위치
- `${MAX_RETRY}` ← 정책 매개변수

## 의존성

`harness` 엔지니어링 활성 필요.

## 활성화 시그널

| 조건 | 점수 |
|------|------|
| GDD*.md 존재 | 30 |
| 하위 디렉토리에 GDD | 30 |
| README/docs에 "game design" | 20 |
| Content/ 디렉토리 | 10 |
| UE5 프레임워크 | 15 |
| Unity 프레임워크 | 15 |
| Phase*.md | 10 |

## 사용 예시

### 프로젝트 전체
```
/progress-check    # 시스템별 완성도 매트릭스
/gap-analysis      # GDD↔코드 차이
/next-task         # 다음 작업
/phase-review      # Phase 완료 점검
```

### 레벨 단위 워크플로우 (v1.1.0)
```
# 1. 새 레벨 작업 시작
/level-init UnderwaterFacility
   → .claude/Scenarios/UnderwaterFacility.md 자동 생성
   → background.md / GDD_05 / huddle.md / GDD_04 에서 시설 정보 자동 추출

# 2. 작업 중 진행도 조회
/level-status                     # 9개 레벨 전체 진행도 표
/level-status UnderwaterFacility   # 특정 레벨 Phase A~G 상세

# 3. 작업 완료 보고
/level-update UnderwaterFacility "A2 완료, A3 진행 중"
   → 체크박스 자동 갱신, 변경 이력 1행 추가

# 4. 다음 작업 추천
/level-next UnderwaterFacility
   → 의존성 그래프 + 블로커 + Cross-Team 호출 권장

# 5. Phase 완료 게이트
/level-review UnderwaterFacility
   → 정량/정성/품질/합의 4개 기준 검토 → 다음 Phase 진입 판정
```

### 레벨 단위 관리 핵심 메커니즘

- **마스터 문서**: `.claude/Scenarios/{LevelName}.md` (단일 진실의 원천)
- **표준 13 섹션**: 시설/시나리오/모듈/메카닉/몬스터/인터랙션/공포/유혹/보스/진행도/협업/이력/다음행동
- **Phase A~G**: 시나리오 → Fab 에셋 → 모듈 → 몬스터 → 인터랙션 → Director → 검증
- **진행도 표기**: `[ ]` 미시작 / `[~]` 진행중 / `[x]` 완료 / `[!]` 블로커
- **Cross-Team 자동 추천**: Phase 진입 시점에 ai/animation/horror/balance/mission 팀 호출 권장
- **mission 팀 11번 에이전트**: `mission-level-orchestrator` 가 메타 운영 (`team-templates/mission-11-level-orchestrator.md`)

## 13 도메인 팀

각 팀은 표준 10단계 워크플로우 (01_design_concretizer → ... → 10_feature_activator) 또는 변형.

| 도메인 | 핵심 |
|--------|------|
| combat | 전투 (무기·어빌리티·데미지) |
| ai | 몬스터·NPC AI |
| audio | 사운드 큐·믹스 |
| horror | 공포 연출·라이팅·점프스케어 |
| mission | 의뢰 흐름·Experience |
| balance | 수치 튜닝 |
| player | 캐릭터·장비·인벤토리 |
| interaction | 상호작용·픽업·장애물 |
| ui | HUD·MVVM·CommonUI |
| network | 멀티플레이어·세션 |
| animation | 몽타주·StateMachine·IK |
| skill | 메타 (.claude/skills 관리) |

각 README.md 템플릿은 변수화되어 있어 신규 프로젝트에서 즉시 활용 가능.
