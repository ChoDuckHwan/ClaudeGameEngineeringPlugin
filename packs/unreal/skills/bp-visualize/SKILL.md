---
name: bp-visualize
description: "Widget Blueprint, BehaviorTree, AnimInstance Blueprint(State Machine) 작업 가이드를 인터랙티브 HTML 시각자료로 동시 생성합니다. 사용자가 UE 에디터에서 따라 만들 수 있도록 좌측 노드 그래프 + 우측 단계별 작업 지시 사이드바를 제공합니다. 사용자가 '위젯 만들어줘, BT 짜줘, AnimBP 상태머신, BP 시각 가이드, 노드 그래프 그려, blueprint 가이드 HTML, 따라 만들 수 있게, 위젯 설계 도와줘, behavior tree 만들기, anim state machine' 등을 언급할 때 활성화됩니다."
---

# BP Visualize Skill (Authoring Guide → HTML)

Blueprint 작업 가이드를 줄 때 **텍스트 설명 + 동시에 인터랙티브 HTML 시각자료**를 생성합니다.
사용자는 HTML을 옆 모니터에 띄워놓고 UE 에디터에서 단계대로 따라 만들면 됩니다.

> **Progressive Disclosure** ([skill-_template.md](../../../../core/templates/skill-_template.md) ≤500줄 정책): SKILL.md는 오케스트레이션·DSL 개요·트리거만.
> 상세 DSL 명세·viewer 템플릿·예시는 `references/`로 분리.

## References

- [dsl_schema.md](references/dsl_schema.md) — YAML DSL 스키마 (Widget/BT/AnimBP 3종)
- [viewer_widget.html](references/viewer_widget.html) — Widget Blueprint HTML 뷰어 (좌측 트리 + 우측 단계)
- [viewer_bt.html](references/viewer_bt.html) — BehaviorTree HTML 뷰어
- [viewer_statemachine.html](references/viewer_statemachine.html) — AnimBP State Machine HTML 뷰어
- [workflow.md](references/workflow.md) — Claude 행동 절차 (DSL→HTML 치환·저장)
- [examples.md](references/examples.md) — 실제 가이드 예시 (W_HealthHUD, BT_Guard, ABP_Locomotion)

---

## 트리거 (Should-Trigger)

- "체력바 위젯 만들어줘"
- "BT_Guard 추격 패트롤 짜줘"
- "AnimBP에 Idle/Walk/Run 상태머신 만들고 싶어"
- "Widget Blueprint 가이드를 시각자료로 줘"
- "이 BT 구조 따라 만들 수 있게 그려줘"
- "노드 그래프로 보여주면서 설명해줘"

## Should-NOT-Trigger

| 입력 예시 | 기대 호출 | 이유 |
|-----------|-----------|------|
| "기존 WBP 분석해줘 (이미 만든 것)" | (Python 추출 도구 — v2 후보) | 본 스킬은 **forward**(작업 가이드), 역방향 분석 아님 |
| "위젯 C++ 클래스 코드 짜줘" | [ui-helper](../ui-helper/SKILL.md) | C++ 위젯 베이스 클래스는 ui-helper |
| "UI 디자인 이론" | [game-design-core](../../../game-dev/skills/game-design-core/SKILL.md) | 시각화가 아닌 설계 원칙 질의 |
| "위젯이 안 뜨는데 디버깅" | [unreal-engine](../unreal-engine/SKILL.md) | 디버깅·문제해결은 일반 UE 스킬 |

## Identity

**WHO**: 솔로 개발자가 Blueprint 자산(WBP/BT/AnimBP)을 새로 만들거나 수정할 때.

**WHEN**:
- 노드/위젯 5개 이상인 가이드(텍스트만으로는 따라가기 어려움)
- BT/StateMachine 같이 **구조와 흐름이 중요한** 자산
- 여러 자식·전환을 가진 복잡한 위젯 계층

**WHY**: 텍스트 가이드만으로는 "어디에 무엇을 어떻게" 매칭이 어려움. HTML로 노드 그래프 + 단계 클릭 시 해당 노드 강조 → UE 에디터 작업을 **눈으로 보면서** 따라할 수 있음.

---

## 핵심 워크플로우 (Claude 행동)

### Step 1: 자산 타입 판별

| 사용자 키워드 | 타입 | 사용 viewer |
|-------------|------|------------|
| 위젯, WBP, UI, HUD, Widget | WidgetBlueprint | viewer_widget.html |
| BT, BehaviorTree, AI 트리 | BehaviorTree | viewer_bt.html |
| AnimBP, 상태머신, StateMachine, Anim Graph | AnimInstance | viewer_statemachine.html |
| EventGraph, BP 노드 | (v2 후보, 지금은 텍스트) | N/A |

### Step 2: 가이드 + DSL 작성

응답 본문에:
1. **자연어 설명** — 목적·핵심 결정·주의사항
2. **YAML DSL** — 구조와 단계를 표준 포맷으로 (스키마는 [dsl_schema.md](references/dsl_schema.md))

> DSL은 사용자에게 보여줘도 되지만 **메인은 HTML**. 사용자가 옆에 두고 볼 시각자료가 핵심.

### Step 3: HTML 생성

