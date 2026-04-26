---
name: progress-check
description: 프로젝트 전체 개발 진행도를 스캔하고 시스템별 완성도를 리포트합니다. 사용자가 "진행도, 진행 상황, progress, 얼마나 됐어, 현황, 개발 상태, status, 어디까지 했어" 등을 언급할 때 활성화됩니다.
---

# Progress Check - 개발 진행도 분석기

## Identity
ProjectFIB 프로젝트의 개발 진행도를 정량적으로 측정하는 전문 분석기입니다. C++ 소스코드, 콘텐츠 에셋, 기획 문서를 교차 비교하여 시스템별 완성도를 산출합니다.

## Instructions

### 실행 절차

**Step 1: 소스코드 스캔**
프로젝트 소스 디렉토리를 탐색하여 시스템별 파일 수와 구현 상태를 파악합니다.

스캔 대상 디렉토리 (`Source/ProjectFIB/` 하위):
- `AbilitySystem/` - GAS 핵심 시스템
- `Character/` - 캐릭터 계층 구조
- `GameModes/` - 게임 모드 & Experience
- `Input/` - Enhanced Input
- `Interaction/` - 상호작용 시스템
- `Inventory/` - 인벤토리 & 아이템
- `Item/` - 아이템 프래그먼트
- `Obstacles/` - 장애물 시스템
- `Player/` - 플레이어 시스템
- `Teams/` - 팀 시스템
- `UI/` - UI 프레임워크
- `Camera/` - 카메라 시스템
- `Settings/` - 설정 시스템
- `System/` - 코어 시스템
- `Equipment/` - 장비 시스템
- `Audio/` - 오디오 시스템
- `Animation/` - 애니메이션
- `GameFeatures/` - 게임 피처 액션
- `Voice/` - 음성 채팅
- `Messages/` - 메시지 시스템
- `Performance/` - 성능 모니터링
- `Physics/` - 물리/충돌
- `Development/` - 개발 도구
- `Hotfix/` - 핫픽스 시스템
- `CommonGame/` - 공통 게임 레이아웃

각 디렉토리에서:
1. `.h` / `.cpp` 파일 수 카운트
2. 주요 클래스의 함수 본문이 비어있는지 확인 (stub 여부)
3. `UFUNCTION`, `UPROPERTY` 매크로 사용 빈도로 구현 깊이 추정

**Step 2: 콘텐츠 에셋 스캔**
`Content/` 디렉토리를 탐색하여 에셋 현황을 파악합니다.

스캔 항목:
- `Content/Main/Maps/` - 맵 파일 (`.umap`) 수 → 목표 9개 테마 맵
- `Content/Main/Item/` - 아이템 에셋 수
- `Content/Main/Character/` - 캐릭터 모델/애니메이션
- `Content/Main/UI/` - UI 위젯 에셋 수
- `Content/Main/Audio/` - 오디오 에셋
- `Content/Main/Enviroment/` - 환경 에셋
- `Content/Main/Resources/` - 퍼즐/리소스 에셋
- Experience 데이터 에셋 수

**Step 3: 기획 문서 대조**
`.claude/` 내 기획 문서에서 계획된 피처 목록을 추출하고 구현 상태와 비교합니다.

기획 문서 목록:
- `background.md` - 10개 테마 시설 설정
- `huddle.md` - 테마별 장애물/아이템 설계
- `FixItBots_Phase1_핵심시스템구현_완전판.md` - Phase 1 요구사항
- `FixItBots_Phase2_악령.md` - Phase 2 악령 시스템
- `FixItBots_Phase3_일반몬스터.md` - Phase 3 몬스터 시스템
- `FixItBots_잠금장치시스템.md` - 잠금/봉인 시스템
- `GDD_*.md` - 게임 디자인 문서들

**Step 4: 진행도 산출 및 리포트 출력**

출력 포맷:
```
## ProjectFIB 개발 진행도 리포트
날짜: {현재 날짜}

### 전체 진행도: {코드}% 코드 / {콘텐츠}% 콘텐츠 / {전체}% 종합

### 시스템별 상세
| 시스템 | 코드(.h/.cpp) | 콘텐츠(에셋) | 진행도 | 상태 |
|--------|--------------|-------------|--------|------|
| ... | ... | ... | ...% | 아이콘 |

### Phase별 진행도
| Phase | 목표 | 완료 항목 | 미완료 항목 | 진행도 |
|-------|------|----------|-----------|--------|

### 핵심 병목
1. {가장 진행이 느린 시스템}
2. {두 번째}
3. {세 번째}

### 최근 변경사항 (git log 기반)
- {최근 커밋 요약}
```

### 진행도 계산 기준

**코드 완성도** (가중치 50%):
- 파일 존재 + 비어있지 않음 = 기본 점수
- 핵심 함수 구현 여부 = 추가 점수
- 네트워크 복제 코드 포함 = 추가 점수

**콘텐츠 완성도** (가중치 30%):
- 맵: 존재하는 맵 / 목표 맵 수 (9)
- 캐릭터: 플레이어 + 몬스터 + NPC 모델
- 아이템: 정의된 아이템 에셋 수
- UI: 위젯 블루프린트 수

**기획 대비 구현율** (가중치 20%):
- 기획서에 명시된 시스템 중 코드로 존재하는 비율

### 상태 아이콘
- `완료` - 코드 + 콘텐츠 모두 80% 이상
- `진행중` - 코드 있음, 콘텐츠 부족 또는 반대
- `미착수` - 기획만 존재
- `병목` - 다른 시스템의 선행 조건인데 미완성

## Project File Reference

| 역할 | 경로 |
|------|------|
| 소스 코드 | `Source/ProjectFIB/` |
| 콘텐츠 | `Content/Main/` |
| 기획 문서 | `.claude/` |
| 빌드 설정 | `Source/ProjectFIB/ProjectFIB.Build.cs` |
| 프로젝트 설정 | `ProjectFIB.uproject` |
| 게임플레이 태그 | `Config/DefaultGameplayTags.ini` |

## Common Mistakes
- 코드 파일 수만으로 완성도를 판단하지 말 것 - 빈 stub 파일이 있을 수 있음
- 콘텐츠 에셋 수가 많아도 실제 게임에서 사용되지 않을 수 있음
- git log가 없는 경우 (non-git repo) 최근 변경사항은 파일 수정 시간으로 대체
- Phase 문서가 한국어로 작성되어 있으므로 한국어 키워드로 검색
