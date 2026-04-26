# Teammaker Team — 팀 구성 팀 (헤드헌터)

ProjectFIB의 새로운 에이전트 팀을 기획·설계·구성·검증하는 **메타 팀**입니다. 인력구직 사이트의 헤드헌터처럼, 프로젝트에 필요한 전문가 팀을 분석하고 최적의 구성원을 배치합니다.

## Pattern (Tier 2 #2)

- **Primary**: Hierarchical Delegation (**Depth 1** — 사용자 D0, teammaker D1, 생성된 도메인 팀의 단계 에이전트 D2)
- **Producer-Reviewer**: 04 agent_profiler ↔ 06 quality_auditor (max_retry=2)
- **Parallelizable Stages**: `[02, 03]` — talent_scout(기존 패턴 분석)과 needs_analyst 후속 분석 일부 동시 가능
- **Mode**: **Agent Team** — 메타 팀 특성상 다수 에이전트 협업 필수
- **Depth Cap**: ≤2 강제 ([`_patterns.md`](../_patterns.md) ⑥) — teammaker는 다른 팀을 만들지만 만든 팀이 또 다른 팀을 만드는 D3 시도는 거절
- **Reference**: [`_patterns.md`](../_patterns.md), [`03_team_architect.md`](03_team_architect.md) Depth Guard

## 팀 구성

| # | 역할 | 에이전트 | 모델 | 핵심 업무 |
|---|------|---------|------|-----------|
| 01 | 니즈 분석가 | `teammaker-needs-analyst` | opus | 사용자 요청 + GDD/코드 분석 → 팀 필요성·범위 정의 |
| 02 | 인재 스카우트 | `teammaker-talent-scout` | sonnet | 기존 팀 패턴·모범사례 수집, 재사용 가능 역할 식별 |
| 03 | 팀 아키텍트 | `teammaker-team-architect` | opus | 팀 규모·역할·파이프라인·모델 배분 설계 |
| 04 | 에이전트 프로파일러 | `teammaker-agent-profiler` | opus | 개별 에이전트 .md 파일 작성 (프론트매터 + 본문) |
| 05 | 팀 어셈블러 | `teammaker-team-assembler` | sonnet | README.md 작성, 파일 정리, 최종 팀 패키지 조립 |
| 06 | 품질 감사관 | `teammaker-quality-auditor` | opus | 완성된 팀의 누락·중복·일관성·파이프라인 검증 |
| 07 | 학습형 기록자 | `teammaker-history` | sonnet | 활동 이력 기록 + 교훈 추출 + 원칙 축적 + 성장 지표 |
| 08 | 스킬 확장가 | `teammaker-skill-expander` | opus | history 기반 자기 개선, 역할 템플릿 확장, 파이프라인 최적화 |

## 워크플로우

```
사용자 요청: "XX 시스템 팀을 구성해줘"
    │
    ▼
[01 니즈 분석가] ─── 팀 요구사항서 ───▶ [02 인재 스카우트] ─── 기존 패턴 분석 ───┐
                                                                                  │
                                          ┌───────────────────────────────────────┘
                                          ▼
                                    [03 팀 아키텍트] ─── 팀 설계서 ──────────────┐
                                                                                 │
                                          ┌──────────────────────────────────────┘
                                          ▼
                                    [04 에이전트 프로파일러] ─── ##_agent.md 파일들 ──┐
                                                                                      │
                                          ┌───────────────────────────────────────────┘
                                          ▼
                                    [05 팀 어셈블러] ─── README.md + 파일 정리 ──────┐
                                                                                      │
                                          ┌───────────────────────────────────────────┘
                                          ▼
                                    [06 품질 감사관] ─── 검증 리포트 ──▶ 사용자에게 전달
                                          │                               │
                                          ▼ (문제 발견 시)                 ▼
                                    [03] 또는 [04]로 피드백         [07 학습형 기록자]
                                          → 수정 → 재검증               │
                                                                  교훈·원칙 축적
                                                                         │
                                                                         ▼
                                                              [08 스킬 확장가]
                                                                         │
                                                               teammaker 자기 개선
                                                                         │
                                                                         ▼
                                                              [01~06 에이전트 업그레이드]
```

### 자기 발전 흐름 (무한루프 아님 — 조건 충족 + 사용자 호출 시에만)

```
  팀 구성 활동 ──▶ [07 기록 + 교훈 축적] ──▶ 데이터 쌓임
                                                   │
                                             조건 충족 시
                                             사용자가 호출
                                                   │
                                                   ▼
                                    [08 분석 + 개선안 제시] ──▶ 사용자 승인 ──▶ 개선 ──▶ 종료 ■
```

**발동 조건**: 반복 실패 2회 이상 / 사용자 명시 요청 / 팀 3개 생성 후 회고 / 품질 하락 감지

## 사용 예시

### 새 팀 전체 구성
```
1. "몬스터 AI 팀을 구성해줘"               → 01_needs_analyst
2. "기존 팀들의 패턴을 분석해줘"            → 02_talent_scout
3. "AI 팀 구조를 설계해줘"                  → 03_team_architect
4. "각 에이전트 프로필을 작성해줘"           → 04_agent_profiler
5. "README와 파일을 정리해줘"               → 05_team_assembler
6. "완성된 팀을 검증해줘"                   → 06_quality_auditor
```

### 기존 팀 확장/수정
```
"combat 팀에 밸런스 전문가를 추가해줘"      → 01 분석 → 03 설계 → 04 작성
"interaction 팀 파이프라인을 개선해줘"      → 02 분석 → 03 재설계 → 05 정리
```

### 팀 품질 감사
```
"skill 팀이 잘 구성되어 있는지 확인해줘"    → 06_quality_auditor
```

### 자기 발전
```
"지금까지 팀 구성 이력을 분석해줘"          → 07_teammaker_history
"teammaker 팀을 개선할 부분이 있나?"        → 08_skill_expander
"지난번 실패 패턴을 반영해서 개선해줘"      → 08_skill_expander
```

## Dry-Run

이 팀은 **실행 전 계획 미리보기**를 지원한다.

- 호출 예: `"teammaker dry-run으로 [신규 팀 도메인] 구성 계획 보여줘"`
- 표준 출력: [`_patterns.md` Dry-Run 모드](../_patterns.md#dry-run-모드-표준-tier-2-4)
- 권장 사용 시점:
  1. 신규 도메인 팀 생성 직전 (생성될 8~10개 에이전트 미리 보기)
  2. 기존 팀 확장/수정 (영향 범위 사전 점검)
  3. teammaker 자체 자기개선 발동 검토 (#08 skill_expander)

## 핵심 원칙

1. **기존 패턴 존중**: skill/interaction/combat 팀의 검증된 패턴을 기반으로 설계
2. **파이프라인 우선**: 개별 에이전트보다 팀 전체 흐름의 효율성 우선
3. **최소 충분**: 불필요한 역할 추가 금지 — 실제 필요한 만큼만 구성
4. **일관된 형식**: 프론트매터, 네이밍, 번호 체계 등 기존 컨벤션 준수
5. **도메인 전문성**: 각 에이전트에 ProjectFIB 고유의 기술 컨텍스트 내장
6. **자기 발전**: 팀을 만들수록 더 잘 만들게 — history 교훈 → skill_expander 개선 루프
