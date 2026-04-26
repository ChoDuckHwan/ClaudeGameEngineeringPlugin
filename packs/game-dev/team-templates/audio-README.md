# Audio/Cue Team — 사운드/큐 시스템 팀

ProjectFIB 의 오디오 시스템(MetaSounds/SoundCue, GameplayCue, AudioBus, Submix, Sound Concurrency, Attenuation, 호러 사운드 디자인, 음성 채팅)을 책임지는 팀입니다.

## Pattern (Tier 2 #2)

- **Primary**: Pipeline (01 → 02 → 04 → 06+07+08)
- **Producer-Reviewer**: 04 ↔ 07 (max_retry=2)
- **Parallelizable Stages**: `[06, 07, 08]` — 큐 변경 리포트·검증·테스트 독립
- **Mode**: **Sub-agent** (대부분 단발 큐 작업) — 신규 시스템 도입 시에만 Agent Team
- **Reference**: [`_patterns.md`](../_patterns.md)

## 팀 구성

| # | 역할 | 에이전트 | 모델 | 핵심 업무 |
|---|------|---------|------|----------|
| 01 | 기획 구체화 | `audio-design-concretizer` | opus | GDD_07 공포연출/GDD_09 몰입강화 → 오디오 사양서 |
| 02 | 아키텍트 | `audio-architect` | opus | GameplayCue 계층, AudioBus/Submix 라우팅, Concurrency 그룹 설계 |
| 03 | 구조 설명 | `audio-structure-explainer` | opus | 큐 트리거 흐름, Mix 라우팅 다이어그램 |
| 04 | 기능 구현 | `audio-feature-implementer` | opus | GameplayCueNotify_Static/Actor, Sound Concurrency 코드 구현 |
| 05 | 기능 개선 | `audio-feature-improver` | opus | Voice 수 제한, Attenuation 곡선, Submix CPU 최적화 |
| 06 | 변경 리포트 | `audio-change-reporter` | sonnet | 큐/AudioBus/Submix 변경 영향 정리 |
| 07 | 검증원 | `audio-verifier` | opus | Cue 권한, Concurrency 누락, 클립핑, Loop 누수 검증 |
| 08 | 테스터 | `audio-tester` | opus | 1-4인 동시 사운드, 카메라 거리별 Attenuation, 묵음/피크 |
| 09 | 히스토리 | `audio-history` | sonnet | 활동/사운드 디렉터 노트/플레이테스트 피드백 누적 |
| 10 | 기능 활성화 | `audio-feature-activator` | opus | MetaSound 에셋 생성, GameplayCue Tag 매핑, AudioBus/Submix 설정, 인게임 듣기 가이드 |

## 워크플로우

```
기획 (GDD_07 공포연출, GDD_09 몰입, FIBAudioSettings)
    │
    ▼
[01 구체화] ─▶ [02 아키텍트] ─▶ [04 구현] ─▶ [06 리포트] + [07 검증] + [08 테스트]
                                                                   │
                                          ┌────────────────────────┘
                                          ▼
                                    [05 개선] ─▶ [03 구조 설명]
                                          │
                                          ▼
                                    [10 활성화] ─▶ 사용자 인게임 듣기
                                          │
                                          ▼
                                    [09 히스토리]
```

## Cross-Team 협업

- **combat 팀**: 공격/피격 GameplayCue 트리거 — combat 이 어빌리티/이펙트, audio 가 큐 사운드
- **ai 팀**: 몬스터 발자국/포효/숨소리 큐 — audio 가 Cue, ai 가 트리거 시점
- **interaction 팀**: 인터랙션 효과음 (열림/잠김/실패) — audio 가 큐 사운드, interaction 이 트리거
- **ui 팀** (향후): UI SFX 가이드라인

## 핵심 원칙

1. **GameplayCue 우선**: 모든 게임플레이 사운드는 GameplayCue 로 트리거 (직접 PlaySound 금지)
2. **Concurrency 강제**: 모든 Cue 에 SoundConcurrency 지정 (Voice 폭주 방지)
3. **Attenuation 명시**: 모든 World Sound 에 Attenuation 지정 (디폴트 무한거리 금지)
4. **Listen Server 의식**: 호스트는 자기 사운드 + 모든 클라 사운드 → CPU 부담 측정
5. **Submix Mix 권한**: AudioBus 와 Submix 변경은 audio-architect 만
6. **호러 디자인 일관성**: GDD_07 의 디제틱/논디제틱 구분 엄수

## Dry-Run

이 팀은 **실행 전 계획 미리보기**를 지원한다.

- 호출 예: `"audio 팀 dry-run으로 [큐 작업] 계획 보여줘"`
- 표준 출력: [`_patterns.md` Dry-Run 모드](../_patterns.md#dry-run-모드-표준-tier-2-4)
- 권장 사용 시점:
  1. 신규 GameplayCue 추가 (Concurrency·Submix 영향 사전 점검)
  2. AudioBus/Submix 라우팅 변경 (전체 믹스 회귀 위험 큰 작업)

## 관련 문서

- [GDD_07_공포연출.md](../../GDD_07_공포연출.md)
- [GDD_09_몰입강화.md](../../GDD_09_몰입강화.md)
- [SETTINGS.md](../../SETTINGS.md) (FIBAudioSettings 부분)
- `Source/ProjectFIB/Audio/FIBAudioSettings.*`
- `Source/ProjectFIB/Audio/`
