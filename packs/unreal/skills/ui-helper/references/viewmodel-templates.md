## 4. ViewModel 템플릿

### 4.1 UI 전용 ViewModel

별도의 프레젠테이션 로직이 필요한 경우.
Model(InventoryManager 등)의 데이터를 View에 맞게 변환.

**위치**: `Source/ProjectFIB/UI/<FeatureName>/FIB<Feature>ViewModel.h/.cpp`

**헤더 파일 (.h)**
```cpp
// Copyright Epic Games, Inc. All Rights Reserved.

#pragma once

#include "UI/FIBViewModel.h"
#include "GameplayTagContainer.h"
#include "FIBInventoryViewModel.generated.h"

class UFIBInventoryManagerComponent;
class UFIBInventoryItemInstance;
struct FGameplayTag;

UCLASS()
class PROJECTFIB_API UFIBInventoryViewModel : public UFIBViewModel
{
	GENERATED_BODY()

public:
	virtual void Initialize(UObject* InOwner) override;
	virtual void Deinitialize() override;

	// View-facing API
	UFUNCTION(BlueprintPure, Category = "FIB|Inventory")
	TArray<UFIBInventoryItemInstance*> GetDisplayItems() const;

	UFUNCTION(BlueprintPure, Category = "FIB|Inventory")
	int32 GetSelectedSlotIndex() const;

	UFUNCTION(BlueprintPure, Category = "FIB|Inventory")
	UFIBInventoryItemInstance* GetSelectedItem() const;

	UFUNCTION(BlueprintPure, Category = "FIB|Inventory")
	int32 GetTotalItemCount() const;

	// View commands
	UFUNCTION(BlueprintCallable, Category = "FIB|Inventory")
	void SelectSlot(int32 SlotIndex);

	UFUNCTION(BlueprintCallable, Category = "FIB|Inventory")
	void UseSelectedItem();

private:
	void SetupListeners();
	void TeardownListeners();

	UFUNCTION()
	void HandleInventoryChanged();

	UPROPERTY()
	TWeakObjectPtr<UFIBInventoryManagerComponent> InventoryManager;
};
```

**소스 파일 (.cpp)**
```cpp
// Copyright Epic Games, Inc. All Rights Reserved.

#include "UI/Inventory/FIBInventoryViewModel.h"
#include "Inventory/FIBInventoryManagerComponent.h"
#include "Inventory/FIBInventoryItemInstance.h"
#include "Player/FIBPlayerState.h"

#include UE_INLINE_GENERATED_CPP_BY_NAME(FIBInventoryViewModel)

void UFIBInventoryViewModel::Initialize(UObject* InOwner)
{
	Super::Initialize(InOwner);

	// Find the InventoryManager from the PlayerState (Model)
	if (APlayerController* PC = Cast<APlayerController>(InOwner))
	{
		if (AFIBPlayerState* PS = PC->GetPlayerState<AFIBPlayerState>())
		{
			InventoryManager = PS->FindComponentByClass<UFIBInventoryManagerComponent>();
		}
	}

	SetupListeners();
}

void UFIBInventoryViewModel::Deinitialize()
{
	TeardownListeners();
	InventoryManager.Reset();

	Super::Deinitialize();
}

TArray<UFIBInventoryItemInstance*> UFIBInventoryViewModel::GetDisplayItems() const
{
	if (UFIBInventoryManagerComponent* InvMgr = InventoryManager.Get())
	{
		return InvMgr->GetAllItems();
	}
	return TArray<UFIBInventoryItemInstance*>();
}

int32 UFIBInventoryViewModel::GetSelectedSlotIndex() const
{
	if (UFIBInventoryManagerComponent* InvMgr = InventoryManager.Get())
	{
		return InvMgr->GetCurrentSelectedSlotIndex();
	}
	return INDEX_NONE;
}

UFIBInventoryItemInstance* UFIBInventoryViewModel::GetSelectedItem() const
{
	if (UFIBInventoryManagerComponent* InvMgr = InventoryManager.Get())
	{
		return InvMgr->GetItemInSlot(InvMgr->GetCurrentSelectedSlotIndex());
	}
	return nullptr;
}

int32 UFIBInventoryViewModel::GetTotalItemCount() const
{
	if (UFIBInventoryManagerComponent* InvMgr = InventoryManager.Get())
	{
		return InvMgr->GetAllItems().Num();
	}
	return 0;
}

void UFIBInventoryViewModel::SelectSlot(int32 SlotIndex)
{
	if (UFIBInventoryManagerComponent* InvMgr = InventoryManager.Get())
	{
		InvMgr->SetCurrentSelectedSlotIndex(SlotIndex);
		NotifyPropertyChanged(GET_MEMBER_NAME_CHECKED(UFIBInventoryViewModel, InventoryManager));
	}
}

void UFIBInventoryViewModel::UseSelectedItem()
{
	// Delegate to InventoryManager
	if (UFIBInventoryManagerComponent* InvMgr = InventoryManager.Get())
	{
		// Use item logic via ASC
	}
}

void UFIBInventoryViewModel::SetupListeners()
{
	// Listen for inventory changes via the InventoryManager's delegates or GameplayMessage
}

void UFIBInventoryViewModel::TeardownListeners()
{
	// Remove all listeners
}

void UFIBInventoryViewModel::HandleInventoryChanged()
{
	NotifyPropertyChanged(FName("Items"));
}
```

