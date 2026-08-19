# bp-visualize 예시 모음

실제로 Claude가 작성할 DSL 예시 3종. 그대로 viewer 템플릿에 주입 가능.

---

## 예시 1: W_HealthHUD (Widget Blueprint)

### 사용자 요청
"체력바와 수치를 함께 표시하는 미니멀 HUD 위젯 만들어줘"

### Claude 응답 (DSL 부분만)

```yaml
target: WidgetBlueprint
name: W_HealthHUD
goal: "체력 바 + 수치 미니멀 HUD (좌하단 고정)"

tree:
  - id: Root
    class: CanvasPanel
    note: "Designer 루트"
    children:
      - id: HBox
        class: HorizontalBox
        slot:
          anchors: "BottomLeft"
          alignment: "0,1"
          offsets: "20,-20,0,0"
          size_to_content: true
        children:
          - id: HP_Bar
            class: ProgressBar
            props:
              percent: 1.0
              fill_color: "1,0.1,0.1,1"
              bar_fill_type: "LeftToRight"
            slot:
              size_x: 200
              size_y: 18
          - id: HP_Text
            class: TextBlock
            props:
              text: "100 / 100"
              font_size: 16
              color_and_opacity: "1,1,1,1"
            slot:
              padding: "8,0,0,0"
              vertical_alignment: "Center"

steps:
  - id: s1
    text: "Content Browser 우클릭 > User Interface > Widget Blueprint > 부모 클래스 <프로젝트의 위젯 베이스 클래스>, 이름 W_HealthHUD"
    highlight: []
  - id: s2
    text: "Hierarchy의 기본 Root는 CanvasPanel로 (기본값 그대로)"
    highlight: [Root]
  - id: s3
    text: "Palette에서 Horizontal Box 검색 → Hierarchy의 CanvasPanel 위로 드래그, 이름 HBox"
    highlight: [HBox]
  - id: s4
    text: "HBox 선택 → Details > Slot(Canvas Panel Slot): Anchor 좌하단, Alignment X=0 Y=1, Position X=20 Y=-20, Size To Content 체크"
    highlight: [HBox]
  - id: s5
    text: "HBox 자식으로 ProgressBar 추가, 이름 HP_Bar. Details > Percent=1.0, Fill Color/Opacity 빨강 (1,0.1,0.1), Bar Fill Type LeftToRight"
    highlight: [HP_Bar]
  - id: s6
    text: "HP_Bar의 Slot(Horizontal Box Slot): Size X=200, Y=18"
    highlight: [HP_Bar]
  - id: s7
    text: "HBox 자식으로 TextBlock 추가, 이름 HP_Text. Details > Text=\"100 / 100\", Font Size=16"
    highlight: [HP_Text]
  - id: s8
    text: "HP_Text의 Slot: 좌측 패딩=8, Vertical Alignment=Center"
    highlight: [HP_Text]
  - id: s9
    text: "Compile + Save. 이후 ViewModel(예: 체력 컴포넌트) 바인딩은 ui-helper 스킬 참조"
    highlight: []

notes:
  - "이 위젯은 정적 표시용. 실시간 HP 갱신은 별도 ViewModel 바인딩 필요."
  - "프로젝트 컨벤션: HUD는 좌하단 (vertical_slice 정책)."
```

### 변환 후 HTML
→ `.claude/bp_guides/W_HealthHUD.html`

---

## 예시 2: BT_GuardEnemy (BehaviorTree)

### 사용자 요청
"적 NPC에 추격/패트롤 BT 짜줘. HasTarget이 true면 추격, 아니면 패트롤"

### Claude 응답 (DSL)

