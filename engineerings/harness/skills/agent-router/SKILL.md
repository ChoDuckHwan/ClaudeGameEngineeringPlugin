---
name: agent-router
description: "사용자의 코드/질문을 분석해 .claude/agents/ 8개 specialist 에이전트 중 가장 적합한 1~2개를 자동 선택해 호출합니다. Expert Pool 패턴 구현체. 사용자가 '어느 에이전트 부를지 모르겠어, 적합한 전문가 찾아줘, 자동 라우팅, agent route, expert pool, 전문가 매칭, 분석 맡길 곳, 어디에 물어봐야 돼' 등을 언급하거나, 명확한 도메인 키워드 없이 '이 코드 분석/리뷰/도와줘' 같은 모호한 요청을 할 때 활성화됩니다."
---

# Agent Router

`.claude/agents/`의 8개 specialist agent를 **자동 분배**하는 라우터.
Harness 6패턴 중 **③ Expert Pool** 구현체.

> **본문 ≤500줄** ([_template.md](../_template.md) 정책 준수).

## 트리거 (Should-Trigger)

- "이 코드 분석해줘" (도메인 모호)
- "어디에 물어봐야 할지 모르겠어"
- "적절한 전문가 찾아줘"
- "/agent-router this RPC handler"
- "리뷰 부탁" (대상 불특정)

## Should-NOT-Trigger

| 입력 예시 | 기대 호출 | 이유 |
|-----------|-----------|------|
| "GAS 어빌리티 만들어줘" | gas-helper or gas-ability-developer 직접 | 도메인 명확 |
| "팀 만들어줘" | teammaker | 라우터 ≠ 팀생성 |
| "스킬 검증해줘" | skill-validate | 메타 작업은 직접 |
| "interaction 팀 호출" | 사용자가 명시 | 명시 호출 우선 |

## Identity

specialist agent 8개는 각자 좁은 전문 영역을 담당하지만, 사용자 입력은 종종 **여러 영역에 걸쳐있거나 모호**하다.
이 스킬은 입력을 분류해 **가장 적합한 1~2개 specialist를 자동 호출**한다.
사용자가 매번 "어느 에이전트 부를까?"를 결정할 부담 제거 + 사용 빈도 낮은 specialist도 자연스럽게 활용.

## 라우팅 매핑 (8 specialist)

| Specialist | 트리거 키워드 | 입력 패턴 | 모델 |
|-----------|---------------|-----------|------|
| **unreal-architect** | "어떻게 구현, 설계, 아키텍처, C++ vs BP, 시스템 설계, scalable" | 추상적 시스템 설계 질문 | opus |
| **gas-ability-developer** | "어빌리티, GAS, AttributeSet, GameplayEffect, GameplayCue, ability task, tag relationship" | 구체적 GAS 코드 작성 | opus |
| **interaction-system** | "상호작용, 픽업, 아이템 사용, 문, 컴퓨터, 스위치, IInteractableTarget, IPickupable" | 인터랙션 파이프라인 작업 | opus |
| **design-pattern-advisor** | "디자인 패턴, 상태머신, factory, observer, decoupling, 시스템 간 통신" | 패턴 추천 (메타 설계) | opus |
| **ue-performance-analyzer** | "성능, Tick, 최적화, replication 비용, draw call, GPU/CPU, profile" | 작성된 코드 성능 리뷰 | sonnet |
| **security-vulnerability-analyzer** | "보안, 취약점, exploit, 클라이언트 조작, 권한 우회, 인증, 입력 검증" | 작성된 코드 보안 리뷰 | sonnet |
| **game-balance-designer** | "밸런스, HP/데미지, 드롭률, progression, 난이도, 경제, 상성" | 수치·곡선 설계 | sonnet |
| **stress-test-runner** | "스트레스 테스트, 100~500회, load test, race condition, 메모리 누수, spawn cycle" | 100+ 반복 테스트 실행 | haiku |

## Instructions

### Step 1: 입력 분류

