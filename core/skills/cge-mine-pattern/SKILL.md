---
name: cge-mine-pattern
description: "프로젝트의 HISTORY.md·작업 이력에서 반복되는 패턴을 발굴해 신규 엔지니어링·팩 후보로 제안한다. 사용자 노하우 누적의 핵심 메커니즘. 사용자가 '/cge mine-pattern', '패턴 발굴', '내 작업 패턴', '신규 엔지니어링 후보', '노하우 추출', 'mine pattern', 'extract pattern'을 언급할 때 활성화."
---

# CGE Mine Pattern — 사용자 노하우 발굴

프로젝트에서 누적된 작업 이력에서 **반복 패턴 → 신규 엔지니어링·팩 후보**를 자동 추출.

## 트리거

- `/cge mine-pattern`
- "내가 자주 하는 작업 패턴 찾아줘"
- "노하우 추출"
- "신규 엔지니어링 후보 발굴"

## Identity

CGE의 **자기 진화 핵심 채널**. 사용자가 같은 작업을 5+회 반복하면 그건 새로운 자산 후보.
이 스킬은 다음을 분석:
- `_meta/HISTORY.md` (CGE 자체 이력)
- `.claude/team/*/HISTORY.md` (도메인 활동 이력)
- `.claude/SESSION_HANDOFF.md` (세션 인계 기록)
- git log (실제 코드 활동)

## 절차

### Step 1: 데이터 수집

```
Glob: .claude/team/*/HISTORY.md
Read 모두 → 활동 로그 추출

Read .claude/SESSION_HANDOFF.md → 최근 N개 핸드오프

Bash: git log --since="3 months ago" --pretty=format:"%h %s" → 활동 패턴
```

### Step 2: 패턴 추출

다음 시그널 누적:

| 패턴 종류 | 검출 기준 |
|-----------|-----------|
| 반복 작업 | 같은 종류 작업 5+회 (예: "새 obstacle 만들기") |
| 반복 실수 | ❌ 같은 교훈 3+회 |
| 누락 자동화 | 매번 수동으로 같은 검증 단계 수행 |
| 자주 호출되는 파일 조합 | 항상 함께 편집되는 파일군 |
| 미충족 시그널 | activation_criteria가 50%에 가까운데 자동 권장 안 된 팩 |

### Step 3: 후보 분류

각 패턴을 분류:

- **신규 스킬 후보**: 단발 자동화로 충분
- **신규 에이전트 후보**: 복합 판단 필요
- **신규 팩 후보**: 도메인 전체가 누락
- **신규 엔지니어링 후보**: 작업 방식론 자체가 새로움

### Step 4: 제안서 작성

```markdown
# 🔬 Pattern Mining Report

## 발굴 기간
2026-01-26 ~ 2026-04-26 (3개월)
- 활동 로그: 47건
- 핸드오프: 23건
- 커밋: 156건

## 🔴 반복 패턴 (Top 5)

### P-1: "새 Obstacle 추가" 작업 (12회)
- 항상 같은 단계: GDD 읽기 → 클래스 생성 → 등록 → 테스트
- **후보**: `pack:obstacle-author` 팩 또는 `agent:obstacle-implementer`
- **예상 효과**: 작업당 30분 → 5분

### P-2: "GAS 어빌리티 구현" 후 보안 검증 누락 (5회 ❌)
- security-vulnerability-analyzer 매번 수동 호출
- **후보**: PostToolUse 훅 확장 — RPC 코드 변경 시 자동 보안 분석
- **예상 효과**: 회귀 차단

### P-3: ...

## 🟡 누락 자동화 (3건)

### A-1: 빌드 후 자동 verifier 호출
- 7회 수동 패턴 발견
- **후보**: PostToolUse 매핑에 추가

## 🟢 신규 도메인 후보

### D-1: "Voice Chat" 도메인 (감지)
- src/Voice/ 디렉토리 + 의존성
- 활성 팩 없음
- **후보**: teammaker로 voice-team 생성 → packs/voice-chat 팩 후보

## 사용자 결정

다음 중 어떤 것을 진행할까요?
1. P-1 → packs/obstacle-author 신규 팩 작성
2. P-2 → settings.local.json PostToolUse 매핑 확장
3. D-1 → teammaker 호출로 voice-team 생성
4. 모두 → 큐에 등록만 하고 추후 진행
5. 거부
```

### Step 5: 승인 시 실행

각 후보별:
- **신규 스킬/에이전트**: skill-team 또는 teammaker 호출
- **신규 팩**: 새 디렉토리 + pack.json 골격 생성 → 사용자가 자산 작성
- **신규 엔지니어링**: `_user/<name>/` 골격 생성 → 사용자 확장
- **PostToolUse 확장**: settings.local.json 매핑 갱신

### Step 6: `_meta/engineering-requests.md` 등록

승인 안 된 후보도 큐에 누적 → 다음 mine-pattern 호출 시 재평가.

## 메타-메타 진화

`_meta/engineering-requests.md`에서 **3+ 프로젝트가 같은 패턴 후보 등록** 시:
- `_meta/promotions.md`로 승격 후보
- 정식 `engineerings/` 디렉토리에 추가 검토

## Examples

### 예시: 새 obstacle 패턴 12회
```
mine-pattern 출력:
- "Obstacle 추가" 작업 12회
- 후보: pack:obstacle-author

사용자: "1 진행"
→ packs/_user/obstacle-author/ 골격 생성
→ pack.json + activation_criteria 골격
→ 사용자가 skills/agents 채움
→ 추후 정식 packs/ 승격 후보
```

## Should-NOT-Trigger

| 입력 | 기대 |
|------|------|
| "history 보여줘" | cge-list 또는 직접 Read |
| "팀 진화" | harness-evolve (harness 엔지니어링 내부) |

## 관련

- [`cge-sync-lessons`](../cge-sync-lessons/SKILL.md) — 다중 프로젝트 학습
- [`harness-evolve`](../../../engineerings/harness/skills/harness-evolve/SKILL.md) — harness 도메인 팀 자가개선 (다른 스코프)
- `_meta/engineering-requests.md` — 후보 큐
