# Producer-Reviewer Retry Policy

도메인 팀의 `04_*_implementer` ↔ `07_*_verifier` 재작업 루프 표준.

> **문제**: 현재 모든 도메인 팀에서 verifier가 fail을 발견하면 **루프가 비공식**.
> 무한 루프 또는 단발 종료 양극단 위험. 본 정책으로 표준화.

---

## 표준 루프

```
[04 implementer] ──code──▶ [07 verifier]
                              │
                              ├─ PASS ──▶ [08 tester] (다음 단계)
                              │
                              └─ FAIL ──┬─ retry_count < max_retry
                                        │     └──▶ [04 implementer] (피드백 첨부)
                                        │           retry_count += 1
                                        │
                                        └─ retry_count == max_retry
                                              └──▶ HALT — 사용자에게 보고
                                                   (수동 개입 필요)
```

---

## 표준 값

| 항목 | 기본값 | 비고 |
|------|--------|------|
| `max_retry` | **2** | 03 회 시도 = 1차 + 2회 재시도 |
| 피드백 첨부 | 필수 | verifier 리포트의 Critical/High 이슈 전체 |
| HALT 시 산출물 | 부분 산출물 + 마지막 verifier 리포트 | 사용자가 수동 검토 |
| 토큰 소진 시 | 즉시 HALT (retry_count 무관) | 안전 장치 |

---

## 도메인별 오버라이드

특정 도메인이 표준값과 달라야 할 경우 `team/<도메인>/README.md`에 명시:

```markdown
## Retry Policy
- `max_retry`: 1 (네트워크 도메인 — 보수적 검증 필요)
- `feedback_severity_floor`: High (Low 이슈는 재시도 트리거 X)
```

| 도메인 | max_retry | 사유 |
|--------|-----------|------|
| (기본) | 2 | 표준 |
| network | 1 | 네트워크 안전성 critical, 신중한 수동 검토 우선 |
| balance | 3 | 수치 조정은 미세 반복 필요 |
| skill (메타) | 2 | 표준 |

---

## verifier 측 구현 권고

각 도메인 `07_*_verifier.md` 프론트매터에 다음 메타 추가:

```yaml
---
name: <domain>-verifier
description: ...
tools: Glob, Grep, Read, ...
model: opus
retry_policy:
  max_retry: 2
  feedback_severity_floor: Medium
  halt_on_critical_count: 5  # Critical 5개 이상이면 즉시 HALT
---
```

> 위 `retry_policy` 키는 informational. 실제 루프 제어는 호출자(orchestrator 또는 사용자)가 본 문서 규약에 따라 실행한다.

---

## 적용 대상 verifier 목록

```
.claude/team/ai/07_ai_verifier.md
.claude/team/animation/07_*_verifier.md (생성 시)
.claude/team/audio/07_audio_verifier.md
.claude/team/balance/...
.claude/team/combat/08_combat_code_verifier.md
.claude/team/horror/...
.claude/team/interaction/07_verifier.md
.claude/team/mission/...
.claude/team/network/07_network_verifier.md
.claude/team/player/07_player_verifier.md
.claude/team/skill/skill-validator.md
.claude/team/ui/07_ui_verifier.md
.claude/team/teammaker/06_quality_auditor.md
```

> **점진 적용**: 본 문서 작성 시점에는 메타 추가가 일괄 적용되지 않음.
> 각 verifier가 호출될 때 본 정책을 참조하면 효력 발생.
> 차후 `harness-audit` 스킬이 누락 메타를 검출하고 권고.

---

## 호출자(orchestrator) 의사 코드

```pseudo
retry_count = 0
while True:
    code = invoke(implementer, input, feedback=last_feedback or None)
    report = invoke(verifier, code)
    if report.status == PASS:
        break
    if report.critical_count >= halt_on_critical_count:
        HALT(reason="critical_overflow", artifact=code, report=report)
    if retry_count >= max_retry:
        HALT(reason="retry_exhausted", artifact=code, report=report)
    last_feedback = report.filter(severity >= feedback_severity_floor)
    retry_count += 1
```

---

## 참조

- [_patterns.md](_patterns.md) — ④ Producer-Reviewer 패턴
- [HARNESS.md](../HARNESS.md) — 전체 하네스 맵
