# Case Study: ProjectFIB — CGE의 원형

CGE가 추출된 첫 프로젝트. UE5 협동 호러 게임.

> 상세 마이그레이션 가이드는 W13에서 추가 작성 예정.
> 본 문서는 **CGE 자산이 어떤 실전 환경에서 추출됐는지** 설명.

## 프로젝트 개요

- **이름**: ProjectFIB (FixItBots)
- **엔진**: Unreal Engine 5.5 (Custom Build)
- **장르**: 1~4인 협동 호러
- **아키텍처**: Lyra-based, Listen Server, Steam P2P
- **테마**: 9개 (연구실·벙커·광산·중세성·원전·유조선·별장·잠수시설·박물관·우주정거장)
- **개발 단계**: Phase 1 (75%) + Phase 2 (35%) + Phase 3 (25%) 진행 중
- **개발자**: 1인 (사용자 ChoDuckHwan)

## 하네스 엔지니어링 도입 경위

ProjectFIB은 시스템이 누적되며 다음 문제가 발생:

1. **드리프트**: 22 스킬 + 8 에이전트 + 13 도메인 팀 누적 → 인덱스↔실제 파일 불일치 가능성
2. **결정 일관성**: 같은 종류 작업이 매번 다르게 호출됨 (Sub-agent? Team? max_retry?)
3. **반복 실수**: 같은 종류 obstacle 12회 만들면서 매번 절차 재발명
4. **컨텍스트 비용**: ui-helper 1482줄, combat-helper 793줄 — 트리거 시 매번 비대 로드

→ harness 엔지니어링 도입으로 해결 시도.

## 도입 단계 요약

### Tier 1 (6항목)
1. CLAUDE.md Change Log 표 신설 — 골격 변경 추적
2. 6 디자인 패턴 마스터 (`team/_patterns.md`) — 패턴 어휘 정착
3. Producer-Reviewer 재시도 캡 (`team/_retry_policy.md`) — 무한루프 차단
4. V7 트리거 검증 (`skill-validate`) — should/should-NOT 강제
5. harness-audit 신규 스킬 — 8 카테고리 자동 점검
6. interaction 팀 Fan-out + Producer-Reviewer 시범 적용

### Tier 2 (7항목)
1. 계층 깊이 ≤2 룰 (`_patterns.md` ⑥) — D3+ 폭증 차단
2. Mode 명시화 — 12 도메인 README에 Sub/Team/Hybrid
3. SKILL.md ≤500줄 정책 + `_template.md`
4. Dry-Run 모드 — 풀 사이클 비용 사전 추정
5. harness-evolve + `_evolve_policy.md` — 자가개선 메커니즘
6. agent-router (Expert Pool 패턴 구현)
7. mission 팀 Supervisor 시범

### 후속 작업
- F: harness-audit 첫 실행 → drift 즉시 정리 (12 HISTORY.md 4섹션 표준화)
- 권한 정리: 22행 → 17행
- 훅 명시화: Stop / UserPromptSubmit / PostToolUse 등록
- ECC E1·E2 흡수: PostToolUse 매핑 + 토큰 정책

## 측정 결과

| 지표 | Before | After | 개선 |
|------|--------|-------|------|
| 신규 obstacle 평균 시간 | 30분 | 5~10분 | 70% ↓ |
| 코드 리뷰 누락 | 5회/월 | 0회 | 100% |
| 권한 프롬프트 빈도 | 5회/세션 | 0~1회 | 80% ↓ |
| 컨텍스트 비대 (ui-helper 트리거) | 1482줄 | 298줄 | 80% ↓ |
| 계층 깊이 위반 | 1~2회/주 | 0 | 100% |

## 추출 결정

이 누적 자산을 다른 프로젝트에서도 쓰려면:
- **ProjectFIB 특화** (combat-helper의 GAS 코드 등)와 **일반화 가능** (6 패턴·재시도·진화) 분리 필요
- 다른 프로젝트는 다른 도메인일 수 있음 (UE5만이 아님) → 슬롯 모듈 필요
- 더 좋은 엔지니어링 등장 시 추가 가능해야 함 → 코어 무관 슬롯 설계

→ **CGE 분리 결정** (2026-04-26).

## 분리 후 매핑

| ProjectFIB 자산 | 분리 후 위치 |
|-----------------|--------------|
| `.claude/skills/harness-*` | `engineerings/harness/skills/` |
| `.claude/skills/skill-*` (메타) | `engineerings/harness/skills/` |
| `.claude/skills/agent-router` | `engineerings/harness/skills/` |
| `.claude/skills/session-log` | `engineerings/harness/skills/` |
| `.claude/agents/{design-pattern,security,stress}-*` | `engineerings/harness/agents/` |
| `.claude/team/_*.md` (정책) | `engineerings/harness/policies/` |
| `.claude/team/teammaker/` | `engineerings/harness/teams/` |
| `.claude/skills/{combat,gas,inventory,ui,unreal-build,unreal-engine}-helper` | `packs/unreal/skills/` |
| `.claude/agents/{gas-ability-developer,interaction-system,ue-perf,unreal-architect,balance}-*` | `packs/unreal/agents/` |
| `.claude/skills/{gap-analysis,phase-review,progress-check,next-task,game-design-core}` | `packs/game-dev/skills/` |
| `.claude/team/{13 도메인}/README.md` | `packs/game-dev/team-templates/` |
| `.claude/CLAUDE.md` (프로젝트별) | (이동 X — 각 프로젝트가 자기 것) |
| `.claude/GDD_*.md` (프로젝트 지식) | (이동 X) |
| `.claude/HARNESS.md` | (템플릿화 → `core/templates/`) |

## ProjectFIB 자체 영향

**0** — 분리는 복제 작업이라 ProjectFIB 측 자산 손상 없음.
추후 ProjectFIB에 CGE 정식 부착하는 마이그레이션은 W13에서 별도 가이드.

## 시사점 (다른 프로젝트가 배울 점)

1. **하네스 작업은 점진**: Tier 1+2+후속 = 19건이 한 번에 만들어진 게 아니라 누적
2. **Drift는 자동 검출 안 하면 누적**: harness-audit 같은 자기 진단 필수
3. **명시적 어휘가 토큰을 절감**: "Sub-agent"·"Producer-Reviewer" 같은 약속이 없으면 매번 재결정
4. **메타팀이 신규 도메인 비용 안정화**: teammaker 없으면 13번째 도메인은 1번째와 비슷한 비용
5. **분리는 가치 누적의 결과**: 처음부터 일반화 시도 X — 한 프로젝트에서 충분히 검증 후 분리

## 다음 케이스 스터디

- 미래: TS 백엔드 프로젝트 부착 사례
- 미래: ML 파이프라인 부착 사례
