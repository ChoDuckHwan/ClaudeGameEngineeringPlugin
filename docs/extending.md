# Extending CGE — 사용자 확장 가이드

CGE를 자기 환경에 맞게 확장하는 모든 방법.

## 확장 종류

| 종류 | 위치 | 비용 | 영향 범위 |
|------|------|------|-----------|
| 단일 스킬 추가 | 활성 엔지니어링·팩의 `skills/` 또는 `_user/` | 낮음 | 현재 프로젝트만 |
| 단일 에이전트 추가 | 동일 | 낮음 | 동일 |
| 새 정책 매개변수 | 정책 .md 수정 | 낮음 | 활성 엔지니어링 |
| 새 시그널 | `core/signals/*.json` | 중 | 모든 프로젝트 |
| 새 팩 | `packs/<id>/` | 중 | 활성화 시 |
| 새 엔지니어링 | `engineerings/<id>/` | 큼 | 활성화 시 |
| 본체 코어 수정 | `core/*` | 매우 큼 | 모든 프로젝트 |

## 확장 우선순위 (권장)

```
1. 사용자 작업 패턴 발견 → /cge mine-pattern
                            ↓
                       후보 큐 등록
                            ↓
2. 단일 자산 충분? → 스킬·에이전트만 추가
                            ↓ 아니오
3. 도메인 누락? → 새 팩 작성
                            ↓ 아니오
4. 협업 방식 자체 새로움? → 새 엔지니어링 작성
                            ↓ 아니오
5. 시그널·정책만 조정? → 본체 수정 PR
```

## 일상적 확장: 단일 스킬

### Step 1: 템플릿 복사
```bash
cp core/templates/skill-_template.md \
   engineerings/_user/my-skills/skills/my-new-skill/SKILL.md
```

### Step 2: frontmatter + 본문 작성
- `name`: kebab-case, 디렉토리명과 일치
- `description`: 트리거 키워드 6+ (한·영)
- 본문 ≤500줄, references 분리

### Step 3: 검증
```
/skill-validate my-new-skill
```

V7(should/should-NOT) 통과 확인.

### Step 4: 부착
- `_user/my-skills/`에 두면 → 다음 부착 시 자동 후보
- 또는 즉시: `/cge install skill <path-or-url>`

## 시그널 카탈로그 확장

새 언어·빌드시스템·프레임워크·문서 타입 추가:

### `core/signals/languages.json`에 추가
```json
{
  "languages": {
    "deno": {
      "extensions": [".ts"],
      "manifest_required": "deno.json",
      "min_count_for_signal": 3
    }
  }
}
```

### `core/signals/build_systems.json`에 추가
```json
{
  "build_systems": {
    "deno": {
      "manifests": ["deno.json", "deno.jsonc"],
      "primary_language": "deno"
    }
  }
}
```

→ Phase 0 Discovery에서 즉시 인식.

## 정책 매개변수 조정

### 도메인별 max_retry 오버라이드
`_retry_policy.md`에 추가:
```markdown
| my-domain | max_retry=4 | 휴리스틱 작업 — 시도 많이 필요 |
```

### 모델 선택 변경
`_token_policy.md` "도메인별 모델 비율" 표 갱신.

## 새 팩 vs 새 엔지니어링 결정

| 질문 | 답 → 종류 |
|------|-----------|
| 협업 방식 자체가 새로움? | YES → 엔지니어링 |
| 도메인이 새로움? | YES → 팩 |
| 단일 작업만? | YES → 스킬 또는 에이전트 |

예시:
- React/Next 프로젝트용 자산군 → **팩** (web-pack)
- "TDD 강제" 작업 방식 → **엔지니어링** (tdd-strict)
- "GAS 어빌리티 구현" 단일 작업 → **에이전트** (gas-ability-developer)

## 사용자 노하우 격리: `_user/`

모든 사용자 자작 자산은 `_user/` 디렉토리에 두면 격리:
```
engineerings/_user/<id>/
packs/_user/<id>/
```

- 본체 자산과 분리 (충돌·오염 방지)
- 3+ 프로젝트에서 사용 시 정식 승격 후보 (`_meta/promotions.md`)

## 메타-메타 학습 활용

```
/cge mine-pattern   # 내 프로젝트 패턴 발굴
/cge sync-lessons   # 다른 내 프로젝트 노하우 흡수
```

3+ 프로젝트가 같은 패턴 보이면 → `_meta/engineering-requests.md`/`pack-requests.md` 큐 → 정식 승격.

## 본체 PR

본체 `core/` 수정 또는 정식 `engineerings/`/`packs/` 추가는 PR:

1. fork
2. 작업 (`engineerings/<id>/` 또는 `packs/<id>/`)
3. `_meta/promotions.md`에 후보 등록
4. PR 제출
5. 메인테이너 검토 → 승인 시 정식 슬롯

## 흔한 질문

### Q. 다른 사람의 스킬을 가져오고 싶어요
```
/cge install skill https://github.com/other/their-skill
```
스킬 매니페스트 검증 후 부착. 충돌 시 사용자 결정.

### Q. 내가 만든 엔지니어링이 효과 있는지 어떻게 측정?
- 부착 후 5+ 사이클 실행
- HISTORY.md 누적 → harness-evolve로 진화 후보 보기
- 토큰·시간·통과율 추이 추적

### Q. 본체 수정 없이 기능 끄기/켜기?
`/cge uninstall <type> <id>`로 제거. 재부착은 `/cge install`.

### Q. 다른 프로젝트 노하우를 가져오려면?
```
/cge sync-lessons
```
다른 CGE 부착 프로젝트들의 `_project_profile.json` + HISTORY를 합류.

## 다음

- [`engineering-slot-guide.md`](engineering-slot-guide.md) — 새 엔지니어링 상세
- [`pack-authoring.md`](pack-authoring.md) — 새 팩 상세
- [`lifecycle.md`](lifecycle.md) — install/uninstall/replace
- 본체 메타루프: `_meta/`
