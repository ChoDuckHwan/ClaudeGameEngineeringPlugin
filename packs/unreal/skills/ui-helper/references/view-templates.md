## 3. View 템플릿

### 3.1 전체화면 위젯 (메뉴/설정)

`UFIBActivatableWidget` 상속. 메뉴, 설정, 인벤토리 화면 등 전체화면 UI에 사용.

**헤더 파일 (.h)**
```cpp
// Copyright Epic Games, Inc. All Rights Reserved.

#pragma once

#include "UI/FIBActivatableWidget.h"
#include "YourScreenWidget.generated.h"

class UFIBViewModel;
class UFIBButtonBase;
class UFIBCommonTextBlock;

UCLASS(Abstract, BlueprintType, Blueprintable)
class PROJECTFIB_API UYourScreenWidget : public UFIBActivatableWidget
{
	GENERATED_BODY()

public:
	UYourScreenWidget(const FObjectInitializer& ObjectInitializer);

protected:
	virtual void NativeOnActivated() override;
	virtual void NativeOnDeactivated() override;

	// ViewModel property change handler
	UFUNCTION()
	void HandleViewModelPropertyChanged(UFIBViewModel* InViewModel, FName PropertyName);

	// Refresh all UI elements from ViewModel
	void RefreshUI();

	// Back button handler
	UFUNCTION()
	void OnBackButtonClicked();

protected:
	UPROPERTY(BlueprintReadOnly, meta = (BindWidget))
	TObjectPtr<UFIBButtonBase> Btn_Back;

	UPROPERTY(BlueprintReadOnly, meta = (BindWidgetOptional))
	TObjectPtr<UFIBCommonTextBlock> TB_Title;

private:
	UPROPERTY()
	TObjectPtr<UFIBViewModel> ViewModel;
};
```

**소스 파일 (.cpp)**
```cpp
// Copyright Epic Games, Inc. All Rights Reserved.

#include "YourScreenWidget.h"
#include "UI/FIBViewModel.h"
#include "UI/Foundation/FIBButtonBase.h"
#include "CommonUIExtensions.h"

#include UE_INLINE_GENERATED_CPP_BY_NAME(YourScreenWidget)

UYourScreenWidget::UYourScreenWidget(const FObjectInitializer& ObjectInitializer)
	: Super(ObjectInitializer)
{
	// Menu input mode: UI receives all input
	InputConfig = EFIBWidgetInputMode::Menu;
}

void UYourScreenWidget::NativeOnActivated()
{
	Super::NativeOnActivated();

	// Create and initialize ViewModel
	ViewModel = NewObject<UFIBViewModel>(this, UYourViewModel::StaticClass());
	ViewModel->Initialize(GetOwningPlayer());
	ViewModel->OnPropertyChanged.AddDynamic(this, &ThisClass::HandleViewModelPropertyChanged);

	// Bind buttons
	if (Btn_Back)
	{
		Btn_Back->OnClicked().AddUObject(this, &ThisClass::OnBackButtonClicked);
	}

	// Initial UI refresh
	RefreshUI();
}

void UYourScreenWidget::NativeOnDeactivated()
{
	// Unbind ViewModel
	if (ViewModel)
	{
		ViewModel->OnPropertyChanged.RemoveDynamic(this, &ThisClass::HandleViewModelPropertyChanged);
		ViewModel->Deinitialize();
		ViewModel = nullptr;
	}

	// Unbind buttons
	if (Btn_Back)
	{
		Btn_Back->OnClicked().RemoveAll(this);
	}

	Super::NativeOnDeactivated();
}

void UYourScreenWidget::HandleViewModelPropertyChanged(UFIBViewModel* InViewModel, FName PropertyName)
{
	// Handle specific property changes or refresh all
	RefreshUI();
}

void UYourScreenWidget::RefreshUI()
{
	// Update UI elements from ViewModel data
}

void UYourScreenWidget::OnBackButtonClicked()
{
	DeactivateWidget();
}
```

### 3.2 HUD 요소 위젯 (게임 오버레이)

`UFIBCommonUserWidget` 상속. HP바, 미니맵, 상태 표시 등에 사용.
시스템 컴포넌트를 직접 ViewModel로 사용하는 패턴.

