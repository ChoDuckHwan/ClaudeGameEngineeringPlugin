# BP 가이드 DSL 스키마 (YAML)

`bp-visualize` 스킬이 사용하는 작업 가이드 표준 포맷.
Claude가 DSL을 작성 → viewer HTML 템플릿에 inline 주입.

---

## 공통 헤더

```yaml
target: WidgetBlueprint | BehaviorTree | AnimInstance
name: <자산명, 예: W_HealthHUD>      # 필수, HTML 파일명 결정
goal: <한 줄 목적>                   # 필수
notes: []                            # 선택, 사용자에게 보일 추가 메모
```

---

## 1. Widget Blueprint

```yaml
target: WidgetBlueprint
name: W_HealthHUD
goal: "체력 표시 미니멀 HUD"

tree:
  - id: Root                          # 노드 고유 ID (steps의 highlight에서 참조)
    class: CanvasPanel                # UE 위젯 클래스 (prefix 없이)
    note: "Designer 루트"             # 선택, 노드 카드에 표시
    slot: null                        # root는 슬롯 없음
    props: {}                         # 선택, 위젯 속성
    children:
      - id: HBox
        class: HorizontalBox
        slot:                         # 부모 패널이 정의한 layout
          anchors: "Center"
          alignment: "0.5,0.5"
        children:
          - id: HP_Bar
            class: ProgressBar
            props:
              percent: 1.0
              fill_color: "1,0.1,0.1"
          - id: HP_Text
            class: TextBlock
            props:
              text: "100"
              font_size: 24
            slot:
              padding: "8,0,0,0"

steps:
  - id: s1                            # 단계 ID
    text: "Content Browser 우클릭 > User Interface > Widget Blueprint > 이름: W_HealthHUD"
    highlight: []                     # 강조할 노드 ID 배열 (빈 배열 = 강조 없음)
  - id: s2
    text: "Hierarchy에서 Root를 CanvasPanel로 (기본값 그대로)"
    highlight: [Root]
  - id: s3
    text: "Palette → Horizontal Box를 Hierarchy의 CanvasPanel 위로 드래그"
    highlight: [HBox]
  - id: s4
    text: "HBox 선택 → Details > Anchor: Center, Alignment X=0.5 Y=0.5"
    highlight: [HBox]
  - id: s5
    text: "HBox 자식으로 ProgressBar 추가, 이름 HP_Bar, Fill Color 빨강 (1,0.1,0.1)"
    highlight: [HP_Bar]
  - id: s6
    text: "HBox 자식으로 TextBlock 추가, 이름 HP_Text, 좌측 패딩 8"
    highlight: [HP_Text]
```

### 카테고리 자동 분류 (viewer 색상)

| 클래스 키워드 | 카테고리 | 색 |
|-------------|---------|-----|
| Panel, Box, Canvas, Grid, Overlay, ScrollBox, WrapBox, SizeBox, Border | panel | 파랑 |
| Text, RichText | text | 초록 |
| Button, CheckBox, ToggleButton | button | 노랑 |
| Image, Icon | image | 보라 |
| 기타 | other | 회색 |

---

## 2. BehaviorTree

```yaml
target: BehaviorTree
name: BT_GuardEnemy
goal: "타겟 발견 시 추격, 없으면 패트롤"

blackboard:                            # 선택, 참고용 (HTML에 표시)
  name: BB_GuardEnemy
  keys:
    - { name: HasTarget, type: Bool }
    - { name: TargetActor, type: "Object:Actor" }
    - { name: PatrolPoint, type: Vector }

tree:                                  # 루트 노드부터
  type: Composite                      # Composite | Task | Decorator | Service
  class: BTComposite_Selector          # UE 클래스명 (prefix 포함)
  id: Root
  display_name: "Root Selector"        # 선택, 노드 라벨
  children:                            # Composite만 children
    - type: Composite
      class: BTComposite_Sequence
      id: ChaseSeq
      display_name: "Chase"
      decorators:                      # 진입 조건
        - { class: BTDecorator_Blackboard, id: HasTargetDeco, key: HasTarget, op: IsSet }
      services: []                     # 활성화 중 주기 실행
      children:
        - { type: Task, class: BTTask_MoveTo, id: MoveToTarget, blackboard_key: TargetActor }
        - { type: Task, class: BTTask_BlueprintBase, id: AttackTask, display_name: "Attack" }
    - type: Composite
      class: BTComposite_Sequence
      id: PatrolSeq
      display_name: "Patrol"
      children:
        - { type: Task, class: BTTask_BlueprintBase, id: GetPatrolPoint, display_name: "Get Patrol Point" }
        - { type: Task, class: BTTask_MoveTo, id: MoveToPatrol, blackboard_key: PatrolPoint }

steps:
  - { id: s1, text: "BehaviorTree 신규 BT_GuardEnemy, Blackboard BB_GuardEnemy 생성", highlight: [] }
  - { id: s2, text: "Blackboard에 키 추가: HasTarget(Bool), TargetActor(Object:Actor), PatrolPoint(Vector)", highlight: [] }
  - { id: s3, text: "Root에 Selector 추가 (root에서 와이어 드래그)", highlight: [Root] }
  - { id: s4, text: "Selector 좌측 자식으로 Sequence 추가, 이름 Chase", highlight: [ChaseSeq] }
  - { id: s5, text: "ChaseSeq에 Blackboard Decorator: Key=HasTarget, Operator=IsSet", highlight: [ChaseSeq, HasTargetDeco] }
  - { id: s6, text: "ChaseSeq 자식: MoveTo(BB key=TargetActor), Attack(BTTask_BlueprintBase)", highlight: [MoveToTarget, AttackTask] }
  - { id: s7, text: "Selector 우측 자식으로 Sequence 추가, 이름 Patrol", highlight: [PatrolSeq] }
  - { id: s8, text: "PatrolSeq 자식: GetPatrolPoint(custom), MoveTo(BB key=PatrolPoint)", highlight: [GetPatrolPoint, MoveToPatrol] }
```

