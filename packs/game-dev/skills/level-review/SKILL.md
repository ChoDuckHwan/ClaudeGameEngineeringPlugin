---
name: level-review
description: "특정 레벨의 현재 Phase 완료도를 검토하고 다음 Phase 진입 준비도를 평가합니다. 미완 항목 / 블로커 / 품질 게이트 / Cross-Team 합의 4가지 기준 검사. 게임 전체 phase-review 와 차이: 이 스킬은 레벨 단위. 사용자가 '레벨 리뷰, 레벨 점검, level review, 페이즈 완료 검토, 다음 페이즈 가도 돼, level phase gate' 등을 언급할 때 활성화됩니다."
---

# Level Review — 레벨 Phase 완료 게이트 검토

## Identity

특정 레벨의 현재 Phase 가 정말 완료됐는지 + 다음 Phase 진입에 위험 없는지 평가하는 Gate Review. `phase-review` 와 차이: 이건 **레벨 단위 Phase A~G**.

## When to RUN

- Phase 끝났다고 사용자가 보고 / `/level-update` 가 Phase 완료 자동 감지 시
- 호출: `/level-review <LevelName>` 또는 자연어

## Phase 별 완료 기준

| Phase | 완료 기준 | 품질 게이트 |
|:---:|---|---|
| **A** 시나리오 | 5/5 (마스터/Bestiary/InteractionMap/HTML/핸드오프) | Bestiary 외형 묘사 Fab 검색 가능 수준 |
| **B** Fab 에셋 | 3/3 (환경/몬스터/모듈 분해) | 에셋 임포트 빌드 깨끗 |
| **C** 모듈 .umap | N+2 (모든 모듈 + NavMesh + SpawnPoint) | 모듈 간 충돌 없음, NavMesh 도달성 |
| **D** Vertical Slice | 3/3 (C++/BP/PIE) | 1인 PIE 동작 확인 |
| **E** 인터랙션 | 디자인 따라 N개 | 서버 권한 / 네트워크 안전 |
| **F** Director | 3/3 (Pool/Budget/Action) | 1-4인 스케일링 검증 |
| **G** 통합 검증 | 4/4 (1인/4인/호기심/환경) | 세션 15-25분 안 완주 가능 |

## 검토 체크리스트

### 1. 완료도 (정량)

- 해당 Phase 의 체크박스 100% [x]?
- 부분 완료 시 — 어느 항목 / 사유 / 영향

### 2. 블로커 (정성)

- [!] 마크 항목 존재?
- 다음 Phase 의존성 위반?

### 3. 품질 게이트 (Phase 별)

위 표 참조. 양적 100% 아니라 질적 검토.

### 4. Cross-Team 합의

- Phase A → ai 팀 합의 완료?
- Phase D → animation 팀 합의?
- 등 Phase 별 해당 팀이 OK 했는지

## 절차

### Step 1. 레벨 + Phase 식별

- 인자 또는 가장 최근 완료된 Phase 자동 식별

### Step 2. 마스터 문서 분석

- 체크박스 100% 확인
- [!] 블로커 추출
- 변경 이력 마지막 5건 — 안정성 확인

### Step 3. 품질 게이트 적용

Phase 별 게이트 항목 점검 (위 표).

### Step 4. 합의 확인

해당 Phase 가 영향 주는 팀 식별 → Cross-Team 호출 권장.

### Step 5. 출력

```markdown
# {LevelName} Phase {X} 완료 검토

## 정량
- 체크박스: 5/5 (100%)
- 블로커: 없음
- 직전 갱신: 2026-05-11

## 품질 게이트 (Phase A 기준)
- ✅ 마스터 문서 13 섹션 채워짐
- ✅ Bestiary 외형 묘사 Fab 검색 가능
- ⚠️ InteractionMap 의 모듈 매핑 일부 미정 — 사용자 확인 권장
- ✅ HTML 시각화 디자이너 가시화 가능
- ✅ SESSION_HANDOFF 갱신

## Cross-Team 합의
- ai 팀: 몬스터 사양 OK (Bestiary 작성됨)
- mission 팀: Experience 골격 다음 Phase 작업
- horror 팀: 시각 연출 Phase C-D 에서 합류

## 판정
✅ **Phase A 완료 합격. Phase B 진입 가능.**

(또는)
⚠️ **부분 완료. 다음 항목 보완 후 진입 권장:**
- (구체적 항목)

## 다음 Phase 진입 가이드

### Phase B — Fab 에셋 임포트
- 책임: 사용자 + ai 팀 (몬스터 매쉬 검색)
- 첫 작업: Fab 마켓플레이스에서 시설 환경 에셋 임포트
- 명령: `/level-update {LevelName} "B1 진행 중"`
```

## 절대 원칙

- ✓ 정량 + 정성 검토 결합
- ✓ Phase 별 게이트 항목 표준화 (위 표)
- ✓ 강제 진입 가능 (사용자 결정) 하지만 위험 명시
- ✓ 다음 Phase 진입 가이드 항상 제공
- ❌ 정량만으로 합격 판정 (품질 게이트 무시 X)
- ❌ phase-review 스킬과 중복 (그건 게임 전체)