**헤더 파일 (.h)**
```cpp
// Copyright Epic Games, Inc. All Rights Reserved.

#pragma once

#include "UI/Common/Widget/FIBCommonUserWidget.h"
#include "YourHUDElement.generated.h"

class UFIBHealthComponent;
class UProgressBar;
class UFIBCommonTextBlock;

UCLASS(Abstract, BlueprintType, Blueprintable)
class PROJECTFIB_API UYourHUDElement : public UFIBCommonUserWidget
{
	GENERATED_BODY()

protected:
	virtual void NativeConstruct() override;
	virtual void NativeDestruct() override;

	// Health change handler (System Bridge ViewModel pattern)
	UFUNCTION()
	void HandleHealthChanged(UFIBHealthComponent* HealthComp, float OldValue, float NewValue, AActor* Instigator);

	UFUNCTION()
	void HandleMaxHealthChanged(UFIBHealthComponent* HealthComp, float OldValue, float NewValue, AActor* Instigator);

	// Update UI from current values
	UFUNCTION(BlueprintImplementableEvent)
	void OnHealthUpdated(float CurrentHealth, float MaxHealth, float HealthPercent);

protected:
	UPROPERTY(BlueprintReadOnly, meta = (BindWidgetOptional))
	TObjectPtr<UProgressBar> PB_Health;

	UPROPERTY(BlueprintReadOnly, meta = (BindWidgetOptional))
	TObjectPtr<UFIBCommonTextBlock> TB_HealthText;

private:
	UPROPERTY()
	TWeakObjectPtr<UFIBHealthComponent> CachedHealthComponent;
};
```

**소스 파일 (.cpp)**
```cpp
// Copyright Epic Games, Inc. All Rights Reserved.

#include "YourHUDElement.h"
#include "Character/FIBHealthComponent.h"
#include "Components/ProgressBar.h"

#include UE_INLINE_GENERATED_CPP_BY_NAME(YourHUDElement)

void UYourHUDElement::NativeConstruct()
{
	Super::NativeConstruct();

	// System Bridge: bind directly to HealthComponent as ViewModel
	if (APawn* Pawn = GetOwningPlayerPawn())
	{
		if (UFIBHealthComponent* HC = UFIBHealthComponent::FindHealthComponent(Pawn))
		{
			CachedHealthComponent = HC;
			HC->OnHealthChanged.AddDynamic(this, &ThisClass::HandleHealthChanged);
			HC->OnMaxHealthChanged.AddDynamic(this, &ThisClass::HandleMaxHealthChanged);

			// Initial update
			OnHealthUpdated(HC->GetHealth(), HC->GetMaxHealth(), HC->GetHealthNormalized());
		}
	}
}

void UYourHUDElement::NativeDestruct()
{
	// Unbind from HealthComponent
	if (UFIBHealthComponent* HC = CachedHealthComponent.Get())
	{
		HC->OnHealthChanged.RemoveDynamic(this, &ThisClass::HandleHealthChanged);
		HC->OnMaxHealthChanged.RemoveDynamic(this, &ThisClass::HandleMaxHealthChanged);
	}
	CachedHealthComponent.Reset();

	Super::NativeDestruct();
}

void UYourHUDElement::HandleHealthChanged(UFIBHealthComponent* HealthComp, float OldValue, float NewValue, AActor* Instigator)
{
	if (HealthComp)
	{
		const float MaxHealth = HealthComp->GetMaxHealth();
		const float Percent = (MaxHealth > 0.0f) ? (NewValue / MaxHealth) : 0.0f;

		if (PB_Health)
		{
			PB_Health->SetPercent(Percent);
		}

		OnHealthUpdated(NewValue, MaxHealth, Percent);
	}
}

void UYourHUDElement::HandleMaxHealthChanged(UFIBHealthComponent* HealthComp, float OldValue, float NewValue, AActor* Instigator)
{
	if (HealthComp)
	{
		const float CurrentHealth = HealthComp->GetHealth();
		const float Percent = (NewValue > 0.0f) ? (CurrentHealth / NewValue) : 0.0f;

		if (PB_Health)
		{
			PB_Health->SetPercent(Percent);
		}

		OnHealthUpdated(CurrentHealth, NewValue, Percent);
	}
}
```

