# Player/Equipment Team — 플레이어/장비 시스템 팀

ProjectFIB 의 플레이어 시스템(캐릭터 본체, 장비 슬롯·로드아웃, 인벤토리, 무게/스태미나/정신력, 다운/부활, 협동 메커닉, 접근성/온보딩)을 책임지는 팀입니다.

## Pattern (Tier 2 #2)

- **Primary**: Pipeline (01 → 02 → 04)
- **Producer-Reviewer**: 04 ↔ 07 (max_retry=2)
- **Parallelizable Stages**: `[06, 07, 08]` — Attribute/Inventory/장비 슬롯 변경 영향 분석 독립
- **Mode**: **Hybrid** — 다운/부활 race·접근성 회귀처럼 cross-cutting 검증은 Agent Team, 단일 슬롯 작업은 Sub-agent
- **Reference**: [`_patterns.md`](../_patterns.md)

## 팀 구성

| # | 역할 | 에이전트 | 모델 | 핵심 업무 |
|---|------|---------|------|----------|
| 01 | 기획 구체화 | `player-design-concretizer` | opus | GDD_03/08A → 캐릭터·장비·인벤토리 기술 사양 |
| 02 | 아키텍트 | `player-architect` | opus | Character/PlayerState/Component 설계, ASC↔Inventory 결합점 |
| 03 | 구조 설명 | `player-structure-explainer` | opus | 초기화 상태머신, 다운/부활, 장비 변경 흐름 다이어그램 |
| 04 | 기능 구현 | `player-feature-implementer` | opus | Character/Component/AttributeSet/Fragment 구현 |
| 05 | 기능 개선 | `player-feature-improver` | opus | 인벤토리 트래픽, 장비 변경 비용, 다운/부활 race 개선 |
| 06 | 변경 리포트 | `player-change-reporter` | sonnet | Attribute/Inventory/장비 슬롯 변경 영향 정리 |
| 07 | 검증원 | `player-verifier` | opus | ASC 권한, 무게 우회, 장비 동기화, 접근성 회귀 검증 |
| 08 | 테스터 | `player-tester` | opus | 1-4인 시나리오, 다운 체인, 무게 한도, 접근성 옵션 |
| 09 | 히스토리 | `player-history` | sonnet | 활동/온보딩 피드백/장비 메타 분석 누적 |
| 10 | 기능 활성화 | `player-feature-activator` | opus | PlayerState/Character BP, AbilitySet, ItemDefinition, Loadout DataAsset, Experience 등록 가이드 |

## 워크플로우

```
기획 (GDD_03 플레이어, GDD_08A 아이템, Phase1 §11~12)
    │
    ▼
[01]→[02]→[04]→[06]+[07]+[08] ─▶ [05]→[03] ─▶ [10]→[09]
```

## Cross-Team 협업

- **combat 팀**: 무기 어빌리티/데미지는 combat, 장비 슬롯·인벤토리·스태미나 비용 후크는 player
- **interaction 팀**: 픽업·아이템 사용은 interaction, 인벤토리 매니저·Fragment 정의는 player
- **ai 팀**: 어그로 대상의 정신력/소음 등급은 player 가 정의, ai 가 소비
- **ui 팀**: HUD 의 HP/Stamina/Sanity/Inventory 슬롯 위젯 — player 가 데이터, ui 가 위젯
- **balance 팀** (향후): 8A 수치 튜닝

## 핵심 원칙

1. **ASC 는 PlayerState**: 리스폰 시 어빌리티 영속성 — Pawn 으로 옮기지 않음
2. **Inventory 도 PlayerState**: 사망/리스폰에도 인벤토리 유지
3. **무게 검증은 서버**: 클라가 보낸 픽업 요청에서 무게 한도 재계산
4. **다운/부활은 결정론적**: 서버 가 다운 트리거 → 클라 시각화 → 부활 인터랙션 → 서버 검증
5. **Sanity/Stamina 회복은 컨디션 기반**: 정지/걷기/은신 같은 명시적 상태 태그에 결합
6. **접근성 우선**: 색맹 / 자막 / 모션 제한 옵션은 모든 신규 기능에서 옵션화
7. **온보딩 비파괴**: 첫 세션 학습 흐름에 영향 주는 변경은 명시적 마이그레이션

## Dry-Run

이 팀은 **실행 전 계획 미리보기**를 지원한다.

- 호출 예: `"player 팀 dry-run으로 [캐릭터/장비 작업] 계획 보여줘"`
- 표준 출력: [`_patterns.md` Dry-Run 모드](../_patterns.md#dry-run-모드-표준-tier-2-4)
- 권장 사용 시점:
  1. 신규 Attribute/Fragment 추가 (cross-cutting 검증 비용 큼)
  2. 다운/부활 race 수정 (서버·클라 동기 회귀 위험)

## 관련 문서

- [GDD_03_플레이어.md](../../GDD_03_플레이어.md)
- [GDD_08A_밸런스_아이템.md](../../GDD_08A_밸런스_아이템.md)
- [GDD_10_기술매핑.md](../../GDD_10_기술매핑.md)
- [FixItBots_Phase1_핵심시스템구현_완전판.md](../../FixItBots_Phase1_핵심시스템구현_완전판.md)
- `Source/ProjectFIB/Player/`, `Source/ProjectFIB/Character/`, `Source/ProjectFIB/Inventory/`
