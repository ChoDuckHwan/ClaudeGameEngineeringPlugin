# Team Evolution Policy

도메인 팀(`team/<도메인>/`)이 **자기 활동에서 학습해 자기 정의를 개선하는** 표준.
Harness 플러그인의 `/harness:evolve` 메커니즘을 ProjectFIB 13개 도메인에 일반화.

> **기존 자산과 관계**:
> - `teammaker/08_skill_expander.md` = teammaker **자체** 개선 (메타팀 전용)
> - 본 정책 = **모든 도메인 팀**에 적용되는 일반화된 진화 규약
> - `_retry_policy.md` = 단일 작업 내 재시도 (마이크로 루프)
> - 본 정책 = 작업 누적 후 팀 정의 개선 (매크로 루프)

---

## 발동 조건 (4가지) — 한 가지라도 충족 시 진화 후보

| # | 조건 | 측정 | 출처 |
|---|------|------|------|
| **C1** | 반복 실패 (같은 패턴 ❌ 2회+) | `09_history.md` 활동 로그 ❌ 카운트 | history grep `❌` 패턴 |
| **C2** | 사용자 명시 호출 | `"<도메인> 팀 진화시켜줘"`, `/harness-evolve <domain>` | 사용자 입력 |
| **C3** | 마일스톤 (활동 5회 누적) | `09_history.md` 활동 로그 행 수 | history line count |
| **C4** | 품질 하락 (통과율 -20%p) | 최근 5건 vs 이전 5건의 verifier PASS율 | history 통과율 추이 |

> **자동 실행 금지**: 본 정책은 **트리거 조건 충족 시 후보 상태**만 만든다. 실제 진화 실행은 **사용자 승인 필수**.

---

## 진화 절차 (5단계)

```
[Step 1: 진단]    history.md + 통과율 + 사용자 피드백 분석
       │
       ▼
[Step 2: 후보 식별]  개선 카테고리 4종(아래) × 우선순위 매기기
       │
       ▼
[Step 3: 제안서]   IMP-NNN 형식 개선안 작성 (변경 전후 명시)
       │
       ▼
[Step 4: 사용자 승인]  ✅/❌/수정 — 승인된 항목만 다음 단계
       │
       ▼
[Step 5: 실행 + 기록]  파일 수정 → history에 진화 기록 → 종료
```

**한 번 진화 = 1회만 실행 후 종료**. 연쇄 자기개선 금지.

---

## 개선 카테고리 (4종)

### Cat-A: 에이전트 역량 (Agent Capability)
- 기존 단계 에이전트(.md)의 지시사항 강화
- 예: 04_implementer가 자주 누락하는 검증을 본문에 추가
- 영향 범위: 단일 에이전트 파일

### Cat-B: 파이프라인 (Pipeline Topology)
- 단계 추가/삭제/순서 변경, 병렬화 도입(Fan-out)
- 예: 06+07+08 순차 → 병렬 (Mode를 Sub-agent → Hybrid)
- 영향 범위: README.md `## Pattern` + 워크플로우 다이어그램

### Cat-C: 정책 매개변수 (Policy Parameters)
- `max_retry`, `feedback_severity_floor`, `halt_on_critical_count` 등 조정
- 예: balance 도메인 max_retry 2 → 3 (수치 미세조정 반복 필요)
- 영향 범위: `_retry_policy.md` 도메인별 오버라이드 표

### Cat-D: 트리거·인터페이스 (Trigger & Interface)
- 트리거 키워드 추가/충돌 해결, 호출 예시 보강
- 예: 사용자가 자주 쓴 자연어 표현이 트리거되지 않음 → 키워드 추가
- 영향 범위: 단계 에이전트 frontmatter description, README 사용 예시

> **금지 카테고리**: 게임 코드 자체, 다른 도메인 팀의 정의, 깊이 ≤2 위반(D3 시도)

---

## 진화 리포트 표준 형식