```
사용자 입력에서 다음 시그널 검출:
  - 키워드 매칭 (위 매핑 표)
  - 코드 패턴 (Tick → performance, RPC → security, AttributeSet → GAS)
  - 의도 분류 (설계 vs 구현 vs 리뷰 vs 테스트)
```

### Step 2: 매핑 점수 계산

각 specialist에 대해 0~3점:
- 3점: 정확한 도메인 일치 (키워드 ≥2개)
- 2점: 부분 일치 (키워드 1개 + 컨텍스트 매칭)
- 1점: 약한 연관성
- 0점: 무관

### Step 3: 결과 보고 + 사용자 확인

```markdown
# 🎯 Agent Routing

## 입력 분석
- **요청 유형**: 설계 / 구현 / 리뷰 / 테스트
- **검출 키워드**: [...]
- **컨텍스트 시그널**: [...]

## 라우팅 후보

| 순위 | Specialist | 점수 | 호출 사유 |
|------|-----------|------|-----------|
| 1 | gas-ability-developer | 3 | "AttributeSet" 키워드 + "구현" 의도 |
| 2 | ue-performance-analyzer | 2 | "Tick" 컨텍스트 |

## 추천 행동
- ✅ **단일 호출**: gas-ability-developer (점수 3)
- 🔄 **순차 호출**: gas-ability-developer → ue-performance-analyzer (구현 후 성능 리뷰)
- ⛔ **호출 없음**: 모두 점수 1 이하 → 직접 처리 권장

## 사용자 결정
- "1번 진행" → Task(subagent_type="gas-ability-developer")
- "1+2 순차" → 1번 후 2번
- "다른 거" → 사용자 지정
- "취소" → 종료
```

### Step 4: 승인 후 호출

```
사용자가 "진행" → Task tool로 specialist 호출
호출 결과를 사용자에게 전달 + 라우팅 이력 기록 (선택적)
```

## Examples

### 예시 1: GAS 명확 케이스

```
입력: "스프린트 어빌리티 만들어줘 (스태미나 소모)"
→ gas-ability-developer (점수 3 — 어빌리티+AttributeSet 키워드)
→ 단일 호출 권장
```

### 예시 2: 다영역 케이스 (성능 + 보안)

```
입력: "이 RPC 핸들러 검토해줘"
→ security-vulnerability-analyzer (점수 3 — RPC = 권한 검증)
→ ue-performance-analyzer (점수 2 — RPC = 빈도 영향)
→ 순차 호출 권장 (security 먼저)
```

### 예시 3: 모호 케이스

```
입력: "이 코드 좀 봐줘"
→ 컨텍스트 부족
→ "어떤 측면을 보길 원하나요?
     1) 설계 적절성 → unreal-architect
     2) 성능 → ue-performance-analyzer
     3) 보안 → security-vulnerability-analyzer
     4) 패턴 추천 → design-pattern-advisor"
→ 사용자 명시 후 호출
```

### 예시 4: 라우터 거부

```
입력: "팀 만들어줘"
→ 모든 specialist 점수 ≤1
→ "이 작업은 specialist가 아닌 teammaker 메타팀이 적합합니다.
   teammaker 호출하시겠습니까?"
```

## Output Format

위 Step 3 마크다운 형식 그대로.

## 라우팅 정확도 누적

라우팅 실패(사용자가 "다른 거" 선택)는 다음 위치에 누적:

```
.claude/skills/agent-router/routing_log.md (추후 신설)
```

5건 누적 시 `harness-evolve`가 router 키워드 매핑 개선안 자동 검출.

## 참조

- [_patterns.md ③ Expert Pool](../../team/_patterns.md) — 패턴 정의
- [agents/](../../agents/) — 8개 specialist 디렉토리
- [HARNESS.md L3-A](../../HARNESS.md) — 단일 specialist 목록
- [skills/harness-evolve](../harness-evolve/SKILL.md) — 라우팅 정확도 학습
