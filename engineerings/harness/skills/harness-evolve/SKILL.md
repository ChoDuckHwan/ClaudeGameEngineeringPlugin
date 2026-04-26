---
name: harness-evolve
description: "도메인 팀의 HISTORY.md 누적 데이터를 분석해 팀 정의 자가개선 후보를 제안합니다. 반복 실패·5회 마일스톤·품질 하락·사용자 명시 호출 4가지 조건 중 하나라도 충족 시 발동. 사용자가 '팀 진화, 팀 개선, harness evolve, 자가개선, self improve, history 기반 개선, 진화시켜줘, 팀 업그레이드, 학습 반영' 등을 언급할 때 활성화됩니다."
---

# Harness Evolve

도메인 팀이 누적된 활동 이력에서 **자기 정의를 학습·개선**하도록 진단·제안하는 스킬.

> **본문 ≤500줄** ([_template.md](../_template.md) 정책 준수). 상세 절차는 [team/_evolve_policy.md](../../team/_evolve_policy.md) 참조.

## 트리거 (Should-Trigger)

- "interaction 팀 진화시켜줘"
- "combat 팀 history 보고 개선안 뽑아줘"
- "/harness-evolve ai"
- "최근 mission 팀 통과율 떨어졌나? 진화 후보 봐줘"
- "팀들 자가개선 발동 가능한 곳 있나?"

## Should-NOT-Trigger

| 입력 예시 | 기대 호출 | 이유 |
|-----------|-----------|------|
| "스킬 만들어줘" | skill-implement | 진화 ≠ 신규 생성 |
| "팀 만들어줘" | teammaker | 진화 ≠ 신규 팀 |
| "코드 개선해줘" | 도메인 helper 스킬 | 진화 = 팀 정의 개선이지 게임 코드 X |
| "teammaker 자체 개선" | teammaker/08_skill_expander | 메타팀 전용은 08 |

## Identity

도메인 팀(`team/<도메인>/`)이 작업을 누적 수행하면 HISTORY.md에 로그·교훈이 쌓인다.
이 스킬은 그 데이터를 읽어 **반복 실패 패턴·품질 하락·구조적 비효율**을 검출하고
팀 정의(에이전트 .md / README / 정책 매개변수)를 어떻게 개선할지 **제안서**를 작성한다.

**자동 실행하지 않음** — 사용자 승인 필수. 한 번 진화 = 1회 적용 후 종료.

## Instructions

### Step 1: 도메인 식별

```
입력 예시 → 대상 도메인:
  "interaction 팀 진화"        → interaction
  "/harness-evolve combat"     → combat
  "팀들 자가개선 발동 가능한 곳" → 13개 도메인 전부 스캔 모드
```

### Step 2: 발동 조건 검사 (4가지)

[_evolve_policy.md](../../team/_evolve_policy.md) `## 발동 조건` 표 참조:

| 조건 | 검사 방법 |
|------|-----------|
| C1 반복 실패 | `team/<domain>/HISTORY.md` Grep `❌` → 같은 패턴 2회+ 검출 |
| C2 사용자 호출 | 본 스킬이 호출된 시점 = 자동 충족 |
| C3 5회 마일스톤 | history `# 활동 로그` 섹션 활동 수 ≥5 |
| C4 품질 하락 | history 최근 5건 통과율 vs 이전 5건 통과율 (-20%p 이상) |

**한 가지라도 충족 → Step 3로**. 아무것도 충족 X → "진화 시점 아님" 보고 후 종료.

### Step 3: 진단

```
1. team/<domain>/HISTORY.md 전체 읽기
   - 활동 로그
   - 축적된 원칙
   - 도메인 인사이트
   - 성장 지표

2. team/<domain>/README.md 읽기 (현재 ## Pattern, Mode, Dry-Run)

3. team/<domain>/*.md 전체 단계 에이전트 읽기 (현재 정의)

4. harness-audit 결과가 있다면 함께 (drift 정보)
```

### Step 4: 개선 카테고리 매핑

발견 사항을 4개 카테고리로 분류:

- **Cat-A 에이전트 역량**: 단계 .md 본문 강화
- **Cat-B 파이프라인**: README ## Pattern 변경 (Mode·Parallelizable·Producer-Reviewer)
- **Cat-C 정책 매개변수**: max_retry, feedback_severity_floor 등
- **Cat-D 트리거·인터페이스**: frontmatter description 키워드, 사용 예시

### Step 5: 진화 제안서 작성

[_evolve_policy.md](../../team/_evolve_policy.md) `## 진화 리포트 표준 형식` 정확히 따름.
한 번에 **최대 3개 IMP** — 점진 개선 원칙.

### Step 6: 사용자 승인 요청

승인 받기 전 절대 파일 수정 X. 출력에 명시:

```
## 승인 요청
- [ ] IMP-001 적용
- [ ] IMP-002 적용
- [ ] 모두 거부 후 종료
```

### Step 7: 승인 시 실행 + history 기록

```
1. 승인된 IMP만 변경 사항 Edit으로 적용
2. team/<domain>/HISTORY.md에 진화 활동 추가
   - 날짜, 트리거 종류, 적용된 IMP, 예상 효과
3. CLAUDE.md ## Change Log에 1행 추가
4. 종료 — 다음 진화는 5회 활동 누적 후에만
```

## Examples

### 예시 1: 사용자 명시 호출 (C2)

```
사용자: "interaction 팀 진화시켜줘"

응답 흐름:
1. 도메인 = interaction
2. C2 자동 충족
3. interaction/HISTORY.md 읽음 → 활동 8건, ❌ 2건 ("RequiredItemDef 누락" 반복)
4. Cat-A 후보: 04_feature_implementer.md에 RequiredItemDef 검증 step 추가
5. 진화 리포트 출력 (IMP-001)
6. 사용자 승인 대기
```

### 예시 2: 다중 도메인 스캔 (관리자 모드)

```
사용자: "팀들 자가개선 발동 가능한 곳 있나?"

응답 흐름:
1. 13개 도메인 HISTORY.md 일괄 읽기
2. 각 도메인의 C1/C3/C4 자동 검사
3. 표 형식 출력:
   | 도메인 | 트리거 | 우선순위 |
   | interaction | C1 (반복 실패) | 🔴 |
   | combat | C3 (5회 마일스톤) | 🟡 |
   | (나머지) | 미충족 | — |
4. 사용자에게 "어느 도메인 진화 진행?" 질문
```

## Output Format

[_evolve_policy.md](../../team/_evolve_policy.md) `## 진화 리포트 표준 형식` 그대로.

## 진화 빈도 가드

| 도메인 | 최소 간격 |
|--------|-----------|
| 일반 | 활동 5회 또는 1주 |
| network/balance | 활동 3회 또는 3일 |
| skill | 진화 후보 누적 5건 |
| teammaker | **본 스킬 대상 X** — `teammaker/08_skill_expander` 사용 |

가드 위반 시 (예: 어제 진화했는데 오늘 또 호출) → 진화 거부 + 사유 보고.

## 관련

- [_evolve_policy.md](../../team/_evolve_policy.md) — 표준 정책 (마스터 문서)
- [_retry_policy.md](../../team/_retry_policy.md) — 마이크로 재시도 (보완 관계)
- [team/teammaker/08_skill_expander.md](../../team/teammaker/08_skill_expander.md) — teammaker 전용
- [skills/harness-audit](../harness-audit/SKILL.md) — drift 검출 (진화 진단 시 입력으로 사용 가능)
- [HARNESS.md](../../HARNESS.md) — 전체 하네스 맵
