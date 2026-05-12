# 레벨 마스터 문서 표준 템플릿

> **사용법**: 새 레벨 작업 시작 시 이 파일을 복사 → `{LevelName}.md` 로 리네임 → 빈 필드 채움
> **자동화**: `/level-init <LevelName>` 스킬로 자동 생성 가능
> **갱신**: 사용자 작업 진행 시 `/level-update <LevelName>` 스킬로 체크리스트 동기화

---

# 테마 {N} — {시설 한글명} ({English Name}) 레벨 시나리오 마스터

> **생성**: YYYY-MM-DD
> **시각화**: [{LevelName}_LevelFlow.html](./{LevelName}_LevelFlow.html)
> **상태**: Phase A 문서화 / Phase B 에셋 / Phase C 모듈 / Phase D 몬스터 / Phase E 인터랙션 / Phase F Director / Phase G 검증

---

## 1. 시설 개요

| 항목 | 내용 |
|---|---|
| **시설명** | (예: 아비스 스테이션) |
| **위치** | (예: 마리아나 해구 수심 3,800m) |
| **역할** | (예: FIB 심해 생태계 연구) |
| **구조** | (예: 6개 모듈 + 에어록 + 외부 통로) |
| **세션 목표 시간** | 15-25분 (GDD_02 기준) |
| **권장 의뢰 등급** | Bronze / Silver / Gold |
| **출처 GDD** | background.md 테마 N, GDD_05 §5-X, GDD_04 |

## 2. 시나리오

**배경**: (한 단락 — 시설의 역사 + 사고 + 현재 상태)

**플레이어 동기**:
- ① **회수 미션**: (계약 보상)
- ② **비밀 진실**: (스토리/단서)
- ③ **호기심 / 욕심**: (호기심 트랩 강조)

**페이싱**: (4단계 사이클 흐름 — 불안 → 긴장 → 공포 → 해소)

## 3. 모듈 구성 ({N} 구역)

```
[ASCII 모듈 그래프]

[A. 시작] → [B. 준비] → [C. ...]
                              ↓
                          [D. 허브]
                          ↙        ↘
                      [E. ...]   [F. ...]
                          ↘        ↙
                          [G. 봉인실]
                              ↓
                       (보스 페이즈)
                              ↓
                          [A. 탈출]
```

| 구역 | 환경 | 위협 | 보상 / 단서 |
|:---:|---|---|---|
| A | 안전 | 무 | 시작 장비 |
| B | 실내 | (몬스터) | (단서) |
| ... | ... | ... | ... |

## 4. 환경 메카닉 (테마 고유)

(예: 외부 수중 통로 — 산소 게이지, 이동 속도, 시야, 안내, 안전 지점)

| 요소 | 값 |
|---|---|
| (산소/방사능/온도 등) | (값) |

## 5. 몬스터 라인업

| 티어 | 이름 | 위협 | 호기심 트랩 | 상세 |
|---|---|:---:|:---:|---|
> **표준 분배**: 일반 8 (공통 2 + 테마 6) + 치프 1-2 + 보스 1-2+ ([정책 문서](./_MONSTER_DISTRIBUTION_POLICY.md))
> **레벨 등급**: Bronze (1+1) / Silver (2+2) / Gold (2+2) / Final (2-3 + 3-5)

### Tier 1 — 일반 몬스터 (8종)

**1-A. 공통 재사용 (2종, 모든 9 테마 활용)**

