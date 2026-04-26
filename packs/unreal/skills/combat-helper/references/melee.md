## 근접 전투 Ability

### 기본 근접 공격 Ability

```cpp
#pragma once

#include "AbilitySystem/Abilities/FIBGameplayAbility.h"
#include "FIBGameplayAbility_MeleeAttack.generated.h"

UCLASS()
class PROJECTFIB_API UFIBGameplayAbility_MeleeAttack : public UFIBGameplayAbility
{
    GENERATED_BODY()

public:
    UFIBGameplayAbility_MeleeAttack();

protected:
    virtual void ActivateAbility(const FGameplayAbilitySpecHandle Handle,
                                  const FGameplayAbilityActorInfo* ActorInfo,
                                  const FGameplayAbilityActivationInfo ActivationInfo,
                                  const FGameplayEventData* TriggerEventData) override;

    // 공격 히트 판정
    UFUNCTION()
    void PerformMeleeTrace();

    // 공격 범위
    UPROPERTY(EditDefaultsOnly, Category="Melee")
    float AttackRange = 200.0f;

    // 공격 각도 (전방 범위)
    UPROPERTY(EditDefaultsOnly, Category="Melee")
    float AttackAngle = 60.0f;

    // 데미지 적용
    UPROPERTY(EditDefaultsOnly, Category="Melee")
    TSubclassOf<UGameplayEffect> DamageEffect;

    // 넉백 효과
    UPROPERTY(EditDefaultsOnly, Category="Melee")
    float KnockbackForce = 500.0f;

    // 스태미나 코스트
    UPROPERTY(EditDefaultsOnly, Category="Melee")
    FGameplayTag StaminaCostTag;

    // 애니메이션
    UPROPERTY(EditDefaultsOnly, Category="Animation")
    TObjectPtr<UAnimMontage> AttackMontage;
};
```

**구현 예시 (.cpp)**
```cpp
#include "FIBGameplayAbility_MeleeAttack.h"
#include "AbilitySystemComponent.h"
#include "Kismet/KismetSystemLibrary.h"

UFIBGameplayAbility_MeleeAttack::UFIBGameplayAbility_MeleeAttack()
{
    ActivationPolicy = EFIBAbilityActivationPolicy::OnInputTriggered;
    ActivationGroup = EFIBAbilityActivationGroup::Exclusive_Blocking;
}

void UFIBGameplayAbility_MeleeAttack::ActivateAbility(const FGameplayAbilitySpecHandle Handle,
                                                        const FGameplayAbilityActorInfo* ActorInfo,
                                                        const FGameplayAbilityActivationInfo ActivationInfo,
                                                        const FGameplayEventData* TriggerEventData)
{
    Super::ActivateAbility(Handle, ActorInfo, ActivationInfo, TriggerEventData);

    // 스태미나 소모 확인
    if (!CommitAbility(Handle, ActorInfo, ActivationInfo))
    {
        EndAbility(Handle, ActorInfo, ActivationInfo, true, true);
        return;
    }

    // 공격 애니메이션 재생
    if (AttackMontage && ActorInfo->SkeletalMeshComponent.IsValid())
    {
        ActorInfo->SkeletalMeshComponent->GetAnimInstance()->Montage_Play(AttackMontage);
    }

    // 애니메이션 노티파이 시점에 히트 판정 (타이머로 시뮬레이션)
    FTimerHandle TimerHandle;
    GetWorld()->GetTimerManager().SetTimer(TimerHandle, this,
        &UFIBGameplayAbility_MeleeAttack::PerformMeleeTrace, 0.3f, false);
}

void UFIBGameplayAbility_MeleeAttack::PerformMeleeTrace()
{
    AActor* OwnerActor = GetAvatarActorFromActorInfo();
    if (!OwnerActor) return;

    FVector Start = OwnerActor->GetActorLocation();
    FVector Forward = OwnerActor->GetActorForwardVector();
    FVector End = Start + (Forward * AttackRange);

    // Sphere Sweep으로 히트 판정
    TArray<FHitResult> HitResults;
    FCollisionQueryParams Params;
    Params.AddIgnoredActor(OwnerActor);

    bool bHit = GetWorld()->SweepMultiByChannel(
        HitResults,
        Start,
        End,
        FQuat::Identity,
        ECC_Pawn,
        FCollisionShape::MakeSphere(50.0f),
        Params
    );

    if (bHit)
    {
        for (const FHitResult& Hit : HitResults)
        {
            AActor* HitActor = Hit.GetActor();
            if (!HitActor) continue;

            // 각도 체크 (전방 범위 내)
            FVector ToTarget = (HitActor->GetActorLocation() - Start).GetSafeNormal();
            float DotProduct = FVector::DotProduct(Forward, ToTarget);
            float Angle = FMath::Acos(DotProduct) * (180.0f / PI);

            if (Angle <= AttackAngle)
            {
                // 데미지 적용
                if (DamageEffect)
                {
                    FGameplayEffectContextHandle EffectContext = GetAbilitySystemComponentFromActorInfo()->MakeEffectContext();
                    EffectContext.AddHitResult(Hit);

                    FGameplayEffectSpecHandle SpecHandle = GetAbilitySystemComponentFromActorInfo()->MakeOutgoingSpec(
                        DamageEffect, GetAbilityLevel(), EffectContext);

                    GetAbilitySystemComponentFromActorInfo()->ApplyGameplayEffectSpecToTarget(
                        *SpecHandle.Data.Get(), UAbilitySystemBlueprintLibrary::GetAbilitySystemComponent(HitActor));
                }

                // 넉백 적용
                if (UPrimitiveComponent* HitComp = Hit.GetComponent())
                {
                    FVector KnockbackDir = (HitActor->GetActorLocation() - Start).GetSafeNormal();
                    HitComp->AddImpulse(KnockbackDir * KnockbackForce, NAME_None, true);
                }
            }
        }
    }

    // Ability 종료
    EndAbility(CurrentSpecHandle, CurrentActorInfo, CurrentActivationInfo, true, false);
}
```

