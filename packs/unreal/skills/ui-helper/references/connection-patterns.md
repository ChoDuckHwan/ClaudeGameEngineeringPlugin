## 5. 연결 패턴

### 5.1 델리게이트 바인딩

컴포넌트의 델리게이트에 직접 바인딩. 가장 직접적인 방식.

```cpp
// NativeOnActivated 또는 NativeConstruct에서 바인딩
void UMyWidget::NativeOnActivated()
{
    Super::NativeOnActivated();

    if (UFIBHealthComponent* HC = GetHealthComponent())
    {
        HC->OnHealthChanged.AddDynamic(this, &ThisClass::HandleHealthChanged);
    }
}

// NativeOnDeactivated 또는 NativeDestruct에서 해제
void UMyWidget::NativeOnDeactivated()
{
    if (UFIBHealthComponent* HC = CachedHealthComp.Get())
    {
        HC->OnHealthChanged.RemoveDynamic(this, &ThisClass::HandleHealthChanged);
    }

    Super::NativeOnDeactivated();
}
```

### 5.2 Gameplay Message 바인딩

느슨한 결합. 시스템 간 통신에 적합.
인벤토리 변경 (`FFIBInventoryChangeMessage`) 등에 사용.

```cpp
#include "GameFramework/GameplayMessageSubsystem.h"

void UMyWidget::NativeOnActivated()
{
    Super::NativeOnActivated();

    // Register for inventory change messages
    if (UWorld* World = GetWorld())
    {
        UGameplayMessageSubsystem& MessageSystem = UGameplayMessageSubsystem::Get(World);
        InventoryListenerHandle = MessageSystem.RegisterListener(
            TAG_FIB_Inventory_Message_StackChanged,
            this, &ThisClass::HandleInventoryMessage);
    }
}

void UMyWidget::NativeOnDeactivated()
{
    // Unregister message listener
    if (InventoryListenerHandle.IsValid())
    {
        if (UWorld* World = GetWorld())
        {
            UGameplayMessageSubsystem& MessageSystem = UGameplayMessageSubsystem::Get(World);
            MessageSystem.UnregisterListener(InventoryListenerHandle);
        }
        InventoryListenerHandle.Reset();
    }

    Super::NativeOnDeactivated();
}

void UMyWidget::HandleInventoryMessage(FGameplayTag Channel, const FFIBInventoryChangeMessage& Message)
{
    // Update UI based on inventory change
    RefreshInventoryDisplay();
}
```

### 5.3 ViewModel PropertyChanged 바인딩

`UFIBViewModel::OnPropertyChanged`를 사용한 패턴.

```cpp
void UMyWidget::NativeOnActivated()
{
    Super::NativeOnActivated();

    // Create ViewModel and bind
    ViewModel = NewObject<UMyViewModel>(this);
    ViewModel->Initialize(GetOwningPlayer());
    ViewModel->OnPropertyChanged.AddDynamic(this, &ThisClass::HandlePropertyChanged);

    RefreshUI();
}

void UMyWidget::NativeOnDeactivated()
{
    if (ViewModel)
    {
        ViewModel->OnPropertyChanged.RemoveDynamic(this, &ThisClass::HandlePropertyChanged);
        ViewModel->Deinitialize();
        ViewModel = nullptr;
    }

    Super::NativeOnDeactivated();
}

void UMyWidget::HandlePropertyChanged(UFIBViewModel* InVM, FName PropertyName)
{
    if (PropertyName == FName("Items"))
    {
        RefreshItemList();
    }
    else if (PropertyName == FName("SelectedSlot"))
    {
        RefreshSlotHighlight();
    }
    else
    {
        // Unknown property - refresh all
        RefreshUI();
    }
}
```

---

## 6. Game Feature 연동

### UGameFeatureAction_AddWidgets를 통한 위젯 추가

**HUD 레이아웃 추가 (Experience Data Asset에서)**
```
Layout:
  - LayoutClass: /Game/UI/HUD/W_MyHUDLayout (UFIBActivatableWidget 서브클래스)
    LayerID: UI.Layer.Game
```

**개별 HUD 요소 추가**
```
Widgets:
  - WidgetClass: /Game/UI/HUD/W_HealthBar (UUserWidget 서브클래스)
    SlotID: UI.Slot.HUD.HealthBar (UIExtension 슬롯 태그)
```

### C++에서 레이어에 위젯 푸시

```cpp
#include "CommonUIExtensions.h"

// Menu 레이어에 위젯 푸시
UCommonUIExtensions::PushStreamedContentToLayerForPlayer(
    GetOwningLocalPlayer(),
    FGameplayTag::RequestGameplayTag("UI.Layer.Menu"),
    MenuWidgetClass);

// Modal 레이어에 위젯 푸시
UCommonUIExtensions::PushStreamedContentToLayerForPlayer(
    GetOwningLocalPlayer(),
    FGameplayTag::RequestGameplayTag("UI.Layer.Modal"),
    ModalWidgetClass);
```

---

