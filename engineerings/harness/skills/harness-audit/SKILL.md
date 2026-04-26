---
name: harness-audit
description: "**하네스 골격 정합성 검사 전용**. .claude/ 디렉토리(agents·skills·team·CLAUDE.md·HARNESS.md·MEMORY.md) 사이의 인덱스↔실제 파일 drift, 깨진 참조, 누락 메타, retry_policy/Pattern/Dry-Run 누락을 리포트합니다. 게임 코드나 SKILL.md 자체 품질은 다루지 않음. 사용자가 \"하네스 정합성, 하네스 점검, .claude drift, .claude 무결성, harness audit, 골격 점검\" 등을 언급할 때 활성화됩니다. 단일 스킬 QA는 skill-validate, 코드 무결성은 도메인 verifier로."
---

# Harness Audit

`.claude/` 디렉토리 하네스 골격의 정합성을 점검하고 **drift**(인덱스와 실제 파일 사이 차이)를 검출하는 스킬.

## 트리거

- "하네스 감사해줘" / "harness audit"
- ".claude 정합성 검사" / ".claude 점검"
- "drift 있나?" / "무결성 확인"
- "스킬 인덱스 맞아?"

## 점검 항목 (8 카테고리)

### A. 파일-인덱스 정합성
- [ ] `CLAUDE.md`에 언급된 시스템·태그·경로가 실제 코드에 존재 (Grep)
- [ ] `HARNESS.md`에 나열된 스킬/에이전트/팀 파일이 실제 존재 (Glob)
- [ ] `MEMORY.md` 링크의 대상 파일이 존재
- [ ] `.claude/team/*/README.md`에 언급된 단계 파일이 실제 존재

### B. 스킬 무결성 (`.claude/skills/`)
- [ ] 각 디렉토리에 `SKILL.md` 존재
- [ ] frontmatter `name`이 디렉토리명과 일치
- [ ] description에 트리거 키워드 ≥3개
- [ ] 빈 스텁(`SKILL.md` 본문 ≤10줄) 없음
- [ ] 다른 스킬과 트리거 키워드 충돌 (skill-validate V7 위임)
- [ ] **본문 줄수 정책** (Progressive Disclosure):
  - ✅ ≤500줄: 정상
  - 🟡 500~800줄: WARNING (references/ 분리 권고)
  - 🔴 >800줄: HIGH (references/ 분리 필수, 컨텍스트 비대화)
- [ ] **references/ 디렉토리** 존재 시 본문에서 포인터로 참조됨

### B-스캔 명령
```bash
for f in .claude/skills/*/SKILL.md; do
  lines=$(wc -l < "$f")
  name=$(basename $(dirname "$f"))
  if [ $lines -gt 800 ]; then echo "🔴 $name: $lines (HIGH)"
  elif [ $lines -gt 500 ]; then echo "🟡 $name: $lines (WARNING)"
  fi
done
```

### C. 에이전트 무결성 (`.claude/agents/`, `.claude/team/`)
- [ ] frontmatter `name` 존재
- [ ] `description` ≥1줄
- [ ] `tools` 배열 명시
- [ ] `model` 명시 (opus / sonnet / haiku)

### D. 도메인 팀 표준 준수 (`.claude/team/<도메인>/`)
- [ ] `README.md` 존재
- [ ] 표준 단계(01_design_concretizer ~ 10_feature_activator) 누락 검출
- [ ] 단계 파일명이 README 표와 일치
- [ ] `## Pattern` 섹션 존재 (`_patterns.md` 도입 후)
- [ ] verifier에 `retry_policy` 메타 존재 (`_retry_policy.md` 도입 후)
- [ ] **계층 깊이 ≤2 준수**: 단계 에이전트 frontmatter `tools`에 `Agent` 또는 `TaskCreate` 없음 (다른 팀 호출 금지)
- [ ] **팀 내부 다이어그램 검증**: README 워크플로우에 다른 팀 노드(예: `combat-team`, `ui-team`) 등장 X
- [ ] **Pattern 섹션 4행 완비**: `## Pattern` 섹션에 Primary / Producer-Reviewer / Parallelizable Stages / **Mode** 4행 모두 명시
- [ ] **Mode 값 유효**: Mode가 `Agent Team` / `Sub-agent` / `Hybrid` 셋 중 하나
- [ ] **Dry-Run 섹션 존재**: `## Dry-Run` 섹션 + `_patterns.md` Dry-Run 모드 링크 + 권장 사용 시점 ≥1개
- [ ] **HISTORY.md 4섹션 형식**: 일반 12개 도메인은 `team/<도메인>/HISTORY.md`에 4섹션 (`# 활동 로그` / `# 축적된 원칙` / `# 도메인 인사이트` / `# 성장 지표`) 존재. teammaker·skill은 단일 파일 결합형 (특수 케이스)
- [ ] **진화 후보 누적 알림**: 09_history에서 ❌ 2회+ 검출 시 "harness-evolve 발동 권장" 표시
- [ ] **마일스톤 도달 알림**: 활동 ≥5회 누적 시 "harness-evolve 가능" 표시
- [ ] **Supervisor 모드 도메인 검증**: README에 `## Supervisor 모드` 절차가 있다면 (a) 위임 단위 ≥§섹션, (b) worker ≤4, (c) 깊이 ≤2 준수 명시 확인
- [ ] **agent-router 매핑 일관성**: `skills/agent-router/SKILL.md` 라우팅 표의 specialist 8개가 `.claude/agents/` 실제 파일과 일치 (이름·존재)

