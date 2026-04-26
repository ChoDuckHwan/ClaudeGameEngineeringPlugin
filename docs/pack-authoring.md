# Pack Authoring Guide

도메인 팩(unreal, web, ml, mobile, ...) 작성 법.

> **정식 스펙**: [`core/policies/_pack_slot_spec.md`](../core/policies/_pack_slot_spec.md)

## 팩 vs 엔지니어링

| | 팩 | 엔지니어링 |
|--|----|-----------|
| 범위 | 도메인 (UE5, web, ML) | 협업 방식 |
| 의존 | 엔지니어링 위에 | core 위에 |
| 다중 활성 | 가능 (unreal+game-dev 동시) | 보통 단일 (exclusive_with) |
| 예 | `unreal`, `web`, `python-ml` | `harness`, `ecc`, `archon` |

## 단계별 작성

### Step 1: 디렉토리

```
packs/<id>/
├── pack.json                 ← 매니페스트
├── activation_criteria.json  ← 점수 기반 활성 조건
├── README.md
├── skills/                   ← 도메인 helper
├── agents/                   ← specialist
├── team-templates/           ← 변수화 README
├── post-edit-map.json        ← (선택) PostToolUse 매핑
└── docs/                     ← (선택)
```

### Step 2: pack.json

```json
{
  "id": "<id>",
  "name": "<Display>",
  "version": "1.0.0",
  "description": "<one-line>",
  "license": "MIT",

  "domain": "<game|web|ml|cli|library|mobile>",
  "subdomain": "<more-specific>",
  "frameworks": [],
  "languages": [],

  "depends_on_engineering": ["harness"],
  "depends_on_pack": [],
  "exclusive_with": [],

  "provides": {
    "skills": [],
    "agents": [],
    "team_templates": [],
    "post_edit_mapping": "post-edit-map.json"
  },

  "post_install": {
    "merge_post_edit_map": true,
    "messages": []
  }
}
```

### Step 3: activation_criteria.json (점수 기반)

```json
{
  "scoring": {
    "max_score": 100,
    "auto_recommend_threshold": 80,
    "user_query_threshold": 50
  },
  "criteria": [
    {"type": "has_file", "pattern": "package.json", "score": 40, "required": true},
    {"type": "has_dependency", "manifest_glob": "package.json", "name": "react", "score": 30},
    {"type": "language", "primary": "typescript", "score": 20},
    {"type": "has_directory", "pattern": "src/components", "score": 10}
  ]
}
```

### Criteria 타입

| 타입 | 의미 |
|------|------|
| `has_file` | 파일 존재 (glob) |
| `has_directory` | 디렉토리 존재 |
| `has_dependency` | 매니페스트의 의존성에 항목 |
| `language` | 주 언어 매칭 |
| `framework` | 프레임워크 시그너처 |
| `document_pattern` | 문서 키워드 |
| `git_activity` | 디렉토리 활동 빈도 |

`required: true`인 조건 미충족 시 점수 0 (자동 비활성).

### Step 4: 자산 작성

#### Skills
`skills/<id>/SKILL.md` — `_template.md` 따름. ≤500줄, references 분리.

#### Agents
`agents/<id>.md` — frontmatter (name, description, tools, model).

#### Team Templates (변수화)
`team-templates/<domain>-README.md`:
```markdown
# ${PROJECT_NAME} ${DOMAIN_NAME} Team

## Pattern
- Primary: Pipeline
- Mode: Hybrid
- max_retry: ${MAX_RETRY}

## 팀 구성
| 단계 | 역할 |
|------|------|
| 01 | ${DOMAIN_NAME}-design-concretizer |
| ... |

## 관련 문서
- ${GDD_PATH}/<domain>.md
```

부착 시 `installer`가 변수 치환 후 `.claude/team/<domain>/README.md`로 복사.

### Step 5: post-edit-map.json (선택)

언어·파일 패턴별 PostToolUse 알림:
```json
{
  "merge_strategy": "append",
  "watch_paths": ["${PROJECT_ROOT}/src"],
  "mappings": [
    {"id": "ts-file", "patterns": ["*.ts", "*.tsx"], "message": "TS 변경 — tsc/eslint 권장"}
  ]
}
```

부착 시 core의 `post-edit-map.default.json`과 병합.

### Step 6: README.md 작성

What / Why / When / How + 활성 시그널 표 + 사용 예시.

### Step 7: 등록

- 정식 PR → `packs/<id>/`
- 또는 로컬: `packs/_user/<id>/`

## 예시: web 팩 (미래)

```
packs/web/
├── pack.json
├── activation_criteria.json    # package.json + framework 점수
├── README.md
├── skills/
│   ├── react-helper/
│   ├── nextjs-helper/
│   ├── api-route-helper/
│   └── tailwind-helper/
├── agents/
│   ├── frontend-architect.md
│   ├── ssr-optimizer.md
│   ├── api-security-analyzer.md
│   └── lighthouse-perf-analyzer.md
├── team-templates/
│   ├── auth-team-README.md
│   ├── payment-team-README.md
│   └── frontend-team-README.md
└── post-edit-map.json          # *.ts/*.tsx → tsc, *.css → none
```

## 흔한 실수

| 안티패턴 | 올바른 방법 |
|----------|-------------|
| 한 팩에 모든 도메인 욱여넣기 | 팩 분리 (`web-frontend` + `web-backend`) |
| 엔지니어링 의존성 누락 | `depends_on_engineering` 명시 |
| 활성 조건이 너무 느슨 | `required: true`로 핵심 조건 강제 |
| 변수 치환 안 한 본문 | 모든 ProjectFIB-specific → `${VAR}` |
| Team template 없이 신규 도메인만 | teammaker 활용 또는 템플릿 함께 제공 |

## 메타-메타 진화

`_meta/pack-requests.md`에 동일 도메인 후보 3+ 등록 시 정식 packs/ 승격 후보.

## 다음

- [`engineering-slot-guide.md`](engineering-slot-guide.md)
- [`lifecycle.md`](lifecycle.md)