### 3.3 리스트 아이템 위젯 (ListView 엔트리)

`UFIBCommonUserWidget` + `IUserObjectListEntry` 상속. ListView 항목 표시에 사용.
기존 `UFIBSessionListWidget` 패턴을 따른다.

**리스트 데이터 객체 (.h)**
```cpp
// Copyright Epic Games, Inc. All Rights Reserved.

#pragma once

#include "CoreMinimal.h"
#include "YourListItemData.generated.h"

// Data object for ListView entry (follows UFIBSessionListItem pattern)
UCLASS()
class PROJECTFIB_API UYourListItemData : public UObject
{
	GENERATED_BODY()

public:
	UPROPERTY(BlueprintReadOnly, Category = "Data")
	FText DisplayName;

	UPROPERTY(BlueprintReadOnly, Category = "Data")
	int32 Quantity = 0;

	UPROPERTY(BlueprintReadOnly, Category = "Data")
	int32 ItemIndex = INDEX_NONE;

	// Initialize from source data
	void SetData(const FText& InName, int32 InQuantity, int32 InIndex);
};
```

**리스트 데이터 객체 (.cpp)**
```cpp
// Copyright Epic Games, Inc. All Rights Reserved.

#include "YourListItemData.h"

#include UE_INLINE_GENERATED_CPP_BY_NAME(YourListItemData)

void UYourListItemData::SetData(const FText& InName, int32 InQuantity, int32 InIndex)
{
	DisplayName = InName;
	Quantity = InQuantity;
	ItemIndex = InIndex;
}
```

**리스트 아이템 위젯 (.h)**
```cpp
// Copyright Epic Games, Inc. All Rights Reserved.

#pragma once

#include "UI/Common/Widget/FIBCommonUserWidget.h"
#include "Blueprint/IUserObjectListEntry.h"
#include "YourListItemWidget.generated.h"

class UFIBCommonTextBlock;
class UFIBButtonBase;
class UYourListItemData;

UCLASS(Abstract, BlueprintType, Blueprintable)
class PROJECTFIB_API UYourListItemWidget : public UFIBCommonUserWidget, public IUserObjectListEntry
{
	GENERATED_BODY()

protected:
	// IUserObjectListEntry interface
	virtual void NativeOnListItemObjectSet(UObject* ListItemObject) override;
	virtual void NativeOnEntryReleased() override;
	// End IUserObjectListEntry

	UPROPERTY(BlueprintReadOnly, meta = (BindWidget))
	TObjectPtr<UFIBCommonTextBlock> TB_Name;

	UPROPERTY(BlueprintReadOnly, meta = (BindWidget))
	TObjectPtr<UFIBCommonTextBlock> TB_Quantity;

	UPROPERTY(BlueprintReadOnly, meta = (BindWidgetOptional))
	TObjectPtr<UFIBButtonBase> Btn_Action;

private:
	UPROPERTY()
	TObjectPtr<UYourListItemData> DataObject;

	UFUNCTION()
	void OnActionButtonClicked();
};
```

**리스트 아이템 위젯 (.cpp)**
```cpp
// Copyright Epic Games, Inc. All Rights Reserved.

#include "YourListItemWidget.h"
#include "YourListItemData.h"
#include "UI/Common/FIBCommonTextBlock.h"
#include "UI/Foundation/FIBButtonBase.h"

#include UE_INLINE_GENERATED_CPP_BY_NAME(YourListItemWidget)

void UYourListItemWidget::NativeOnListItemObjectSet(UObject* ListItemObject)
{
	IUserObjectListEntry::NativeOnListItemObjectSet(ListItemObject);

	DataObject = Cast<UYourListItemData>(ListItemObject);
	if (!DataObject)
	{
		return;
	}

	// Update UI from data
	if (TB_Name)
	{
		TB_Name->SetText(DataObject->DisplayName);
	}

	if (TB_Quantity)
	{
		TB_Quantity->SetText(FText::AsNumber(DataObject->Quantity));
	}

	// Bind button
	if (Btn_Action)
	{
		Btn_Action->OnClicked().AddUObject(this, &ThisClass::OnActionButtonClicked);
	}
}

void UYourListItemWidget::NativeOnEntryReleased()
{
	IUserObjectListEntry::NativeOnEntryReleased();

	// Unbind button
	if (Btn_Action)
	{
		Btn_Action->OnClicked().RemoveAll(this);
	}

	DataObject = nullptr;
}

void UYourListItemWidget::OnActionButtonClicked()
{
	if (DataObject)
	{
		// Handle action (e.g., select item, use item)
	}
}
```

