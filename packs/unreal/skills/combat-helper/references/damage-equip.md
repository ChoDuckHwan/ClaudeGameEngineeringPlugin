## 데미지 시스템

### 데미지 GameplayEffect

**GE_Damage_Melee**
```cpp
// C++로 생성하거나 블루프린트 Data Asset으로
// Duration: Instant
// Modifiers:
//   - Attribute: Health
//   - Operation: Additive
//   - Magnitude: -30 (SetByCaller 사용)
```

### 데미지 계산 Execution

```cpp
UCLASS()
class UFIBDamageExecution : public UGameplayEffectExecutionCalculation
{
    GENERATED_BODY()

public:
    UFIBDamageExecution();

    virtual void Execute_Implementation(const FGameplayEffectCustomExecutionParameters& ExecutionParams,
                                        FGameplayEffectCustomExecutionOutput& OutExecutionOutput) const override;

protected:
    // 데미지 계산 로직
    // - 기본 데미지
    // - 방어력 감소
    // - 크리티컬 히트
    // - 헤드샷 보너스
};
```

## 무기 장착 시스템

### Equipment Manager Component

```cpp
UCLASS()
class UFIBEquipmentManagerComponent : public UActorComponent
{
    GENERATED_BODY()

public:
    // 무기 장착
    UFUNCTION(BlueprintCallable, Server, Reliable, Category="Equipment")
    void Server_EquipWeapon(UFIBInventoryItemInstance* WeaponItem);

    // 무기 해제
    UFUNCTION(BlueprintCallable, Server, Reliable, Category="Equipment")
    void Server_UnequipWeapon();

    // 현재 장착된 무기
    UFUNCTION(BlueprintPure, Category="Equipment")
    UFIBInventoryItemInstance* GetEquippedWeapon() const { return EquippedWeapon; }

protected:
    UPROPERTY(Replicated)
    TObjectPtr<UFIBInventoryItemInstance> EquippedWeapon;

    // 무기 메시를 캐릭터에 attach
    UFUNCTION()
    void AttachWeaponMesh(USkeletalMesh* WeaponMesh);

    // 무기 Ability 부여
    UFUNCTION()
    void GrantWeaponAbilities(const UFIBInventoryItemFragment_Weapon* WeaponFragment);
};
```

