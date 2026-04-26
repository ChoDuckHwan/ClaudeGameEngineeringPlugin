## 원거리 전투 Ability

### 샷건 발사 Ability

```cpp
#pragma once

#include "AbilitySystem/Abilities/FIBGameplayAbility.h"
#include "FIBGameplayAbility_FireShotgun.generated.h"

UCLASS()
class UFIBGameplayAbility_FireShotgun : public UFIBGameplayAbility
{
    GENERATED_BODY()

public:
    UFIBGameplayAbility_FireShotgun();

protected:
    virtual void ActivateAbility(const FGameplayAbilitySpecHandle Handle,
                                  const FGameplayAbilityActorInfo* ActorInfo,
                                  const FGameplayAbilityActivationInfo ActivationInfo,
                                  const FGameplayEventData* TriggerEventData) override;

    // 발사 로직
    UFUNCTION()
    void FireShot();

    // 펠렛 수 (샷건 특성)
    UPROPERTY(EditDefaultsOnly, Category="Weapon")
    int32 PelletCount = 8;

    // 확산 각도
    UPROPERTY(EditDefaultsOnly, Category="Weapon")
    float SpreadAngle = 30.0f;

    // 사거리
    UPROPERTY(EditDefaultsOnly, Category="Weapon")
    float MaxRange = 2000.0f;

    // 반동 강도
    UPROPERTY(EditDefaultsOnly, Category="Weapon")
    float RecoilPitch = -5.0f;

    // 데미지 이펙트
    UPROPERTY(EditDefaultsOnly, Category="Weapon")
    TSubclassOf<UGameplayEffect> DamageEffect;

    // 발사 사운드/이펙트
    UPROPERTY(EditDefaultsOnly, Category="Effects")
    TObjectPtr<USoundBase> FireSound;

    UPROPERTY(EditDefaultsOnly, Category="Effects")
    TObjectPtr<UParticleSystem> MuzzleFlash;
};
```

