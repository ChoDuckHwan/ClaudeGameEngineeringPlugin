## 무기 시스템 구현

### 무기 아이템 설계

**무기 Base Fragment**
```cpp
#pragma once

#include "Inventory/FIBInventoryItemDefinition.h"
#include "FIBInventoryItemFragment_Weapon.generated.h"

UENUM(BlueprintType)
enum class EWeaponType : uint8
{
    Melee,        // 근접 무기 (삽, 망치, 칼)
    Ranged,       // 원거리 무기 (샷건, 권총)
    Throwable,    // 투척 무기 (수류탄, 물건)
    Tool          // 도구 겸 무기 (사다리, 프라이팬)
};

UCLASS(DefaultToInstanced, EditInlineNew)
class PROJECTFIB_API UFIBInventoryItemFragment_Weapon : public UFIBInventoryItemFragment
{
    GENERATED_BODY()

public:
    UPROPERTY(EditDefaultsOnly, BlueprintReadOnly, Category="Weapon")
    EWeaponType WeaponType = EWeaponType::Melee;

    // 무기를 장착할 때 부여할 Ability
    UPROPERTY(EditDefaultsOnly, BlueprintReadOnly, Category="Weapon")
    TSubclassOf<UFIBGameplayAbility> EquipAbilityClass;

    // 공격 시 사용할 Ability
    UPROPERTY(EditDefaultsOnly, BlueprintReadOnly, Category="Weapon")
    TSubclassOf<UFIBGameplayAbility> AttackAbilityClass;

    // 무기 데미지 (GameplayEffect로 적용)
    UPROPERTY(EditDefaultsOnly, BlueprintReadOnly, Category="Weapon")
    TSubclassOf<UGameplayEffect> DamageEffectClass;

    // 무기 메시 (3인칭/1인칭)
    UPROPERTY(EditDefaultsOnly, BlueprintReadOnly, Category="Weapon")
    TObjectPtr<USkeletalMesh> WeaponMesh;

    // 무기 애니메이션
    UPROPERTY(EditDefaultsOnly, BlueprintReadOnly, Category="Weapon")
    TObjectPtr<UAnimMontage> AttackMontage;

    virtual void OnInstanceCreated(UFIBInventoryItemInstance* Instance) const override;
};
```

### 근접 무기 Fragment

**삽 (Shovel) - Lethal Company 스타일**
```cpp
UCLASS()
class UFIBInventoryItemFragment_Shovel : public UFIBInventoryItemFragment_Weapon
{
    GENERATED_BODY()

public:
    UFIBInventoryItemFragment_Shovel()
    {
        WeaponType = EWeaponType::Melee;
    }

    // 공격 데미지
    UPROPERTY(EditDefaultsOnly, Category="Melee")
    float BaseDamage = 30.0f;

    // 공격 범위
    UPROPERTY(EditDefaultsOnly, Category="Melee")
    float AttackRange = 200.0f;

    // 공격 속도 (초 단위)
    UPROPERTY(EditDefaultsOnly, Category="Melee")
    float AttackCooldown = 1.0f;

    // 스태미나 소모
    UPROPERTY(EditDefaultsOnly, Category="Melee")
    float StaminaCost = 15.0f;

    // 넉백 강도
    UPROPERTY(EditDefaultsOnly, Category="Melee")
    float KnockbackForce = 500.0f;
};
```

### 원거리 무기 Fragment

**샷건 (Shotgun) - Lethal Company 스타일**
```cpp
UCLASS()
class UFIBInventoryItemFragment_Shotgun : public UFIBInventoryItemFragment_Weapon
{
    GENERATED_BODY()

public:
    UFIBInventoryItemFragment_Shotgun()
    {
        WeaponType = EWeaponType::Ranged;
    }

    // 탄약 수
    UPROPERTY(EditDefaultsOnly, Category="Ranged")
    int32 MaxAmmo = 2;

    // 장전 시간
    UPROPERTY(EditDefaultsOnly, Category="Ranged")
    float ReloadTime = 3.0f;

    // 발사 데미지
    UPROPERTY(EditDefaultsOnly, Category="Ranged")
    float BaseDamage = 100.0f;

    // 확산 각도 (샷건은 넓은 범위)
    UPROPERTY(EditDefaultsOnly, Category="Ranged")
    float SpreadAngle = 30.0f;

    // 반동 강도
    UPROPERTY(EditDefaultsOnly, Category="Ranged")
    float RecoilStrength = 2.5f;

    // 발사체 개수 (샷건 펠렛)
    UPROPERTY(EditDefaultsOnly, Category="Ranged")
    int32 PelletCount = 8;
};
```

