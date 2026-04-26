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

### Skills (5)
- `gap-analysis` — GDD↔구현 갭
- `phase-review` — Phase 완료 조건 점검
- `progress-check` — 시스템별 진행도
- `next-task` — 우선순위 작업 추천
- `game-design-core` — 디자인 이론

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

```
/progress-check    # 시스템별 완성도 매트릭스
/gap-analysis      # GDD↔코드 차이
/next-task         # 다음 작업
/phase-review      # Phase 완료 점검
```

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
