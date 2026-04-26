# Token Optimization Policy

13 도메인 × 10단계 + 22 스킬 + 8 specialist 인프라가 누적되면 토큰 비용이 폭증한다.
본 정책은 ECC ([affaan-m/everything-claude-code](https://github.com/affaan-m/everything-claude-code)) 1.10.0의 토큰 최적화 가이드를 ProjectFIB 컨텍스트에 흡수한 것.

> **출처**: ECC v1.10.0 토큰 정책 (60% 비용 절감 사례 보고).
> 본 정책은 측정·검증된 가이드만 흡수, 우리 환경에 맞지 않는 항목은 제외.

---

## 1. 모델 선택 정책 (Default = Sonnet)

| 작업 유형 | 권장 모델 | 사유 |
|-----------|-----------|------|
| **단순 정보 조회·읽기** | Haiku | 분류·매칭만 — 추론 깊이 불필요 |
| **표준 코드 생성·검증** | **Sonnet (default)** | 대부분의 도메인 작업 |
| **복합 판단·창의 평가** | Opus | 기획 구체화·재미 검증·아키텍트 |
| **메타 작업·자기개선** | Opus | teammaker / harness-evolve |

### 도메인별 모델 비율 (현재)

각 도메인 README에 명시된 모델 비율 — 변경 시 본 정책에 근거.

| 도메인 | opus | sonnet | haiku |
|--------|------|--------|-------|
| 일반 13 도메인 | 6~7 | 2~3 | 0 |
| teammaker | 5 | 3 | 0 |
| 단발 specialist | 4 | 3 | 1 (stress-test-runner) |

**비율 가드**: opus ≤ 70%, sonnet ≥ 25%, haiku 1+ (단순 작업용)

---

## 2. Compaction 정책

### 자동 compaction 시점 (권장)

| 시점 | 사유 |
|------|------|
| 도메인 팀 풀 사이클(10단계) 완료 후 | 단계별 산출물은 history.md로 옮김 → 메인 컨텍스트 정리 |
| Phase 단위 작업 종료 시 | Phase 간 컨텍스트 격리 |
| 진단 완료 후 구현 진입 시 | 연구 단계 컨텍스트 → 구현 단계로 전환 |

### Compaction 회피 시점

| 시점 | 사유 |
|------|------|
| Producer-Reviewer 루프 진행 중 | max_retry 도중 정보 손실 위험 |
| Supervisor 워커 활성 중 | worker 상태 추적 필요 |
| dry-run 출력 직후 사용자 결정 대기 | 결정 컨텍스트 보존 |

---

## 3. MAX_THINKING 가이드

ECC v1.10.0 권장: `MAX_THINKING_TOKENS=10000` (extended thinking 사용 시).

| 작업 | 권장값 |
|------|--------|
| 단순 조회·매칭 | 미사용 |
| 표준 구현 | 4000 |
| 아키텍처·복합 판단 | **10000** (ECC 표준) |
| 메타 진화·이론적 추론 | 16000 |

> 본 프로젝트의 모든 어빌리티·인터랙션·세션 작업은 4000~10000 범위 권장.
> 16000은 teammaker / harness-evolve / 신규 패턴 도입 시에만.

---

## 4. 컨텍스트 비용 가이드

### Skill 호출 비용 (입력 토큰)

| 카테고리 | 평균 토큰 | 비고 |
|----------|-----------|------|
| 메타 스킬(skill-*) | 50~250 | 본문 컴팩트 ✅ |
| 도메인 helper (개선 후) | 200~500 | _template.md 정책 준수 ✅ |
| 도메인 helper (개선 전 ui/combat) | 800~1500 | references 분리로 해소 ✅ |
| 도메인 팀 풀 사이클 | 8000~30000 | 10 단계 누적 |

### 비용 절감 전략

1. **Sub-agent 우선** — Mode가 Sub-agent인 도메인은 single Task call로 끝냄 (Agent Team의 1/3 비용)
2. **Dry-Run 선행** — 풀 사이클 전 비용 추정 → 잘못된 호출 차단
3. **References 분리** — SKILL.md 본문은 ≤500줄, 상세는 명시 호출 시에만 로드
4. **Specialist 직접 호출** — agent-router보다 도메인 명확하면 specialist 직접 (라우터 토큰 절감)
5. **harness-audit 배치 실행** — 매 변경마다 X, 주 1회 또는 골격 5건 변경 시

---

## 5. ProjectFIB 토큰 예산 권장

| 작업 단위 | 예산 | 초과 시 |
|-----------|------|---------|
| 단일 스킬 호출 | ≤2000 입력 | 본문 비대 점검 (harness-audit B) |
| 도메인 팀 1단계 | ≤5000 입력 | 단계 .md 본문 점검 |
| 도메인 팀 풀 사이클 | ≤30000 입력 | dry-run 미선행이거나 Mode 부적절 |
| 한 세션 누적 | ≤200000 입력 | compaction 권장 |

> 초과 시 `harness-evolve` 발동 후보 — 비용 추이를 history 성장 지표에 기록.

---

## 6. 관찰 가능성 (Observability)

각 도메인 HISTORY.md `# 성장 지표`에 다음 행 추가 권장:

```
| 평균 토큰/풀사이클 | NNNN | ↑↓→ |
| 최대 토큰/풀사이클 | NNNN | |
| dry-run 사용률 | N% | |
| Sub-agent vs Team 비율 | N:M | |
```

> harness-evolve가 평균 토큰 +30% 증가 시 자동 진화 후보 (C4 품질 하락 변형).

---

## 7. 흡수 안 한 ECC 항목 (의도적 제외)

| 항목 | 제외 사유 |
|------|-----------|
| 다국어 규칙 (TS/Py/Go/...) | UE5 C++ 단일 — 무관 |
| 명령어→스킬 마이그레이션 | 처음부터 스킬 기반 |
| AGENTS.md (다중 런타임) | Claude Code 단일 |
| 48 agents 카탈로그 | 도메인 특화 8 specialist + 13 팀이 적합 |

---

## 참조

- [HARNESS.md Cross-Harness 섹션](../HARNESS.md) — ECC 검토 결과
- [_patterns.md Mode 정책](_patterns.md) — Sub-agent vs Team 결정
- [_evolve_policy.md](_evolve_policy.md) — 토큰 폭증 감지 시 진화 트리거
- ECC repo: https://github.com/affaan-m/everything-claude-code (MIT)
