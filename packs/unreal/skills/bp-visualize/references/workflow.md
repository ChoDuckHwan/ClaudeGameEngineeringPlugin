# bp-visualize 워크플로우 (Claude 행동 절차)

본 문서는 **Claude가 본 스킬을 호출했을 때 정확히 무엇을 하는지** 단계별 명세.
사용자 가이드는 SKILL.md examples 섹션과 [examples.md](examples.md) 참조.

---

## Phase 1: 자산 타입 판별

사용자 요청에서 키워드와 컨텍스트로 자산 타입을 결정.

| 사용자 키워드 | target | viewer |
|-------------|--------|--------|
| 위젯, WBP, HUD, UI, Widget, Designer | WidgetBlueprint | viewer_widget.html |
| BT, BehaviorTree, AI 트리, behavior tree | BehaviorTree | viewer_bt.html |
| AnimBP, 상태머신, StateMachine, Anim Graph | AnimInstance | viewer_statemachine.html |

판별 불가 또는 모호하면 **1번만** 확인.

---

## Phase 2: DSL 작성

스키마는 [dsl_schema.md](dsl_schema.md). 필수 필드:

- `target`, `name`, `goal`
- `tree` (Widget/BT) 또는 `states` + `transitions` (StateMachine)
- `steps` (최소 3개, 권장 5~10개)

### 작성 원칙

1. **ID는 단순·고유하게** — `Root`, `HBox`, `HP_Bar` 같이 짧게. `steps[].highlight`에서 자주 참조됨.
2. **단계 텍스트는 한 줄 ≤80자** — UE 에디터에서 한눈에 읽을 수 있게.
3. **단계 순서 = 사용자가 실제로 작업하는 순서** — 의존성 있는 작업은 뒤로.
4. **단계당 highlight 노드 ≤3개** — 너무 많으면 강조 의미 희석.
5. **첫 단계는 보통 "자산 생성"** (highlight 비움), 마지막은 "저장/컴파일/테스트".

### Self-check (DSL 작성 후 필수)

- [ ] 모든 `steps[].highlight` ID가 `tree`/`states`/`transitions`의 실제 ID에 존재?
- [ ] `tree` 노드 ID 중복 없음?
- [ ] `name` 필드가 프로젝트 명명 규약을 따르나 (관례: `W_*` / `BT_*` / `ABP_*`)?
- [ ] AnimBP의 경우 `is_entry: true`인 상태가 정확히 1개?

---

## Phase 3: HTML 생성

### 단계

1. **출력 디렉토리 확인**
   ```
   .claude/bp_guides/ 존재 확인. 없으면 mkdir
   ```

2. **viewer 템플릿 Read**
   - WidgetBlueprint → `references/viewer_widget.html`
   - BehaviorTree → `references/viewer_bt.html`
   - AnimInstance → `references/viewer_statemachine.html`

3. **DSL을 JSON 문자열로 변환**
   - Claude가 JSON 객체로 직접 작성 (yaml.dump 같은 변환기 없음)
   - 들여쓰기 2-space, ensure_ascii=False

4. **JSON 안전 escape**
   ```
   json_str = json_str.replace("</", "<\\/")
   ```
   자산명/텍스트에 `</script>` 등이 있으면 HTML 깨짐.

5. **템플릿 치환** (2곳)
   - `/*<<DATA>>*/ { ...demo... };` → `/*<<DATA>>*/ <실제 JSON>;`
     - 정규식: `/\*<<DATA>>\*/\s*\{[\s\S]*?\};` (non-greedy)
   - `<title>{{ASSET_NAME}} — ...</title>` → `<title>{name} — ...</title>`
     - 단순 문자열 치환: `{{ASSET_NAME}}` → `name`

6. **Write**
   ```
   .claude/bp_guides/<name>.html
   ```

### 예시 (Pseudo-code)

```python
import json, re

template = Read("references/viewer_widget.html")
dsl = { ... DSL dict ... }
json_str = json.dumps(dsl, ensure_ascii=False, indent=2).replace("</", "<\\/")

# 데모 데이터 치환 (non-greedy으로 첫 매칭만)
html = re.sub(
    r'/\*<<DATA>>\*/\s*\{[\s\S]*?\};',
    f'/*<<DATA>>*/ {json_str};',
    template,
    count=1
)
# 제목 치환
html = html.replace('{{ASSET_NAME}}', dsl['name'])

Write(f".claude/bp_guides/{dsl['name']}.html", html)
```

> **실제 호출 시**: Claude는 Read/Write 도구로 위 흐름을 수행. Python 인터프리터는 없음. 직접 문자열 조작.

---