1. 해당 타입의 viewer 템플릿 `Read`
2. 템플릿 안의 `/*<<DATA>>*/ { ...demo... }` 자리표시자를 실제 DSL 변환 JSON으로 치환
3. `<title>{{ASSET_NAME}}</title>`의 `{{ASSET_NAME}}`도 실제명으로 치환
4. `.claude/bp_guides/<name>.html`로 `Write`

> JSON 안전 escape: `</script>` 시퀀스가 있으면 깨짐. JSON 문자열화 후 `.replace("</", "<\\/")` 적용.

### Step 4: 사용자 안내

```markdown
✅ 가이드 + 시각자료 생성 완료
- 텍스트 가이드: (위 본문 참조)
- 시각자료: [bp_guides/<name>.html](.claude/bp_guides/<name>.html) ← 더블클릭하여 브라우저로 열기
- 좌측 그래프 + 우측 단계 리스트. 단계를 클릭하면 해당 노드가 강조됩니다.
```

---

## Output Format

```markdown
## <자산명> — <한 줄 목적>

[자연어 설명: 왜 이렇게 만드는지, 핵심 결정]

### 작업 가이드 (DSL)
```yaml
target: <type>
name: <자산명>
goal: <한 줄 목적>
tree: ...
steps: ...
```

### 시각자료
✅ [bp_guides/<name>.html](.claude/bp_guides/<name>.html)
- 좌측: 노드 그래프 (pan/zoom)
- 우측: 단계 N개 (클릭 시 해당 노드 강조)
- 다크/라이트 토글, 검색

### 다음 단계
[UE 에디터 실행 + HTML 열기 + 단계 따라하기 안내]
```

---

## Sharp Edges

- **자산 이름 명시 필수**: `name:` 필드 없으면 HTML 파일명 결정 불가 → Claude는 시작 전 사용자에게 확인 또는 컨벤션 기반 자동 명명(예: `W_FeatureName`).
- **단계와 노드 ID 일치**: `steps[].highlight` 배열의 ID가 `tree`의 노드 ID와 일치해야 강조 동작. 오타 시 강조 안 됨 → DSL 작성 후 자체 검증 필수.
- **출력 디렉토리 자동 생성 안 함**: `.claude/bp_guides/`가 없으면 Write 실패. Claude는 Write 전에 디렉토리 존재 확인 또는 mkdir.
- **AnimBP EventGraph는 미지원**: State Machine만 지원. EventGraph는 텍스트 가이드로.
- **너무 작은 자산엔 과잉**: 노드 3개 이하 위젯에 HTML은 오버킬 → 텍스트만으로 충분, 시각자료 생성 스킵.
- **CDN 의존**: viewer는 unpkg.com에서 cytoscape.js 로드. 오프라인이면 [workflow.md §오프라인](references/workflow.md) 참조.
- **재실행 시 덮어씀**: 동일 이름 HTML은 그대로 덮어씀. 버전 보관 필요하면 사용자 수동 rename.

---

## Examples

### 케이스 1: Widget Blueprint

```
사용자: "체력바 + 수치 표시하는 미니멀 HUD 위젯 만들어줘"

Claude:
1. 자산 타입 = WidgetBlueprint
2. 텍스트 가이드 + YAML DSL (Root CanvasPanel → HBox → ProgressBar + TextBlock)
3. viewer_widget.html 읽기 → DSL inline 치환 → bp_guides/W_HealthHUD.html 저장
4. 결과 링크 + 단계 6개 안내
```

상세 예시: [examples.md §W_HealthHUD](references/examples.md)

### 케이스 2: BehaviorTree

```
사용자: "Spirit AI에 추격/패트롤 BT 짜줘"

Claude:
1. 자산 타입 = BehaviorTree
2. DSL: Selector → [Chase Sequence (Blackboard deco), Patrol Sequence]
3. viewer_bt.html 치환 → bp_guides/BT_Guard.html
4. 8단계 안내 (Blackboard 키 → 노드 추가 → 데코 설정 → 자식 배치)
```

상세 예시: [examples.md §BT_Guard](references/examples.md)

### 케이스 3: AnimBP State Machine

```
사용자: "ABP_Player에 Idle/Walk/Run 상태머신 만들고 싶어"

Claude:
1. 자산 타입 = AnimInstance/StateMachine
2. DSL: 3 states + 4 transitions (속도 조건)
3. viewer_statemachine.html 치환 → bp_guides/ABP_Locomotion_SM.html
4. 9단계 안내
```

상세 예시: [examples.md §ABP_Locomotion](references/examples.md)

---

## 관련 스킬·문서

- [skills/ui-helper](../ui-helper/SKILL.md) — UI C++ 위젯 베이스 클래스 (본 스킬 산출물 ↔ ui-helper 산출물 함께 사용)
- [skills/unreal-engine](../unreal-engine/SKILL.md) — 일반 UE 개발 질의
- [skills/combat-helper](../combat-helper/SKILL.md) — 전투 AI BT 도메인
- `HARNESS.md` / `CLAUDE.md` — 부착된 사용자 프로젝트 루트에 생성되는 문서 (플러그인 저장소 안이 아니라 프로젝트 쪽)

---

> 본 스킬은 **forward 가이드 시각화 전용**. 기존 BP 역방향 추출(자산 분석) 도구는 v2 후보로 보류.
