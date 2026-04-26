# Combat Team — 전투 시스템 구현 팀

ProjectFIB 의 전투 시스템(무기, 어빌리티, 데미지 계산, 어트리뷰트, 전투 AI 패턴, 협동 전투)을 기획 구체화부터 구현·검증·테스트·활성화까지 책임지는 팀입니다.

## Pattern (Tier 2 #2)

- **Primary**: Pipeline (01 → 02 → 03 → 04 → 05)
- **Producer-Reviewer**: 05 ↔ 08 (max_retry=2, [`_retry_policy.md`](../_retry_policy.md))
- **Parallelizable Stages**: `[06, 07, 08, 09]` 4-way Fan-out — 변경/재미/코드/버그 검증 동일 코드에 독립 실행
- **Mode**: **Agent Team** — 4-way 병렬 검증 시 발견 공유 필수, 가장 강한 Fan-out 패턴 도메인
- **Reference**: [`_patterns.md`](../_patterns.md)

## 팀 구성

| # | 역할 | 에이전트 | 모델 | 핵심 업무 |
|---|------|---------|------|----------|
| 01 | 기획 구체화 | `combat-design-concretizer` | opus | GDD 시리즈 → 전투 기술 사양서 |
| 02 | 학습 가이드 | `combat-learning-guide` | opus | 학습 자료, 참조 문서, 사전 학습 |
| 03 | 주의사항 어드바이저 | `combat-caution-advisor` | opus | 함정·실수 패턴 사전 경고 |
| 04 | 아키텍트 | `combat-architect` | opus | 클래스 구조, AbilitySet 설계 |
| 05 | 구현자 | `combat-implementer` | opus | C++ 구현 |
| 06 | 변경 리포터 | `combat-change-reporter` | sonnet | 변경 파일/클래스 정리 |
| 07 | 재미 검증 | `combat-fun-validator` | opus | 전투감/플레이 재미 측면 검증 |
| 08 | 코드 검증 | `combat-code-verifier` | opus | 네트워크/GAS/메모리/표준 검증 |
| 09 | 버그 테스터 | `combat-bug-tester` | opus | 버그 재현, 회귀 테스트, 1-4인 |
| 10 | 히스토리 | `combat-history` | sonnet | 활동 이력, 밸런스 튜닝 누적 |
| 11 | 기능 활성화 | `combat-feature-activator` | opus | 사용자 적용 가이드(Ability/Effect BP, AbilitySet, Input, AnimMontage), 밸런스 튜닝 위치 안내, 텍스트 설정 자동 적용 |

## 워크플로우

```
기획 문서 (GDD_03/04/05/08B, huddle.md)
    │
    ▼
[01 구체화] ─▶ [02 학습] ─▶ [03 주의사항] ─▶ [04 아키텍트] ─▶ [05 구현]
                                                                │
                  ┌─────────────────────────────────────────────┤
                  ▼              ▼              ▼               ▼
            [06 리포트]   [07 재미 검증]   [08 코드 검증]   [09 버그 테스트]
                  │              │              │               │
                  └──────────────┴──────────────┴───────────────┘
                                                                ▼
                                                      [11 기능 활성화]
                                                                │
                                                                ▼
                                                          사용자 체험
                                                                │
                                                                ▼
                                                       [10 히스토리]
```

## Cross-Team 협업 지점

- **ai 팀**: 몬스터 공격 어빌리티 발동 조건은 AI 팀, 데미지/이펙트는 combat
- **interaction 팀**: 무기로 장애물 파괴 (Barricade) — 어빌리티는 combat, 인터랙션 매칭은 interaction

## 사용 예시

### 신규 무기 전체 프로세스
```
1. "차지 어택 기획 구체화"           → 01
2. "차지 어택 클래스 설계"           → 04
3. "차지 어택 구현"                  → 05
4. "변경 정리"                       → 06
5. "재미 검증"                       → 07
6. "코드 검증"                       → 08
7. "1-4인 버그 테스트"               → 09
8. "차지 어택 게임 적용 가이드"       → 11
```

## Dry-Run

이 팀은 **실행 전 계획 미리보기**를 지원한다.

- 호출 예: `"combat 팀 dry-run으로 [전투 작업] 계획 보여줘"`
- 표준 출력: [`_patterns.md` Dry-Run 모드](../_patterns.md#dry-run-모드-표준-tier-2-4)
- 권장 사용 시점:
  1. 신규 무기/어빌리티 풀 사이클 (4-way Fan-out 비용 가장 큼)
  2. cross-team 협업 (ai/animation 영향)

## 관련 문서

- [GDD_03_플레이어.md](../../GDD_03_플레이어.md)
- [GDD_08B_밸런스_몬스터.md](../../GDD_08B_밸런스_몬스터.md)
- [agents/gas-ability-developer.md](../../agents/gas-ability-developer.md)
- [agents/game-balance-designer.md](../../agents/game-balance-designer.md)