### 4.2 시스템 브릿지 패턴 (새 클래스 불필요)

기존 컴포넌트가 ViewModel 역할을 하는 경우. **새 클래스를 만들지 않는다.**
View에서 기존 컴포넌트의 델리게이트에 직접 바인딩.

**HP 바 연결 패턴**
```cpp
// View의 NativeConstruct 또는 NativeOnActivated에서:
if (APawn* Pawn = GetOwningPlayerPawn())
{
    if (UFIBHealthComponent* HC = UFIBHealthComponent::FindHealthComponent(Pawn))
    {
        // HealthComponent가 ViewModel 역할
        HC->OnHealthChanged.AddDynamic(this, &ThisClass::HandleHealthChanged);
        HC->OnMaxHealthChanged.AddDynamic(this, &ThisClass::HandleMaxHealthChanged);

        // Initial update
        OnHealthUpdated(HC->GetHealth(), HC->GetMaxHealth(), HC->GetHealthNormalized());
    }
}
```

**팀 정보 연결 패턴**
```cpp
// View에서 TeamSubsystem을 직접 쿼리:
if (UWorld* World = GetWorld())
{
    if (UFIBTeamSubsystem* TeamSub = World->GetSubsystem<UFIBTeamSubsystem>())
    {
        // TeamSubsystem이 Model, 직접 접근
        int32 TeamId = TeamSub->FindTeamFromObject(GetOwningPlayerPawn());
    }
}
```

### 4.3 리스트 데이터 객체

ListView용 UObject 래퍼. `UFIBSessionListItem` 패턴을 따른다.
섹션 3.3의 `UYourListItemData` 참조.

**사용 패턴 (ListView에 데이터 채우기)**
```cpp
// View 또는 ViewModel에서 ListView 데이터 생성
void UMyListView::PopulateList(const TArray<UFIBInventoryItemInstance*>& Items)
{
    if (!ListView) return;

    ListView->ClearListItems();

    for (UFIBInventoryItemInstance* Item : Items)
    {
        UYourListItemData* DataObj = NewObject<UYourListItemData>(this);
        DataObj->SetData(
            Item->GetItemDef()->GetDisplayName(),
            Item->GetStatTagStackCount(TAG_Item_Count),
            Items.IndexOfByKey(Item)
        );
        ListView->AddItem(DataObj);
    }
}
```

---

