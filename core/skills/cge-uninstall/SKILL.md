---
name: cge-uninstall
description: "CGE에 부착된 엔지니어링·팩·스킬·에이전트를 제거한다. 의존성 역검사·최근 사용 경고 후 사용자 승인하에 비활성화. 사용자가 '/cge uninstall', '제거', '비활성화', '해제', 'uninstall engineering', 'remove pack'을 언급할 때 활성화."
---

# CGE Uninstall — 자산 제거

부착된 자산을 제거. **의존성 역검사**가 핵심 — 잘못 제거하면 의존하는 다른 자산이 깨짐.

## 트리거

- `/cge uninstall engineering harness`
- `/cge uninstall pack unreal`
- `/cge uninstall skill skill-id`

## 절차

### Step 1: 자산 식별

`.claude/_project_profile.json`에서 활성 자산 검색.

### Step 2: 의존성 역검사

이 자산을 의존하는 다른 활성 자산 찾기:
- 직접 의존: 다른 매니페스트의 `depends_on`
- 간접 의존: HISTORY.md에서 사용 흔적

### Step 3: 최근 사용 검사

`.claude/team/*/HISTORY.md` + `.claude/skills/agent-router/routing_log.md`(있으면) Grep:
- 최근 7일 호출 카운트
- 0회 → 안전
- 1~10회 → 주의
- 10+ → 강한 경고

### Step 4: 사용자 경고

```markdown
⚠️ Uninstall Risk Assessment

**제거 대상**: engineering:harness@1.0

**의존성 충격**:
- skill: agent-router (harness 제공)
- skill: skill-validate (harness 제공)
- ... 22 스킬 비활성화 예정

**최근 7일 사용**: 47회 호출

**롤백**: .claude/_backup/<timestamp>/ 자동 생성

진행? [Y/n]
```

### Step 5: `installer` 호출 (uninstall 모드)

Task tool로 위임.

### Step 6: 프로파일 + Change Log 갱신

## Should-NOT-Trigger

| 입력 | 기대 |
|------|------|
| "엔지니어링 교체" | cge-replace (마이그레이션 포함) |
| "전체 초기화" | 별도 — `.claude/_backup/<initial>/` 복원 또는 cge-bootstrap 재실행 |

## 관련

- [`cge-replace`](../cge-replace/SKILL.md) — 제거 대신 교체
- [`installer` agent](../../agents/installer.md)
