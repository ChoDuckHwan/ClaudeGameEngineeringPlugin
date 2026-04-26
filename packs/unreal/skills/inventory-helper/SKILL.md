---
name: inventory-helper
description: Fragment 기반 인벤토리 시스템 구현을 돕습니다. 사용자가 새로운 아이템, Fragment, 픽업 시스템, 슬롯 관리를 추가하거나 인벤토리 시스템을 수정하려 할 때 자동으로 활성화됩니다.
---

# Inventory System Helper Skill

ProjectFIB의 Fragment 기반 인벤토리 시스템 구현을 돕는 스킬입니다.

## 핵심 아키텍처

### 시스템 개요
- **Fragment 패턴**: 아이템 기능을 모듈화하여 확장 가능
- **Fast Array Serialization**: 네트워크 효율적인 복제
- **슬롯 시스템**: 퀵 슬롯/핫바 지원
- **PlayerState에 위치**: 리스폰 시에도 인벤토리 유지

### 주요 컴포넌트
1. **UFIBInventoryItemDefinition** - 아이템 정의 (Data Asset)
2. **UFIBInventoryItemFragment** - 아이템 기능 모듈
3. **UFIBInventoryItemInstance** - 런타임 아이템 인스턴스
4. **UFIBInventoryManagerComponent** - 인벤토리 관리 (PlayerState)
5. **IPickupable** - 픽업 인터페이스

## 새 아이템 정의 생성

### 1. Item Definition 클래스 생성

**헤더 파일 (.h)**
```cpp
#pragma once

#include "Inventory/FIBInventoryItemDefinition.h"
#include "MyItemDefinition.generated.h"

UCLASS(Blueprintable)
class PROJECTFIB_API UMyItemDefinition : public UFIBInventoryItemDefinition
{
    GENERATED_BODY()

public:
    UMyItemDefinition();
};
```

**소스 파일 (.cpp)**
```cpp
#include "MyItemDefinition.h"

UMyItemDefinition::UMyItemDefinition()
{
    // DisplayName 등은 블루프린트나 Data Asset에서 설정
}
```

### 2. Data Asset 생성 (블루프린트)
1. Content Browser 우클릭 → Miscellaneous → Data Asset
2. Parent Class: `UMyItemDefinition` 선택
3. 이름: `DA_MyItem`
4. `DisplayName` 설정: "내 아이템"
5. `Fragments` 배열에 원하는 Fragment 추가

## Fragment 생성

### 기본 Fragment 템플릿

**헤더 파일 (.h)**
```cpp
#pragma once

#include "Inventory/FIBInventoryItemDefinition.h"
#include "MyItemFragment.generated.h"

UCLASS(DefaultToInstanced, EditInlineNew)
class PROJECTFIB_API UMyItemFragment : public UFIBInventoryItemFragment
{
    GENERATED_BODY()

public:
    virtual void OnInstanceCreated(UFIBInventoryItemInstance* Instance) const override;

    UPROPERTY(EditDefaultsOnly, BlueprintReadOnly, Category="Item")
    float MyProperty = 1.0f;
};
```

**소스 파일 (.cpp)**
```cpp
#include "MyItemFragment.h"
#include "Inventory/FIBInventoryItemInstance.h"

void UMyItemFragment::OnInstanceCreated(UFIBInventoryItemInstance* Instance) const
{
    Super::OnInstanceCreated(Instance);

    // 아이템 인스턴스 생성 시 초기화 로직
    // 예: Stat Tag 추가, 초기값 설정 등
}
```

### 사용 가능한 아이템 Fragment (Usable)

이미 제공되는 `UFIBInventoryItemFragment_Usable` 사용:
```cpp
// Data Asset에서 설정
Fragments:
  - UFIBInventoryItemFragment_Usable
    - UseAbilityClass: 사용 시 활성화할 Ability 클래스
    - UseAbilityTag: Ability 활성화 태그
    - bConsumeOnUse: true (사용 시 소모)
```

## 인벤토리 관리

### 아이템 추가
```cpp
// C++
UFIBInventoryManagerComponent* InventoryManager = PlayerState->FindComponentByClass<UFIBInventoryManagerComponent>();
if (InventoryManager)
{
    // Definition으로 추가
    UFIBInventoryItemInstance* NewItem = InventoryManager->AddItemDefinition(ItemDefClass, StackCount);

    // 특정 슬롯에 설정
    InventoryManager->SetItemToSlot(0, NewItem);
}
```

```cpp
// Blueprint
GetInventoryManagerComponent()->AddItemDefinition(ItemDef, StackCount)
```

### 아이템 제거
```cpp
// Instance로 제거
InventoryManager->RemoveItemInstance(ItemInstance);

// Definition으로 소모 (여러 스택 처리)
InventoryManager->ConsumeItemsByDefinition(ItemDefClass, NumToConsume);
```

