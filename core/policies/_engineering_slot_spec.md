# Engineering Slot Specification

엔지니어링 방식(harness, ECC, archon, custom)을 플러그인 슬롯으로 추가할 때 따르는 표준.

## 디렉토리 구조

```
engineerings/<id>/
├── engineering.json          ← 매니페스트 (필수)
├── README.md                 ← 이 엔지니어링이 무엇인지 (필수)
├── skills/                   ← 고유 스킬 (선택)
├── agents/                   ← 고유 에이전트 (선택)
├── policies/                 ← 정책 문서 (선택)
├── teams/                    ← 권장 팀 템플릿 (선택)
└── docs/                     ← 설명·노하우 (선택)
```

## engineering.json 스키마

```json
{
  "id": "<kebab-case-unique-id>",
  "name": "<Display Name>",
  "version": "<semver>",
  "description": "<one-line>",
  "license": "<SPDX or text>",
  "author": "<name or org>",
  "homepage": "<url>",

  "compatible_project_types": ["*", "game", "web", "ml", "..."],
  "exclusive_with": ["<other-engineering-id>"],
  "depends_on": ["core", "<other-engineering>"],

  "activation_signals": [
    "always",
    "has_file:<glob>",
    "has_directory:<glob>",
    "user_choice"
  ],
  "deactivation_signals": [],

  "provides": {
    "skills": ["<skill-id>", "..."],
    "agents": ["<agent-id>", "..."],
    "policies": ["_patterns", "..."],
    "team_templates": ["<team-id>", "..."],
    "hooks": []
  },

  "post_install": {
    "copy_policies_to": ".claude/team/",
    "copy_team_templates_to": ".claude/team/",
    "messages": [
      "<message-shown-to-user-after-install>"
    ]
  },

  "tags": ["meta", "self-improvement", "..."]
}
```

## 필드 설명

### `compatible_project_types`
- `["*"]` — 어떤 프로젝트든
- `["game"]` — 게임 개발만
- `["web", "mobile"]` — 다중 가능

### `exclusive_with`
같은 시점에 활성화될 수 없는 엔지니어링. 예: `archon`이 결정론적 런타임이라 `harness`(팀 아키텍처)와 공존 가능하면 비워둠.

### `activation_signals`
플러그인이 자동 권장할 조건. 예시:
- `"always"` — 항상 권장
- `"has_file:*.uproject"` — 특정 파일 존재 시
- `"has_directory:src/auth"` — 특정 디렉토리
- `"language:typescript"` — 언어 시그널 매칭
- `"user_choice"` — 사용자가 명시 선택해야 활성

다중 시그널은 OR 조건. AND가 필요하면 별도 매니페스트 필요.

### `provides`
이 엔지니어링이 활성화 시 사용 가능해지는 자산 목록. 부착 시 `installer` 에이전트가 이 목록을 참조.

### `post_install`
부착 직후 자동 실행할 명령 또는 사용자 안내 메시지.

## 검증

새 엔지니어링 추가 시 다음을 통과해야:

1. `engineering.json` 스키마 일치
2. `provides`에 나열된 모든 자산 파일 실제 존재
3. `depends_on`이 가리키는 엔지니어링이 plugin에 존재
4. `exclusive_with`이 가리키는 엔지니어링도 존재
5. 자산의 trigger 키워드가 다른 엔지니어링과 충돌 없음 (skill-validate V7 위임)
6. `README.md`에 "WHAT / WHY / WHEN / HOW" 4섹션 존재

## 예시: harness 엔지니어링

[../../engineerings/harness/engineering.json](../../engineerings/harness/engineering.json) 참조.

## 새 엔지니어링 추가 절차

1. `engineerings/<id>/` 디렉토리 생성
2. 본 스펙에 따라 `engineering.json` 작성
3. 자산(skills/agents/policies/teams) 작성
4. `README.md` 작성
5. PR 또는 `_meta/promotions.md`에 후보 등록
6. `installer` 에이전트가 검증 → 통과 시 정식 슬롯
