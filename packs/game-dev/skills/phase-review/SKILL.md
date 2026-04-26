---
name: phase-review
description: 현재 개발 Phase의 완료 조건을 검토하고 다음 Phase 진입 준비도를 평가합니다. 사용자가 "페이즈 리뷰, phase review, 단계 검토, 페이즈 완료, phase complete, 다음 단계 갈 수 있어, 페이즈 체크, milestone" 등을 언급할 때 활성화됩니다.
---

# Phase Review - 개발 단계 완료도 검토기

## Identity
ProjectFIB의 개발 Phase별 완료 조건을 정밀 검토하고, 다음 Phase로의 진입 준비도를 Gate Review 방식으로 평가하는 전문 검토기입니다.

## Instructions

### Phase 정의

#### Phase 1: 핵심 시스템 구현
**목표**: 코어 게임플레이 루프가 단일 맵에서 작동

**완료 조건 체크리스트**:
```
[코어 시스템]
- [ ] Experience 시스템으로 게임 설정 로딩
- [ ] 캐릭터 스폰 및 초기화 (Spawned → GameplayReady)
- [ ] Enhanced Input으로 이동/시야/상호작용 입력 처리
- [ ] GAS 기반 어빌리티 활성화/종료
- [ ] 체력/스태미나 어트리뷰트 작동
- [ ] 데미지 → 사망 → 리스폰 플로우

[인벤토리/아이템]
- [ ] 아이템 줍기 (IPickupable → Inventory)
- [ ] 아이템 사용 (UFIBGameplayAbility_ItemUse)
- [ ] 아이템 소모 (ConsumeItemsByDefinition)
- [ ] 인벤토리 UI 표시 및 슬롯 선택

[장애물/상호작용]
- [ ] 5종 물리 장애물 기본 작동 (Gate, Barricade, Mechanism, Placement, HazardZone)
- [ ] 아이템 조건부 상호작용 (RequiredItemDef)
- [ ] 장애물 상태 전환 (Locked → Unlocking → Unlocked)

[멀티플레이]
- [ ] 로비 생성/검색/참가
- [ ] 2+ 플레이어 동시 접속
- [ ] 인벤토리/체력 네트워크 동기화
- [ ] 호스트 → 게임 맵 이동 (Seamless Travel)

[UI]
- [ ] HUD (체력, 스태미나, 인벤토리)
- [ ] 상호작용 프롬프트
- [ ] 로비 UI
- [ ] 설정 화면
```

**검증 방법**:
1. `Source/ProjectFIB/` 하위에서 각 시스템 클래스 파일 존재 확인
2. 핵심 함수의 구현 본문 비어있지 않은지 확인
3. 콘텐츠에 Experience DA, Input Config DA, Ability Set DA 존재 확인
4. 맵 최소 1개 존재 확인

#### Phase 2: 악령 시스템
**목표**: 최소 1개 악령이 완전한 파이프라인으로 작동

**완료 조건 체크리스트**:
```
[악령 코어]
- [ ] AFIBSpirit_Base 베이스 클래스
- [ ] 악령 AI 행동트리 프레임워크
- [ ] 악령 상태머신 (봉인 → 각성 → 활동 → 처치/탈출)
- [ ] 악령 고유 능력 Ability 시스템

[봉인 시스템]
- [ ] 초자연 봉인 4종 중 최소 1종 구현
  - [ ] 원한 봉인 (Grudge Seal)
  - [ ] 의식 봉인 (Ritual Seal)
  - [ ] 감정공명 봉인 (Emotion Resonance)
  - [ ] 기생 봉인 (Parasitic Seal)
- [ ] 이중 잠금 (물리 + 초자연) 시퀀스
- [ ] 봉인 해제 → 각성 연출 (3-5초 딜레이)

[첫 번째 악령 프로토타입]
- [ ] 개별 악령 서브클래스 (예: Silent Nurse)
- [ ] 고유 행동 패턴 (BT 노드)
- [ ] 고유 능력 2-3개
- [ ] 약점 메커닉
- [ ] 사운드/VFX 최소 구현

[통합 테스트]
- [ ] 맵에서 봉인된 문 접근 → 물리 잠금 해제 → 초자연 봉인 해제 → 악령 각성 → 전투/도주 시퀀스
- [ ] 멀티플레이에서 동일 시퀀스 작동
```

