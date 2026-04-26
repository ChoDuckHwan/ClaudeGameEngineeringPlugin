# AI Team — 몬스터/악령 AI 구현 팀

ProjectFIB 의 AI 시스템(Spirit 상태머신, 일반 몬스터 행동, Perception, StateTree, 인카운터 매니지먼트, 네트워크 권한)을 기획 구체화부터 구현·검증·테스트까지 책임지는 팀입니다.

## Pattern (Tier 2 #2)

- **Primary**: Pipeline (01 → 02 → 04)
- **Producer-Reviewer**: 04 ↔ 07 (max_retry=2, [`_retry_policy.md`](../_retry_policy.md))
- **Parallelizable Stages**: `[06, 07, 08]` 변경 리포트·검증·테스트 동일 코드에 독립
- **Mode**: **Hybrid** — 04~07 구현/검증 루프는 Sub-agent, 06+07+08 병렬 단계는 Agent Team
- **Reference**: [`_patterns.md`](../_patterns.md)

## 팀 구성

| # | 역할 | 에이전트 | 모델 | 핵심 업무 |
|---|------|---------|------|----------|
| 01 | 기획 구체화 | `ai-design-concretizer` | opus | GDD_04/05, Phase2/3 → AI 기술 사양서 |
| 02 | 아키텍트 | `ai-architect` | opus | AIController/StateTree/Perception/Component 클래스 설계 |
| 03 | 구조 설명 | `ai-structure-explainer` | opus | Perception→Decision→Action 루프, 상태 전이 다이어그램 |
| 04 | 기능 구현 | `ai-feature-implementer` | opus | StateTree/AIController/Perception/Spirit 상태머신 C++ 구현 |
| 05 | 기능 개선 | `ai-feature-improver` | opus | Tick 비용, Perception 캐시, 네트워크 RPC 빈도 최적화 |
| 06 | 변경 리포트 | `ai-change-reporter` | sonnet | 변경 파일/클래스/AI 행동 사이드 이펙트 보고 |
| 07 | 검증원 | `ai-verifier` | opus | 권한 분리, StateTree 무한루프, NavMesh, 메모리 누수 검증 |
| 08 | 테스터 | `ai-tester` | opus | 인카운터 시나리오, 1-4인 스케일링, 스트레스 테스트 |
| 09 | 히스토리 | `ai-history` | sonnet | 활동 이력, AI 튜닝 교훈, 실패 패턴 축적 |
| 10 | 기능 활성화 | `ai-feature-activator` | opus | 사용자 적용 가이드(에디터 단계, BP/StateTree 생성, 콘솔 테스트), 텍스트 설정 자동 적용, 롤백 절차 |

## 워크플로우

```
기획 문서 (GDD_04 악령, GDD_05 몬스터, Phase2/3, background.md)
    │
    ▼
[01 기획 구체화] ─── AI 기술 사양서 ───▶ [02 아키텍트] ─── 클래스/StateTree 설계 ───┐
                                                                                       │
                                          ┌────────────────────────────────────────────┘
                                          ▼
                                    [04 기능 구현] ─── C++/StateTree/BB ──────────┐
                                          │                                       │
                                          ▼                                       ▼
                                    [06 변경 리포트]                         [07 검증원]
                                          │                                       │
                                          ▼                                       ▼
                                    사용자에게 보고                          [08 테스터]
                                                                                  │
                                                                                  ▼
                                                                      인카운터 테스트 리포트
                                                                                  │
                                          ┌───────────────────────────────────────┘
                                          ▼
                                    [05 기능 개선] (필요 시 — 튜닝 루프)
                                          │
                                          ▼
                                    [03 구조 설명] (요청 시)
                                          │
                                          ▼
                                    [10 기능 활성화] ─── 사용자 적용 가이드 ──┐
                                          │                                   │
                                          ▼                                   ▼
                                    [09 히스토리] 활동/교훈 누적         사용자가 게임에서 체험
```

