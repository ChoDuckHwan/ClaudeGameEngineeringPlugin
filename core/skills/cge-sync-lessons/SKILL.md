---
name: cge-sync-lessons
description: "여러 프로젝트의 _project_profile.json + HISTORY.md를 합류해 플러그인 본체의 _meta/lessons.md를 갱신한다. 메타-메타 학습 — 다른 프로젝트 노하우를 현재 프로젝트로 흡수. 3+ 프로젝트가 같은 패턴 보이면 정식 자산 승격 후보. 사용자가 '/cge sync-lessons', 'lessons 동기화', '다른 프로젝트 노하우', 'meta learning', '플러그인 학습'을 언급할 때 활성화."
---

# CGE Sync Lessons — 메타-메타 학습

플러그인이 부착된 모든 프로젝트의 노하우를 합류해 본체에 흡수.

## 트리거

- `/cge sync-lessons`
- "다른 프로젝트 노하우 가져와"
- "lessons 동기화"
- "플러그인 학습"

## Identity

CGE의 **메타-메타 학습 채널**. 단일 프로젝트의 mine-pattern과 다름:
- mine-pattern: 1개 프로젝트 → 1개 프로젝트 개선
- sync-lessons: N개 프로젝트 → 플러그인 본체 + 모든 프로젝트로 전파

## 입력

사용자가 명시한 다른 CGE 부착 프로젝트 경로 목록 (또는 글로벌 레지스트리 — 미래).

## 절차

### Step 1: 다른 프로젝트 목록 입력

```
사용자: "다른 프로젝트 경로 알려주세요 (콤마 구분)"
입력: i:\Project_A, i:\Project_B, c:\Work\Project_C
```

또는 `_meta/adopters.md`에서 자동 로드 (사용자가 등록한 프로젝트).

### Step 2: 각 프로젝트의 학습 데이터 수집

```
For each project_path:
  Read project_path/.claude/_project_profile.json
  Read project_path/.claude/team/*/HISTORY.md
  Read project_path/.claude/SESSION_HANDOFF.md (선택)
```

### Step 3: 패턴 합류

여러 프로젝트에서 공통 발견:
- **공통 반복 작업**: 3+ 프로젝트에서 같은 종류 작업
- **공통 실패 패턴**: 3+ 프로젝트에서 같은 ❌
- **공통 누락 자산**: 3+ 프로젝트에서 같은 missing domain
- **공통 정책 오버라이드**: 같은 매개변수를 여러 프로젝트가 같은 값으로 조정

### Step 4: 플러그인 본체 갱신 후보

```markdown
# 🔄 Sync Lessons Report

## 분석한 프로젝트
- ProjectFIB (UE5 game)
- Project_A (TS web)
- Project_B (Python ML)

## 공통 패턴 (3+ 프로젝트)

### CP-1: PostToolUse 알림이 너무 시끄럽다 (3 프로젝트 ❌)
- 모든 프로젝트가 같은 메시지 disable 시도
- **본체 후보**: post_edit_alert.ps1에 verbosity 정책 추가

### CP-2: harness-audit 권장 주기 1주는 너무 짦다 (3 프로젝트)
- 모두 2주로 조정
- **본체 후보**: _evolve_policy.md 기본값 갱신

## 단독 노하우 (1 프로젝트지만 흡수 가치)

### SL-1: ProjectFIB의 Phase §섹션 분배 패턴
- mission Supervisor 모드가 효과적
- **본체 후보**: harness 엔지니어링의 _patterns.md ⑤ Supervisor 강화

## 본체 갱신 결정

다음을 적용?
1. CP-1 → post_edit_alert.ps1 verbosity 추가 — 모든 프로젝트로 전파
2. CP-2 → _evolve_policy.md 기본값 1주 → 2주
3. SL-1 → _patterns.md ⑤ 사례 추가 (정보만)

[Y/n/select]
```

### Step 5: 본체 갱신 + 전파

승인 시:
- 플러그인 본체 파일 수정 (engineerings/harness/policies/...)
- 부착된 프로젝트들에 변경 알림 (rebootstrap 권장)

### Step 6: `_meta/lessons.md` 누적

이번 sync 결과를 누적:
```markdown
## 2026-04-26 sync (3 projects)
- CP-1 적용
- CP-2 적용
- SL-1 정보로 보관

다음 sync 후보:
- ...
```

### Step 7: 승격 메커니즘

`_user/` 디렉토리에 사용자 만든 엔지니어링이 3+ 프로젝트에서 사용 → `engineerings/` 정식 승격 후보.
`_meta/promotions.md`로 큐 등록.

## Examples

### 예시: 3 프로젝트가 같은 새 패턴 발견
```
3 프로젝트 모두 "결제 흐름 코드"에 패턴 발견:
- 항상 PaymentGateway → Validator → Persister 순서

→ 본체 후보: harness 엔지니어링의 _patterns.md에 ⑦ Payment Pipeline 추가?
→ 또는: packs/_user/payment-flow 신규 팩 작성?
```

## 권한 요구

- 다른 프로젝트 디렉토리 Read 권한 필요
- `_project_profile.json` 같은 형식이어야 합류 가능

## Should-NOT-Trigger

| 입력 | 기대 |
|------|------|
| "프로젝트 분석" | project-analyst (단일 프로젝트) |
| "특정 프로젝트 패턴" | cge-mine-pattern |

## 관련

- [`cge-mine-pattern`](../cge-mine-pattern/SKILL.md) — 단일 프로젝트
- `_meta/adopters.md` — 부착 프로젝트 등록
- `_meta/lessons.md` — 누적 결과
- `_meta/promotions.md` — 정식 승격 후보 큐