```yaml
target: BehaviorTree
name: BT_GuardEnemy
goal: "타겟 발견 시 추격(Chase), 없으면 순찰(Patrol)"

blackboard:
  name: BB_GuardEnemy
  keys:
    - { name: HasTarget, type: Bool }
    - { name: TargetActor, type: "Object:Actor" }
    - { name: PatrolPoint, type: Vector }
    - { name: HomeLocation, type: Vector }

tree:
  type: Composite
  class: BTComposite_Selector
  id: Root
  display_name: "Root"
  decorators: []
  services: []
  children:
    - type: Composite
      class: BTComposite_Sequence
      id: ChaseSeq
      display_name: "Chase"
      decorators:
        - { class: BTDecorator_Blackboard, id: HasTargetDeco, key: HasTarget, op: IsSet }
      services: []
      children:
        - { type: Task, class: BTTask_MoveTo, id: MoveToTarget, blackboard_key: TargetActor, display_name: "MoveTo Target" }
        - { type: Task, class: BTTask_BlueprintBase, id: AttackTask, display_name: "Attack" }
    - type: Composite
      class: BTComposite_Sequence
      id: PatrolSeq
      display_name: "Patrol"
      decorators: []
      services: []
      children:
        - { type: Task, class: BTTask_BlueprintBase, id: GetPatrolPoint, display_name: "Get Random Patrol Point" }
        - { type: Task, class: BTTask_MoveTo, id: MoveToPatrol, blackboard_key: PatrolPoint, display_name: "MoveTo Patrol" }
        - { type: Task, class: BTTask_Wait, id: WaitAtPatrol, display_name: "Wait 2s" }

steps:
  - id: s1
    text: "Content Browser > Artificial Intelligence > Behavior Tree, 이름 BT_GuardEnemy. 같이 Blackboard도 생성, 이름 BB_GuardEnemy"
    highlight: []
  - id: s2
    text: "BB_GuardEnemy 열고 키 추가: HasTarget(Bool), TargetActor(Object:Actor), PatrolPoint(Vector), HomeLocation(Vector)"
    highlight: []
  - id: s3
    text: "BT_GuardEnemy 열고 Details에서 Blackboard Asset = BB_GuardEnemy 설정"
    highlight: []
  - id: s4
    text: "Root에서 와이어 드래그 > Selector 추가. 이름 Root Selector"
    highlight: [Root]
  - id: s5
    text: "Selector 좌측 자식으로 Sequence 추가, 이름 Chase (UE는 좌→우 우선순위)"
    highlight: [ChaseSeq]
  - id: s6
    text: "Chase Sequence 우클릭 > Add Decorator > Blackboard. Details에서 Key=HasTarget, Key Query=Is Set"
    highlight: [ChaseSeq, HasTargetDeco]
  - id: s7
    text: "Chase 자식: MoveTo 추가 (Details > Blackboard Key=TargetActor), 이름 MoveTo Target"
    highlight: [MoveToTarget]
  - id: s8
    text: "Chase 자식: BTTask_BlueprintBase 상속한 BT_Attack 태스크 추가 (별도 BP 클래스 생성 필요), 이름 Attack"
    highlight: [AttackTask]
  - id: s9
    text: "Selector 우측 자식으로 Sequence 추가, 이름 Patrol"
    highlight: [PatrolSeq]
  - id: s10
    text: "Patrol 자식 3개: GetRandomPatrolPoint(custom BP Task), MoveTo(BB Key=PatrolPoint), Wait(Duration=2.0)"
    highlight: [GetPatrolPoint, MoveToPatrol, WaitAtPatrol]
  - id: s11
    text: "Save. 해당 AIController(프로젝트의 AI 컨트롤러 베이스)에서 RunBehaviorTree(BT_GuardEnemy) 호출하여 적용"
    highlight: []

notes:
  - "HasTarget의 set/clear는 별도 Perception(Sight/Hearing) AIPerceptionComponent에서 처리"
  - "AttackTask는 BTTask_BlueprintBase 상속 + Event Receive Execute AI로 구현"
```

→ `.claude/bp_guides/BT_GuardEnemy.html`

---

## 예시 3: ABP_PlayerLocomotion (AnimInstance State Machine)

### 사용자 요청
"플레이어 AnimBP에 Idle/Walk/Run 상태머신 만들고 싶어. 속도 기반 전환"

### Claude 응답 (DSL)

