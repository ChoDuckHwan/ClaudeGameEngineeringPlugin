# Network/Session Team — 네트워크/세션 시스템 팀

ProjectFIB 의 Listen Server 멀티플레이어, Steam P2P, 세션 관리(Lobby/Browse/Join/Leave/Restart), GAS 리플리케이션, RPC 권한, 호스트 마이그레이션, 네트워크 암호화를 책임지는 팀입니다.

## Pattern (Tier 2 #2)

- **Primary**: Pipeline (01 → 02 → 04)
- **Producer-Reviewer**: 04 ↔ 07 (**max_retry=1** — 네트워크 안전성 critical, 보수적 검증 우선, [`_retry_policy.md`](../_retry_policy.md) 오버라이드)
- **Parallelizable Stages**: `[06, 07, 08]` — RPC/Replication/세션 변경 영향 분석 독립
- **Mode**: **Hybrid** — 검증(07)이 보안·치팅·DDoS까지 다루어 무거움 → 단독 Sub-agent로 깊이 검증
- **Reference**: [`_patterns.md`](../_patterns.md)

## 팀 구성

| # | 역할 | 에이전트 | 모델 | 핵심 업무 |
|---|------|---------|------|----------|
| 01 | 기획 구체화 | `network-design-concretizer` | opus | FixItBots_ListenServer.md → 네트워크 기술 사양서 |
| 02 | 아키텍트 | `network-architect` | opus | Subsystem/GameInstance/Session 클래스 설계, RPC 매트릭스 |
| 03 | 구조 설명 | `network-structure-explainer` | opus | 세션 라이프사이클·권한 분리·리플리케이션 다이어그램 |
| 04 | 기능 구현 | `network-feature-implementer` | opus | Subsystem/RPC/Replication/Steam P2P 구현 |
| 05 | 기능 개선 | `network-feature-improver` | opus | 대역폭 절감, RPC 빈도, 리플리케이션 조건 최적화 |
| 06 | 변경 리포트 | `network-change-reporter` | sonnet | 리플리케이션/RPC/세션 API 변경 영향 정리 |
| 07 | 검증원 | `network-verifier` | opus | 권한 우회·치팅·DDoS·재진입·암호화 검증 |
| 08 | 테스터 | `network-tester` | opus | 1-4인 시나리오, 호스트 마이그레이션, 패킷 손실 |
| 09 | 히스토리 | `network-history` | sonnet | 활동/네트워크 사고/튜닝 누적 |
| 10 | 기능 활성화 | `network-feature-activator` | opus | Steam AppId/EOS, 세션 위젯 연결, 콘솔 테스트, 4인 PIE 가이드 |

## 워크플로우

```
기획 (FixItBots_ListenServer.md, GDD_02 세션디자인)
    │
    ▼
[01 구체화] ─▶ [02 아키텍트] ─▶ [04 구현] ─▶ [06 리포트] + [07 검증] + [08 테스트]
                                                                   │
                                          ┌────────────────────────┘
                                          ▼
                                    [05 개선] (필요 시) ─▶ [03 구조 설명] (요청 시)
                                          │
                                          ▼
                                    [10 활성화] ─▶ 사용자 4인 PIE / Steam 빌드 체험
                                          │
                                          ▼
                                    [09 히스토리]
```

## Cross-Team 협업

- **ai 팀**: AI 결정의 서버 권한 가드 — network 가 권한 패턴 표준 제공
- **interaction 팀**: 4인 동시 인터랙션 시 서버 처리 — network 가 RPC 패턴 검토
- **combat 팀**: 어빌리티 리플리케이션 / 데미지 RPC — network 가 GAS Replication Mode 지정 감수
- **ui 팀** (향후): 세션 위젯 / 로비 UI 의 콜백 시그니처

## 핵심 원칙

1. **Listen Server 가정**: Host = Server + Autonomous. 모든 코드 검토는 Listen Server 모델 기준
2. **서버 권한 절대**: 클라이언트 입력은 항상 의심
3. **대역폭 의식**: 4인 환경에서 폭증하는 RPC/Replication 빈도 측정
4. **재진입 안전**: 세션 Leave/Rejoin 사이클 무한 반복해도 안정
5. **Steam P2P 전제**: NAT 뚫기 / Steam SDK 의존성 명시
6. **Encryption 검증**: `UFIBGameInstance` 의 NetworkEncryptionToken 흐름 검토

## Dry-Run

이 팀은 **실행 전 계획 미리보기**를 지원한다.

- 호출 예: `"network 팀 dry-run으로 [세션/RPC 작업] 계획 보여줘"`
- 표준 출력: [`_patterns.md` Dry-Run 모드](../_patterns.md#dry-run-모드-표준-tier-2-4)
- 권장 사용 시점:
  1. RPC/Replication 매트릭스 변경 (보안·치팅 검증 깊음 — max_retry=1)
  2. 세션 라이프사이클 변경 (1-4인 시나리오·재진입 회귀 위험)

## 관련 문서

- [FixItBots_ListenServer.md](../../FixItBots_ListenServer.md)
- [GDD_02_세션디자인.md](../../GDD_02_세션디자인.md)
- `Source/ProjectFIB/System/FIBCommonSessionSubsystem.*`
- `Source/ProjectFIB/System/FIBGameInstance.*`
- `Source/ProjectFIB/System/FIBGameSession.*`
