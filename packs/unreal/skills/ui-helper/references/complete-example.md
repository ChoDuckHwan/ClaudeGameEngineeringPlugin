## 8. 완성 예제

### 예제 1: HP 바 (시스템 브릿지 ViewModel)

폴더: `Source/ProjectFIB/UI/HUD/`
- View: `FIBHealthBarWidget` (UFIBCommonUserWidget)
- ViewModel: `UFIBHealthComponent` (기존 클래스, 직접 바인딩)
- Model: `UFIBHealthSet` (AttributeSet)

```
View --[OnHealthChanged]--> HealthComponent(ViewModel) --[AttributeChange]--> HealthSet(Model)
```

### 예제 2: 인벤토리 화면 (UI 전용 ViewModel)

폴더: `Source/ProjectFIB/UI/Inventory/`
- View: `FIBInventoryScreenWidget` (UFIBActivatableWidget)
- ViewModel: `FIBInventoryViewModel` (UFIBViewModel, 새로 생성)
- Model: `UFIBInventoryManagerComponent` (기존 클래스)

```
View --[OnPropertyChanged]--> InventoryViewModel --[GetAllItems]--> InventoryManager(Model)
```

### 예제 3: 아이템 정보 팝업 (모달)

폴더: `Source/ProjectFIB/UI/ItemInfo/`
- View: `FIBItemInfoModalWidget` (UFIBActivatableWidget)
- ViewModel: 없음 (데이터를 직접 전달)
- Model: `UFIBInventoryItemInstance` (기존 클래스)

```cpp
// 호출 코드
UFIBItemInfoModalWidget* Modal = Cast<UFIBItemInfoModalWidget>(
    UCommonUIExtensions::PushStreamedContentToLayerForPlayer(
        LocalPlayer, TAG_UI_LAYER_MODAL, ItemInfoWidgetClass));
if (Modal)
{
    Modal->SetItemInstance(SelectedItem);
}
```

---

