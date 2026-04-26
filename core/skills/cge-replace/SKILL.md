---
name: cge-replace
description: "엔지니어링·팩을 새 버전 또는 다른 ID로 교체. 자동 자산 매핑·정책 매개변수 마이그레이션·롤백 안전장치 포함. 사용자가 '/cge replace', '엔지니어링 교체', 'harness 1→2', '버전 업그레이드', 'replace engineering'을 언급할 때 활성화."
---

# CGE Replace — 엔지니어링·팩 교체

같은 자산의 새 버전 또는 다른 자산으로 교체.
**제거 + 부착의 단순 결합이 아니라** 자산 매핑·정책 마이그레이션이 핵심.

## 트리거

- `/cge replace engineering harness@1.0 with harness@2.0`
- `/cge replace engineering harness with new-engineering`
- `/cge replace pack unreal@1.0 with unreal@2.0`

## 인자 형식

```
/cge replace <type> <id>[@version] with <id>[@version]
```

## 절차

### Step 1: old + new 매니페스트 로드

old: `.claude/_project_profile.json`에서 활성 버전
new: `engineerings/<id>/engineering.json` 또는 `packs/<id>/pack.json`

### Step 2: 자산 매핑

old.provides vs new.provides 비교:

| 매칭 | 처리 |
|------|------|
| 같은 ID, 같은 카테고리 | 자동 마이그레이션 |
| old에만 있음 | 사용자 결정 (보존? 제거?) |
| new에만 있음 | 자동 추가 |
| 다른 ID이지만 의미상 같음 | (휴리스틱 — 사용자 확인) |

### Step 3: 정책 매개변수 마이그레이션

`_project_profile.json.policy_overrides`를 new 스키마로 변환:
- 같은 키 → 그대로
- 사라진 키 → 보관 (rollback용)
- 새 키 → new 매니페스트 권장값

### Step 4: 단계적 교체

1. **백업**: `.claude/_backup/<replace-timestamp>/`
2. **Stage**: new 자산을 `.claude/_staging/<new-id>/`에 부착
3. **Conflict check**: 기존 활성 자산과 충돌 검사
4. **Activate**: old 비활성 → new 활성 (atomic 시도)
5. **Verify**: harness-audit 실행
6. **Rollback**: 실패 시 `_backup/`에서 복원

### Step 5: 사용자 보고

```markdown
✅ Replace Complete

old: harness@1.0 (22 skills, 3 agents, 4 policies)
new: harness@2.0 (24 skills, 3 agents, 5 policies)

자동 마이그레이션: 22 skills + 3 agents + 4 policies
신규 추가: 2 skills (harness-explain, harness-trace), 1 policy (_observability)
사라진 항목: 없음

정책 매개변수 마이그레이션: max_retry 2 → 2 (유지), MAX_THINKING 10000 → 12000
```

## Examples

### 예시 1: 같은 ID 버전업
```
/cge replace engineering harness@1.0 with harness@2.0

→ 대부분 자산 자동 마이그레이션
→ 신규 자산 자동 추가
→ 정책 키 차이 사용자 결정
```

### 예시 2: 다른 엔지니어링으로 전환
```
/cge replace engineering harness with archon

⚠️ harness ↔ archon은 exclusive_with 관계
⚠️ 자산 매핑 휴리스틱 — 18/22 매칭, 4 항목 사용자 확인 필요
⚠️ teammaker 메타팀 → archon에 대응 자산 없음 (제거? 보존?)

진행? [Y/n]
```

## Should-NOT-Trigger

| 입력 | 기대 |
|------|------|
| "팩 추가" | cge-install |
| "팩 제거" | cge-uninstall |
| "프로젝트 변화 반영" | cge-rebootstrap |

## 관련

- [`cge-install`](../cge-install/SKILL.md)
- [`cge-uninstall`](../cge-uninstall/SKILL.md)
- [`installer` agent](../../agents/installer.md) (replace 모드)