## 사용 예시

### 새 몬스터 구현 전체 프로세스
```
1. "Crawler 몬스터 기획을 구체화해줘"             → 01_ai_design_concretizer
2. "Crawler AIController/StateTree 구조 설계해줘"  → 02_ai_architect
3. "Crawler 코드 구현해줘"                         → 04_ai_feature_implementer
4. "변경된 코드를 정리해줘"                        → 06_ai_change_reporter
5. "AI 동작을 검증해줘"                            → 07_ai_verifier
6. "1-4인 인카운터 시나리오 테스트해줘"             → 08_ai_tester
7. "Perception 비용을 줄여줘"                      → 05_ai_feature_improver
8. "Crawler 를 게임에 적용하는 방법 알려줘"          → 10_ai_feature_activator
```

### 악령 시스템 개선
```
"Spirit 상태머신 구조를 설명해줘"                  → 03_ai_structure_explainer
"FIBSpiritStateComponent 코드를 검증해줘"          → 07_ai_verifier
"악령 등장 빈도 튜닝 결과를 기록해줘"               → 09_ai_history
```

## Cross-Team 협업 지점

- **combat 팀과**: 몬스터의 공격 어빌리티, 데미지 어트리뷰트 — combat 팀이 어빌리티/이펙트, AI 팀이 활성화 조건/타이밍
- **interaction 팀과**: Spirit 봉인 상호작용, 함정형 장애물의 AI 트리거 — interaction 팀이 인터랙션 면, AI 팀이 반응 행동
- **teammaker 팀과**: AI 팀 자체 확장은 teammaker 가 감사

## Dry-Run

이 팀은 **실행 전 계획 미리보기**를 지원한다.

- 호출 예: `"ai 팀 dry-run으로 [몬스터/AI 작업] 계획 보여줘"`
- 표준 출력: [`_patterns.md` Dry-Run 모드](../_patterns.md#dry-run-모드-표준-tier-2-4)
- 권장 사용 시점:
  1. 신규 몬스터 첫 구현 (StateTree·Perception·NavMesh 의존 확인)
  2. Spirit 상태머신 변경 (1-4인 인카운터 영향 범위)

## 관련 문서

- [GDD_04_악령.md](../../GDD_04_악령.md) — 악령 컨셉/상태/약점
- [GDD_05_몬스터.md](../../GDD_05_몬스터.md) — 일반 몬스터 사양
- [GDD_08B_밸런스_몬스터.md](../../GDD_08B_밸런스_몬스터.md) — AI 밸런스
- [FixItBots_Phase2_악령.md](../../FixItBots_Phase2_악령.md) — Spirit 시스템 구현 가이드
- [FixItBots_Phase3_일반몬스터.md](../../FixItBots_Phase3_일반몬스터.md) — 몬스터 구현 가이드
- [agents/gas-ability-developer.md](../../agents/gas-ability-developer.md) — 어빌리티 협업
- [team/combat/](../combat/) — 전투 팀 (cross-team 파이프라인)

## 핵심 원칙

1. **서버 권한 절대 원칙**: 모든 AI 결정은 서버에서. 클라이언트는 시각화만.
2. **Tick 최소화**: Perception/StateTree는 인터벌·이벤트 기반. 매 프레임 Tick 금지
3. **코옵 스케일링**: 모든 AI는 플레이어 수(1-4)에 따라 어그로/스폰/난이도가 자동 조정
4. **상태머신 명시성**: Spirit 5상태(Sealed/Awakening/Active/Retreated/Defeated) 같은 명시적 게이트웨이 사용. 암묵적 상태 금지
5. **NavMesh 안전**: 모든 Move 전 NavMesh 도달성 검증. 경로 없으면 fallback 행동
6. **테스트는 1인+4인 양쪽**: 솔로에서만 동작하고 4인에서 깨지는 패턴 금지
