---
name: level-update
description: "사용자의 작업 완료 보고를 받아 레벨 마스터 문서의 진행도 체크박스를 갱신하고 변경 이력에 1행 추가합니다. 다중 항목 동시 갱신 / 블로커 표시 / Phase 완료 자동 감지 지원. 사용자가 '레벨 업데이트, level update, 완료 보고, [작업 ID] 완료, 진행도 갱신, 체크 해줘' 등을 언급할 때 활성화됩니다."
---

# Level Update — 진행도 체크리스트 갱신

## Identity

사용자의 자연어 작업 보고를 파싱하여 `.claude/Scenarios/{LevelName}.md` 의 체크박스를 정확하게 갱신. 변경 이력 누적.

## When to RUN

- 사용자가 작업 완료 / 진행 중 / 블로커를 보고
- 호출: `/level-update <LevelName> "<보고 내용>"` 또는 자연어

## 입력 패턴 인식

| 보고 패턴 | 동작 |
|---|---|
| "C1 완료" | C1 → `[x]` |
| "B2 진행 중" | B2 → `[~]` |
| "D1 블로커 (NavMesh 미빌드)" | D1 → `[!]` + 메모 |
| "A2, A3 완료" | 다중 갱신 |
| "Phase A 끝났어" | A1-A5 모두 `[x]` |
| "다시 D1 미시작으로" | D1 → `[ ]` (되돌리기) |

## 절차

### Step 1. 입력 파싱

- 레벨명 추출 (인자 또는 자연어에서 "UnderwaterFacility 의 ...")
- 항목 식별 (A1 / B2 / D1 등 Phase + 번호)
- 상태 식별 (완료 / 진행 중 / 블로커 / 미시작)
- 메모 추출 (블로커 사유 등)

### Step 2. 마스터 문서 Read + Edit

- `.claude/Scenarios/{LevelName}.md` Read
- 해당 체크박스 라인 Edit
- 다중 항목이면 순차 Edit

### Step 3. 변경 이력 추가 (§12)

```markdown
| YYYY-MM-DD HH:mm | A2 완료 (Bestiary 작성) | 사용자 작업 보고 |
```

### Step 4. Phase 완료 자동 감지

해당 Phase 의 모든 항목이 `[x]` 면:
```markdown
🎉 Phase A 완료! `/level-review {LevelName}` 권장.
```

### Step 5. Cross-Team 호출 자동 추천

Phase 전환 시점 매핑:

| 완료 Phase | 권장 다음 액션 |
|---|---|
| A | Phase B 시작 → 사용자 Fab 에셋 임포트 |
| B | Phase C → 디자이너 모듈 .umap 제작 |
| C | Phase D → ai-feature-implementer 호출 (첫 몬스터 vertical slice) |
| D | Phase E → interaction-feature-implementer 호출 |
| E | Phase F → balance-feature-implementer (예산 분배) |
| F | Phase G → 통합 PIE 검증 |
| G | 레벨 완료 → `/level-review` 최종 |

### Step 6. 출력

```markdown
# {LevelName} 진행도 갱신

## 변경
- A2 → [x] 완료 (Bestiary 작성)
- A3 → [x] 완료 (InteractionMap)

## 새 진행도
Phase A: 80% (4/5) — A5 만 남음

## 다음 행동
- A5 SESSION_HANDOFF 갱신 (남은 마지막 항목)
- 또는 Phase A 완료 후 /level-review UnderwaterFacility
```

## 절대 원칙

- ✓ 보고 파싱 모호 시 사용자 확인
- ✓ 변경 이력 항상 1행 이상 추가
- ✓ 다중 항목 동시 갱신 OK (Edit replace_all 또는 순차)
- ✓ Phase 자동 감지 → 자동 추천
- ❌ 사용자 보고 없이 임의 갱신
- ❌ 마스터 문서 외 다른 파일 수정 (별도 스킬)