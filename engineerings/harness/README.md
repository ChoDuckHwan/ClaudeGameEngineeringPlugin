# Harness Engineering

> 6 디자인 패턴 + Producer-Reviewer 재시도 + 자가개선 + 토큰 최적화.
> CGE의 첫 번째 탑재 엔지니어링 슬롯.

## What

도메인 작업을 **에이전트 팀 단위**로 조직화해 일관된 품질·재시도·자가개선·진화 메커니즘을 제공하는 엔지니어링 방식. 각 도메인이 같은 표준(Pattern·Mode·Retry·History·Dry-Run)을 따르므로 예측 가능하고 비용 통제 가능.

## Why

- **반복 가능성**: 모든 도메인이 같은 10단계 워크플로우 → 신규 도메인도 빠르게 정착
- **자가 진화**: 활동 누적 → 5회 마일스톤 / 반복 실패 / 품질 하락 자동 감지 → 정의 개선 후보
- **충돌 방지**: 트리거·계층·의존성 모두 명시적 가드
- **비용 통제**: Mode(Sub-agent/Team/Hybrid) + Dry-Run + 토큰 예산

## When

- 새 도메인이 자주 추가되는 프로젝트
- 1~4인 팀 또는 1인 멀티-역할 작업
- 동일 패턴 작업이 5+회 반복되는 환경
- 품질 게이트가 필요한 작업 (코드 리뷰·검증·테스트)

## How

### 6 디자인 패턴
1. **Pipeline** — 순차 의존
2. **Fan-out / Fan-in** — 병렬 분석 → 통합
3. **Expert Pool** — 라우터 → 전문가 선택 (`agent-router` 구현체)
4. **Producer-Reviewer** — 생성↔검증, max_retry 캡
5. **Supervisor** — 중앙 분배, 동적 재할당
6. **Hierarchical Delegation** — 계층 위임 (깊이 ≤2 강제)

### 핵심 자산

| 카테고리 | 자산 | 역할 |
|----------|------|------|
| Skills | harness-audit | 골격 정합성 검사 |
| Skills | harness-evolve | 도메인 팀 자가개선 |
| Skills | agent-router | Expert Pool — specialist 자동 분배 |
| Skills | session-log | 세션 핸드오프 자동 기록 |
| Skills | skill-{analyze,scenario,improve,implement,validate,changelog} | 메타 스킬 6 단계 |
| Agents | design-pattern-advisor | 디자인 패턴 자문 |
| Agents | security-vulnerability-analyzer | 보안 취약점 분석 |
| Agents | stress-test-runner | 100~500 반복 스트레스 |
| Policies | _patterns | 6 디자인 패턴 마스터 |
| Policies | _retry_policy | Producer-Reviewer 재시도 캡 |
| Policies | _evolve_policy | 4 트리거 자가개선 |
| Policies | _token_policy | 모델·MAX_THINKING·예산 |
| Teams | teammaker | 새 도메인 팀을 자동 생성하는 메타팀 |

## 사용 예시

### 부착 후 첫 명령
```
/harness-audit       # 정합성 검사 (8 카테고리)
/agent-router        # 모호한 요청에 specialist 자동 분배
```

### 도메인 팀 자가개선 (5회 활동 누적 후)
```
/harness-evolve <domain>
```

### 새 도메인 팀 생성 (teammaker 메타팀)
```
"<domain> 팀 만들어줘"
→ teammaker 8 단계 워크플로우 진행
```

## 기원

ProjectFIB(UE5 협동 호러 게임)에서 Tier 1+2+후속 작업으로 누적된 경험을 일반화.
- Tier 1 (6항목): 6 패턴 + 재시도 캡 + V7 트리거 + harness-audit + Fan-out 시범
- Tier 2 (7항목): 깊이 ≤2 + Mode 명시 + Dry-Run + harness-evolve + agent-router + Supervisor + ≤500줄
- 후속: 권한·훅 정리 + Trigger audit + ECC 흡수 (E1·E2)

상세 사례: [`docs/case-studies/projectfib.md`](../../docs/case-studies/projectfib.md)

## 외부 영감

본 엔지니어링은 다음 외부 작업에서 일부 개념을 흡수:
- **revfactory/harness** (Apache 2.0): 6 패턴 분류 개념
- **affaan-m/everything-claude-code** (MIT): 토큰 최적화 정책 개념

본 엔지니어링의 본문·구조는 ProjectFIB 개발 중 독립 작성됨.

## 향후 개선

`harness-evolve` + `cge-mine-pattern` + `cge-sync-lessons`로 다중 프로젝트 데이터 누적 → v1.1+ 자동 진화 예정.

## 관련

- 슬롯 스펙: [`core/policies/_engineering_slot_spec.md`](../../core/policies/_engineering_slot_spec.md)
- 다른 엔지니어링: `engineerings/_user/` 또는 미래 `ecc/`, `archon/`
