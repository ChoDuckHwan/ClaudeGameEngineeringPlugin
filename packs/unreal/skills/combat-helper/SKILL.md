---
name: combat-helper
description: Lethal Company와 R.E.P.O. 스타일의 공포 게임 전투 시스템 구현을 돕습니다. 사용자가 무기, 근접 전투, 원거리 전투, AI 전투 시스템, 스태미나, 회피, 데미지, 장착 시스템을 추가하거나 수정할 때 자동으로 활성화됩니다.
---

# Combat System Helper Skill

Lethal Company와 R.E.P.O.를 참고한 공포 게임 전투 시스템 구현 가이드.

> **Progressive Disclosure** ([_template.md](../_template.md) ≤500줄 정책 — Tier 2 #3): 본 SKILL.md는 설계 원칙·밸런스·구현 순서·디버깅 핵심만 담는다. 시스템별 코드 템플릿은 `references/`로 분리.

## References

- [weapons.md](references/weapons.md) — 무기 시스템 (Inventory Fragment + GAS 통합)
- [melee.md](references/melee.md) — 근접 전투 Ability (콤보·히트박스·애니메이션)
- [ranged.md](references/ranged.md) — 원거리 전투 (탄약·반동·Line Trace/Projectile)
- [stamina-defense.md](references/stamina-defense.md) — 스태미나 + 회피·방어 (구르기·무적프레임·블록)
- [ai-physics.md](references/ai-physics.md) — AI 전투 (Behavior Tree + EQS) + 물리 상호작용
- [damage-equip.md](references/damage-equip.md) — 데미지 시스템 (GAS Effect) + 무기 장착

---

## 1. 게임 참고 분석

### Lethal Company 전투 특징
- **제한적인 전투**: 소수의 무기만 (삽, 스턴 수류탄, 샷건, 칼)
- **생존 우선**: 전투보다 회피와 도망이 핵심
- **근접 전투 중심**: 대부분 근접 무기 사용
- **협동 필수**: 팀워크로 위협 극복
- **자원 관리**: 무기는 비싸고 제한적

### R.E.P.O. 전투 특징
- **물리 기반**: 모든 물체를 무기로 활용 가능
- **전술적 AI**: 적들이 엄폐물 사용, 의사소통
- **다양한 근접 무기**: 프라이팬, 망치, 야구방망이
- **음성 기반 긴장감**: 소리로 적을 유인하거나 회피
- **환경 활용**: 물건을 던지거나 바리케이드 생성

---

## 2. 전투 시스템 설계 개요

### 핵심 설계 원칙
1. **긴장감 유지**: 전투는 위험하고 자원이 제한적
2. **선택의 중요성**: 싸울지 도망칠지 판단이 생존의 핵심
3. **협동 강조**: 혼자서는 버티기 어려움
4. **물리 상호작용**: 환경과 물체 활용
5. **공포 요소 통합**: 전투가 공포감을 강화

### 시스템 구성 요소

| # | 시스템 | 핵심 기술 | references |
|---|--------|-----------|-----------|
| 1 | 무기 시스템 | Inventory + GAS | [weapons.md](references/weapons.md) |
| 2 | 근접 전투 | Melee Ability + Combo | [melee.md](references/melee.md) |
| 3 | 원거리 전투 | Projectile + Recoil + Ammo | [ranged.md](references/ranged.md) |
| 4 | 방어/회피 | Dodge + Block + Stamina | [stamina-defense.md](references/stamina-defense.md) |
| 5 | AI 전투 | Behavior Tree + EQS | [ai-physics.md](references/ai-physics.md) |
| 6 | 데미지 시스템 | GAS Attributes + Effects | [damage-equip.md](references/damage-equip.md) |
| 7 | 물리 상호작용 | Physics Handle + Throwable | [ai-physics.md](references/ai-physics.md) |
| 8 | 장착 시스템 | Inventory + Equip | [damage-equip.md](references/damage-equip.md) |

---

## 3. 패턴 선택 가이드

| 시나리오 | 사용할 references |
|----------|-------------------|
| 신규 근접 무기 (삽, 망치) | weapons + melee + damage-equip |
| 원거리 무기 (샷건) | weapons + ranged + damage-equip |
| 던지기 가능한 도구 | weapons + ai-physics |
| 회피 어빌리티 | stamina-defense |
| 적 AI 공격 패턴 | ai-physics + damage-equip |
| 환경 오브젝트 무기화 | ai-physics |

---

## 4. 공포 게임 전투 밸런스

### 자원 제한
- 탄약은 극도로 제한적 (샷건 2발)
- 근접 무기는 내구도 또는 스태미나 소모
- 체력 회복 아이템 희귀

### 위협 레벨
- 일반 적: 근접 2-3타에 처치 가능
- 엘리트 적: 5-7타 필요, 회피 필수
- 보스급: 직접 전투 불가능, 환경 활용 또는 도망

### 긴장감 요소
- 공격 시 소음 발생 (다른 적 유인)
- 스태미나 관리 실패 시 무방비 상태
- 치명적인 실수 (샷건 오발, 근접 빗나감)

### 협동 시너지
- 한 명이 어그로, 다른 플레이어가 측면 공격
- 스턴 → 집중 공격 콤보
- 자원 공유 (탄약, 체력)

---

## 5. 흔한 실수 (반드시 피할 것)

| 안티패턴 | 올바른 방법 |
|----------|-------------|
| 클라이언트에서 데미지 계산 | 서버 권위 — `GameplayEffectExecution` 서버 실행 |
| 무기 직접 PlaySound | GameplayCue로 트리거 |
| Tick에서 히트박스 검사 | Sweep/Overlap 이벤트 또는 AnimNotify 윈도우 |
| 탄약을 클라이언트가 감소 | 서버 검증 후 Replicated Attribute 갱신 |
| 적 AI가 클라이언트 결정 | 서버에서만 BT/StateTree 실행 → Multicast로 시각화 |
| 무기 장착이 PlayerState X | PlayerState (사망/리스폰 영속성) |

---

## 6. 주요 파일 위치

- **Ability Base**: `Source/ProjectFIB/AbilitySystem/Abilities/FIBGameplayAbility.h`
- **Attribute Sets**: `Source/ProjectFIB/AbilitySystem/Attributes/` (FIBHealthSet, FIBCombatSet)
- **Inventory System**: `Source/ProjectFIB/Inventory/` (Fragment + ItemDefinition)
- **Combat Abilities**: `Source/ProjectFIB/AbilitySystem/Abilities/Combat/` (구현 시 생성)
- **Animation**: `Source/ProjectFIB/Character/` (Montage Notify 동기 — animation 팀 협업)

---

## 7. 구현 순서 권장사항

| 단계 | 작업 | 참조 |
|------|------|------|
| 1 | 스태미나 AttributeSet | [stamina-defense.md](references/stamina-defense.md) |
| 2 | 무기 Inventory Fragment + 장착/해제 | [weapons.md](references/weapons.md), [damage-equip.md](references/damage-equip.md) |
| 3 | 근접 공격 Ability + 히트 판정 + GE | [melee.md](references/melee.md), [damage-equip.md](references/damage-equip.md) |
| 4 | 원거리 발사 Ability + 탄약 + 반동 | [ranged.md](references/ranged.md) |
| 5 | 회피·블록·무적프레임 | [stamina-defense.md](references/stamina-defense.md) |
| 6 | 적 AttributeSet + AI Ability + Behavior Tree | [ai-physics.md](references/ai-physics.md) |
| 7 | Throwable + Physics Handle | [ai-physics.md](references/ai-physics.md) |
| 8 | 밸런싱 (balance 팀과 협업) | (외부) |

---

## 8. 디버깅 팁

### 콘솔 명령어
```
God                              // 무적 모드 (FIBCheatManager)
UnlimitedHealth 1                // 무한 체력
DumpAbilitySystemState           // ASC 상태
ShowDebug AbilitySystem          // 어빌리티 디버그
AbilitySystem.Debug.Target       // 디버그 대상 지정
showdebug ai                     // AI 디버그
```

### 비주얼 디버그
```cpp
// 공격 범위
DrawDebugSphere(GetWorld(), Start, AttackRange, 16, FColor::Red, false, 2.0f);

// 히트 판정 라인
DrawDebugLine(GetWorld(), Start, End, FColor::Green, false, 1.0f);

// Sweep 박스
DrawDebugBox(GetWorld(), Center, HalfExtent, Rotation.Quaternion(), FColor::Yellow, false, 1.0f);
```

---

## 9. 참고 사항

- **서버 권위**: 모든 전투 로직은 서버에서 검증 (Listen Server 모델)
- **예측 사용**: 클라이언트 예측으로 반응성 향상 (GAS 기본 지원)
- **물리 동기화**: 중요한 물리 객체는 복제 필수
- **최적화**: 대량 AI 전투 시 LOD 및 Tick 최적화 (`combat 팀의 09_combat_bug_tester` 참조)
- **공포 요소**: 전투가 공포감을 약화시키지 않도록 균형 유지 (`07_combat_fun_validator` 검증)
- **사운드 중요**: 공격/피격 사운드가 긴장감의 핵심 (audio 팀 협업)

---

## Cross-Team 협업

| 팀 | 협업 지점 |
|----|-----------|
| ai | 몬스터 공격 어빌리티 발동 조건 → ai 팀, 데미지/이펙트 → combat |
| animation | Montage Notify 윈도우 (공격 타이밍) — `07_animation_verifier`가 ±33ms 검증 |
| audio | 공격/피격 GameplayCue 사운드 |
| balance | 무기 데미지·쿨다운·스태미나 비용 |
| interaction | 무기로 장애물(Barricade) 파괴 |
| network | RPC/Replication 권한 매트릭스 |

---

## 관련 스킬·문서

- [skills/_template.md](../_template.md) — 스킬 작성 표준 (≤500줄)
- [skills/gas-helper](../gas-helper/SKILL.md) — GAS 코드 자세히
- [team/combat/README.md](../../team/combat/README.md) — combat 팀 (Mode: Agent Team, 4-way Fan-out)
- [GDD_03_플레이어.md](../../GDD_03_플레이어.md)
- [GDD_08B_밸런스_몬스터.md](../../GDD_08B_밸런스_몬스터.md)
