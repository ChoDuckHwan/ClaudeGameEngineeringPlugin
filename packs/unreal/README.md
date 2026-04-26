# Unreal Engine Pack

UE 5.x 프로젝트용 도메인 자산.

## What

Unreal Engine 5.x 게임 개발에 특화된 helper 스킬 + specialist 에이전트.

## When

`*.uproject` + `Source/` 디렉토리가 있는 프로젝트에 자동 권장 (≥80% confidence).

## Provides

### Skills (6)
- `combat-helper` — 전투 시스템 (무기·근접·원거리·AI·스태미나·데미지)
- `gas-helper` — Gameplay Ability System
- `inventory-helper` — Fragment 기반 인벤토리
- `ui-helper` — MVVM + CommonUI
- `unreal-build-helper` — 빌드·컴파일·프로젝트 재생성
- `unreal-engine` — UE C++/BP 일반 가이드

### Agents (5)
- `gas-ability-developer` — GAS 어빌리티 신규 구현
- `interaction-system` — 상호작용·픽업 작업
- `ue-performance-analyzer` — 성능 분석 (Tick·Replication·draw call)
- `unreal-architect` — 시스템 설계 자문
- `game-balance-designer` — 수치·곡선 설계

### PostToolUse 매핑
- `*.cpp/*.h` → 빌드 권장
- `*.Build.cs/*.Target.cs` → GenerateProjectFiles + 풀 빌드
- `*.uproject` → 프로젝트 재생성
- `*.usf/*.ush/*.hlsl` → 셰이더 재컴파일
- `*.ini` → 에디터 재시작

## 의존성

`harness` 엔지니어링 활성 필요 (코어 메타 작업이 harness 정책 사용).

## 활성화 시그널 (확장 가능)

| 조건 | 점수 | 필수 |
|------|------|------|
| `*.uproject` 존재 | 50 | ✓ |
| `Source/` 디렉토리 | 15 | |
| `Content/` 디렉토리 | 10 | |
| `Config/` 디렉토리 | 5 | |
| 주 언어 C++ | 10 | |
| GameplayAbilities 의존 | 5 | |
| EnhancedInput 의존 | 5 | |

총 100점 만점, ≥80 자동 권장.

## 사용 예시

```
"새 obstacle 만들어줘"   → interaction-system 에이전트 자동 호출
"GAS 어빌리티 구현"      → gas-ability-developer
"이 코드 성능 봐줘"      → ue-performance-analyzer (또는 agent-router 자동 분배)
"빌드해줘"               → unreal-build-helper
```

## 기원

ProjectFIB(UE5 협동 호러 게임)에서 추출 + 일반화.
ProjectFIB 고유 이름(예: `FIBObstacle_*`)은 예시로 표시되어 있음.