| # | 이름 | 분류 | 위협 | 호기심 트랩 | 상세 |
|:---:|---|---|:---:|:---:|---|
| C1 | (공통 정찰/방해) | 1-A | ●○○○○ | — | [§C1](./{LevelName}_Bestiary.md#c1) |
| C2 | (공통 호기심 트랩) | 1-A | ●●○○○ | **✓** | [§C2](./{LevelName}_Bestiary.md#c2) |

**1-B. 테마 전용 (6종)**

| # | 이름 | 역할 | 위협 | 호기심 트랩 | 상세 |
|:---:|---|---|:---:|:---:|---|
| T1 | (테마 정찰) | 정찰/방해 | ●●○○○ | — | [§T1](./{LevelName}_Bestiary.md#t1) |
| T2 | (테마 매복) | 매복 (실내) | ●●○○○ | — | [§T2](./{LevelName}_Bestiary.md#t2) |
| T3 | (테마 환경) | 환경형 | ●●○○○ | — | [§T3](./{LevelName}_Bestiary.md#t3) |
| T4 | (테마 돌격 외) | 돌격 (실외) | ●●●○○ | — | [§T4](./{LevelName}_Bestiary.md#t4) |
| T5 | (테마 돌격 내) | 돌격 (실내) | ●●●○○ | — | [§T5](./{LevelName}_Bestiary.md#t5) |
| T6 | (테마 호기심 트랩) | 매복/환경 | ●●○○○ → ●●●○○ | **✓** | [§T6](./{LevelName}_Bestiary.md#t6) |

### Tier 2 — 치프 (의뢰 등급별: Bronze 1 / Silver+ 2 / Final 2-3)

| 슬롯 | 이름 | 위협 | 영역 | 상세 |
|:---:|---|:---:|---|---|
| Chief 1 | (치프 1) | ●●●●○ | (실내/실외) | [§Chief1](./{LevelName}_Bestiary.md#chief1) |
| Chief 2 | (Silver+ 부터) | ●●●●○ | (다른 영역) | [§Chief2](./{LevelName}_Bestiary.md#chief2) |

### Tier 3 — 보스 (의뢰 등급별: Bronze 1 / Silver-Gold 2 / Final 3-5)

| 슬롯 | 이름 | 위협 | 페이즈 | 상세 |
|:---:|---|:---:|:---:|---|
| Boss 1 | (메인 보스) | ★★★★★ | (페이즈 수) | [§Boss1](./{LevelName}_Bestiary.md#boss1) |
| Boss 2 | (Silver+ 부터) | ★★★★★ | (페이즈 수) | [§Boss2](./{LevelName}_Bestiary.md#boss2) |

> Final 레벨 (테마 9 박물관) = 보스 3-5종 대미 인카운터 (이전 보스들의 합체/부활/변형).
> 외형 / Fab 검색 / 유튜브 레퍼런스 → [Bestiary 문서](./{LevelName}_Bestiary.md).

## 6. 인터랙션 / 장애물

### 6-A. huddle.md 테마 {N} — 재사용 (N종)

| # | 장애물 | 카테고리 | 모듈 |
|:---:|---|---|---|
| 1 | (이름) | Gate | (모듈) |
| ... | ... | ... | ... |

### 6-B. 신규 / 공통 재사용

| # | 이름 | 카테고리 | 모듈 | 효과 |
|:---:|---|---|---|---|
| N-1 | 비밀 버튼 | Mechanism | (모듈) | 50% 보상 / 50% 위기 |
| N-2 | 비밀 잠금실 | Gate (특수) | (모듈) | 단서 수집 → 보너스 |
| N-3 | 협동 잠금 해제 | TimedSequence | (모듈) | 2명+ 동시 작동 |
| N-4 | 환경 함정 | Hazard (트리거) | (모듈) | 트리거 영역 |

## 7. 4단계 공포 사이클 매핑 (GDD_07)

| 단계 | 지속 | 위치 / 트리거 |
|---|---|---|
| 🌊 불안 (Ambient) | 30s-3min | (모듈) |
| ⚠️ 긴장 (Tension) | 10-30s | (모듈) |
| 😱 공포 (Terror) | 3-10s | (트리거) |
| 😅 해소 (Relief) | 10-30s | (모듈) |

## 8. 유혹 메카닉 분포

| 위치 | 유혹 | 리스크 / 보상 | 학습 가치 |
|:---:|---|---|---|
| (모듈) | (유혹) | (리스크) | (학습) |

## 9. 보스 페이즈

| 페이즈 | 위치 | 핵심 메카닉 | 약점 단계 |
|:---:|---|---|---|
| **1 예고** | (위치) | (메카닉) | (단서 수집) |
| **2 침입** | (위치) | (메카닉) | 1단계 스턴 |
| **3 대면** | (위치) | (메카닉) | 2-4단계 봉인 |

## 10. 진행도 추적

> **갱신 정책**: 사용자가 작업 완료 보고할 때 해당 [ ] → [x] 로 변경. `/level-update` 스킬 활용.

### Phase A — 시나리오 문서화

- [ ] **A1.** 마스터 문서 ({LevelName}.md) ← 본 문서
- [ ] **A2.** Bestiary 문서 ({LevelName}_Bestiary.md)
- [ ] **A3.** InteractionMap 문서 ({LevelName}_InteractionMap.md)
- [ ] **A4.** 시각화 HTML ({LevelName}_LevelFlow.html)
- [ ] **A5.** SESSION_HANDOFF 갱신

### Phase B — Fab 에셋 임포트

- [ ] B1. 시설 환경 에셋 임포트
- [ ] B2. 몬스터 메쉬 검색 + 구매
- [ ] B3. 모듈 분해 (Sublevel 단위)

### Phase C — 모듈 레벨 제작 (3-4세션)

- [ ] C1. (모듈 A) (.umap)
- [ ] C2. (모듈 B) (.umap)
- [ ] ...
- [ ] C{N}. NavMesh + SpawnPoint + 단서 위치

### Phase D — 첫 몬스터 vertical slice

- [ ] D1. (대상 몬스터) C++ 클래스
- [ ] D2. Blueprint 시제품
- [ ] D3. 1인 PIE 동작 확인

### Phase E — 인터랙션 통합

- [ ] E1. (인터랙션 1)
- [ ] E2. (인터랙션 2)
- [ ] E3. (인터랙션 3)

### Phase F — Encounter Director

- [ ] F1. AFIBMonsterSpawnPoint + Pool DataAsset
- [ ] F2. ContractDefinition + EncounterBudget
- [ ] F3. Experience Action_RandomSpawn

### Phase G — 통합 검증

- [ ] G1. 1인 PIE 풀 사이클
- [ ] G2. 4인 PIE
- [ ] G3. 호기심 트랩 학습 곡선 확인
- [ ] G4. 환경 메카닉 검증

## 11. Cross-Team 협업

| 팀 | 책임 | 호출 시점 |
|---|---|---|
| **ai** | 몬스터 사양/구현 | Phase A2, D, F |
| **mission** | Experience + 모듈 + 봉인실 | Phase C, F |
| **balance** | 위협 예산 + 인원 스케일링 | Phase F |
| **horror** | 4단계 사이클 시각 연출 | Phase C, D |
| **audio** | 사운드 + 보스 큐 | Phase C, D |
| **interaction** | 신규 인터랙션 | Phase E |
| **animation** | 몬스터 몽타주 | Phase D |

## 12. 변경 이력

| 일시 | 변경 | 사유 |
|---|---|---|
| YYYY-MM-DD | 문서 신규 작성 | Phase A1 시작 |

## 13. 다음 행동

```
□ (현재 미완 첫 항목부터)
```

다음 세션 / 작업 재개 시 위 ☐ 항목부터 진행. `/level-status {LevelName}` 으로 진행도 조회.

---

## 부록 A — Phase 정의 (모든 레벨 공통)

| Phase | 명칭 | 책임 | 산출물 |
|:---:|---|---|---|
| **A** | 시나리오 문서화 | mission + ai | 마스터 / Bestiary / InteractionMap / HTML |
| **B** | Fab 에셋 임포트 | 사용자 | 에셋 파일들 |
| **C** | 모듈 레벨 제작 | 디자이너 | .umap × N |
| **D** | 몬스터 Vertical Slice | ai + animation | C++/BP/AI 시제품 |
| **E** | 인터랙션 통합 | interaction | 신규 N-* 컴포넌트 |
| **F** | Encounter Director | mission + balance | SpawnPool + Budget |
| **G** | 통합 검증 | 전체 | PIE 결과 리포트 |

## 부록 B — 표기 규칙

- 진행 상태: `[ ]` 미시작 / `[~]` 진행 중 / `[x]` 완료 / `[!]` 블로커
- 우선순위: ⭐ 중요 / 🚨 긴급 / ⏳ 대기
- 위협: ●○○○○ (●5단계) / ★★★★★ (보스급)
- 호기심 트랩: ✓ (호기심 트랩 포함 몬스터/인터랙션)
- 모듈 환경: 실내 / 외부 / 보스