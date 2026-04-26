# Animation Team — 전투 애니메이션·몽타주 전문 팀

ProjectFIB 의 전투 애니메이션 자연스러움·몽타주 최적화·AnimInstance 분석·StateMachine 설계·IK·RootMotion·Notify 동기화를 전담하는 **고급 애니메이션 전문가 팀**입니다. 블루프린트 AnimGraph / AnimMontage 에셋 내용을 직접 분석·이해하고 개선점을 제시하며, 가이드 시 외부 자료(블로그·유튜브·공식 문서) 링크를 자동 첨부합니다.

## Pattern (Tier 2 #2)

- **Primary**: Pipeline (01 → 02 → 04)
- **Producer-Reviewer**: 04 ↔ 07 (max_retry=2, 자연스러움 점수 기준)
- **Parallelizable Stages**: `[06, 07, 08]` — 변경 리포트·BP 분석 검증·인게임 테스트 동시 가능
- **Mode**: **Hybrid** — combat 팀과 협업 시 Agent Team, 단독 분석 시 Sub-agent
- **Reference**: [`_patterns.md`](../_patterns.md)

## 차별점

다른 팀과의 명시적 차이:

1. **블루프린트 분석 능력**: AnimInstance Blueprint, AnimMontage, BlendSpace, AnimGraph 에셋 내용을 (텍스트 export / .uasset 메타데이터로) 읽고 이해
2. **외부 자료 자동 첨부**: 모든 가이드에 관련 블로그/유튜브/UE 공식 문서 링크 1-3개 첨부 (WebFetch/WebSearch 사용)
3. **자연스러움 진단**: Blend Time, Foot IK, Root Motion 동기화, Hit Reaction Layer, Anim Notify 정확도 측정
4. **combat 팀의 협력자**: combat 이 어빌리티/데미지, animation 이 모션 자연스러움 + 몽타주 최적화

## 팀 구성

| # | 역할 | 에이전트 | 모델 | 핵심 업무 |
|---|------|---------|------|----------|
| 01 | 기획 구체화 | `animation-design-concretizer` | opus | 전투 모션 기획 → 몽타주/StateMachine 사양 (자연스러움 기준 포함) |
| 02 | 아키텍트 | `animation-architect` | opus | AnimInstance/AnimGraph/StateMachine/Layer 설계, 몽타주 슬롯 계층 |
| 03 | 구조 설명 + 자료 큐레이터 | `animation-structure-explainer` | opus | 흐름 다이어그램 + **블로그/유튜브/공식문서 링크 첨부** |
| 04 | 기능 구현 | `animation-feature-implementer` | opus | AnimNotify, AnimNotifyState, IK FABRIK/CCDIK, Procedural Anim 구현 |
| 05 | 자연스러움 개선 | `animation-naturalness-improver` | opus | Blend Time, Foot IK, Root Motion, Lean Tilt, 12 원칙 적용 + **레퍼런스 영상 첨부** |
| 06 | 변경 리포트 | `animation-change-reporter` | sonnet | 몽타주/AnimGraph/Notify 변경 정리 |
| 07 | 분석 검증원 | `animation-verifier` | opus | **AnimInstance BP / Montage 에셋 분석**, 몽타주 자연스러움·성능 진단, 12원칙 위반 식별 |
| 08 | 테스터 | `animation-tester` | opus | 인게임 모션 검증, 1-4인 동기화, IK 충돌, Notify 빈도, Frame Drop |
| 09 | 히스토리 + 자료 라이브러리 | `animation-history` | sonnet | 활동/플레이테스트 모션 피드백 + **수집된 외부 자료 라이브러리** |
| 10 | 기능 활성화 | `animation-feature-activator` | opus | AnimBP 슬롯 추가, 몽타주 에셋 생성, AnimMontage Notify 배치, ABP↔어빌리티 연결 + **튜토리얼 링크** |

## 워크플로우

