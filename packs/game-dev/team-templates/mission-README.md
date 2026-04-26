# Mission/Experience Team — 미션/세션 흐름 팀

ProjectFIB 의 게임플레이 세션 흐름(의뢰 선택→로비→Experience 로딩→플레이→정산→복귀), 시설/맵 관리, 봉인실 잠금 시스템, 트리거/퍼즐/함정 상위 흐름을 책임지는 팀입니다. *기술적* 세션은 network 팀이, *게임플레이* 세션은 이 팀이 담당.

## Pattern (Tier 2 #2 + #7)

- **Primary**: Pipeline (01 → 02 → 04)
- **Secondary**: **Supervisor (Tier 2 #7 시범 적용)** — Phase 1/2/3 §섹션 단위 동적 분배 시 발동
- **Producer-Reviewer**: 04 ↔ 07 (max_retry=2)
- **Parallelizable Stages**: `[06, 07, 08]` — Experience/Contract/SealLock 검증 독립
- **Mode**: **Hybrid** — 단발 작업은 Sub-agent, **Phase 다중 §섹션 분배는 Agent Team (Supervisor)**
- **Reference**: [`_patterns.md`](../_patterns.md) ⑤ Supervisor

### Supervisor 모드 발동 조건

다음 중 하나라면 mission 팀이 Supervisor 모드로 전환:

1. **Phase의 §섹션 ≥3개 동시 진행** (예: Phase1 §4·§5·§7 동시)
2. **사용자 명시 호출**: `"mission 팀 supervisor 모드로 Phase1 §4-§9 분배해줘"`
3. **Dry-Run에서 작업량 추정 ≥3 worker 필요**

### Supervisor 모드 절차

```
Step 1. mission-architect (02)가 Phase §섹션 → 작업 단위 분해 (의존성 그래프 작성)
Step 2. mission-architect가 supervisor 역할 인수 — 공유 작업 목록 작성
Step 3. mission-feature-implementer (04)를 N개 worker로 병렬 호출
   - worker_A: §4 (의존성 없음)
   - worker_B: §5 (§4 완료 후)
   - worker_C: §7 (의존성 없음, A와 병렬)
Step 4. supervisor가 worker 진행 상황 추적 (TaskUpdate)
Step 5. 완료 worker 결과 누적 → 06_change_reporter + 07_verifier에 전달
Step 6. 모든 worker 완료 시 09_history에 분배 패턴 기록
```

### Supervisor 모드 가드

- **위임 단위 최소 크기**: §섹션 1개 이상 (너무 작은 단위 금지 — supervisor 병목)
- **worker 수 ≤4**: 4 초과 시 §을 더 큰 단위로 묶기
- **재시도 캡 worker별 적용**: 각 worker가 04↔07 max_retry=2 독립 추적
- **계층 깊이 ≤2 준수**: supervisor(D1) → worker(D2 = 같은 04 에이전트) → 다른 팀 호출 ❌

## 팀 구성

| # | 역할 | 에이전트 | 모델 | 핵심 업무 |
|---|------|---------|------|----------|
| 01 | 기획 구체화 | `mission-design-concretizer` | opus | GDD_00/02 + Phase1 §4-§9 + 잠금장치 → 미션 기술 사양 |
| 02 | 아키텍트 | `mission-architect` | opus | Experience/GameMode/PawnData/Action 설계, ContractSelection 흐름 |
| 03 | 구조 설명 | `mission-structure-explainer` | opus | 의뢰→로비→게임→정산 시퀀스, Experience 로딩 단계 다이어그램 |
| 04 | 기능 구현 | `mission-feature-implementer` | opus | ExperienceDefinition/Action/ContractDefinition/SealLockComponent 구현 |
| 05 | 기능 개선 | `mission-feature-improver` | opus | Experience 로딩 비용, GameFeature 토글 race, 정산 트래픽 개선 |
| 06 | 변경 리포트 | `mission-change-reporter` | sonnet | Experience/Contract/SealLock 변경 영향 정리 |
| 07 | 검증원 | `mission-verifier` | opus | 권한, GameFeature 의존성 누락, 정산 위변조, 봉인실 race 검증 |
| 08 | 테스터 | `mission-tester` | opus | 1-4인 풀 사이클, 잠금실 변형, GameFeature 토글, 호스트 종료 |
| 09 | 히스토리 | `mission-history` | sonnet | 활동/세션 분석/정산 곡선/리텐션 누적 |
| 10 | 기능 활성화 | `mission-feature-activator` | opus | Experience DataAsset, ContractDefinition, GameFeature 플러그인, Lobby/Map 등록 가이드 |

## 워크플로우

```
기획 (GDD_00 비전, GDD_02 세션, Phase1 §4-§9, 잠금장치 시스템)
    │
    ▼
[01]→[02]→[04]→[06]+[07]+[08] ─▶ [05]→[03] ─▶ [10]→[09]
```

## Cross-Team 협업

- **network 팀**: 세션 *기술* 측면. mission 은 기술 세션 위에 게임플레이 흐름을 얹음
- **player 팀**: PawnData / Loadout 적용 시점은 Experience 의 책임
- **interaction 팀**: 봉인실 잠금장치는 mission 이 상위 흐름, interaction 이 인터랙션 면
- **balance 팀** (신규): 의뢰 보상 / 정산 곡선 / 등급별 난이도
- **ai 팀**: 테마별 몬스터 스폰 정책 (Experience 가 결정)

## 핵심 원칙

1. **Experience 가 진실의 원천**: 모든 기능 활성화는 Experience Definition 통과
2. **Game Feature 모듈성**: 새 미션 콘텐츠는 GameFeature Plugin 단위
3. **정산 서버 권한**: 보상 계산 / 인벤토리 정산은 서버에서만
4. **봉인실 결정론**: 잠금/해제 상태는 서버 결정. 클라는 시각화
5. **Lobby ↔ Game 전환 안전**: 인벤토리/Loadout 영속, 세션 상태 유지
6. **호스트 종료 = 세션 종료**: 호스트 마이그레이션 미지원

## Dry-Run

이 팀은 **실행 전 계획 미리보기**를 지원한다.

- 호출 예: `"mission 팀 dry-run으로 [Experience/Contract 작업] 계획 보여줘"`
- 표준 출력: [`_patterns.md` Dry-Run 모드](../_patterns.md#dry-run-모드-표준-tier-2-4)
- 권장 사용 시점:
  1. 신규 Experience/Contract 추가 (GameFeature 의존성 매트릭스 사전 점검)
  2. 봉인실 잠금 시스템 변경 (interaction·player·ai cross-team)

## 관련 문서

- [GDD_00_게임비전.md](../../GDD_00_게임비전.md)
- [GDD_02_세션디자인.md](../../GDD_02_세션디자인.md)
- [GDD_06_장애물_퍼즐.md](../../GDD_06_장애물_퍼즐.md) (퍼즐 흐름 부분)
- [GDD_10_기술매핑.md](../../GDD_10_기술매핑.md)
- [FixItBots_Phase1_핵심시스템구현_완전판.md](../../FixItBots_Phase1_핵심시스템구현_완전판.md) §4-§9
- [FixItBots_잠금장치시스템.md](../../FixItBots_잠금장치시스템.md)
- `Source/ProjectFIB/GameModes/`, `Source/ProjectFIB/System/`