### 아이템 검색
```cpp
// 특정 Definition의 첫 번째 아이템 찾기
UFIBInventoryItemInstance* Item = InventoryManager->FindFirstItemStackByDefinition(ItemDefClass);

// 모든 아이템 가져오기
TArray<UFIBInventoryItemInstance*> AllItems = InventoryManager->GetAllItems();

// 총 개수 확인
int32 TotalCount = InventoryManager->GetTotalItemCountByDefinition(ItemDefClass);
```

## 슬롯 시스템

### 슬롯 관리
```cpp
// 특정 슬롯의 아이템 가져오기
UFIBInventoryItemInstance* Item = InventoryManager->GetItemInSlot(0);

// 아이템을 슬롯에 설정
bool bSuccess = InventoryManager->SetItemToSlot(0, ItemInstance);

// 빈 슬롯 찾기
int32 EmptySlot = InventoryManager->FindFirstEmptySlot(MaxSlotCount);

// 현재 선택된 슬롯
int32 CurrentSlot = InventoryManager->GetCurrentSelectedSlotIndex();
InventoryManager->SetCurrentSelectedSlotIndex(1);
```

### 슬롯 아이템 사용
```cpp
// 현재 선택된 슬롯의 아이템 사용
UFIBAbilitySystemComponent* ASC = PlayerState->GetAbilitySystemComponent();
bool bUsed = InventoryManager->UseItemInCurrentSlot(ASC);
```

### 아이템 드롭
```cpp
// 슬롯에서 아이템 드롭 (월드에 생성)
AActor* DroppedActor = InventoryManager->DropItemFromSlot(
    SlotIndex,
    PickupActorClass,
    SpawnTransform
);
```

## 픽업 시스템

### Pickupable 액터 생성

**헤더 파일 (.h)**
```cpp
#pragma once

#include "GameFramework/Actor.h"
#include "Interaction/IInteractableTarget.h"
#include "Inventory/IPickupable.h"
#include "MyPickupItem.generated.h"

UCLASS()
class PROJECTFIB_API AMyPickupItem : public AActor, public IInteractableTarget, public IPickupable
{
    GENERATED_BODY()

public:
    AMyPickupItem();

    // IInteractableTarget
    virtual void GatherInteractionOptions(const FInteractionQuery& InteractQuery,
                                          FInteractionOptionBuilder& OptionBuilder) override;

    // IPickupable
    virtual FInventoryPickup GetPickupInventory() const override;

protected:
    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category="Pickup")
    FInventoryPickup StaticInventory;

    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category="Interaction")
    FInteractionOption InteractionOption;
};
```

**소스 파일 (.cpp)**
```cpp
#include "MyPickupItem.h"

AMyPickupItem::AMyPickupItem()
{
    // 메시 컴포넌트 등 설정
    InteractionOption.Text = FText::FromString(TEXT("줍기"));
}

void AMyPickupItem::GatherInteractionOptions(const FInteractionQuery& InteractQuery,
                                              FInteractionOptionBuilder& OptionBuilder)
{
    OptionBuilder.AddInteractionOption(InteractionOption);
}

FInventoryPickup AMyPickupItem::GetPickupInventory() const
{
    return StaticInventory;
}
```

### 픽업 아이템 설정 (Blueprint)
```
StaticInventory:
  Templates:
    - ItemDef: DA_MyItem
      StackCount: 1
```

### 픽업 처리
```cpp
// C++ - Interaction Ability에서
#include "Inventory/IPickupable.h"

TScriptInterface<IPickupable> Pickupable = UPickupableStatics::GetFirstPickupableFromActor(TargetActor);
if (Pickupable)
{
    UFIBInventoryManagerComponent* InventoryManager = GetInventoryManager();
    UPickupableStatics::AddPickupToInventory(InventoryManager, Pickupable);

    // 픽업 후 액터 파괴
    TargetActor->Destroy();
}
```

## Stat Tags 시스템

### Stat Tag 사용 (아이템 속성 관리)
```cpp
// Tag Stack 추가
ItemInstance->AddStatTagStack(FGameplayTag::RequestGameplayTag("Item.Stat.Durability"), 100);

// Tag Stack 제거
ItemInstance->RemoveStatTagStack(FGameplayTag::RequestGameplayTag("Item.Stat.Durability"), 10);

// Tag 개수 확인
int32 Durability = ItemInstance->GetStatTagStackCount(FGameplayTag::RequestGameplayTag("Item.Stat.Durability"));

// Tag 존재 확인
bool bHasDurability = ItemInstance->HasStatTag(FGameplayTag::RequestGameplayTag("Item.Stat.Durability"));
```

## 네트워크 복제

### 복제 구조
```cpp
// UFIBInventoryManagerComponent는 PlayerState에 위치
// - 모든 클라이언트에 복제됨
// - FFastArraySerializer 사용으로 효율적

// FFIBInventoryList::NetDeltaSerialize
// - 변경된 항목만 복제
// - 대역폭 최적화

// 복제 콜백
// - PreReplicatedRemove: 아이템 제거 전
// - PostReplicatedAdd: 아이템 추가 후
// - PostReplicatedChange: 아이템 변경 후
```

