## AI 전투 시스템

### Enemy Attribute Set

```cpp
UCLASS()
class UFIBEnemyAttributeSet : public UFIBAttributeSet
{
    GENERATED_BODY()

public:
    ATTRIBUTE_ACCESSORS(UFIBEnemyAttributeSet, Health);
    ATTRIBUTE_ACCESSORS(UFIBEnemyAttributeSet, MaxHealth);
    ATTRIBUTE_ACCESSORS(UFIBEnemyAttributeSet, AttackPower);
    ATTRIBUTE_ACCESSORS(UFIBEnemyAttributeSet, MoveSpeed);
    ATTRIBUTE_ACCESSORS(UFIBEnemyAttributeSet, AggroRange);

protected:
    UPROPERTY(BlueprintReadOnly, ReplicatedUsing = OnRep_Health, Category="Enemy")
    FGameplayAttributeData Health;

    UPROPERTY(BlueprintReadOnly, Category="Enemy")
    FGameplayAttributeData MaxHealth;

    UPROPERTY(BlueprintReadOnly, Category="Enemy")
    FGameplayAttributeData AttackPower;

    UPROPERTY(BlueprintReadOnly, Category="Enemy")
    FGameplayAttributeData MoveSpeed;

    UPROPERTY(BlueprintReadOnly, Category="Enemy")
    FGameplayAttributeData AggroRange;
};
```

### 적 AI 공격 Ability

```cpp
UCLASS()
class UFIBGameplayAbility_EnemyMeleeAttack : public UFIBGameplayAbility
{
    GENERATED_BODY()

public:
    // 공격 범위
    UPROPERTY(EditDefaultsOnly, Category="AI")
    float AttackRange = 150.0f;

    // 공격 쿨다운
    UPROPERTY(EditDefaultsOnly, Category="AI")
    float AttackCooldown = 2.0f;

    // 공격 예고 시간 (플레이어가 회피할 시간)
    UPROPERTY(EditDefaultsOnly, Category="AI")
    float TelegraphDuration = 0.5f;

    // 데미지
    UPROPERTY(EditDefaultsOnly, Category="AI")
    TSubclassOf<UGameplayEffect> DamageEffect;
};
```

### Behavior Tree 태스크

**BTTask_CheckPlayerInRange.h**
```cpp
UCLASS()
class UBTTask_CheckPlayerInRange : public UBTTaskNode
{
    GENERATED_BODY()

public:
    virtual EBTNodeResult::Type ExecuteTask(UBehaviorTreeComponent& OwnerComp, uint8* NodeMemory) override;

    UPROPERTY(EditAnywhere, Category="AI")
    float AttackRange = 200.0f;

    UPROPERTY(EditAnywhere, Category="AI")
    FBlackboardKeySelector TargetKey;
};
```

## 물리 상호작용 시스템 (R.E.P.O. 스타일)

### Throwable Object Component

```cpp
#pragma once

#include "Components/ActorComponent.h"
#include "FIBThrowableComponent.generated.h"

UCLASS(ClassGroup=(Custom), meta=(BlueprintSpawnableComponent))
class PROJECTFIB_API UFIBThrowableComponent : public UActorComponent
{
    GENERATED_BODY()

public:
    UFIBThrowableComponent();

    // 물건 집기
    UFUNCTION(BlueprintCallable, Category="Throwable")
    void PickUp(AActor* Grabber);

    // 물건 던지기
    UFUNCTION(BlueprintCallable, Category="Throwable")
    void Throw(FVector Direction, float Force);

    // 투척 데미지
    UPROPERTY(EditAnywhere, Category="Throwable")
    float ThrowDamage = 20.0f;

    // 투척 힘 승수
    UPROPERTY(EditAnywhere, Category="Throwable")
    float ThrowForceMultiplier = 1000.0f;

    // 히트 시 이펙트
    UPROPERTY(EditAnywhere, Category="Throwable")
    TSubclassOf<UGameplayEffect> ImpactDamageEffect;

protected:
    virtual void BeginPlay() override;

    UFUNCTION()
    void OnHit(UPrimitiveComponent* HitComp, AActor* OtherActor,
               UPrimitiveComponent* OtherComp, FVector NormalImpulse, const FHitResult& Hit);

private:
    bool bIsBeingHeld = false;
    TWeakObjectPtr<AActor> CurrentGrabber;
};
```

