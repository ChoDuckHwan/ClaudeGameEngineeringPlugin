# Agent Team Design Patterns

ProjectFIB 도메인 팀(`.claude/team/<도메인>/`)을 설계할 때 사용하는 **6가지 표준 패턴**.
출처: revfactory/harness 의 패턴 분류(Apache 2.0)를 ProjectFIB 컨텍스트에 맞춰 흡수.

> **현재 상태**: 13개 도메인 팀이 모두 **Pipeline 단일 패턴**만 사용 중.
> 이 문서는 신규 팀 설계 또는 기존 팀 리팩터링 시 **Pipeline 외 패턴 후보**를 명시화한다.

---

## 패턴 선택 결정 트리

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

---

## ① Pipeline (순차 의존)

**현재 사용 도메인**: 13개 전체 (interaction/combat/ai/network/audio/player/ui/mission/balance/horror/animation/skill/teammaker)

```
[01 design_concretizer] → [02 architect] → [04 implementer] → [07 verifier] → [08 tester]
```

| 항목 | 내용 |
|------|------|
| **사용 시점** | 이전 산출물 없이 다음 단계 진행 불가 |
| **장점** | 단계별 명확한 책임, 진행 추적 용이 |
| **단점** | 초반 병목이 전체 지연, 병렬화 이점 X |
| **권장 모드** | Sub-agent (팀 모드 이점 적음) |
| **재시도** | 단계 단위 (`_retry_policy.md` 참조) |

---

## ② Fan-out/Fan-in (병렬 분석 → 통합)

**도입 후보 도메인**: combat (verifier·tester·security 동시), ui (가독성·접근성·반응형 동시)

```
              ┌─▶ [security_auditor] ─┐
[input] ──┬──▶├─▶ [performance_auditor]├─▶ [integrator] ─▶ output
          │   └─▶ [correctness_auditor]┘
          │ (동일 입력 병렬 분배)
```

| 항목 | 내용 |
|------|------|
| **사용 시점** | 동일 입력에 대해 서로 다른 관점이 필요할 때 |
| **장점** | 단독 조사 대비 품질 큰 향상, 시간 단축 |
| **단점** | 통합 단계 품질이 전체 결정, 토큰 비용 큼 |
| **권장 모드** | **Agent Team 필수** (병렬 실행 + 발견 공유) |
| **ProjectFIB 적용 후보** | `07_verifier` 전 단계에서 보안/성능/정확성을 병렬로 |

---

## ③ Expert Pool (라우터 → 전문가 선택)