```
기획 / combat 팀 요청
    │
    ▼
[01]→[02]→[04]→[06]+[07 분석]+[08]
                    │
                    ▼ (자연스러움 점수 낮으면)
                  [05 자연스러움 개선]
                    │
                    ▼
                  [03 구조 설명 + 자료 첨부]
                    │
                    ▼
                  [10 활성화 + 튜토리얼 링크]
                    │
                    ▼
                  [09 활동/자료 라이브러리]
```

## Cross-Team 협업

- **combat 팀**: 어빌리티 활성화 시점 = animation 의 Notify/Slot 트리거 시점. combat 이 GAS, animation 이 모션 자연스러움
- **player 팀**: Character Movement 의 Lean/Pivot/Stop 이 부드러운지 검증
- **ai 팀**: 몬스터 공격 모션, 시선 IK, 위치 적응 (Look At)
- **horror-direction 팀**: 점프스케어 모션의 카메라 흔들림과 동기

## 핵심 원칙

1. **12 애니메이션 원칙 적용**: Anticipation, Follow-through, Squash/Stretch, Timing 의식
2. **Blend Time 표준**: 공격 In 0.05-0.1s / Out 0.15-0.25s, 이동 0.15-0.3s, 죽음 0.0-0.05s
3. **Root Motion 정확성**: RM 사용 시 서버 검증 필수, 캡슐 콜리전 동기
4. **Foot IK 필수**: 경사면/계단에서 발 미끄러짐 방지
5. **Notify Window 정확도**: 데미지 Notify 와 시각 임팩트 ±33ms (1프레임 30fps)
6. **Layer 분리**: Upper Body / Lower Body / Additive 슬롯 명확히
7. **외부 자료 의무**: 모든 가이드에 1-3개 외부 링크 첨부 (블로그/유튜브/UE 공식)
8. **저작권 의식**: 링크는 출처. 영상 다운로드/저장 X

## 외부 자료 카탈로그 (시작점)

이 팀이 자주 참조하는 신뢰할 만한 채널 (유튜브 등):

- **Unreal Engine 공식**: youtube.com/@UnrealEngine
- **Mathew Wadstein**: 노드 단위 튜토리얼 (`@MathewWadstein`)
- **Smart Poly / Ali Elzoheiry**: 게임플레이 시스템 + ABP
- **Cobra Code**: 전투/몽타주 (`@CobraCode`)
- **Reuben Ward / Ryan Laley**: GAS + Animation
- **UE Docs**: dev.epicgames.com/documentation/en-us/unreal-engine/animation
- **Lyra 샘플**: docs.unrealengine.com/5.5/en-US/lyra-sample-game-in-unreal-engine
- **Polygonhive / Last Wars**: 폴리시 / 12원칙
- **GDC Vault**: 발표 슬라이드

각 에이전트는 작업 종료 시 09 의 자료 라이브러리에 신규 발견 자료를 등록.

## 관련 문서

- `Source/ProjectFIB/Animation/` (있다면)
- `Source/ProjectFIB/Character/FIBCharacter_Player.*`
- Plugin: ContextualAnimation (활성화됨)
- Plugin: GameplayAbilities (Montage 트리거)
- [GDD_03_플레이어.md](../../GDD_03_플레이어.md) (캐릭터 모션 기준)

## Dry-Run

이 팀은 **실행 전 계획 미리보기**를 지원한다.

- 호출 예: `"animation 팀 dry-run으로 [모션 작업] 계획 보여줘"`
- 표준 출력: [`_patterns.md` Dry-Run 모드](../_patterns.md#dry-run-모드-표준-tier-2-4)
- 권장 사용 시점:
  1. 신규 몽타주 자연스러움 진단 (외부 자료 수집 비용 미리 보기)
  2. combat 팀과 cross-team 협업 시점

## 사용 예시

```
1. "도끼 차지 어택 몽타주 자연스러움 개선해줘"
   → 07 (분석) → 05 (개선 + 레퍼런스 영상 링크) → 06

2. "몬스터 공격 모션 끊김 진단"
   → 07 (분석) → 03 (자료 + 다이어그램)

3. "1-4인에서 다른 클라 모션이 끊겨"
   → 08 (테스트) → 05 (네트워크 동기 + 공식 문서 링크)
```
