---
name: cge-install
description: "단일 엔지니어링·팩·스킬·에이전트를 CGE에 부착한다. 매니페스트 검증·의존성·충돌 검사 후 사용자 승인하에 .claude/에 자산 활성화. 사용자가 '/cge install', '엔지니어링 추가', '팩 활성화', '스킬 부착', 'install engineering', 'install pack'을 언급할 때 활성화."
---

# CGE Install — 단일 자산 부착

엔지니어링·팩·스킬·에이전트 단위로 부착.

## 트리거

- `/cge install engineering harness`
- `/cge install pack unreal`
- `/cge install skill <git-url>`
- `/cge install agent <id>`

## 인자 형식

```
/cge install <type> <id-or-url>

<type>: engineering | pack | skill | agent
<id-or-url>:
  - 로컬 ID (engineerings/<id> 또는 packs/<id>)
  - git URL (외부 자산)
  - 마켓플레이스 식별자 (미래)
```

## 절차

### Step 1: 매니페스트 로드

| type | 매니페스트 위치 |
|------|----------------|
| engineering | `engineerings/<id>/engineering.json` |
| pack | `packs/<id>/pack.json` |
| skill | `<source>/SKILL.md` frontmatter |
| agent | `<source>/<id>.md` frontmatter |

### Step 2: 검증

- 스키마 일치 (engineering_slot_spec / pack_slot_spec)
- 의존성 가용 (`depends_on`)
- 충돌 검사 (`exclusive_with` + 활성 자산)
- 기존 `.claude/` 자산과 trigger 충돌 (skill-validate V7 위임)

### Step 3: 사용자 승인

```markdown
# 📥 Install Proposal

**자산**: engineering:harness@1.0
**제공**: 22 skills + 3 agents + 4 policies + teammaker team
**의존성**: core (활성 ✓)
**충돌**: 없음
**예상 토큰 비용**: ~5000 (부착 시 1회)

진행? [Y/n]
```

### Step 4: `installer` 에이전트 호출

Task tool로 `installer` 호출 → 실제 부착.

### Step 5: 검증 + 보고

`harness-audit` 실행 → 정합성 확인 → 사용자 보고.

## Examples

### 예시 1: 엔지니어링 부착
```
/cge install engineering harness

Plugin: harness 매니페스트 검증 OK
       의존성: core ✓
       충돌: 없음
       제공: 22 skills, 3 agents, 4 policies, teammaker

승인? [Y/n] Y

✅ harness@1.0 활성화 완료
```

### 예시 2: 외부 git 스킬
```
/cge install skill https://github.com/example/super-skill

Plugin: 매니페스트 다운로드 + 검증
       trigger 충돌 검사: skill-validate (V7) 위임
       기존 'audit' 키워드와 부분 충돌 발견

⚠️ super-skill의 트리거 "audit"이 harness-audit과 겹침
선택: [skip / install-with-rename / install-anyway / cancel]
```

## Should-NOT-Trigger

| 입력 | 기대 |
|------|------|
| "엔지니어링 만들어줘" | 신규 엔지니어링 작성은 별도 — _user/ 디렉토리에 직접 작성 또는 cge-mine-pattern |
| "부착된 자산 보여줘" | cge-list |

## 관련

- [`cge-uninstall`](../cge-uninstall/SKILL.md)
- [`cge-replace`](../cge-replace/SKILL.md)
- [`installer` agent](../../agents/installer.md)