## Phase 4: 사용자 안내

응답 본문 마지막에:

```markdown
### ✅ 시각자료 생성 완료
[bp_guides/<name>.html](.claude/bp_guides/<name>.html) ← **더블클릭하여 브라우저로 열기**

- 좌측: 노드 그래프 (pan/zoom, 검색)
- 우측 상단: 단계 리스트 (체크박스로 진행도 추적)
- 단계 클릭 → 해당 노드 강조 + 자동 줌
- 우측 하단: 선택된 노드/단계 상세

UE 에디터를 옆에 띄워놓고 단계를 하나씩 따라하세요.
```

---

## 트러블슈팅 (Claude 자체 점검)

| 증상 | 원인 | 대처 |
|------|------|------|
| HTML 열어도 빈 화면 | JSON 안에 `</script>` | escape 누락 — `.replace("</","<\\/")` 적용 후 재생성 |
| 단계 클릭해도 강조 안 됨 | `highlight` ID 오타 | self-check에서 ID 매칭 검증 |
| 노드가 한 줄로 나옴 | 자식 없는 트리 | DSL 자체가 단순해서 정상. 노드 1~2개는 텍스트로 충분 |
| HTML 너무 큼 (10MB+) | DSL에 거대 텍스트 inline | steps 텍스트는 ≤200자, 긴 설명은 별도 마크다운 |

---

## 오프라인 환경

기본 viewer는 unpkg.com CDN에서 cytoscape.js / dagre를 로드한다. **오프라인이거나 CDN이 막힌
사내망이면 뷰어가 빈 화면으로 뜬다.** 콘솔에 `cytoscape is not defined`가 보이면 이 경우다.

라이브러리는 이 플러그인에 동봉하지 않는다 — 400KB의 서드파티 JS를 스킬 저장소에 넣는 대신,
필요한 사람이 자기 출력 디렉토리에 한 번 받는 쪽이 낫다고 판단했다.

### 옵션 A: 라이브러리 로컬 다운로드 (한 번만)

`<출력경로>`는 HTML을 쓰는 디렉토리다 (기본 `.claude/bp_guides/`). 그 아래 `vendor/`에 받는다.

**PowerShell**
```powershell
$out = ".claude/bp_guides/vendor"      # ← 프로젝트 루트에서 실행
New-Item -ItemType Directory -Force $out | Out-Null
iwr https://unpkg.com/cytoscape@3.28.1/dist/cytoscape.min.js -OutFile "$out/cytoscape.min.js"
iwr https://unpkg.com/dagre@0.8.5/dist/dagre.min.js          -OutFile "$out/dagre.min.js"
iwr https://unpkg.com/cytoscape-dagre@2.5.0/cytoscape-dagre.js -OutFile "$out/cytoscape-dagre.js"
```

**bash**
```bash
out=".claude/bp_guides/vendor"
mkdir -p "$out"
curl -sL https://unpkg.com/cytoscape@3.28.1/dist/cytoscape.min.js   -o "$out/cytoscape.min.js"
curl -sL https://unpkg.com/dagre@0.8.5/dist/dagre.min.js            -o "$out/dagre.min.js"
curl -sL https://unpkg.com/cytoscape-dagre@2.5.0/cytoscape-dagre.js -o "$out/cytoscape-dagre.js"
```

그 후 viewer 템플릿 3개의 `<script src="https://unpkg.com/...">`를 `<script src="vendor/...">`로
일괄 치환한다 (한 번만). 생성되는 HTML이 `bp_guides/` 바로 아래이므로 `vendor/`는 상대경로로 맞는다.

> 템플릿을 고치면 이 플러그인을 업데이트할 때 덮어써진다. 유지하려면 치환한 사본을
> `packs/_user/` 아래에 두고 그쪽을 쓴다.

### 옵션 B: 인라인 임베드 (완전 자기완결)

viewer 템플릿의 `<script src="...">`를 `<script>...라이브러리 코드 전체...</script>`로 교체.
HTML 하나당 +~400KB지만 파일 하나만 주고받으면 되므로, **가이드를 남에게 전달할 때**는 이쪽이 낫다.

---

## v2 후보 (구현 보류)

- [ ] EventGraph (BP 이벤트그래프) viewer — 노드 + 핀 + 와이어
- [ ] AnimGraph 전체 (StateMachine 외 BlendSpace/IK 등)
- [ ] DataTable / Curve 데이터 시각화
- [ ] 가이드 → UE 자동 생성 (T3D paste 역방향)
- [ ] 노드 클릭 시 UE Editor jump (커스텀 URL handler)
- [ ] 다국어 단계 텍스트 (en/ko 토글)
