---
name: level-next
description: "현재 진행 중인 레벨의 다음 우선 작업 1-3개를 추천합니다. Phase 의존성 그래프 + 블로커 분석 + Cross-Team 호출 시점 인식. 사용자가 '레벨 다음, 다음 단계, level next, 뭐 해야 돼 이 레벨에서, 이 시설 다음, 다음 작업' 등을 언급할 때 활성화됩니다. 프로젝트 전체 다음 작업은 next-task, 이 스킬은 레벨 단위."
---

# Level Next — 레벨 다음 작업 추천

## Identity

특정 레벨의 마스터 문서를 읽고 다음 우선 작업 1-3개 추천. `next-task` 스킬과 차이: next-task 는 프로젝트 전체, 이 스킬은 **레벨 단위**.

## When to RUN

- 사용자가 특정 레벨에서 뭐 할지 묻기
- 호출: `/level-next <LevelName>` 또는 자연어 "수중 시설 다음 뭐 해야 돼"

## When to SKIP

- 프로젝트 전반의 다음 작업 → `next-task` 스킬로 라우팅
- 레벨 마스터 문서 없음 → `/level-init` 권장

## 우선순위 알고리즘

```
1. 블로커 [!] 항목 → 최우선 (의존 깊음)
2. 같은 Phase 내 첫 미완 [ ] → 다음 작업
3. Phase 내 병렬 가능 항목 → 동시 진행 추천
4. Phase 완료 가까움 (1-2개 남음) → 마무리 강조
5. Phase 끝났으면 → 다음 Phase 진입 + Cross-Team 호출
```

## Phase 의존성 그래프

```
A (시나리오) ──▶ B (Fab 에셋) ──▶ C (모듈 .umap)
                                       ↓
                                  D (몬스터 vertical slice)
                                       │
                                  ├──▶ E (인터랙션 통합)
                                  └──▶ F (Encounter Director)
                                       ↓
                                  G (통합 검증)

병렬 가능: D ⇆ E ⇆ F (C 완료 후)
순차 필수: A → B → C → (D,E,F) → G
```

## 절차

### Step 1. 레벨 식별

- 인자 또는 자연어에서 LevelName 추출
- 진행 중 레벨 1개만 있으면 자동 선택

### Step 2. 마스터 문서 분석

- `.claude/Scenarios/{LevelName}.md` Read
- 각 Phase 의 체크박스 상태 카운트
- 블로커 [!] 항목 추출

### Step 3. 추천 산출

```
case 블로커 존재:
  → 블로커 해결 우선. 해결책 1-2개 제안

case Phase 내 미완 항목:
  → 의존성 없는 항목부터 (있으면 병렬 추천)

case Phase 완료:
  → /level-review 호출 권장 → 다음 Phase 진입
```

### Step 4. Cross-Team 호출 권장

| 다음 작업 | 호출 권장 |
|---|---|
| A2 (Bestiary 작성) | ai-design-concretizer |
| C{N} (.umap 제작) | 디자이너 (수동) |
| D1 (몬스터 C++ 구현) | ai-feature-implementer + animation 협업 |
| E (인터랙션 컴포넌트) | interaction-feature-implementer |
| F (예산 분배) | balance-feature-implementer + mission-feature-implementer |
| G (PIE 검증) | 전체 (1인/4인 테스트) |

### Step 5. 출력

```markdown
# {LevelName} 다음 우선 작업

## 1순위 ⭐
**A2. Bestiary 문서 작성**
- 의존성: 없음 (A1 완료)
- 호출: `ai-design-concretizer` 또는 직접 작성
- 예상 시간: 1-2 시간

## 2순위 (병렬 가능)
**A3. InteractionMap 문서 작성**
- 의존성: 없음
- huddle.md 테마 8 기반 매핑

## 다음 Phase 준비
A 완료 후 → B (Fab 에셋 임포트) 진입 → 사용자 Fab 작업 필요

## 명령
- 작업 시작 후 완료 보고: `/level-update {LevelName} "A2 완료"`
- 진행도 조회: `/level-status {LevelName}`
```

## 절대 원칙

- ✓ 의존성 그래프 인식 (순서 위반 추천 X)
- ✓ 블로커 항상 최우선
- ✓ 병렬 가능 항목 명시
- ✓ Cross-Team 호출 자동 추천
- ❌ 마스터 문서 외 데이터 추측
- ❌ 프로젝트 전반 작업 추천 (next-task 영역)