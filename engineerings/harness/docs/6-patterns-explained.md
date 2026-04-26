# 6 Design Patterns Explained

Harness 엔지니어링의 6 디자인 패턴 상세. 정식 정의는 [`policies/_patterns.md`](../policies/_patterns.md) 참조.

## 결정 트리

```
질문 1: 단계가 이전 단계 산출물에 강하게 의존하는가?
   └─ 예 → ① Pipeline
   └─ 아니오 ↓

질문 2: 같은 입력에 대해 여러 관점/영역의 분석이 필요한가?
   └─ 예 → ② Fan-out/Fan-in
   └─ 아니오 ↓

질문 3: 입력 유형에 따라 다른 처리가 필요한가?
   └─ 예 → ③ Expert Pool (라우터)
   └─ 아니오 ↓

질문 4: 산출물 품질을 객관적으로 검증해야 하고, 재작업 루프가 필요한가?
   └─ 예 → ④ Producer-Reviewer
   └─ 아니오 ↓

질문 5: 작업량이 가변적이고 런타임에 분배가 결정되는가?
   └─ 예 → ⑤ Supervisor
   └─ 아니오 ↓

질문 6: 문제가 자연스럽게 계층적으로 분해되는가? (깊이 ≤2)
   └─ 예 → ⑥ Hierarchical Delegation
   └─ 아니오 → 다시 ① Pipeline 검토
```

## 패턴별 1줄 요약

| # | 패턴 | 1줄 |
|---|------|-----|
| ① | Pipeline | 순차 의존 — 단순하고 추적 용이 |
| ② | Fan-out/Fan-in | 같은 입력 → 여러 관점 → 통합 |
| ③ | Expert Pool | 라우터가 적합한 전문가 1~2개 선택 |
| ④ | Producer-Reviewer | 생성↔검증 루프 + max_retry 캡 |
| ⑤ | Supervisor | 중앙 감독자가 워커에 동적 분배 |
| ⑥ | Hierarchical Delegation | 계층 위임 (깊이 ≤2 강제) |

## 적용 매트릭스 (도메인 종류별 추천)

| 도메인 종류 | 1순위 | 2순위 |
|-------------|-------|-------|
| 일반 구현 | Pipeline | Producer-Reviewer |
| 복합 검증 (보안+성능+코드) | Fan-out | Pipeline |
| 모호한 요청 분배 | Expert Pool | — |
| 풀 사이클 구현+검증 | Pipeline + Producer-Reviewer | Fan-out |
| Phase 분배 | Supervisor | Pipeline |
| 메타팀 → 도메인팀 | Hierarchical (D≤2) | — |

## 패턴 결합

같은 도메인이 여러 패턴을 동시 사용 가능:
- combat 팀: Pipeline (01→05) + Fan-out (06,07,08,09) + Producer-Reviewer (05↔08)
- mission 팀: Pipeline + Supervisor (Phase 분배 시)
- teammaker: Hierarchical (D1) + Producer-Reviewer (04↔06)

## 비추천 조합

- ⑥ + ⑥ 중첩 (D3+) — 깊이 폭증, exclusive
- ⑤ supervisor가 또 ⑤ — 감독자 트리, 비효율
- ④ Producer-Reviewer 무한 루프 — max_retry 미설정 시 위험

## 외부 영감

6 패턴 분류 자체는 revfactory/harness (Apache 2.0)에서 흡수. 본 엔지니어링은 각 패턴에 ProjectFIB 사례·가드·매개변수를 추가.

## 다음

[`why-this-works.md`](why-this-works.md) — 왜 이 6개로 충분한가