### 3.4 모달/팝업 위젯

`UFIBActivatableWidget` 상속. 확인/취소 대화상자, 정보 팝업 등에 사용.

**헤더 파일 (.h)**
```cpp
// Copyright Epic Games, Inc. All Rights Reserved.

#pragma once

#include "UI/FIBActivatableWidget.h"
#include "YourModalWidget.generated.h"

class UFIBButtonBase;
class UFIBCommonTextBlock;

DECLARE_DYNAMIC_MULTICAST_DELEGATE_OneParam(FFIBModalResult, bool, bConfirmed);

UCLASS(Abstract, BlueprintType, Blueprintable)
class PROJECTFIB_API UYourModalWidget : public UFIBActivatableWidget
{
	GENERATED_BODY()

public:
	UYourModalWidget(const FObjectInitializer& ObjectInitializer);

	// Set modal content
	UFUNCTION(BlueprintCallable, Category = "FIB|Modal")
	void SetMessage(const FText& InTitle, const FText& InMessage);

	// Result delegate
	UPROPERTY(BlueprintAssignable, Category = "FIB|Modal")
	FFIBModalResult OnModalResult;

protected:
	virtual void NativeOnActivated() override;
	virtual void NativeOnDeactivated() override;

	UFUNCTION()
	void OnConfirmClicked();

	UFUNCTION()
	void OnCancelClicked();

protected:
	UPROPERTY(BlueprintReadOnly, meta = (BindWidget))
	TObjectPtr<UFIBCommonTextBlock> TB_Title;

	UPROPERTY(BlueprintReadOnly, meta = (BindWidget))
	TObjectPtr<UFIBCommonTextBlock> TB_Message;

	UPROPERTY(BlueprintReadOnly, meta = (BindWidget))
	TObjectPtr<UFIBButtonBase> Btn_Confirm;

	UPROPERTY(BlueprintReadOnly, meta = (BindWidget))
	TObjectPtr<UFIBButtonBase> Btn_Cancel;
};
```

**소스 파일 (.cpp)**
```cpp
// Copyright Epic Games, Inc. All Rights Reserved.

#include "YourModalWidget.h"
#include "UI/Foundation/FIBButtonBase.h"
#include "UI/Common/FIBCommonTextBlock.h"

#include UE_INLINE_GENERATED_CPP_BY_NAME(YourModalWidget)

UYourModalWidget::UYourModalWidget(const FObjectInitializer& ObjectInitializer)
	: Super(ObjectInitializer)
{
	InputConfig = EFIBWidgetInputMode::Menu;
}

void UYourModalWidget::SetMessage(const FText& InTitle, const FText& InMessage)
{
	if (TB_Title)
	{
		TB_Title->SetText(InTitle);
	}
	if (TB_Message)
	{
		TB_Message->SetText(InMessage);
	}
}

void UYourModalWidget::NativeOnActivated()
{
	Super::NativeOnActivated();

	if (Btn_Confirm)
	{
		Btn_Confirm->OnClicked().AddUObject(this, &ThisClass::OnConfirmClicked);
	}
	if (Btn_Cancel)
	{
		Btn_Cancel->OnClicked().AddUObject(this, &ThisClass::OnCancelClicked);
	}
}

void UYourModalWidget::NativeOnDeactivated()
{
	if (Btn_Confirm)
	{
		Btn_Confirm->OnClicked().RemoveAll(this);
	}
	if (Btn_Cancel)
	{
		Btn_Cancel->OnClicked().RemoveAll(this);
	}

	Super::NativeOnDeactivated();
}

void UYourModalWidget::OnConfirmClicked()
{
	OnModalResult.Broadcast(true);
	DeactivateWidget();
}

void UYourModalWidget::OnCancelClicked()
{
	OnModalResult.Broadcast(false);
	DeactivateWidget();
}
```

