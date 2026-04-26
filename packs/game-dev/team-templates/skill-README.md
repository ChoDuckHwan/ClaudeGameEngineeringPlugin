# Skill Team

ProjectFIB의 스킬(`.claude/skills/`) 생성 및 관리를 전담하는 에이전트 팀입니다.
입력된 프롬프트를 정확히 이해하고, 프로젝트에 최적화된 스킬을 구현합니다.

## Pattern (Tier 2 #2)

- **Primary**: Pipeline (1 scenario → 2 analyze → 3 improve → 4 changelog → 5 implement)
- **Producer-Reviewer**: 5 implementer ↔ 6 validator (max_retry=2, [`_retry_policy.md`](../_retry_policy.md))
- **Parallelizable Stages**: 없음 — 메타 스킬은 순차 의존 강함
- **Mode**: **Sub-agent** — 메타 작업 단발 호출이 일반적, Agent Team 부담 불필요
- **Reference**: [`_patterns.md`](../_patterns.md)

## Team Pipeline

```
[프롬프트 입력]
    |
    v
1. scenario-detailer ---- GDD/기획 문서 기반 시나리오 구체화
    |
    v
2. structure-analyzer --- 기존 스킬/코드 구조 파악
    |
    v
3. structure-improver --- 구조 개선안 도출
    |
    v
4. change-reporter ------ 이전 vs 개선 구조 변경점 리포트
    |
    v
5. skill-implementer ---- 스킬 파일 작성 및 기능 추가
    |
    v
6. skill-validator ------ 스킬 검증 및 테스트
    |
    v
7. skill-feature-activator ─ 트리거 안내, 메모리/권한/훅 자동 등록, 호출 예시 시연
```

## Agents

| Agent | Role | Skills Used |
|-------|------|-------------|
| `scenario-detailer` | GDD 문서에서 시나리오 추출/구체화 | `/skill-scenario` |
| `structure-analyzer` | 기존 스킬 구조 분석 | `/skill-analyze` |
| `structure-improver` | 구조 개선안 제시 | `/skill-improve` |
| `change-reporter` | 변경 전/후 diff 리포트 | `/skill-changelog` |
| `skill-implementer` | SKILL.md 및 references 작성 | `/skill-implement` |
| `skill-validator` | 스킬 품질 검증 | `/skill-validate` |
| `skill-feature-activator` | 트리거 안내 + 메모리/권한/훅 자동 등록 + 충돌 점검 + 호출 예시 | (수동 호출) |

## Dry-Run

이 팀은 **실행 전 계획 미리보기**를 지원한다.

- 호출 예: `"skill 팀 dry-run으로 [스킬 작업] 계획 보여줘"`
- 표준 출력: [`_patterns.md` Dry-Run 모드](../_patterns.md#dry-run-모드-표준-tier-2-4)
- 권장 사용 시점:
  1. 신규 스킬 풀 사이클 (5→6 Producer-Reviewer 루프 비용 추정)
  2. 메타 스킬 리팩토링 (다른 메타 스킬 의존 영향)

## Usage

이 팀은 스킬 관련 작업에만 집중합니다:
- 새 스킬 생성
- 기존 스킬 개선
- 스킬 구조 리팩토링
- 스킬 품질 검증

게임 코드 구현, 빌드, 에셋 작업 등은 이 팀의 범위 밖입니다.
