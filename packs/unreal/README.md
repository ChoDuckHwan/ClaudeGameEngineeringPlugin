# Unreal Engine Pack

UE 5.x 프로젝트용 도메인 자산.

## What

Unreal Engine 5.x 게임 개발에 특화된 helper 스킬 + specialist 에이전트.

## When

`*.uproject` + `Source/` 디렉토리가 있는 프로젝트에 자동 권장 (≥80% confidence).

## Provides

### Skills (8)
- `bp-visualize` — **Widget/BT/AnimBP 작업 가이드를 인터랙티브 HTML로 생성** (따라 만드는 용도)
- `combat-helper` — 전투 시스템 (무기·근접·원거리·AI·스태미나·데미지)
- `gas-helper` — GAS 코드 템플릿 (프로젝트 규약 기준)
- `gas-master` — **GAS 심층 레퍼런스, UE 5.8 소스로 검증** (9 refs, ~2.4k 줄)
- `inventory-helper` — Fragment 기반 인벤토리
- `ui-helper` — MVVM + CommonUI
- `unreal-build-helper` — 빌드·컴파일·프로젝트 재생성
- `unreal-engine` — UE C++/BP 일반 가이드

#### GAS 자산이 셋인 이유

겹치는 게 아니라 **하는 일이 다릅니다.**

| 스킬 | 답하는 질문 | 성격 |
|---|---|---|
| `unreal-engine` (레퍼런스) | GAS가 뭐고 어떻게 생겼나 | 버전 무관 개론 |
| `gas-helper` | 이 프로젝트에서 어빌리티를 어떻게 쓰나 | 코드 템플릿 |
| `gas-master` | 5.8에서 이게 실제로 어떻게 동작하나 / 왜 안 되나 | 검증된 심층 + 디버깅 |

**5.5 이상에서 GAS 코드를 쓸 때는 `gas-master/references/ue58-deltas.md`를 먼저 봅니다.**
온라인 GAS 자료는 거의 5.5 이전이고, 그 폐기들이 **조용히** 실패합니다 — 옛 필드가 남아 있고
컴파일도 되지만 시스템이 읽지 않습니다. GE 태그를 채웠는데 태그가 안 붙거나, 1.5배 곱 두 개가
2.25배가 아니라 2.0배가 되는 식입니다.

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
