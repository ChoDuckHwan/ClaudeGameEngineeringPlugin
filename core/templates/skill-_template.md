---
name: kebab-case-name
description: "한 줄 설명 + 트리거 키워드 6개 이상 (한·영 양쪽). 사용자가 '키워드1, 키워드2, ...' 등을 언급할 때 활성화됩니다."
---

# Skill Title

> **Progressive Disclosure 정책**: 이 SKILL.md 본문은 **≤500줄**.
> 상세 자료(코드 스니펫, 패턴 카탈로그, 검증 표 등)는 `references/*.md`로 분리.

## 트리거 (Should-Trigger)

이 스킬이 활성화되어야 하는 자연어 예시 ≥3개:

- "예시 1"
- "예시 2"
- "예시 3"

## Should-NOT-Trigger

이 스킬과 비슷해 보이지만 다른 스킬이 호출되어야 하는 케이스 ≥2개:

| 입력 예시 | 기대 호출 | 이유 |
|-----------|-----------|------|
| "..." | other-skill | ... |
| "..." | other-skill | ... |

## Identity

이 스킬의 **존재 이유**를 1~2문단으로. WHO(누가) WHEN(언제) WHY(왜) 사용하는지.

## Instructions

### Step 1: ...
### Step 2: ...
### Step 3: ...

## Examples

### 케이스 1: ...
```
입력: ...
출력: ...
```

## Output Format

```markdown
[표준 출력 형식]
```

## References (≤500줄 정책)

본문이 비대해지면 다음 위치로 분리:

- `references/patterns.md` — 패턴 카탈로그 (When/Why/How)
- `references/sharp_edges.md` — 함정·실수 패턴
- `references/validations.md` — 검증 체크리스트
- `references/examples.md` — 상세 예시 모음

본문에서는 `> 상세는 [references/patterns.md](references/patterns.md) 참조` 형태로 포인터만 둔다.

## 관련 스킬·문서

- [HARNESS.md](../../HARNESS.md) — 전체 하네스 맵
- (활성 엔지니어링·팩의 관련 스킬)
