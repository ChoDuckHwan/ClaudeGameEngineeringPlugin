## 스태미나 시스템

### 스태미나 Attribute Set

```cpp
#pragma once

#include "AbilitySystem/Attributes/FIBAttributeSet.h"
#include "FIBStaminaSet.generated.h"

UCLASS()
class PROJECTFIB_API UFIBStaminaSet : public UFIBAttributeSet
{
    GENERATED_BODY()

public:
    UFIBStaminaSet();

    ATTRIBUTE_ACCESSORS(UFIBStaminaSet, Stamina);
    ATTRIBUTE_ACCESSORS(UFIBStaminaSet, MaxStamina);
    ATTRIBUTE_ACCESSORS(UFIBStaminaSet, StaminaRegenRate);

protected:
    UPROPERTY(BlueprintReadOnly, ReplicatedUsing = OnRep_Stamina, Category="Stamina")
    FGameplayAttributeData Stamina;

    UPROPERTY(BlueprintReadOnly, ReplicatedUsing = OnRep_MaxStamina, Category="Stamina")
    FGameplayAttributeData MaxStamina;

    UPROPERTY(BlueprintReadOnly, Category="Stamina")
    FGameplayAttributeData StaminaRegenRate;

    UFUNCTION()
    void OnRep_Stamina(const FGameplayAttributeData& OldValue);

    UFUNCTION()
    void OnRep_MaxStamina(const FGameplayAttributeData& OldValue);

    virtual void PreAttributeChange(const FGameplayAttribute& Attribute, float& NewValue) override;
};
```

### 스태미나 소모 예시

```cpp
// 근접 공격 시 스태미나 소모
FGameplayEffectSpecHandle SpecHandle = MakeOutgoingGameplayEffectSpec(StaminaCostEffect);
if (SpecHandle.IsValid())
{
    SpecHandle.Data->SetSetByCallerMagnitude(
        FGameplayTag::RequestGameplayTag("Data.Stamina.Cost"),
        15.0f  // 스태미나 15 소모
    );
    ApplyGameplayEffectSpecToOwner(CurrentSpecHandle, CurrentActorInfo, CurrentActivationInfo, SpecHandle);
}
```

## 회피/방어 시스템

### 구르기 (Dodge Roll) Ability

```cpp
UCLASS()
class UFIBGameplayAbility_DodgeRoll : public UFIBGameplayAbility
{
    GENERATED_BODY()

public:
    // 구르기 거리
    UPROPERTY(EditDefaultsOnly, Category="Dodge")
    float DodgeDistance = 400.0f;

    // 구르기 속도
    UPROPERTY(EditDefaultsOnly, Category="Dodge")
    float DodgeDuration = 0.5f;

    // 무적 시간
    UPROPERTY(EditDefaultsOnly, Category="Dodge")
    float InvulnerabilityDuration = 0.3f;

    // 스태미나 코스트
    UPROPERTY(EditDefaultsOnly, Category="Dodge")
    float StaminaCost = 25.0f;

protected:
    virtual void ActivateAbility(const FGameplayAbilitySpecHandle Handle,
                                  const FGameplayAbilityActorInfo* ActorInfo,
                                  const FGameplayAbilityActivationInfo ActivationInfo,
                                  const FGameplayEventData* TriggerEventData) override;
};
```