### E. 권한 위생 (`.claude/settings.local.json`)
- [ ] 중복 항목 없음
- [ ] 과도하게 좁은 항목(특정 1회용 명령) 식별
- [ ] env 플래그 (`CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS`) 명시 확인
- [ ] hooks 섹션 명시 여부 (Stop 훅 등록)

### F. 메모리 위생 (`~/.claude/projects/.../memory/`)
- [ ] `MEMORY.md` ≤200줄
- [ ] 각 항목 파일 존재
- [ ] frontmatter type 유효 (user/feedback/project/reference)
- [ ] 중복 메모리 검출

### G. 핸드오프 신선도
- [ ] `SESSION_HANDOFF.md` 마지막 갱신 시점 ≤7일
- [ ] `.session-log-marker` 존재
- [ ] `check_handoff.ps1` 실행 가능

### H. Change Log 누락 검출
- [ ] 최근 커밋이 `.claude/` 골격을 변경했는데 CLAUDE.md `## Change Log`에 기록 없음 (의심)

## 실행 절차

```
Step 1. 디렉토리 스캔
  Glob: .claude/skills/*/SKILL.md
  Glob: .claude/agents/*.md
  Glob: .claude/team/**/*.md
  Glob: .claude/*.md

Step 2. 각 카테고리 A~H 순회
  파일 존재 / frontmatter / 인덱스 일치 검사

Step 3. drift 발견 시 심각도 분류
  CRITICAL: 인덱스가 가리키는 파일 부재
  HIGH:     frontmatter 깨짐, 표준 단계 누락
  WARNING:  빈 스텁, 트리거 충돌
  INFO:     비표준 명명, 메타 누락

Step 4. 리포트 생성

Step 5. 자동 수정 가능 항목 제시 (사용자 승인 후 적용)
```

## 출력 형식

```markdown
# 🔍 Harness Audit Report

**스캔 시각**: 2026-04-26 02:30
**대상**: .claude/ (스킬 18, 에이전트 8, 팀 13)

## Summary

| 카테고리 | CRITICAL | HIGH | WARNING | INFO |
|----------|:---:|:---:|:---:|:---:|
| A. 파일-인덱스 | 0 | 1 | 2 | 0 |
| B. 스킬 | 0 | 0 | 1 | 3 |
| C. 에이전트 | 0 | 0 | 0 | 0 |
| D. 도메인 팀 | 0 | 2 | 0 | 5 |
| E. 권한 | 0 | 1 | 4 | 0 |
| F. 메모리 | 0 | 0 | 0 | 0 |
| G. 핸드오프 | 0 | 0 | 0 | 0 |
| H. Change Log | 0 | 0 | 1 | 0 |

## 🔴 CRITICAL 이슈
(없음 또는 상세)

## 🟠 HIGH 이슈
### H-D-01: combat 팀 09_combat_bug_tester.md 누락
- **위치**: `.claude/team/combat/`
- **기대**: README가 09 단계 존재 가정
- **실측**: 파일 없음
- **수정**: 파일 생성 또는 README에서 제거

## 🟡 WARNING / 🟢 INFO
(목록)

## 자동 수정 제안
- [ ] settings.local.json 중복 4항목 통합 (-110 글자)
- [ ] 빈 스텁 `skills/SKILL.md` 삭제

## 다음 단계
1. CRITICAL 즉시 수정
2. HIGH는 다음 세션 시작 시 우선 처리
3. WARNING은 일괄 batch
```

## 권장 실행 주기

| 시점 | 트리거 |
|------|--------|
| 매주 1회 | 사용자가 `/harness-audit` 명시 호출 |
| 신규 도메인 팀 생성 후 | teammaker 06_quality_auditor가 본 스킬 호출 |
| Change Log 항목 5개 누적 시 | 권장 (자동 알림은 추후) |

## 참조

- [HARNESS.md](../../HARNESS.md) — 하네스 레이어 맵
- [team/_patterns.md](../../team/_patterns.md) — 디자인 패턴 표준
- [team/_retry_policy.md](../../team/_retry_policy.md) — Producer-Reviewer 재시도 표준
- [skill-validate](../skill-validate/SKILL.md) — V7 트리거 검증 위임