**현재 적용**: [`skills/agent-router`](../skills/agent-router/SKILL.md) — `.claude/agents/` 8개 specialist 라우팅 (Tier 2 #6)

```
                ┌─▶ [unreal-architect]      (설계·아키텍처)
                ├─▶ [gas-ability-developer] (GAS 코드)
                ├─▶ [interaction-system]    (인터랙션 파이프라인)
[agent-router]──┼─▶ [design-pattern-advisor] (패턴 추천)
                ├─▶ [ue-performance-analyzer] (성능 리뷰)
                ├─▶ [security-vulnerability-analyzer] (보안 리뷰)
                ├─▶ [game-balance-designer]  (수치·곡선)
                └─▶ [stress-test-runner]     (반복 테스트)
                (입력 키워드·코드 패턴·의도로 점수 매겨 1~2개 선택)
```

| 항목 | 내용 |
|------|------|
| **사용 시점** | 입력 도메인이 모호하거나 "이 코드 분석/리뷰" 같은 일반 요청 |
| **장점** | 토큰 효율, 불필요한 작업 회피, 사용 빈도 낮은 specialist도 활용 |
| **단점** | 라우터 분류 정확도가 전체 품질 좌우 — 5건 실패 누적 시 `harness-evolve` 발동 |
| **권장 모드** | Sub-agent (Task tool로 단발 호출) |
| **ProjectFIB 구현체** | [`agent-router`](../skills/agent-router/SKILL.md) — 키워드+컨텍스트+의도 3축 점수 매핑 |
| **확장 시점** | 신규 specialist 추가 시 라우터 매핑 표 갱신 |

---

## ④ Producer-Reviewer (생성-검증 + 재시도 캡)

**현재 부분 적용**: 모든 도메인의 `04_implementer` ↔ `07_verifier` 페어. **단, 재시도 루프가 비공식**.

```
[producer] ──▶ [reviewer] ──┬─ PASS ──▶ output
                            │
                            └─ FAIL (≤max_retry) ──▶ [producer] (피드백 첨부)
```

| 항목 | 내용 |
|------|------|
| **사용 시점** | 객관적 검증 기준이 있고 재작업이 의미 있을 때 |
| **장점** | 품질 게이트 명확, 무한 루프 방지 |
| **단점** | max_retry 미설정 시 토큰 폭주 |
| **권장 모드** | Agent Team (실시간 피드백) |
| **재시도 캡** | `_retry_policy.md` (기본 max_retry=2) |
| **ProjectFIB 적용 후보** | 04→07 루프 명문화, 모든 verifier에 max_retry 메타 |

---

## ⑤ Supervisor (중앙 분배)

**현재 시범 적용**: `team/mission/` (Phase 1/2/3 작업 분배) — Tier 2 #7
**확장 후보 도메인**: balance (수치 조정 분배)

```
              ┌─▶ [worker_A: Phase 1 - 핵심시스템] ─┐
[mission     ]├─▶ [worker_B: Phase 2 - 악령]      ├─▶ 통합 보고
 supervisor  ]└─▶ [worker_C: Phase 3 - 일반몬스터] ─┘
              (supervisor가 작업 단위 분배 + 진행 추적 + 동적 재할당)
```

| 항목 | 내용 |
|------|------|
| **사용 시점** | 작업량 가변, 런타임 분배 결정 |
| **장점** | 동적 조정, 공유 작업 목록 자연스러움 |
| **단점** | 감독자 병목 위험 — 위임 단위 충분히 크게 (Phase 단위 권장) |
| **권장 모드** | Agent Team (공유 작업 목록 활용) |
| **ProjectFIB 시범 도메인** | mission — Phase 1/2/3 구현 작업을 동적 분배 |
| **위임 단위 가이드** | "Phase의 §섹션 단위" (예: Phase1 §4 = 1 worker 작업) |
| **분배 정책** | (a) 의존성 무관 §은 병렬, (b) 의존 있는 §은 직렬, (c) supervisor가 매핑 |
| **확장 시점** | mission 시범 5회 후 검증 → balance·skill로 확산 검토 |

---

## ⑥ Hierarchical Delegation (계층 위임)

**현재 부분 적용**: teammaker → (생성된) 도메인 팀. **깊이 캡 ≤2 강제**.

```
Depth 0:  [lead]                                      ← teammaker / 사용자
            │
Depth 1:    ├──▶ [team_lead_A]                        ← 도메인 팀 (Agent Team OK)
            │       │
Depth 2:    │       ├──▶ [worker_A1]  (Sub-agent만)   ← 팀 중첩 금지
            │       └──▶ [worker_A2]  (Sub-agent만)
            │
Depth 1:    └──▶ [team_lead_B]
                    │
Depth 2:            ├──▶ [worker_B1]  (Sub-agent만)
                    └──▶ [worker_B2]  (Sub-agent만)

Depth 3+: 🔴 금지 — 평탄화 또는 외부 메모리(history)로 우회
```

| 항목 | 내용 |
|------|------|
| **사용 시점** | 자연스러운 계층 분해 |
| **장점** | 복잡 문제 단계적 분해 |
| **단점** | 깊이 3+ 시 지연 폭증, 팀 중첩 불가, 컨텍스트 누수 |
| **깊이 한도** | **≤2 강제** (1단=Team / 2단=Sub-agent만) |
| **ProjectFIB 적용** | teammaker(D0) → 도메인 팀(D1) → 단계 에이전트(D2). 단계가 다른 팀 호출 금지. |

### 깊이 위반 시 처리 (Hard Rules)

1. **Depth 3 시도 감지**: 도메인 팀 내부 에이전트가 다른 팀(예: `Agent(subagent_type="...-team")`)을 호출하려 하면 **즉시 중단**
2. **대안 1 — 평탄화**: D3에 두려던 작업을 D2 에이전트로 직접 흡수
3. **대안 2 — 외부 메모리 경유**: D2 에이전트가 산출물을 `team/<도메인>/history.md`에 기록 → 사용자가 다음 턴에 별도 팀 호출 (D0 재시작)
4. **대안 3 — 평행 호출**: 사용자가 D0 레벨에서 두 팀을 순차 호출 (`teammaker` → `combat-team`, 그 다음 `teammaker` → `interaction-team`)

### 검증 책임

- **설계 시점**: `teammaker/03_team_architect`가 신규 팀 설계서에 **깊이 검증 섹션** 포함
- **운영 시점**: `harness-audit`가 각 팀 README의 호출 그래프에서 D3 가능성 검출
- **호출 시점**: orchestrator(사용자/메인 컨텍스트)가 깊이 카운트 추적

---

## 패턴 적용 매트릭스 (도메인 × 패턴)

| 도메인 | 현재 | 권장 추가 | 비고 |
|--------|------|-----------|------|
| interaction | Pipeline | Fan-out (07 단계) | 시범 적용 대상 |
| combat | Pipeline | Fan-out (07/09 병렬) | 검증 항목 다양 |
| ai | Pipeline | — | 순차 의존성 강함 |
| network | Pipeline | Producer-Reviewer 강화 | 안정성 critical |
| audio | Pipeline | — | |
| player | Pipeline | — | |
| ui | Pipeline | Fan-out (가독성/접근성/반응형) | |
| mission | Pipeline | Supervisor 검토 | Phase 분배 적합 |
| balance | Pipeline | Supervisor 검토 | 수치 분배 적합 |
| horror | Pipeline | — | |
| animation | Pipeline | — | |
| skill | Pipeline | Producer-Reviewer 강화 | 메타 루프 |
| teammaker | Hierarchical(1단) | 깊이 ≤2 강제 | 깊이 캡 명문화 필요 |

---

## 신규 팀 설계 시 작성할 항목

각 도메인의 `README.md`에 다음을 명시한다:

```markdown
## Pattern
- **Primary**: Pipeline / Fan-out / ...
- **Parallelizable Stages**: [03, 04] / [07a, 07b, 07c] (있는 경우)
- **Retry Loop**: 04 ↔ 07 (max_retry=2) (Producer-Reviewer 적용 시)
- **Mode**: Agent Team / Sub-agent / Hybrid
```

---

## 참조

- [_retry_policy.md](_retry_policy.md) — Producer-Reviewer 재시도 표준
- [HARNESS.md](../HARNESS.md) — 전체 하네스 레이어 맵
- [team/teammaker/README.md](teammaker/README.md) — 팀 자동 생성 메타팀

---

## Dry-Run 모드 표준 (Tier 2 #4)

도메인 팀을 **실제 호출하지 않고 계획만 생성**하는 모드. 풀 사이클 토큰·시간 비용을 사전 추정하고 사용자가 사전 조정할 수 있도록 한다.

### 호출 형태

```
"<도메인> 팀 dry-run으로 <작업> 계획 보여줘"
"<도메인> 팀 어떻게 진행될지 미리 보기"
"<domain> team dry run for <task>"
```

### Dry-Run 표준 출력 (도메인 팀이 반환할 것)

```markdown
# 🔍 [도메인] Dry-Run Plan: [작업명]

## 호출될 단계 (Pattern: Pipeline / Fan-out / ...)

| # | 에이전트 | 모델 | 입력 | 예상 출력 | 의존 파일 |
|---|---------|------|------|-----------|-----------|
| 01 | design_concretizer | opus | GDD_NN | 기술사양서 | GDD_NN.md |
| 02 | architect | opus | 기술사양서 | 클래스설계 | (사양서) |
| ... |

## 병렬 분기 / 재시도 루프

- **Fan-out stages**: [06, 07, 08] 동시 실행
- **Producer-Reviewer**: 04 ↔ 07 (max_retry=2)

## 예상 비용

| 항목 | 추정 |
|------|------|
| 총 단계 수 | N |
| 예상 토큰 (입력+출력 합) | ~XX,000 tokens |
| 예상 소요 시간 | ~M분 |
| 호출 모드 | Sub-agent / Agent Team / Hybrid |

## 사전 점검

- [ ] 의존 파일 모두 존재
- [ ] retry_policy 메타 적용됨
- [ ] 깊이 ≤2 위반 없음
- [ ] 다른 팀 호출 없음

## 주의·리스크

- (이 작업의 특이 리스크)

## 다음 행동

- ✅ "진행" → 실제 풀 사이클 호출
- 🔧 "단계 X 빼고 진행" → 부분 실행
- ❌ "취소" → 종료
```

### 도메인 README의 ## Dry-Run 섹션 표준

각 도메인 README에 다음 섹션을 둔다 (5~7줄):

```markdown
## Dry-Run

이 팀은 **실행 전 계획 미리보기**를 지원한다.

- 호출 예: `"<도메인> 팀 dry-run으로 [작업] 계획 보여줘"`
- 표준 출력: [`_patterns.md` Dry-Run 모드](../_patterns.md#dry-run-모드-표준-tier-2-4)
- 권장 사용 시점:
  1. 신규 작업 첫 실행 (예상 비용 가늠)
  2. 풀 사이클(10단계 전부) 호출 직전
  3. cross-team 협업 작업 (의존 팀 영향 범위 확인)
```

### Dry-Run 모드의 책임 분담

| 주체 | 책임 |
|------|------|
| **사용자** | "dry-run" 명시 호출 |
| **메인 컨텍스트(orchestrator)** | 도메인 팀의 README + Pattern 섹션 + retry_policy를 읽고 표 채움. **실제 단계 에이전트는 호출하지 않음** |
| **단계 에이전트** | dry-run에서는 호출되지 않음 — 따라서 별도 구현 불필요 |
| **harness-audit** | Dry-Run 섹션 존재 여부 검사 |

> **핵심**: Dry-Run은 메인 컨텍스트가 README 메타데이터만으로 작성. 단계 에이전트 코드 변경 0.