**모달 표시 방법 (호출측 코드)**
```cpp
// Push modal to Modal layer
#include "CommonUIExtensions.h"

UCommonUIExtensions::PushStreamedContentToLayerForPlayer(
    GetOwningLocalPlayer(),
    FGameplayTag::RequestGameplayTag("UI.Layer.Modal"),
    ModalWidgetClass);
```

### 3.5 커스텀 SWidget (Slate 기반)

`SCompoundWidget` 상속 + `UWidget` 래퍼.
프로젝트의 `SActorCanvas` / `UIndicatorLayer` 패턴을 따른다.

**Slate 위젯 (.h)**
```cpp
// Copyright Epic Games, Inc. All Rights Reserved.

#pragma once

#include "Widgets/SCompoundWidget.h"

// Custom Slate widget for specialized rendering
class SFIBCustomWidget : public SCompoundWidget
{
public:
	SLATE_BEGIN_ARGS(SFIBCustomWidget) {}
		SLATE_ARGUMENT(FText, LabelText)
	SLATE_END_ARGS()

	void Construct(const FArguments& InArgs);

	void SetLabelText(const FText& InText);

private:
	TSharedPtr<STextBlock> LabelTextBlock;
};
```

**Slate 위젯 (.cpp)**
```cpp
// Copyright Epic Games, Inc. All Rights Reserved.

#include "SFIBCustomWidget.h"
#include "Widgets/Text/STextBlock.h"
#include "Widgets/Layout/SBox.h"

void SFIBCustomWidget::Construct(const FArguments& InArgs)
{
	ChildSlot
	[
		SNew(SBox)
		.Padding(8.0f)
		[
			SAssignNew(LabelTextBlock, STextBlock)
			.Text(InArgs._LabelText)
		]
	];
}

void SFIBCustomWidget::SetLabelText(const FText& InText)
{
	if (LabelTextBlock.IsValid())
	{
		LabelTextBlock->SetText(InText);
	}
}
```

**UWidget 래퍼 (.h) - UIndicatorLayer 패턴**
```cpp
// Copyright Epic Games, Inc. All Rights Reserved.

#pragma once

#include "Components/Widget.h"
#include "FIBCustomWidgetWrapper.generated.h"

class SFIBCustomWidget;

UCLASS()
class PROJECTFIB_API UFIBCustomWidgetWrapper : public UWidget
{
	GENERATED_UCLASS_BODY()

public:
	UPROPERTY(EditAnywhere, BlueprintReadOnly, Category = "Appearance")
	FText LabelText;

	UFUNCTION(BlueprintCallable, Category = "FIB|Widget")
	void SetLabelText(const FText& InText);

protected:
	// UWidget interface
	virtual void ReleaseSlateResources(bool bReleaseChildren) override;
	virtual TSharedRef<SWidget> RebuildWidget() override;
	// End UWidget

private:
	TSharedPtr<SFIBCustomWidget> MySlateWidget;
};
```

**UWidget 래퍼 (.cpp)**
```cpp
// Copyright Epic Games, Inc. All Rights Reserved.

#include "FIBCustomWidgetWrapper.h"
#include "SFIBCustomWidget.h"

#include UE_INLINE_GENERATED_CPP_BY_NAME(FIBCustomWidgetWrapper)

UFIBCustomWidgetWrapper::UFIBCustomWidgetWrapper(const FObjectInitializer& ObjectInitializer)
	: Super(ObjectInitializer)
{
}

void UFIBCustomWidgetWrapper::SetLabelText(const FText& InText)
{
	LabelText = InText;
	if (MySlateWidget.IsValid())
	{
		MySlateWidget->SetLabelText(InText);
	}
}

void UFIBCustomWidgetWrapper::ReleaseSlateResources(bool bReleaseChildren)
{
	Super::ReleaseSlateResources(bReleaseChildren);
	MySlateWidget.Reset();
}

TSharedRef<SWidget> UFIBCustomWidgetWrapper::RebuildWidget()
{
	MySlateWidget = SNew(SFIBCustomWidget)
		.LabelText(LabelText);

	return MySlateWidget.ToSharedRef();
}
```

---

