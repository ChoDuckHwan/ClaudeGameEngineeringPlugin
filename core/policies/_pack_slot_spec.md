# Pack Slot Specification

도메인 팩(unreal, web, python, ml 등)을 플러그인 슬롯으로 추가할 때 따르는 표준.
엔지니어링과 독립 — 같은 프로젝트가 multiple 팩을 동시에 활성화 가능.

## 디렉토리 구조

```
packs/<id>/
├── pack.json                 ← 매니페스트 (필수)
├── README.md                 ← 이 팩이 다루는 도메인 (필수)
├── activation_criteria.json  ← 자동 권장 조건 (필수)
├── skills/                   ← 도메인 스킬
├── agents/                   ← 도메인 specialist
├── team-templates/           ← 도메인 팀 README 템플릿 (변수화)
├── post-edit-map.json        ← PostToolUse 알림 매핑 (선택)
└── docs/                     ← 도메인 노하우 (선택)
```

## pack.json 스키마

```json
{
  "id": "<kebab-case>",
  "name": "<Display Name>",
  "version": "<semver>",
  "description": "<one-line>",
  "license": "<SPDX>",

  "domain": "<game|web|ml|cli|library|...>",
  "frameworks": ["<framework-id>"],
  "languages": ["<lang>"],

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
    "copy_team_templates_to": ".claude/team/templates/",
    "messages": []
  }
}
```

## activation_criteria.json 스키마

`pack-matcher` 에이전트가 평가하는 조건. 점수 기반.

```json
{
  "version": "1.0",
  "scoring": {
    "max_score": 100,
    "auto_recommend_threshold": 80,
    "user_query_threshold": 50
  },
  "criteria": [
    {
      "type": "has_file",
      "pattern": "*.uproject",
      "score": 50,
      "required": true
    },
    {
      "type": "has_directory",
      "pattern": "Source/",
      "score": 20
    },
    {
      "type": "has_dependency",
      "manifest": "*.uproject",
      "name": "GameplayAbilities",
      "score": 15
    },
    {
      "type": "language",
      "primary": "cpp",
      "score": 15
    }
  ]
}
```

### `criteria` 타입
- `has_file` — 파일 존재 (glob)
- `has_directory` — 디렉토리 존재
- `has_dependency` — 매니페스트의 의존성에 항목 존재
- `language` — 주 언어 매칭
- `framework` — 프레임워크 시그니처 매칭 (예: React import)
- `document_pattern` — 문서 내용 키워드 (예: "GDD"가 README에)
- `git_activity` — 특정 디렉토리의 활동 빈도

`required: true`인 조건이 미충족이면 점수 0 (자동 비활성).

## 새 팩 추가 절차

1. `packs/<id>/` 디렉토리 생성
2. `pack.json` + `activation_criteria.json` + `README.md` 작성
3. 자산 배치
4. (선택) `post-edit-map.json`로 언어별 알림 매핑 기여
5. `_meta/pack-requests.md`의 사용자 요청 충족 여부 확인
6. PR 또는 정식 등록

## 예시

- [../../packs/unreal/pack.json](../../packs/unreal/pack.json)
- [../../packs/game-dev/pack.json](../../packs/game-dev/pack.json)