```yaml
target: AnimInstance
name: ABP_PlayerLocomotion
graph: StateMachine
machine_name: Locomotion_SM
goal: "속도 기반 Idle / Walk / Run 3상태 전환"

states:
  - id: Idle
    asset: Anim_Idle_Loop
    is_entry: true
    display_name: "Idle"
  - id: Walk
    asset: BS_Walk_Directional
    display_name: "Walk"
  - id: Run
    asset: BS_Run_Directional
    display_name: "Run"

transitions:
  - { id: t_idle_walk, from: Idle, to: Walk, condition: "Speed > 10",  duration: 0.15 }
  - { id: t_walk_run,  from: Walk, to: Run,  condition: "Speed > 300", duration: 0.20 }
  - { id: t_walk_idle, from: Walk, to: Idle, condition: "Speed < 10",  duration: 0.20 }
  - { id: t_run_walk,  from: Run,  to: Walk, condition: "Speed < 300", duration: 0.15 }

steps:
  - id: s1
    text: "ABP_PlayerLocomotion 열기 → 좌측 My Blueprint 패널에서 AnimGraph 더블클릭"
    highlight: []
  - id: s2
    text: "AnimGraph 빈 영역 우클릭 > Add New State Machine, 이름 Locomotion_SM. Final Animation Pose 노드에 연결"
    highlight: []
  - id: s3
    text: "Locomotion_SM 더블클릭하여 진입 (내부 그래프). Entry 노드 보임"
    highlight: []
  - id: s4
    text: "Entry에서 와이어 드래그 > Add State 'Idle'. 더블클릭 진입 > Anim_Idle_Loop 재생 노드 연결"
    highlight: [Idle]
  - id: s5
    text: "메인 SM으로 돌아와서 Walk 상태 추가 (빈 영역 우클릭 > Add State). 진입하여 BS_Walk_Directional BlendSpace 연결 (Speed 핀 외부 노출)"
    highlight: [Walk]
  - id: s6
    text: "Run 상태 추가. BS_Run_Directional BlendSpace 연결 (Speed 핀 외부 노출)"
    highlight: [Run]
  - id: s7
    text: "Idle 노드 우측 가장자리 → Walk로 와이어 드래그 (자동 Transition 생성). 더블클릭하여 조건 'Get Speed > 10', Blend Time 0.15"
    highlight: [Idle, Walk, t_idle_walk]
  - id: s8
    text: "Walk → Run 전환 생성, 조건 'Speed > 300', 0.20. 동시에 Walk → Idle 전환 (반대 방향 와이어), 'Speed < 10', 0.20"
    highlight: [Walk, Run, t_walk_run, t_walk_idle]
  - id: s9
    text: "Run → Walk 전환, 'Speed < 300', 0.15"
    highlight: [Run, Walk, t_run_walk]
  - id: s10
    text: "EventGraph에서 EventBlueprintUpdateAnimation > Get Owning Pawn > Get Velocity > VectorLength → Speed 변수 갱신"
    highlight: []
  - id: s11
    text: "Compile + Save. ABP를 캐릭터의 SkeletalMesh > Anim Class에 할당"
    highlight: []

notes:
  - "BlendSpace는 별도 자산. Walk/Run 미보유 시 단순 AnimSequence로 시작 OK"
  - "Speed는 Float 변수로 ABP에 추가 필요"
  - "이후 Jump/Crouch는 별도 State 또는 Layer로 확장"
```

→ `.claude/bp_guides/ABP_PlayerLocomotion.html`

---

## 응답 본문 구조 (Claude 표준)

위 DSL을 사용자에게 보여줄 때 권장 마크다운 형식:

```markdown
## <자산명> — <한 줄 목적>

[자연어 설명: 왜 이렇게 만드는지, 핵심 결정 1-2개]

### 핵심 결정
- [결정 1]
- [결정 2]

### 작업 가이드 (DSL)
```yaml
[DSL 내용]
```

### ✅ 시각자료 생성 완료
[bp_guides/<name>.html](.claude/bp_guides/<name>.html) ← **브라우저로 열기**

- 좌측: 노드 그래프 (pan/zoom)
- 우측 상단: 단계 N개 (체크박스 진행도)
- 단계 클릭 → 해당 노드 강조 + 자동 줌
- 우측 하단: 선택 노드 상세

### 다음 단계 (선택)
- ViewModel 바인딩이 필요하면 [ui-helper](../ui-helper/SKILL.md) 호출
- 컴파일 후 테스트는 [unreal-build-helper](../unreal-build-helper/SKILL.md)
```

---

## DSL 분량 가이드

| 자산 복잡도 | 노드 수 | 단계 수 | DSL 크기 |
|-----------|--------|--------|----------|
| 단순 (HP 바 1개) | ≤5 | 3~5 | <2KB |
| 보통 (HUD 전체) | 5~15 | 6~12 | 2~5KB |
| 복잡 (게임 메뉴 + 서브패널) | 15~40 | 10~20 | 5~12KB |
| 매우 복잡 (전체 화면 UI) | 40+ | 20+ | 12KB+ → 분할 권장 |

**40+ 노드는 분할**: 메인 위젯 + 서브위젯들로 나눠 각각 별도 HTML 생성.
