---
name: gas-helper
description: Gameplay Ability System (GAS) 관련 코드 생성을 돕습니다. 사용자가 새로운 어빌리티, 어트리뷰트, 게임플레이 이펙트, 어빌리티 태스크를 생성하거나 GAS 시스템을 수정하려 할 때 자동으로 활성화됩니다.
---

# Gameplay Ability System Helper Skill

ProjectFIB의 GAS (Gameplay Ability System) 구현을 돕는 스킬입니다.

## 핵심 아키텍처

### AbilitySystemComponent 위치
- **PlayerState**에 위치 (Pawn이 아님!)
- 리스폰 시에도 어빌리티 유지
- `AFIBPlayerState::AbilitySystemComponent`

### 초기화 순서
1. `Spawned` - Pawn 생성
2. `DataAvailable` - PlayerState 연결, ASC 사용 가능
3. `DataInitialized` - Pawn Data 적용
4. `GameplayReady` - 게임플레이 준비 완료

## 새 어빌리티 생성 템플릿

### 1. 헤더 파일 (.h)
```cpp
#pragma once

#include "AbilitySystem/Abilities/FIBGameplayAbility.h"
#include "YourAbilityName.generated.h"

UCLASS()
class PROJECTFIB_API UYourAbilityName : public UFIBGameplayAbility
{
    GENERATED_BODY()

public:
    UYourAbilityName();

protected:
    virtual void ActivateAbility(const FGameplayAbilitySpecHandle Handle,
                                  const FGameplayAbilityActorInfo* ActorInfo,
                                  const FGameplayAbilityActivationInfo ActivationInfo,
                                  const FGameplayEventData* TriggerEventData) override;

    virtual void EndAbility(const FGameplayAbilitySpecHandle Handle,
                           const FGameplayAbilityActorInfo* ActorInfo,
                           const FGameplayAbilityActivationInfo ActivationInfo,
                           bool bReplicateEndAbility,
                           bool bWasCancelled) override;
};
```

### 2. 소스 파일 (.cpp)
```cpp
#include "YourAbilityName.h"

UYourAbilityName::UYourAbilityName()
{
    // 활성화 정책 설정
    ActivationPolicy = EFIBAbilityActivationPolicy::OnInputTriggered;
    // 또는 WhileInputActive, OnSpawn

    // 활성화 그룹 설정
    ActivationGroup = EFIBAbilityActivationGroup::Independent;
    // 또는 Exclusive_Replaceable, Exclusive_Blocking
}

void UYourAbilityName::ActivateAbility(const FGameplayAbilitySpecHandle Handle,
                                        const FGameplayAbilityActorInfo* ActorInfo,
                                        const FGameplayAbilityActivationInfo ActivationInfo,
                                        const FGameplayEventData* TriggerEventData)
{
    Super::ActivateAbility(Handle, ActorInfo, ActivationInfo, TriggerEventData);

    // 코스트/쿨다운 체크
    if (!CommitAbility(Handle, ActorInfo, ActivationInfo))
    {
        EndAbility(Handle, ActorInfo, ActivationInfo, true, true);
        return;
    }

    // 어빌리티 로직 구현

    // 완료 시 EndAbility 호출
    EndAbility(Handle, ActorInfo, ActivationInfo, true, false);
}

void UYourAbilityName::EndAbility(const FGameplayAbilitySpecHandle Handle,
                                   const FGameplayAbilityActorInfo* ActorInfo,
                                   const FGameplayAbilityActivationInfo ActivationInfo,
                                   bool bReplicateEndAbility,
                                   bool bWasCancelled)
{
    // 정리 작업

    Super::EndAbility(Handle, ActorInfo, ActivationInfo, bReplicateEndAbility, bWasCancelled);
}
```

## 새 Attribute Set 생성 템플릿

