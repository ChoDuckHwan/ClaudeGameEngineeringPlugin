---
name: level-status
description: "9개 테마 레벨의 진행도를 조회합니다. 인자 없이 호출 시 전체 레벨 진행도 표, 인자 있을 시 특정 레벨의 Phase A~G 별 체크리스트 + 다음 행동 + 블로커 + Cross-Team 호출 권장 표시. 사용자가 '레벨 진행도, 레벨 상태, level status, 어디까지 했지, 레벨 현황, 진행 상황' 등을 언급할 때 활성화됩니다."
---

# Level Status — 레벨 진행도 조회

## Identity

`.claude/Scenarios/` 의 모든 마스터 문서를 스캔하여 진행도 요약. 단일 레벨 지정 시 상세 모드.

## When to RUN

- 사용자가 진행도 알고 싶어 함
- 호출: `/level-status` (전체) 또는 `/level-status <LevelName>` (단일)

## 절차

### Step 1. 모드 결정

- 인자 없음 → 전체 모드
- 인자 있음 → 단일 레벨 상세 모드

### Step 2. 파일 스캔

```
Glob: .claude/Scenarios/*.md (단, _TEMPLATE 제외)
```

### Step 3-A. 전체 모드 출력

각 마스터 문서 Read → 다음 추출:
- 현재 Phase (어떤 Phase 에서 첫 미완 [ ] 가 있는지)
- 완료율 (전체 체크박스 중 [x] 비율)
- 블로커 ([!] 마크 존재 여부)
- 직전 갱신 (변경 이력 마지막 행)

출력:

```markdown
# 전체 레벨 진행도 (YYYY-MM-DD)

| 레벨 | 현재 Phase | 완료율 | 블로커 | 직전 갱신 | 다음 행동 |
|---|:---:|:---:|:---:|---|---|
| UnderwaterFacility | A | 40% (2/5) | ✗ | 2026-05-11 | A2 Bestiary |
| Tanker | — | 0% | — | — | /level-init Tanker |
| ResearchLab | — | 0% | — | — | — |
...

## 요약
- 진행 중 레벨: N
- 완료 레벨: M
- 미시작 레벨: K
- 블로커 있음: L
```

### Step 3-B. 단일 모드 출력

특정 레벨 마스터 문서 Read → Phase A~G 전부 상세:

```markdown
# {LevelName} 레벨 상세 진행도

## 현재 위치
Phase A 진행도: 40% (2/5)

## Phase 별 상세

### Phase A — 시나리오 문서화 (2/5 완료)
- [x] A1. 마스터 문서
- [ ] A2. Bestiary 문서  ← 다음
- [ ] A3. InteractionMap
- [x] A4. 시각화 HTML
- [ ] A5. SESSION_HANDOFF 갱신

### Phase B — Fab 에셋 임포트 (0/3)
- [ ] B1. ...
...

## 블로커
(있는 경우 [!] 항목 + 해결 방법)

## 직전 갱신 (변경 이력 마지막 3건)
- 2026-05-11: ...
- ...

## 다음 우선 행동
1. ⭐ A2 Bestiary 작성 — `ai-design-concretizer` 호출 권장
2. A3 InteractionMap 작성

## Cross-Team 호출 권장
- Phase A2 진입 → ai 팀 (몬스터 사양)
```

### Step 4. 출력 마무리

- 한 줄 요약 (예: "UnderwaterFacility 가장 진행, 다음은 A2")
- `/level-update` 또는 `/level-next` 안내

## 출력 형식

마크다운 표. 한국어. 시각적 명확.

## 절대 원칙

- ✓ 마스터 문서 Read-only (수정 X)
- ✓ 진행도 계산은 체크박스 카운트 기반 (정확)
- ✓ 다음 행동 추천은 의존성 그래프 인식
- ❌ 임의 데이터 추측 (마스터 문서에 없는 정보 출력 X)