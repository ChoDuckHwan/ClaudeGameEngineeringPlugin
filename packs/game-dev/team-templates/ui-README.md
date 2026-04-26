# UI/HUD Team — UI 시스템 팀

ProjectFIB 의 UI 시스템(CommonUI 레이어, MVVM ViewModel, HUD Layout, Indicator, Lobby/Settings/SessionBrowser/Modal, 접근성/현지화)을 책임지는 팀입니다.

## Pattern (Tier 2 #2)

- **Primary**: Pipeline (01 → 02 → 04)
- **Producer-Reviewer**: 04 ↔ 07 (max_retry=2)
- **Parallelizable Stages**: `[06, 07, 08]` — Fan-out 후보: 가독성·접근성·반응형을 독립 검증으로 분기 가능 (향후 검증원 세분화 시)
- **Mode**: **Hybrid** — 접근성·현지화 회귀처럼 cross-cutting 검증은 Agent Team, 단일 위젯 작업은 Sub-agent
- **Reference**: [`_patterns.md`](../_patterns.md)

## 팀 구성

| # | 역할 | 에이전트 | 모델 | 핵심 업무 |
|---|------|---------|------|----------|
| 01 | 기획 구체화 | `ui-design-concretizer` | opus | GDD_03/07/09 + UI_Layout 폴더 → 위젯 사양서 |
| 02 | 아키텍트 | `ui-architect` | opus | Widget 계층, MVVM ViewModel, UILayer 배정, ActivatableWidget 결정 |
| 03 | 구조 설명 | `ui-structure-explainer` | opus | UI 데이터 흐름(GameplayMessage→VM→Widget), 레이어 스택 다이어그램 |
| 04 | 기능 구현 | `ui-feature-implementer` | opus | UMG 위젯 C++ 클래스, ViewModel, GameplayMessageRouter 구독 구현 |
| 05 | 기능 개선 | `ui-feature-improver` | opus | Tick 위젯 제거, Drawcall 절감, ListView 가상화, ViewModel 갱신 빈도 |
| 06 | 변경 리포트 | `ui-change-reporter` | sonnet | 신규 위젯/VM/Layer/Indicator 변경 영향 정리 |
| 07 | 검증원 | `ui-verifier` | opus | 권한(서버에서 UI 호출 X), 접근성, 현지화 키, MVVM 누수, Tick 사용 |
| 08 | 테스터 | `ui-tester` | opus | 1-4인 PIE, 게임패드/마우스 입력, 접근성 토글, 화면비 |
| 09 | 히스토리 | `ui-history` | sonnet | 활동/UX 피드백/위젯 사용 빈도 누적 |
| 10 | 기능 활성화 | `ui-feature-activator` | opus | UMG 에셋 생성, GameUIPolicy 등록, Indicator 디스크립터, 입력 매핑, Experience UI Action 등록 |

## 워크플로우

```
기획 (GDD_03 온보딩/접근성, GDD_07 공포 UI, GDD_09 적응형 UI, .claude/UI_Layout/)
    │
    ▼
[01]→[02]→[04]→[06]+[07]+[08] ─▶ [05]→[03] ─▶ [10]→[09]
```

## Cross-Team 협업

- **player 팀**: HP/Stamina/Sanity/Inventory 데이터 — player 가 데이터, ui 가 위젯 + ViewModel
- **interaction 팀**: 인터랙션 인디케이터 / 프롬프트 — interaction 의 Indicator System 과 ui 의 위젯 연결
- **combat 팀**: Damage Number / Cooldown UI — combat 이 GameplayMessage, ui 가 위젯
- **network 팀**: Lobby / SessionBrowser / Connecting 위젯 — network 가 Subsystem API, ui 가 위젯 콜백
- **audio 팀**: UI SFX 가이드라인 일치 (CommonUI Sound Style)
- **ai 팀**: 악령 인디케이터 / 인지 표시
- **horror-direction 팀** (향후): 적응형 UI 강도 / 시각적 호러 오버레이

## 핵심 원칙

1. **MVVM 우선**: 위젯에 비즈니스 로직 두지 않음. ViewModel 에 데이터/명령 집중
2. **GameplayMessage 구독**: 위젯이 PlayerState/PlayerController 직접 폴링 X. Message Router 사용
3. **Tick 금지**: 위젯 Tick 사용 금지. Bind 또는 Message 기반
4. **CommonUI Layer 기반**: 직접 AddToViewport 금지. UILayer 태그 통한 Push
5. **접근성 일등 시민**: 모든 위젯이 색맹/자막/스케일/모션 제한 옵션 존중
6. **현지화 키**: 하드코딩 한국어 금지. NSLOCTEXT / FText 사용
7. **게임패드 우선**: 모든 인터랙션이 게임패드로도 동작 (CommonUI Focus)
8. **클라이언트 전용**: UI 코드는 클라에서만. 서버에서 UI API 호출 금지

## Dry-Run

이 팀은 **실행 전 계획 미리보기**를 지원한다.

- 호출 예: `"ui 팀 dry-run으로 [위젯/HUD 작업] 계획 보여줘"`
- 표준 출력: [`_patterns.md` Dry-Run 모드](../_patterns.md#dry-run-모드-표준-tier-2-4)
- 권장 사용 시점:
  1. 신규 위젯/HUD (접근성·현지화·UILayer 영향 사전 점검)
  2. ViewModel 리팩토링 (cross-cutting 영향 큰 작업)

## 관련 문서

- [GDD_03_플레이어.md](../../GDD_03_플레이어.md) (온보딩, 접근성)
- [GDD_07_공포연출.md](../../GDD_07_공포연출.md) (호러 UI)
- [GDD_09_몰입강화.md](../../GDD_09_몰입강화.md) (적응형 UI)
- [GDD_10_기술매핑.md](../../GDD_10_기술매핑.md)
- [UI_Layout/](../../UI_Layout/) (레이아웃 가이드)
- `Source/ProjectFIB/UI/` (HUD, ViewModels, Widgets)
- `Source/ProjectFIB/Indicator/` (Indicator System)

## UI Layer 사용 가이드

| Layer Tag | 용도 | 동시 표시 |
|-----------|------|---------|
| `UI.Layer.Game` | HUD (HP/Stamina/Inventory/Indicator) | 항상 |
| `UI.Layer.GameMenu` | 일시정지, 인벤토리 풀화면 | 단독 |
| `UI.Layer.Lobby` | 로비 메뉴, SessionBrowser | 단독 |
| `UI.Layer.Menu` | 메인 메뉴, 설정 | 단독 |
| `UI.Layer.Popup` | 다이얼로그, 알림 | 다중 |
| `UI.Layer.Modal` | 차단형 (확인 필요) | 단독, 최상위 |
