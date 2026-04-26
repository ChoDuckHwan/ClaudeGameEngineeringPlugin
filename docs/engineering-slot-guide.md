# Engineering Slot Guide — 새 엔지니어링 추가하기

CGE에 새 엔지니어링 방식(예: ECC, Archon, 또는 사용자 자작)을 슬롯으로 추가하는 법.

> **정식 스펙**: [`core/policies/_engineering_slot_spec.md`](../core/policies/_engineering_slot_spec.md)

## 언제 새 엔지니어링을 추가하나

다음 중 하나에 해당:
- 기존 엔지니어링과 **결정적으로 다른 협업 방식** (예: 결정론적 런타임 vs 메타팀)
- 기존 패턴으로 표현 불가능한 새 협업 패턴
- 산업 표준이 부상했을 때 (예: 새 마켓플레이스 표준)
- 사용자가 자기 노하우를 격리하고 싶을 때 → `_user/`

## 단계별 추가 절차

### Step 1: 디렉토리 생성

```
engineerings/<id>/
├── engineering.json          ← 매니페스트 (필수)
├── README.md                 ← What/Why/When/How (필수)
├── skills/                   ← (선택)
├── agents/                   ← (선택)
├── policies/                 ← (선택)
├── teams/                    ← (선택)
└── docs/                     ← (선택)
```

`<id>`는 kebab-case 고유 ID. 예: `harness`, `ecc`, `tdd-strict`, `my-flow`.

### Step 2: engineering.json 작성

```json
{
  "id": "<id>",
  "name": "<Display Name>",
  "version": "1.0.0",
  "description": "<one-line>",
  "license": "MIT",
  "author": "<your-name>",

  "compatible_project_types": ["*"],
  "exclusive_with": [],
  "depends_on": ["core"],

  "activation_signals": ["always"],

  "provides": {
    "skills": [],
    "agents": [],
    "policies": [],
    "team_templates": [],
    "hooks": []
  },

  "post_install": {
    "messages": [
      "<엔지니어링 활성화 후 사용자에게 보여줄 안내>"
    ]
  },

  "tags": []
}
```

### Step 3: 자산 작성

각 자산은 같은 카테고리의 표준 형식:
- skills: `skills/<id>/SKILL.md` (frontmatter + 본문 ≤500줄)
- agents: `agents/<id>.md` (frontmatter)
- policies: `policies/_<name>.md` (정책 마크다운)
- team_templates: `teams/<team-id>/` (변수화된 README + 단계 에이전트)
- hooks: `hooks/<name>.{ps1,sh}` + 매핑 JSON

### Step 4: README.md 작성

다음 4섹션 필수:
- **What**: 이 엔지니어링이 무엇인지
- **Why**: 왜 필요한지
- **When**: 언제 활성화해야 하는지
- **How**: 어떻게 사용하는지

### Step 5: 검증

`cge-install` 또는 직접 검증:
- engineering.json 스키마 일치
- `provides`의 모든 자산 실제 존재
- `depends_on` 가용성
- 트리거 키워드 충돌 없음 (`skill-validate` V7)

### Step 6: 등록

#### 옵션 A: 정식 PR
- `engineerings/<id>/` 작성 후 PR
- `_meta/promotions.md`에 후보 등록
- 메인테이너 검토

#### 옵션 B: 사용자 로컬
- `engineerings/_user/<id>/` 위치
- 자기 프로젝트에서 즉시 사용
- 3+ 프로젝트에서 사용 시 정식 승격 후보

## 활성 시그널 종류

| 시그널 | 의미 | 예 |
|--------|------|-----|
| `"always"` | 항상 권장 | harness 같은 범용 |
| `"has_file:<glob>"` | 파일 존재 | `has_file:*.uproject` |
| `"has_directory:<glob>"` | 디렉토리 존재 | `has_directory:src/auth` |
| `"language:<lang>"` | 주 언어 | `language:typescript` |
| `"framework:<id>"` | 프레임워크 | `framework:react` |
| `"document_pattern:<keyword>"` | 문서 키워드 | `document_pattern:agile` |
| `"user_choice"` | 사용자 명시 필요 | 보수적 엔지니어링 |

다중 시그널은 OR 조건 (`activation_signals` 배열).

## 의존성·충돌 표현

### depends_on
```json
"depends_on": ["core", "harness"]
```
이 엔지니어링은 core + harness가 활성일 때만 활성 가능.

### exclusive_with
```json
"exclusive_with": ["archon"]
```
archon과 동시 활성 불가. `conflict-resolver`가 사용자에게 결정 요청.

## 예시: tdd-strict 엔지니어링

```json
{
  "id": "tdd-strict",
  "name": "Strict TDD",
  "version": "1.0.0",
  "description": "테스트 우선 개발 + Red→Green→Refactor 강제 + 커밋 게이트.",
  "compatible_project_types": ["*"],
  "exclusive_with": [],
  "depends_on": ["core"],
  "activation_signals": ["user_choice"],
  "provides": {
    "skills": ["tdd-red", "tdd-green", "tdd-refactor", "tdd-gate"],
    "agents": ["test-first-architect"],
    "policies": ["_tdd_policy"],
    "hooks": ["tdd_pre_commit.ps1"]
  },
  "post_install": {
    "messages": [
      "TDD-Strict 활성화 — pre-commit 훅이 실패 시 커밋 차단",
      "/tdd-red 부터 시작"
    ]
  }
}
```

## 흔한 실수

| 안티패턴 | 올바른 방법 |
|----------|-------------|
| 기존 엔지니어링 fork → 수정 | 수정은 `_user/<my-fork>/`로 격리, 정식 승격 후 통합 |
| 너무 광범위 (game/web/all 모두) | 도메인 명확히 분리 |
| 의존성 없이 다른 엔지니어링 자산 사용 | `depends_on`에 명시 |
| `exclusive_with` 누락 | 충돌 가능 엔지니어링 명시 |
| README 없이 등록 | What/Why/When/How 필수 |

## 다음

- [`pack-authoring.md`](pack-authoring.md) — 새 팩 만드는 법
- [`lifecycle.md`](lifecycle.md) — install/uninstall/replace
- 정식 스펙: [`core/policies/_engineering_slot_spec.md`](../core/policies/_engineering_slot_spec.md)