### 헤더 파일
```cpp
#pragma once

#include "AbilitySystem/Attributes/FIBAttributeSet.h"
#include "YourAttributeSet.generated.h"

UCLASS()
class PROJECTFIB_API UYourAttributeSet : public UFIBAttributeSet
{
    GENERATED_BODY()

public:
    UYourAttributeSet();

    ATTRIBUTE_ACCESSORS(UYourAttributeSet, YourAttribute);

    virtual void PreAttributeChange(const FGameplayAttribute& Attribute, float& NewValue) override;
    virtual void PostGameplayEffectExecute(const FGameplayEffectModCallbackData& Data) override;

protected:
    UPROPERTY(BlueprintReadOnly, ReplicatedUsing = OnRep_YourAttribute, Category = "Attributes")
    FGameplayAttributeData YourAttribute;

    UFUNCTION()
    void OnRep_YourAttribute(const FGameplayAttributeData& OldValue);
};
```

### 소스 파일
```cpp
#include "YourAttributeSet.h"
#include "Net/UnrealNetwork.h"

UYourAttributeSet::UYourAttributeSet()
{
    // 초기값 설정
}

void UYourAttributeSet::GetLifetimeReplicatedProps(TArray<FLifetimeProperty>& OutLifetimeProps) const
{
    Super::GetLifetimeReplicatedProps(OutLifetimeProps);

    DOREPLIFETIME_CONDITION_NOTIFY(UYourAttributeSet, YourAttribute, COND_None, REPNOTIFY_Always);
}

void UYourAttributeSet::PreAttributeChange(const FGameplayAttribute& Attribute, float& NewValue)
{
    Super::PreAttributeChange(Attribute, NewValue);

    // 값 클램핑
    if (Attribute == GetYourAttributeAttribute())
    {
        NewValue = FMath::Clamp(NewValue, 0.0f, 100.0f);
    }
}

void UYourAttributeSet::PostGameplayEffectExecute(const FGameplayEffectModCallbackData& Data)
{
    Super::PostGameplayEffectExecute(Data);

    // 메타 어트리뷰트 처리 (예: Damage)
}

void UYourAttributeSet::OnRep_YourAttribute(const FGameplayAttributeData& OldValue)
{
    GAMEPLAYATTRIBUTE_REPNOTIFY(UYourAttributeSet, YourAttribute, OldValue);
}
```

## Activation Policies

- **OnInputTriggered**: 입력 누를 때만 활성화 (점프, 사격)
- **WhileInputActive**: 입력 누르는 동안 활성화 (달리기, 조준)
- **OnSpawn**: Pawn 생성 시 자동 부여

## Activation Groups

- **Independent**: 다른 어빌리티와 독립적
- **Exclusive_Replaceable**: 같은 그룹 어빌리티로 대체 가능
- **Exclusive_Blocking**: 같은 그룹 어빌리티 차단

## 주요 파일 위치

- **Base Ability**: `Source/ProjectFIB/AbilitySystem/Abilities/FIBGameplayAbility.h`
- **ASC**: `Source/ProjectFIB/AbilitySystem/FIBAbilitySystemComponent.h`
- **Attribute Sets**: `Source/ProjectFIB/AbilitySystem/Attributes/`
- **PlayerState**: `Source/ProjectFIB/Player/FIBPlayerState.h`

## 일반적인 패턴

### Ability 부여
```cpp
// Ability Set Data Asset 사용
// 또는 Game Feature Action으로 부여
```

### Input 바인딩
```cpp
// Input Config Data Asset에서 Input Action과 Gameplay Tag 매핑
// ASC가 자동으로 바인딩
```

### Network Replication
```cpp
// ASC는 PlayerState에 있으므로 모두에게 복제됨
// 서버에서 검증, 클라이언트 예측 지원
```

## 디버깅 명령어

- `ShowDebug AbilitySystem` - ASC 디버그 정보 표시
- `AbilitySystem.Debug.Target` - 특정 액터 타겟팅
- `DumpAbilitySystemState` - ASC 상태 덤프

## 참고 사항

- 항상 서버에서 검증
- CommitAbility로 코스트/쿨다운 체크
- EndAbility 반드시 호출
- Replicated 속성은 DOREPLIFETIME 사용
- Meta Attributes는 PostGameplayEffectExecute에서 처리
