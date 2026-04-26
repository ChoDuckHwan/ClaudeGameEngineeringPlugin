# Balance Team — 밸런스/수치 튜닝 팀

ProjectFIB 의 모든 수치 밸런스(아이템 스탯, 무기/도구/방어구, 몬스터 HP/데미지, 허들 난이도, 미션 보상, 경제 커브, 상성 매트릭스, DataTable/CurveTable)를 책임지는 팀입니다. 단일 도메인 코드 작성보다 *데이터 튜닝과 곡선 설계*에 특화.

## Pattern (Tier 2 #2)

- **Primary**: Pipeline (01 → 02 → 04)
- **Producer-Reviewer**: 04 ↔ 07 (**max_retry=3** — 수치 미세 조정 반복 필요, [`_retry_policy.md`](../_retry_policy.md) 오버라이드)
- **Parallelizable Stages**: `[06, 07, 08]` — 수치 검증·시뮬레이션 동시 가능
- **Mode**: **Hybrid** — 시뮬레이션(08)이 무거움 → 단독 호출 시 Sub-agent, 풀 사이클 시 Agent Team
- **Reference**: [`_patterns.md`](../_patterns.md)

## 팀 구성

| # | 역할 | 에이전트 | 모델 | 핵심 업무 |
|---|------|---------|------|----------|
| 01 | 기획 구체화 | `balance-design-concretizer` | opus | GDD_08A/B/C → 수치 표·곡선 사양서 |
| 02 | 아키텍트 | `balance-architect` | opus | DataTable / CurveTable 구조 설계, AttributeSet 기본값 매트릭스 |
| 03 | 구조 설명 | `balance-structure-explainer` | opus | 데미지 공식·진행 곡선·상성 매트릭스 다이어그램 |
| 04 | 기능 구현 | `balance-feature-implementer` | opus | DataTable 행 작성, CurveTable 작성, AttributeSet 기본값/Modifier 구현 |
| 05 | 기능 개선 | `balance-feature-improver` | opus | 플레이테스트 데이터 기반 수치 재조정, Outlier 제거 |
| 06 | 변경 리포트 | `balance-change-reporter` | sonnet | 수치 변경 전후 비교 표, 영향 범위 정리 |
| 07 | 검증원 | `balance-verifier` | opus | 수학적 정합성, DPS 계산, 상성 무한루프, 무게 한도 일관성 검증 |
| 08 | 테스터 | `balance-tester` | opus | 시뮬레이션 (Python/스프레드시트), 1-4인 시간 측정, TTK/TTD |
| 09 | 히스토리 | `balance-history` | sonnet | 튜닝 이력, 플레이테스트 피드백, 메타 변화 누적 |
| 10 | 기능 활성화 | `balance-feature-activator` | opus | DataTable/CurveTable 에셋 작성, AttributeSet 기본값 적용, 인게임 검증 |

## 워크플로우

```
기획 (GDD_08A 아이템, GDD_08B 몬스터, GDD_08C 허들/미션/공포)
    │
    ▼
[01]→[02]→[04]→[06]+[07]+[08(시뮬레이션)] ─▶ [05]→[03] ─▶ [10]→[09]
```

## Cross-Team 협업

- **player 팀**: PlayerVitalsSet 기본값, Stamina/Sanity 곡선
- **combat 팀**: 무기 데미지, 쿨다운, 스태미나 비용
- **ai 팀**: 몬스터 HP/속도/공격 빈도
- **interaction 팀**: 허들 난이도 (HitCount, UnsealDuration)
- **mission 팀**: 의뢰 보상, 정산 곡선, 등급별 난이도
- **horror-direction 팀** (향후): 공포 강도 곡선

## 핵심 원칙

1. **데이터 우선**: 코드 매직 넘버 금지. 모든 수치는 DataTable/CurveTable/AttributeSet 기본값
2. **수학적 검증**: 모든 변경은 DPS/TTK/EHP 계산식으로 검증
3. **플레이테스트 → 데이터 → 튜닝 사이클**: 추측 금지, 측정값 기반
4. **상성 명시**: 약점 / 내성 / 무효 매트릭스를 표로 유지
5. **외부 도구 OK**: 시뮬레이션은 Python/스프레드시트 활용 가능
6. **GDD_08* 동기화**: 수치 변경 시 GDD 문서도 함께 갱신 권장

## Dry-Run

이 팀은 **실행 전 계획 미리보기**를 지원한다.

- 호출 예: `"balance 팀 dry-run으로 [수치 튜닝] 계획 보여줘"`
- 표준 출력: [`_patterns.md` Dry-Run 모드](../_patterns.md#dry-run-모드-표준-tier-2-4)
- 권장 사용 시점:
  1. 광범위 수치 재조정 (시뮬레이션 단계 비용 큼 — 사전 점검 필수)
  2. 상성 매트릭스 개편 (cross-team 영향 큼: combat/ai/player)

## 관련 문서

- [GDD_08A_밸런스_아이템.md](../../GDD_08A_밸런스_아이템.md)
- [GDD_08B_밸런스_몬스터.md](../../GDD_08B_밸런스_몬스터.md)
- [GDD_08C_밸런스_허들_미션_공포.md](../../GDD_08C_밸런스_허들_미션_공포.md)
- [GDD_10_기술매핑.md](../../GDD_10_기술매핑.md)
- 기존 단발: `agents/game-balance-designer.md`