```markdown
# 🌱 [도메인] Team Evolution Report

## 진단 요약
- **진화 트리거**: C1 (반복 실패) / C2 (사용자) / C3 (5회 마일스톤) / C4 (품질 하락)
- **분석 기간**: [최근 N건]
- **데이터 소스**: `team/<도메인>/09_history.md` + `harness-audit` 결과 + 사용자 피드백
- **발견된 개선 후보**: N건

## 통과율 추이 (C4 트리거 시 필수)
| 기간 | PASS | FAIL | 통과율 |
|------|------|------|--------|
| 이전 5건 | A | B | X% |
| 최근 5건 | C | D | Y% |
| 변화 | | | ±Δ%p |

## 개선 후보

### IMP-001: [제목]
- **카테고리**: Cat-A / B / C / D
- **트리거 근거**: history의 [활동 ID] 또는 사용자 피드백 [인용]
- **현재 동작**: [한 문단]
- **개선 후 동작**: [한 문단]
- **변경 파일·위치**:
  - `team/<도메인>/04_implementer.md` line ~ : (전) ... → (후) ...
- **예상 효과**: [측정 가능한 지표 — 통과율 +X%p, 토큰 -Y%, 등]
- **부작용 우려**: [있다면 명시]

### IMP-002: ...

## 승인 요청
- [ ] IMP-001 적용
- [ ] IMP-002 적용
- [ ] 모두 거부 후 종료

## history 기록 요청
[09_history.md에 추가할 진화 활동 + 교훈 요약]
```

---

## 책임 분담

| 주체 | 책임 |
|------|------|
| **각 도메인의 09_history.md** | 활동·교훈 시간순 누적, ❌/✅/⚠️ 분류 |
| **harness-evolve 스킬** | 트리거 조건 검사 + 진단 + 제안서 작성 |
| **사용자** | C2 명시 호출, 제안 승인/거부 |
| **단계 에이전트(04, 07 등)** | 진화 실행 시 자기 .md 파일 수정 |
| **harness-audit** | 09_history.md 존재·형식 검사, 진화 후보 누적 알림 |

---

## 파일 분리 표준 (Tier 2 #5 audit 후속)

각 도메인은 **에이전트 정의**와 **활동 데이터**를 분리한다:

| 역할 | 위치 | 형식 | 변경 주체 |
|------|------|------|-----------|
| **History 에이전트 정의** | `team/<도메인>/{09_*_history,history,10_*_history}.md` | frontmatter + 지시사항 | 사람·skill-implement |
| **활동 데이터 (4섹션)** | `team/<도메인>/HISTORY.md` | 4섹션 마크다운 | 09 에이전트가 갱신 |
| **특수 케이스: teammaker** | `team/teammaker/07_teammaker_history.md` 단일 파일 | 정의+데이터 결합 (기존 유지) | 07 에이전트 |
| **특수 케이스: skill** | `team/skill/history.md` 단일 파일 | 정의+데이터 결합 (Windows case-insensitive) | history 에이전트 |

> teammaker(메타팀)와 skill(메타팀)은 단일 파일로 두 역할 결합. 일반 12개 도메인은 분리 표준 적용 (HISTORY.md 별도 데이터 파일).

## HISTORY.md 표준 4섹션 (모든 도메인 데이터 파일)

각 도메인 `team/<도메인>/HISTORY.md`는 다음 4섹션 유지 (teammaker 형식 일반화):

```markdown
# 활동 로그
[YYYY-MM-DD] [활동유형]: [작업명]
- 담당: 04_implementer
- 결과: ✅/⚠️/❌
- 교훈: ...

# 축적된 원칙 (2회+ 반복 교훈)
P-001: ...

# 도메인 인사이트
- 이 도메인 특이사항

# 성장 지표
| 지표 | 값 | 추이 |
| 활동 수 | N | |
| 1차 통과율 | N% | ↑↓→ |
| max_retry 평균 사용 | N.N | |
| 진화 횟수 | N | |
```

> 각 도메인의 09_history가 위 4섹션 형식이 아니면 `harness-evolve` 진단 단계에서 표준화 작업 우선.

---

## 진화 빈도 가드

| 도메인 | 최소 진화 간격 | 사유 |
|--------|----------------|------|
| 일반 | 활동 5회 또는 1주 | 데이터 부족 시 의미 없는 변경 위험 |
| network/balance | 활동 3회 또는 3일 | 변화 빈도 높고 critical |
| skill (메타) | 진화 후보 누적 5건 | 메타루프 비대화 방지 |
| teammaker | (기존 08_skill_expander 정책 그대로) | 별도 정책 |

**연속 진화 금지**: IMP 적용 직후 즉시 또 다른 IMP 후보 평가 ❌. 다음 5회 활동 누적 후에만.

---

## 참조

- [_patterns.md](_patterns.md) — 패턴별 진화 적용 차이 (Pipeline/Fan-out 등)
- [_retry_policy.md](_retry_policy.md) — 마이크로 재시도 정책 (보완 관계)
- [teammaker/08_skill_expander.md](teammaker/08_skill_expander.md) — teammaker 전용 진화 (특수 케이스)
- [HARNESS.md](../HARNESS.md) — 전체 하네스 맵