### 메시지 브로드캐스트
```cpp
// FFIBInventoryChangeMessage
// - 아이템 추가/제거/변경 시 자동 브로드캐스트
// - Gameplay Message Subsystem 사용

// FFIBInventorySlotSelectionMessage
// - 슬롯 선택 변경 시 브로드캐스트
```

## 주요 파일 위치

- **Item Definition**: `Source/ProjectFIB/Inventory/FIBInventoryItemDefinition.h`
- **Item Instance**: `Source/ProjectFIB/Inventory/FIBInventoryItemInstance.h`
- **Manager Component**: `Source/ProjectFIB/Inventory/FIBInventoryManagerComponent.h`
- **Pickupable Interface**: `Source/ProjectFIB/Inventory/IPickupable.h`
- **Pickupable Actor**: `Source/ProjectFIB/Interaction/FIBPickupableItem.h`

## 일반적인 패턴

### 소모성 아이템 (포션, 음식)
```cpp
// Fragment: UFIBInventoryItemFragment_Usable
// - UseAbilityClass: 힐링/버프 Ability
// - bConsumeOnUse: true

// Ability에서:
// 1. CommitAbility로 코스트 확인
// 2. 효과 적용 (GameplayEffect)
// 3. EndAbility
// 4. 인벤토리에서 자동 소모
```

### 장비 아이템 (무기, 방어구)
```cpp
// Fragment: 커스텀 Equipment Fragment
// - 장착 시 Ability 부여
// - 장착 해제 시 Ability 제거
// - Stat 변경 (GameplayEffect)
```

### 퀘스트 아이템
```cpp
// Fragment: 커스텀 Quest Fragment
// - bConsumeOnUse: false (소모 안 됨)
// - 소지만으로 조건 만족
// - HasItemForInteraction으로 확인
```

### 열쇠 아이템
```cpp
// Fragment: 커스텀 Key Fragment
// - bConsumeOnUse: true (사용 시 소모)
// - Interaction에서 ConsumeItemForInteraction 사용
// - 특정 Door/Lock과 연결
```

## 디버깅

### 블루프린트 노드
- `Get All Items` - 모든 아이템 확인
- `Get Item In Slot` - 슬롯 내용 확인
- `Get Total Item Count By Definition` - 특정 아이템 개수

### C++ 로그
```cpp
// InventoryList에서
UE_LOG(LogInventory, Log, TEXT("Added item: %s, Count: %d"),
    *GetNameSafe(ItemDef), StackCount);
```

## 확장 예제

### 무게 제한 시스템
```cpp
// 1. Weight Fragment 생성
UCLASS()
class UInventoryItemFragment_Weight : public UFIBInventoryItemFragment
{
    UPROPERTY(EditDefaultsOnly)
    float Weight = 1.0f;
};

// 2. InventoryManager 확장
bool UFIBInventoryManagerComponent::CanAddItemDefinition(TSubclassOf<UFIBInventoryItemDefinition> ItemDef, int32 StackCount)
{
    // Weight Fragment 확인
    float TotalWeight = CalculateTotalWeight();
    float NewWeight = GetItemWeight(ItemDef) * StackCount;
    return (TotalWeight + NewWeight) <= MaxWeight;
}
```

### 아이템 품질 시스템
```cpp
// Stat Tag 활용
ItemInstance->AddStatTagStack(
    FGameplayTag::RequestGameplayTag("Item.Quality.Rare"), 1);

// UI에서 품질에 따라 색상 변경
if (ItemInstance->HasStatTag(FGameplayTag::RequestGameplayTag("Item.Quality.Legendary")))
{
    // 전설 등급 색상 표시
}
```

### 스택 제한
```cpp
// Fragment에 MaxStack 추가
UCLASS()
class UInventoryItemFragment_Stackable : public UFIBInventoryItemFragment
{
    UPROPERTY(EditDefaultsOnly)
    int32 MaxStackSize = 99;
};

// AddEntry에서 MaxStack 확인
if (Entry.StackCount >= MaxStackSize)
{
    // 새 Entry 생성
}
```

## 참고 사항

- **항상 서버에서 검증**: `BlueprintAuthorityOnly` 함수는 서버에서만 실행
- **Fast Array 사용**: 효율적인 복제를 위해 FFastArraySerializer 패턴 준수
- **Fragment로 확장**: 새 기능은 Fragment로 추가 (상속 대신)
- **Stat Tags 활용**: 동적 속성은 Stat Tag로 관리
- **PlayerState 위치**: 리스폰 후에도 인벤토리 유지
- **Gameplay Message**: 인벤토리 변경 알림을 위한 메시지 시스템 활용
