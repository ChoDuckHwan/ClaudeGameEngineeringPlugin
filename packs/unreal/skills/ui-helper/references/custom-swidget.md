## 7. 커스텀 SWidget 패턴

### 7.1 무한 스크롤 리스트 (SPanel 기반)

UObject를 Model로 사용하지 않는 가상화 리스트. `SActorCanvas` 패턴 참고.

**Slate 위젯 (.h)**
```cpp
// Copyright Epic Games, Inc. All Rights Reserved.

#pragma once

#include "Widgets/SPanel.h"

DECLARE_DELEGATE_RetVal_OneParam(TSharedRef<SWidget>, FOnGenerateRow, int32 /* ItemIndex */);
DECLARE_DELEGATE_RetVal(int32, FOnGetItemCount);

class SFIBVirtualizedList : public SPanel
{
public:
	class FSlot : public TSlotBase<FSlot>
	{
	public:
		FSlot(int32 InItemIndex)
			: TSlotBase<FSlot>()
			, ItemIndex(InItemIndex)
		{
		}

		SLATE_SLOT_BEGIN_ARGS(FSlot, TSlotBase<FSlot>)
		SLATE_SLOT_END_ARGS()
		using TSlotBase<FSlot>::Construct;

		int32 GetItemIndex() const { return ItemIndex; }

	private:
		int32 ItemIndex;
	};

	SLATE_BEGIN_ARGS(SFIBVirtualizedList) {}
		SLATE_EVENT(FOnGenerateRow, OnGenerateRow)
		SLATE_EVENT(FOnGetItemCount, OnGetItemCount)
		SLATE_ARGUMENT(float, ItemHeight)
	SLATE_END_ARGS()

	void Construct(const FArguments& InArgs);

	// SWidget interface
	virtual void OnArrangeChildren(const FGeometry& AllottedGeometry, FArrangedChildren& ArrangedChildren) const override;
	virtual FVector2D ComputeDesiredSize(float) const override;
	virtual FChildren* GetChildren() override { return &Children; }
	virtual FReply OnMouseWheel(const FGeometry& MyGeometry, const FPointerEvent& MouseEvent) override;
	// End SWidget

	void ScrollTo(float Offset);
	void RefreshList();

private:
	void RebuildVisibleChildren(const FGeometry& AllottedGeometry);

	TPanelChildren<FSlot> Children;
	FOnGenerateRow OnGenerateRow;
	FOnGetItemCount OnGetItemCount;

	float ItemHeight = 40.0f;
	float ScrollOffset = 0.0f;
	int32 FirstVisibleIndex = 0;
	int32 VisibleCount = 0;
};
```

### 7.2 UWidget 래퍼 (IndicatorLayer 패턴)

```cpp
UCLASS()
class PROJECTFIB_API UFIBVirtualizedListWidget : public UWidget
{
	GENERATED_UCLASS_BODY()

public:
	UPROPERTY(EditAnywhere, BlueprintReadOnly, Category = "Appearance")
	float ItemHeight = 40.0f;

protected:
	virtual void ReleaseSlateResources(bool bReleaseChildren) override;
	virtual TSharedRef<SWidget> RebuildWidget() override;

private:
	TSharedPtr<SFIBVirtualizedList> MySlateList;
};
```

---

