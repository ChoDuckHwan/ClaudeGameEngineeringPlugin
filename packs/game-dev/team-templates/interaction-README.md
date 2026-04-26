# Interaction Team — 인터랙션 구현 팀

ProjectFIB 인터랙션 시스템(장애물, 픽업, 아이템 사용, UI 프롬프트)의 기획 구체화부터 구현, 검증, 테스트까지 전 과정을 담당하는 팀입니다.

## Pattern (Tier 1 신규)

- **Primary**: Pipeline (01 → 02 → 04 → 06)
- **Producer-Reviewer**: 04 ↔ 07 (max_retry=2, see [`_retry_policy.md`](../_retry_policy.md))
- **Parallelizable Stages**: `[06, 07]` 동시 실행 가능 — 변경 리포트와 검증은 같은 코드 입력에 독립 동작
- **Mode**: Agent Team (06+07 병렬 시) / Sub-agent (단일 단계 호출 시)
- **Reference**: [`_patterns.md`](../_patterns.md)

> **시범 적용 도메인**: 본 팀이 13개 도메인 중 첫 번째로 패턴 명시화. 효과 검증 후 다른 도메인 확산 예정.

## 팀 구성

| # | 역할 | 에이전트 | 모델 | 핵심 업무 |
|---|------|---------|------|-----------|
| 01 | 기획 구체화 | `interaction-design-concretizer` | opus | GDD/huddle.md → 구현 가능한 기술 사양서 변환 |
| 02 | 아키텍트 | `interaction-architect` | opus | 클래스 구조, 상속 계층, 헤더 스켈레톤 설계 |
| 03 | 구조 설명 | `interaction-structure-explainer` | opus | Mermaid 다이어그램, 실행 흐름, 코드 매핑 설명 |
| 04 | 기능 구현 | `interaction-feature-implementer` | opus | .h/.cpp 작성, GAS/인벤토리/네트워크 코드 구현 |
| 05 | 기능 개선 | `interaction-feature-improver` | opus | 중복 제거, 패턴 통일, 성능/네트워크 최적화 |
| 06 | 변경 리포트 | `interaction-change-reporter` | sonnet | 변경 파일/클래스/영향 분석, 사이드 이펙트 보고 |
| 07 | 검증원 | `interaction-verifier` | opus | 네트워크/GAS/메모리/보안 정확성 검증 리포트 |
| 08 | 테스터 | `interaction-tester` | opus | 테스트 시나리오 설계, 자동화 테스트, 스트레스 테스트 |
| 10 | 기능 활성화 | `interaction-feature-activator` | opus | 사용자 적용 가이드(Obstacle BP/ItemDef 생성, 인디케이터, 레벨 배치, E키 테스트), 텍스트 설정 자동 적용 |

## 워크플로우

```
기획 문서 (GDD_06, huddle.md)
    │
    ▼
[01 기획 구체화] ─── 기술 사양서 ───▶ [02 아키텍트] ─── 클래스 설계서 ───┐
                                                                          │
                                          ┌───────────────────────────────┘
                                          ▼
                                    [04 기능 구현] ─── C++ 코드 ──────────┐
                                          │                               │
                                          ├── 병렬 분기 (Fan-out) ────────┤
                                          ▼                               ▼
                                    [06 변경 리포트]               [07 검증원] ◀─┐
                                          │                               │     │ FAIL & retry<2
                                          │                            PASS│     │ (Producer-Reviewer)
                                          ▼                               ▼     │
                                    사용자에게 보고                [08 테스터]   │
                                                                          ▲     │
                                                                          └─────┘
                                                                  (04로 피드백 재투입)
                                                                          │
                                                                          ▼
                                                               테스트 결과 리포트
                                                                          │
                                          ┌───────────────────────────────┘
                                          ▼
                                    [05 기능 개선] (필요시)
                                          │
                                          ▼
                                    [03 구조 설명] (요청시)
                                          │
                                          ▼
                                    [10 기능 활성화] ─── 사용자 적용 가이드 ──▶ 사용자 체험
```

## 사용 예시

### 새 장애물 구현 전체 프로세스
```
1. "WeightLock 장애물 기획을 구체화해줘"     → 01_design_concretizer
2. "WeightLock 클래스 구조를 설계해줘"       → 02_architect
3. "WeightLock 코드를 구현해줘"              → 04_feature_implementer
4. "변경된 코드를 정리해줘"                   → 06_change_reporter
5. "구현된 코드를 검증해줘"                   → 07_verifier
6. "테스트 시나리오를 만들어줘"               → 08_tester
7. "전체 구조를 설명해줘"                     → 03_structure_explainer
8. "코드를 개선할 부분이 있나?"               → 05_feature_improver
9. "WeightLock 을 레벨에 적용하는 절차 알려줘" → 10_interaction_feature_activator
```

### 기존 기능 분석
```
"인터랙션 E키 흐름을 설명해줘"               → 03_structure_explainer
"InteractableComponent 코드를 검증해줘"      → 07_verifier
```

## Dry-Run

이 팀은 **실행 전 계획 미리보기**를 지원한다.

- 호출 예: `"interaction 팀 dry-run으로 [작업] 계획 보여줘"`
- 표준 출력: [`_patterns.md` Dry-Run 모드](../_patterns.md#dry-run-모드-표준-tier-2-4)
- 권장 사용 시점:
  1. 신규 obstacle/픽업 첫 구현 (Fan-out 분기 비용 확인)
  2. cross-team 작업 (player·combat 영향 범위)

## 관련 문서
- [GDD_06_장애물_퍼즐.md](../../GDD_06_장애물_퍼즐.md) — 장애물 기획
- [huddle.md](../../huddle.md) — 테마별 장애물 & 아이템
- [agents/interaction-system.md](../../agents/interaction-system.md) — 기존 인터랙션 에이전트
