---
name: cge-bootstrap
description: "CGE 플러그인을 현재 프로젝트에 부착하고 5-Phase 적응 워크플로우(Discovery → Analysis → Mapping → Synthesis → Activation)를 실행한다. 프로젝트를 자동 분석해 적합한 엔지니어링·팩을 선택하고 .claude/ 골격을 생성. 사용자가 'cge 부착', 'cge bootstrap', '플러그인 부착', '프로젝트 초기 설정', '/cge bootstrap', '하네스 엔지니어링 시작', '메타-에이전트 부착' 등을 언급할 때 활성화."
---

# CGE Bootstrap — 5-Phase Adaptive Attachment

CGE를 새 프로젝트에 부착할 때 발동하는 진입점. **메타-에이전트가 프로젝트를 읽고 자기 자신을 재구성**한다.

> **본문 ≤500줄**. 상세 절차는 [`core/policies/_bootstrap_policy.md`](../../policies/_bootstrap_policy.md) 참조.

## 트리거

- "cge bootstrap"
- "/cge bootstrap"
- "플러그인 부착해줘"
- "이 프로젝트에 하네스 적용"
- "메타-에이전트 시작"

## Should-NOT-Trigger

| 입력 | 기대 호출 | 이유 |
|------|-----------|------|
| "프로젝트 변화 반영" | cge-rebootstrap | 재실행은 별도 |
| "스킬 추가" | cge-install | 단일 자산은 install |
| "harness 활성/비활성" | cge-install / cge-uninstall | lifecycle 명령 |

## Identity

새 프로젝트에 처음 부착할 때 단 한 번 발동. **하이브리드 모드** — Phase 0~3은 자동, Phase 4 (Activation)는 사용자 승인.

## Instructions

### Phase 0: Discovery (자동)

1. 프로젝트 루트(`${PROJECT_ROOT}`) 디렉토리 스캔
2. `core/signals/*.json` 카탈로그 기반으로 시그널 추출:
   - 빌드 시스템 매니페스트 검출
   - 언어 분포 (확장자별 카운트)
   - 프레임워크 시그너처 (의존성 매니페스트 분석)
   - 기획·문서 발견 (`document_types.json` 우선순위)
   - 기존 `.claude/` 자산 검사
   - 최근 git 활동 (활동 디렉토리 빈도)

### Phase 1: Analysis (자동)

`project-analyst` 에이전트를 Task tool로 호출 → `_project_profile.json` 초안 작성.

### Phase 2: Mapping (자동)

병렬 호출:
- `engineering-selector` (Task) → 활성 엔지니어링 후보
- `pack-matcher` (Task) → 활성 팩 후보

충돌 발견 시 `conflict-resolver` 자동 호출.

### Phase 3: Synthesis (사용자 승인 게이트)

제안서 출력 + `AskUserQuestion`으로 결정 받기.
[`_bootstrap_policy.md` Phase 3 섹션](../../policies/_bootstrap_policy.md) 형식 준수.

### Phase 4: Activation (승인 후)

`installer` 에이전트(Task) 호출:
- 활성 자산 `.claude/`로 복사
- 변수 치환
- `_project_profile.json` 저장
- Change Log 갱신
- `harness-audit` 자동 실행 (검증)

### 부착 후 안내

```
✅ CGE Bootstrap Complete

활성: ${ACTIVE_ENGINEERINGS} + ${ACTIVE_PACKS}
다음 단계: /harness-audit, /progress-check, /cge list
```

## Examples

### 예시 1: UE5 프로젝트
```
입력: "/cge bootstrap"

Phase 0: *.uproject 발견, Source/+Content/+Config/, GameplayAbilities 의존성, GDD_*.md 11개
Phase 1: project_type=game, subtype=co-op-horror, frameworks=[UE5, GAS]
Phase 2: harness@1.0 (always-on) + unreal@1.0 (95%) + game-dev@1.0 (88%)
Phase 3: 사용자 승인 요청
Phase 4: 자산 부착 → 22 skills + 8 agents + 13 teams
```

### 예시 2: 빈 디렉토리
```
입력: "/cge bootstrap"

Phase 0: 매니페스트 0건, 언어 0건
Phase 1: project_type=blank-project, confidence=low
Phase 2: harness만 권장, 팩 매칭 0건
Phase 3: "프로젝트 정보를 입력해주세요" 사용자 질의
Phase 4: core + harness만 부착 + missing_domains_queue 채움
```

### 예시 3: TS 백엔드 (팩 없음)
```
입력: "/cge bootstrap"

Phase 0: package.json + Express + tsconfig
Phase 1: project_type=web, subtype=saas-backend
Phase 2: harness OK, web-pack 없음 ❌
Phase 3: "core+harness만 활성? teammaker로 신규 팀 만들기?"
Phase 4: 사용자 결정에 따라 부착 + _meta/pack-requests.md에 web-pack 후보 등록
```

## 재실행 안내

이미 부착된 프로젝트에 다시 호출 시:
- 기존 `_project_profile.json` 발견
- "재부착? 새 프로파일? rebootstrap 권장?" 질의
- → `cge-rebootstrap` 권장

## 관련

- [`_bootstrap_policy.md`](../../policies/_bootstrap_policy.md) — 5 Phase 표준
- [`cge-rebootstrap`](../cge-rebootstrap/SKILL.md) — 변화 반영 재실행
- [`cge-list`](../cge-list/SKILL.md) — 부착 후 자산 확인
- 에이전트: project-analyst, engineering-selector, pack-matcher, conflict-resolver, installer
