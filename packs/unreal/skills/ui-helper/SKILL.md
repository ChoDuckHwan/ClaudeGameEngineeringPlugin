---
name: ui-helper
description: UI 위젯 생성, MVVM 패턴 적용, Lyra 기반 UI 시스템 연동을 돕습니다. 사용자가 새로운 UI 위젯, ViewModel, HUD 요소, 리스트 뷰, 모달 팝업, 커스텀 SWidget을 생성하거나 UI 시스템을 수정하려 할 때 자동으로 활성화됩니다.
---

# UI Helper Skill

ProjectFIB의 MVVM 기반 UI 시스템 구현을 돕는 스킬입니다.
.cpp와 .h 파일만 관리하며, Lyra UI 시스템 패턴을 따릅니다.

> **Progressive Disclosure** ([_template.md](../_template.md) ≤500줄 정책 — Tier 2 #3): 본 SKILL.md는 핵심 아키텍처·베이스 클래스·파일 위치·디버깅만 담는다.
> 상세 코드 템플릿·연결 패턴·완성 예제는 `references/`로 분리.

## References

- [view-templates.md](references/view-templates.md) — View 템플릿 (UFIBActivatableWidget, HUD, ListView, Modal Popup, ListView Entry)
- [viewmodel-templates.md](references/viewmodel-templates.md) — UI 전용 / 시스템 브릿지 / ListView 데이터 ViewModel
- [connection-patterns.md](references/connection-patterns.md) — View↔ViewModel 연결 (UI 전용 / 시스템 브릿지) + Game Feature 연동
- [custom-swidget.md](references/custom-swidget.md) — Slate 커스텀 위젯·Indicator System
- [complete-example.md](references/complete-example.md) — Sanity HUD 풀 예제 (ViewModel + Widget + 연결)

---

## 1. 핵심 아키텍처 (MVVM + Lyra UI)

### MVVM 패턴 정의

- **View** = UMG 위젯. `UFIBActivatableWidget`, `UFIBCommonUserWidget` 등 프로젝트 베이스 클래스 상속
- **ViewModel** = View와 Model 사이의 데이터 브릿지
  - **UI 전용 ViewModel**: `UFIBViewModel` 서브클래스 (UI 폴더에 위치)
  - **시스템 브릿지**: 기존 컴포넌트가 ViewModel 역할 (예: `UFIBHealthComponent`는 HP 바의 ViewModel)
- **Model** = 데이터 소스. `AttributeSet`, `InventoryList`, 서브시스템 등

### 폴더 구조 규칙

```
Source/ProjectFIB/UI/<FeatureName>/
  FIB<Feature>Widget.h/.cpp          - View
  FIB<Feature>ViewModel.h/.cpp       - UI 전용 ViewModel (필요한 경우만)
  FIB<Feature>ListItemData.h/.cpp    - ListView 데이터 객체 (필요한 경우만)
```

비UI ViewModel/Model은 원래 시스템 폴더에 유지:
- `Character/FIBHealthComponent` → HP 바의 ViewModel
- `Inventory/FIBInventoryManagerComponent` → 인벤토리 UI의 Model
- `AbilitySystem/Attributes/FIBHealthSet` → HP 데이터의 Model

### 위젯 라이프사이클 바인딩 규칙

```
NativeOnInitialized()  → 위젯 초기 설정 (한 번만)
NativeConstruct()      → 뷰포트에 추가될 때
NativeOnActivated()    → ViewModel 바인딩 (델리게이트 등록)
NativeOnDeactivated()  → ViewModel 언바인딩 (델리게이트 해제)
NativeDestruct()       → 제거 전 정리
```

**반드시 `NativeOnActivated`에서 바인딩하고, `NativeOnDeactivated`에서 해제해야 한다.**

### UI 레이어 시스템

- `UI.Layer.Game` - 인게임 HUD 요소
- `UI.Layer.Menu` - 메뉴 UI (ESC 메뉴, 설정 등)
- `UI.Layer.Modal` - 모달 팝업 (확인 대화상자 등)

---

## 2. ViewModel 베이스 클래스

UI 전용 ViewModel이 필요한 경우 사용하는 베이스 클래스.
**시스템 브릿지 패턴에서는 이 클래스를 사용하지 않는다** — 기존 컴포넌트(예: `UFIBHealthComponent`)가 직접 ViewModel 역할 수행.

### 헤더 (`Source/ProjectFIB/UI/FIBViewModel.h`)

```cpp
// Copyright Epic Games, Inc. All Rights Reserved.

#pragma once

#include "CoreMinimal.h"
#include "UObject/NoExportTypes.h"
#include "FIBViewModel.generated.h"

DECLARE_DYNAMIC_MULTICAST_DELEGATE_TwoParams(FFIBViewModelPropertyChanged, UFIBViewModel*, ViewModel, FName, PropertyName);

UCLASS(Abstract, Blueprintable, BlueprintType)
class PROJECTFIB_API UFIBViewModel : public UObject
{
    GENERATED_BODY()

public:
    UFIBViewModel();

    UFUNCTION(BlueprintCallable, Category = "FIB|ViewModel")
    virtual void Initialize(UObject* InOwner);

    UFUNCTION(BlueprintCallable, Category = "FIB|ViewModel")
    virtual void Deinitialize();

    UFUNCTION(BlueprintPure, Category = "FIB|ViewModel")
    UObject* GetOwner() const { return Owner; }

    UPROPERTY(BlueprintAssignable, Category = "FIB|ViewModel")
    FFIBViewModelPropertyChanged OnPropertyChanged;

protected:
    UFUNCTION(BlueprintCallable, Category = "FIB|ViewModel")
    void NotifyPropertyChanged(FName PropertyName);

    UPROPERTY()
    TObjectPtr<UObject> Owner;
};
```

### 소스 (`Source/ProjectFIB/UI/FIBViewModel.cpp`)

```cpp
// Copyright Epic Games, Inc. All Rights Reserved.

#include "UI/FIBViewModel.h"

#include UE_INLINE_GENERATED_CPP_BY_NAME(FIBViewModel)

UFIBViewModel::UFIBViewModel() {}

void UFIBViewModel::Initialize(UObject* InOwner) { Owner = InOwner; }

void UFIBViewModel::Deinitialize() { Owner = nullptr; }

void UFIBViewModel::NotifyPropertyChanged(FName PropertyName)
{
    OnPropertyChanged.Broadcast(this, PropertyName);
}
```

> View·ViewModel 구체 템플릿은 [view-templates.md](references/view-templates.md), [viewmodel-templates.md](references/viewmodel-templates.md) 참조.

---

## 3. 패턴 선택 가이드

| 시나리오 | ViewModel 패턴 | 참조 |
|----------|----------------|------|
| HP/Stamina/Sanity 바 | **시스템 브릿지** (HealthComponent 직접) | [connection-patterns.md](references/connection-patterns.md) |
| 인벤토리 슬롯 | **시스템 브릿지** (InventoryComponent) | [connection-patterns.md](references/connection-patterns.md) |
| 설정 UI | **UI 전용 ViewModel** (`UFIBViewModel` 상속) | [viewmodel-templates.md](references/viewmodel-templates.md) |
| 세션 브라우저 ListView | **ListView 데이터 객체** (`UObject` 래퍼) | [view-templates.md](references/view-templates.md) |
| 인디케이터 / 마커 | **커스텀 SWidget + IndicatorDescriptor** | [custom-swidget.md](references/custom-swidget.md) |
| 모달 다이얼로그 | View only (간단 콜백) | [view-templates.md](references/view-templates.md) |

> 위 매핑이 헷갈릴 때 풀 예제 참고: [complete-example.md](references/complete-example.md) (Sanity HUD 케이스)

---

## 4. 흔한 실수 (반드시 피할 것)

| 안티패턴 | 올바른 방법 |
|----------|-------------|
| `NativeConstruct`에서 바인딩 | `NativeOnActivated`에서 바인딩 (`UFIBActivatableWidget` 기준) |
| ViewModel을 raw `UObject*`로 보유 | `UPROPERTY()` + `TObjectPtr<>` 또는 `TWeakObjectPtr<>` |
| 위젯이 PlayerState 직접 폴링 | GameplayMessageRouter 또는 ViewModel 델리게이트 구독 |
| Tick에서 데이터 갱신 | 이벤트 기반 (`OnPropertyChanged` / 메시지) |
| AddToViewport 직접 호출 | `UFIBUIManagerSubsystem::PushWidgetToLayer()` |
| 한국어 문자열 하드코딩 | `NSLOCTEXT` / `FText::FromStringTable` |

---

## 5. Game Feature 연동 (요약)

신규 위젯을 GameFeature에서 동적으로 추가:

1. `UGameFeatureAction_AddWidget` 구성
2. UILayer 태그 지정 (예: `UI.Layer.Game`)
3. Experience Definition에 Action 등록

상세: [connection-patterns.md](references/connection-patterns.md) §Game Feature 섹션.

---

## 6. 커스텀 SWidget 사용 시점

UMG로 표현 불가능한 경우만:
- 다수 동적 인디케이터 (3D 마커 → 2D 투영)
- 커스텀 그리기 (Indicator System의 `SActorCanvas`)
- 좌표·페인트 직접 제어 필요

상세: [custom-swidget.md](references/custom-swidget.md).

---

## 7. 기존 베이스 위젯 사용 가이드

| 베이스 클래스 | 위치 | 용도 |
|---------------|------|------|
| `UFIBButtonBase` | `UI/Foundation/FIBButtonBase.h` | `UCommonButtonBase` 상속, 텍스트·스타일 자동 |
| `UFIBCommonTextBlock` | `UI/Common/FIBCommonTextBlock.h` | `UCommonTextBlock` 상속 |
| `UFIBTabListWidgetBase` | `UI/Common/FIBTabListWidgetBase.h` | 동적 탭 등록 (`FFIBTabDescriptor`) |
| `UFIBTabButtonBase` | `UI/Common/FIBTabButtonBase.h` | `UFIBButtonBase` + `IFIBTabButtonInterface`, 아이콘 |
| `UFIBBoundActionButton` | `UI/Common/FIBBoundActionButton.h` | 입력 방식별 스타일(KB/Pad/Touch) |
| `UFIBEditableTextBox` | `UI/Foundation/FIBEditableTextBox.h` | `UEditableTextBox` |

### 상속 확장 예시

```cpp
UCLASS(Abstract, BlueprintType, Blueprintable)
class PROJECTFIB_API UFIBIconButton : public UFIBButtonBase
{
    GENERATED_BODY()

public:
    UFUNCTION(BlueprintCallable)
    void SetIcon(UTexture2D* InIcon);

protected:
    UPROPERTY(BlueprintReadOnly, meta = (BindWidget))
    TObjectPtr<UImage> Img_Icon;
};
```

---

## 8. 주요 파일 위치

### 베이스 클래스
- `Source/ProjectFIB/UI/FIBActivatableWidget.h` — 입력 모드 지원 활성화 위젯
- `Source/ProjectFIB/UI/Common/Widget/FIBCommonActivatableWidget.h` — 활성화 위젯 래퍼
- `Source/ProjectFIB/UI/Common/Widget/FIBCommonUserWidget.h` — 유저 위젯 래퍼
- `Source/ProjectFIB/UI/Foundation/FIBButtonBase.h`
- `Source/ProjectFIB/UI/Common/FIBCommonTextBlock.h`

### UI 관리
- `Source/ProjectFIB/UI/FIBGameUIPolicy.h`
- `Source/ProjectFIB/UI/FIBUIManagerSubsystem.h`
- `Source/ProjectFIB/GameFeatures/GameFeatureAction_AddWidget.h`

### HUD
- `Source/ProjectFIB/UI/HUD/FIBHUDLayout.h`
- `Source/ProjectFIB/UI/HUD/FIBHUD.h`

### 참고 패턴
- `Source/ProjectFIB/UI/IndicatorSystem/SActorCanvas.h` — SWidget 커스텀 예시
- `Source/ProjectFIB/UI/IndicatorSystem/IndicatorLayer.h` — UWidget 래퍼 예시
- `Source/ProjectFIB/UI/Lobby/FIBSessionListWidget.h` — ListView 엔트리 예시
- `Source/ProjectFIB/UI/Object/FIBSessionListItem.h` — 리스트 데이터 객체 예시

### 시스템 브릿지 ViewModel 예시
- `Source/ProjectFIB/Character/FIBHealthComponent.h`
- `Source/ProjectFIB/Inventory/FIBInventoryManagerComponent.h`

---

## 9. 주의사항 및 디버깅

### 메모리 관리
- ViewModel은 `UObject` 상속이므로 반드시 `UPROPERTY()`로 참조
- 리스폰 가능한 컴포넌트 참조는 `TWeakObjectPtr` 사용
- ListView 데이터 객체는 View가 Outer로 생성 (`NewObject<T>(this)`)

### 바인딩 규칙
- **항상** `NativeOnActivated`에서 바인딩, `NativeOnDeactivated`에서 해제
- HUD 요소 (`UFIBCommonUserWidget`)는 `NativeConstruct`/`NativeDestruct` 사용
- `RemoveDynamic` 전에 컴포넌트 유효성 체크 필수

### 네트워크
- 서버 권위 데이터는 복제된 값만 사용
- InventoryManager는 PlayerState에 위치 (모든 클라이언트에 복제)
- HealthComponent의 델리게이트는 클라이언트에서도 호출됨

### 코드 규칙
- 모든 코드 주석은 영어로 작성
- FIB 프리픽스 준수 (UFIB / FFIB / EFIB / IFIB / AFIB)
- `PROJECTFIB_API` 매크로 포함
- `#include UE_INLINE_GENERATED_CPP_BY_NAME(ClassName)` 사용

### 디버깅 명령
```
WidgetReflector            // 위젯 계층 구조
CommonUI.Debug 1           // CommonUI 디버그
Slate.ShowFocusedWidget 1  // 포커스 확인
```

### ViewModel 디버그 로깅 패턴
```cpp
void UFIBInventoryViewModel::HandleInventoryChanged()
{
    UE_LOG(LogUI, Verbose, TEXT("[%s] Inventory changed, item count: %d"),
        *GetName(), GetTotalItemCount());
    NotifyPropertyChanged(FName("Items"));
}
```

---

## 관련 스킬

- [skills/_template.md](../_template.md) — 스킬 작성 표준 (≤500줄 정책)
- [skills/harness-audit](../harness-audit/SKILL.md) — drift 검사 (B 카테고리 줄수 검사)
- [team/ui/README.md](../../team/ui/README.md) — UI 도메인 팀 (Pattern: Hybrid)