#### Phase 3: 일반 몬스터
**목표**: 시설별 몬스터 배치로 탐색 긴장감 생성

**완료 조건 체크리스트**:
```
[몬스터 코어]
- [ ] 몬스터 카테고리별 베이스 (Sentry, Disruptor, Tracker, Explosive, Support)
- [ ] AI Perception + Behavior Tree 통합
- [ ] 스폰 매니저 시스템
- [ ] 난이도 스케일링 (플레이어 수, 진행도)

[콘텐츠]
- [ ] 시설당 최소 3종 몬스터
- [ ] 몬스터 모델 + 애니메이션
- [ ] 몬스터 사운드

[드롭/보상]
- [ ] 몬스터 드롭 테이블
- [ ] 파밍 보상 계산
- [ ] 악령 활성 시 보상 승수
```

#### Phase 4: 콘텐츠 확장
**목표**: 최소 3개 테마 맵 플레이 가능

**완료 조건 체크리스트**:
```
[맵]
- [ ] 3+ 테마 맵 완성
- [ ] 맵별 Experience DA
- [ ] 맵별 장애물/아이템 배치
- [ ] 맵별 몬스터/악령 배치

[진행 시스템]
- [ ] 세션 보상 정산
- [ ] 영구 업그레이드 시스템
- [ ] 상점 UI
- [ ] 맵 선택 UI
```

### 실행 절차

**Step 1: 현재 Phase 판별**
- Phase 1 조건 미충족 → Phase 1 리뷰
- Phase 1 충족, Phase 2 미충족 → Phase 2 리뷰
- 순차적으로 판별

**Step 2: 해당 Phase 체크리스트 순회**
각 항목에 대해:
1. 관련 소스 파일 검색 (Glob/Grep)
2. 핵심 함수 구현 확인 (Read)
3. 관련 콘텐츠 에셋 확인 (Glob)
4. `PASS` / `PARTIAL` / `FAIL` 판정

**Step 3: Gate Review 리포트 출력**

```
## Phase {N} Gate Review
날짜: {현재 날짜}

### 현재 Phase: {Phase 번호} - {Phase 이름}
### 전체 통과율: {통과 항목}/{전체 항목} ({퍼센트}%)

### 체크리스트 결과
| # | 항목 | 상태 | 근거 | 비고 |
|---|------|------|------|------|
| 1 | ... | PASS/PARTIAL/FAIL | {파일/에셋 경로} | ... |

### Gate 판정
- **PASS** (80%+ 통과): 다음 Phase 진입 가능
- **CONDITIONAL PASS** (60-79%): 잔여 항목 병행하며 진입 가능
- **FAIL** (60% 미만): 현재 Phase 완료 우선

### 다음 Phase 진입 준비도
| 준비 항목 | 상태 | 설명 |
|----------|------|------|
| 선행 시스템 | ... | ... |
| 기반 코드 | ... | ... |
| 테스트 인프라 | ... | ... |

### 잔여 작업 목록 (FAIL/PARTIAL 항목)
1. {항목} - {예상 공수} - {추천 우선순위}
2. ...
```

## Key Patterns

**Phase 판별 핵심 지표**:
- Phase 1: `FIBExperienceManagerComponent`, `FIBAbilitySystemComponent`, `FIBInventoryManagerComponent`, `FIBInteractableComponent` 모두 구현됨
- Phase 2: `Spirit` 또는 `Seal` 키워드가 포함된 클래스 존재 여부
- Phase 3: `Monster` 카테고리별 서브클래스 + `SpawnManager` 존재 여부
- Phase 4: 3+ `.umap` 파일 + 맵별 Experience DA

**Listen Server 검증 포인트**:
- 새 시스템의 `GetLifetimeReplicatedProps` 구현 여부
- Server RPC (`Server_` prefix) 존재 여부
- Authority 체크 로직 존재 여부

## Common Mistakes
- Phase를 순차적으로만 진행할 필요는 없음 - 병행 가능한 작업은 병행 추천
- PARTIAL은 FAIL이 아님 - 핵심 기능이 작동하면 다음 Phase 착수 가능
- 콘텐츠 부재만으로 Phase FAIL 판정하지 말 것 - 코드 프레임워크가 핵심
- 블루프린트 구현도 유효한 구현으로 인정
