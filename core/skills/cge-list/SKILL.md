---
name: cge-list
description: "현재 프로젝트에 활성/비활성된 CGE 자산(엔지니어링·팩·스킬·에이전트)을 조회한다. 활성 자산만 / 부착 가능 / 전체 등 필터 옵션 지원. 사용자가 '/cge list', '활성 자산 확인', '부착된 거 뭐있어', '플러그인 상태', 'list engineerings', 'list packs'를 언급할 때 활성화."
---

# CGE List — 자산 조회

활성/비활성 자산을 조회. 부착 후 현황 확인용.

## 트리거

- `/cge list`
- `/cge list engineerings`
- `/cge list packs`
- `/cge list available`
- `/cge list all`
- "CGE 상태 확인"
- "부착된 자산 보여줘"

## 옵션

| 옵션 | 동작 |
|------|------|
| 없음 | 활성 자산 전체 |
| `engineerings` | 엔지니어링만 |
| `packs` | 팩만 |
| `skills` | 스킬만 |
| `agents` | 에이전트만 |
| `available` | 부착 가능하지만 비활성 |
| `all` | 활성+비활성 모두 |
| `--json` | 기계 가독 출력 |

## 절차

### Step 1: 프로파일 로드

`.claude/_project_profile.json` 읽기.

### Step 2: 카탈로그 로드

- 활성 카탈로그: 프로파일의 `active_*`
- 비활성 카탈로그: `engineerings/*/engineering.json` + `packs/*/pack.json` 모두 스캔 → 활성 목록 차집합

### Step 3: 출력 포맷

```markdown
# 📋 CGE Asset Status

**Project**: ${PROJECT_NAME}
**Bootstrapped**: ${BOOTSTRAP_TIMESTAMP}
**Last rebootstrap**: ${LAST_REBOOTSTRAP}

## ✅ 활성 엔지니어링 (1)
| ID | Version | 활성 시점 | Skills | Agents |
|----|---------|-----------|--------|--------|
| harness | 1.0.0 | 2026-04-26 | 22 | 3 |

## ✅ 활성 팩 (2)
| ID | Version | Confidence | 활성 시점 |
|----|---------|------------|-----------|
| unreal | 1.0.0 | 95% | 2026-04-26 |
| game-dev | 1.0.0 | 88% | 2026-04-26 |

## ⏳ 부착 가능 (비활성)
| Type | ID | 활성 조건 |
|------|----|-----------|
| pack | web | TS+React 미감지 |
| pack | python | Python 미감지 |

## 📊 자산 통계
- Skills: 22 active
- Agents: 8 active
- Teams: 13 active
- Hooks: 3 active (Stop / UserPromptSubmit / PostToolUse)

## 🚧 Missing Domain Queue
- payment-team (감지: src/payment/)
- voice-chat-team (감지: 의존성에 voice 라이브러리)
→ teammaker로 신규 생성 가능 또는 _meta/pack-requests.md에 등록됨

## 🔍 다음 명령
- /cge install pack <id>
- /cge uninstall <type> <id>
- /cge mine-pattern  (사용자 작업 패턴 분석)
```

## Examples

### `/cge list`
활성 자산 전체 (위 형식).

### `/cge list available`
```markdown
# ⏳ Available (Not Active)

## Packs
- web@1.0 — TS+React 미감지
- python@1.0 — Python 미감지
- ml@1.0 — PyTorch/TensorFlow 미감지

## Engineerings
- (없음 — engineerings/ 디렉토리에 harness만)
```

### `/cge list --json`
```json
{
  "active_engineerings": [{"id":"harness","version":"1.0.0"}],
  "active_packs": [...],
  "active_assets": {...},
  "missing_domains": [...]
}
```

## Should-NOT-Trigger

| 입력 | 기대 |
|------|------|
| "스킬 만들어줘" | skill-implement 또는 cge-mine-pattern |
| "drift 검사" | harness-audit |

## 관련

- [`cge-install`](../cge-install/SKILL.md)
- [`cge-mine-pattern`](../cge-mine-pattern/SKILL.md)
- `_project_profile.json` 스키마: [`core/templates/project-profile.json.template`](../../templates/project-profile.json.template)