### 노드 타입과 viewer 색상/모양

| type | 색 | 모양 |
|------|-----|------|
| Composite | 파랑 | 둥근 사각형 |
| Task | 초록 | 둥근 사각형 |
| Decorator | 노랑 | 다이아몬드 (점선 attach) |
| Service | 보라 | 원형 (점선 attach) |

---

## 3. AnimInstance State Machine

```yaml
target: AnimInstance
name: ABP_Player_Locomotion
graph: StateMachine                    # StateMachine만 지원, AnimGraph 전체는 v2
machine_name: Locomotion_SM
goal: "Idle / Walk / Run 3상태, 속도 기반 전환"

states:
  - id: Idle
    asset: Anim_Idle                   # 재생할 AnimSequence/BlendSpace
    is_entry: true                     # Entry에서 이 상태로 연결됨
    display_name: "Idle"
  - id: Walk
    asset: BS_Walk
  - id: Run
    asset: BS_Run

transitions:
  - { id: t1, from: Idle, to: Walk, condition: "Speed > 10", duration: 0.2 }
  - { id: t2, from: Walk, to: Run, condition: "Speed > 300", duration: 0.2 }
  - { id: t3, from: Walk, to: Idle, condition: "Speed < 10", duration: 0.2 }
  - { id: t4, from: Run, to: Walk, condition: "Speed < 300", duration: 0.2 }

steps:
  - { id: s1, text: "ABP_Player 열기 → AnimGraph 탭", highlight: [] }
  - { id: s2, text: "우클릭 > New State Machine, 이름 Locomotion_SM", highlight: [] }
  - { id: s3, text: "State Machine 더블클릭 진입, Entry 노드 확인", highlight: [] }
  - { id: s4, text: "Entry에서 와이어 드래그 > Add State 'Idle', Anim_Idle 재생", highlight: [Idle] }
  - { id: s5, text: "Walk 상태 추가, BlendSpace BS_Walk 연결", highlight: [Walk] }
  - { id: s6, text: "Run 상태 추가, BlendSpace BS_Run 연결", highlight: [Run] }
  - { id: s7, text: "Idle → Walk 전환 생성, 조건 'Get Speed > 10'", highlight: [Idle, Walk, t1] }
  - { id: s8, text: "Walk → Run 전환 'Speed > 300', Walk → Idle 'Speed < 10'", highlight: [Walk, Run, t2, t3] }
  - { id: s9, text: "Run → Walk 전환 'Speed < 300'", highlight: [Run, Walk, t4] }
```

### State Machine viewer 표현

- 상태: 원형 노드, Entry 상태에 ▶ 표시
- 전환: 화살표 + condition 라벨 (마우스 호버 시 duration도 표시)
- 양방향 전환은 2개의 분리된 화살표

---

## Steps 강조 규칙

- `steps[i].highlight: []` — 강조 없음 (단순 안내)
- `steps[i].highlight: [NodeID]` — 단일 노드 강조
- `steps[i].highlight: [NodeID1, NodeID2, ...]` — 다중 노드 동시 강조
- ID는 `tree`(BT/Widget)의 `id` 또는 `states[].id` / `transitions[].id`(StateMachine) 참조

**검증**: Claude는 DSL 작성 후 모든 `highlight` ID가 실제 노드 ID와 일치하는지 self-check 필수.

---

## DSL → HTML 변환 규약

Claude가 HTML 생성 시:

1. 적절한 viewer 템플릿 (`viewer_widget.html` / `viewer_bt.html` / `viewer_statemachine.html`) Read
2. DSL을 Python dict처럼 변환 (Claude가 직접 JSON 객체 작성)
3. 템플릿 안의 `const ASSET_DATA = /*<<DATA>>*/ { ...demo... };` 정규식 매칭
4. demo 부분을 실제 데이터로 교체
5. `<title>{{ASSET_NAME}} — ...</title>`의 `{{ASSET_NAME}}` 교체
6. `.claude/bp_guides/<name>.html`로 Write

**JSON 안전성**: 자산명·텍스트에 `</script>` 포함 시 HTML 깨짐. 치환 전 `replace("</", "<\\/")` 적용.

---

## 명명 규약

아래는 **일반적인 UE 관례**다. 프로젝트에 자체 규약이 있으면 그쪽을 따르고,
`CLAUDE.md`나 기존 자산 이름에서 먼저 확인한다.

- Widget Blueprint 이름: `W_<Feature>` (예: `W_HealthHUD`, `W_InventorySlot`)
- BehaviorTree: `BT_<Subject>` (예: `BT_Spirit_Base`, `BT_GuardEnemy`)
- AnimBP: `ABP_<Character>` 또는 `<Character>_AnimBP`
- 노드 ID: PascalCase 또는 snake_case, 짧고 의미 있게 (steps에서 자주 참조됨)
