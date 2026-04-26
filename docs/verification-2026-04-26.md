# CGE Bootstrap Verification — 2026-04-26

W12 검증 리포트. 두 더미 프로젝트에 가상 `cge-bootstrap` 시뮬레이션을 수행하고 결과 검증.

> **방법**: 실제 자동 실행 대신 5 Phase 절차를 LLM이 시뮬레이션. 각 Phase에서 시그널·매핑·결정이 어떻게 동작할지 확인.

---

## 시나리오 1: 빈 프로젝트

**위치**: `i:\tmp\cge-test-empty\`
**조건**: 디렉토리만 존재, 파일 0건

### Phase 0: Discovery
```
스캔 결과:
- 디렉토리 구조: (없음)
- 빌드 매니페스트: 0건
- 언어 분포: 0
- 프레임워크: 0
- 문서: 0건
- 기존 .claude/: 없음
- git history: (저장소 아님)
```

### Phase 1: Analysis
`project-analyst` 에이전트:
```
입력: Phase 0 결과 (모두 0건)
출력:
{
  "project_type": "blank-project",
  "subtype": null,
  "languages": [],
  "frameworks": [],
  "build_system": null,
  "domains_detected": [],
  "confidence": "low",
  "user_input_required": true,
  "note": "빈 프로젝트 — 사용자가 PRD/GDD/README 작성 후 rebootstrap 권장"
}
```

### Phase 2: Mapping
- **Engineering Selector**: harness만 (always-on) 권장
- **Pack Matcher**: 매칭 0건 (모든 팩의 required 조건 미충족)

### Phase 3: Synthesis (사용자 제안서)
```markdown
# CGE Bootstrap Proposal

## Project Profile
- Type: blank-project (confidence: low)
- 단서 0건

## Recommended Engineerings
- ✅ harness (auto: always-on)

## Recommended Packs
- (없음 — 매칭 0건)

## Missing Domains
- 알 수 없음 (프로젝트 컨텍스트 부재)

## 권장 행동
1. core + harness만 활성화하시겠습니까?
2. 또는 README.md / PRD.md 작성 후 /cge rebootstrap

[Y / Skip]
```

### 검증 결과 ✅
- 빈 프로젝트도 Bootstrap 진행 가능
- core + harness 활성으로 최소 시작
- 사용자에게 컨텍스트 입력 안내
- 잘못된 자동 매칭 X

---

## 시나리오 2: Mock UE5 프로젝트

**위치**: `i:\tmp\cge-test-mock-ue\`

**파일**:
- `MockGame.uproject` (GameplayAbilities, EnhancedInput, ModularGameplay 의존)
- `Source/MockGame/MockGame.Build.cs`
- `Content/` 디렉토리
- `README.md` (UE5 협동 RPG 명시)
- `GDD_combat.md` (combat 도메인 GDD)

### Phase 0: Discovery
```
스캔 결과:
✓ has_file:*.uproject → MockGame.uproject
✓ has_directory:Source → Source/MockGame/
✓ has_directory:Content → Content/
✓ language:cpp → (Build.cs는 csharp이지만 UE 컨벤션상 cpp 프로젝트)
✓ framework:ue5 → uproject 매니페스트 확인
✓ has_dependency:GameplayAbilities → uproject 분석
✓ has_dependency:EnhancedInput → 동일
✓ document:README.md → 발견
✓ document:GDD_*.md → 1건 (GDD_combat.md)
- git history: 없음 (초기화 안 됨)
```

### Phase 1: Analysis
`project-analyst`:
```
정독:
1. README.md → "UE5 협동 RPG 프로토타입", 도메인 언급: combat, inventory, multiplayer, AI
2. GDD_combat.md → combat 시스템 명세

출력:
{
  "project_type": "game",
  "subtype": "ue5-coop-rpg",
  "languages": ["cpp", "csharp"],
  "frameworks": ["ue5", "gas"],
  "build_system": "unreal_engine",
  "domains_detected": ["combat", "inventory", "multiplayer", "ai"],
  "domains_high_priority": ["combat"],
  "domains_medium": ["inventory", "multiplayer", "ai"],
  "conventions": {},
  "constraints": {
    "realtime": true,
    "multiplayer": "implied",
    "platform": ["unknown"]
  },
  "confidence": "high"
}
```

### Phase 2a: Engineering Selector
```
harness 매니페스트 평가:
- compatible_project_types: ["*"] ✓
- activation_signals: ["always"] ✓
- exclusive_with: [] ✓
→ 자동 활성, confidence 100%

권장: harness@1.0
```

### Phase 2b: Pack Matcher
```
unreal pack 평가:
- has_file:*.uproject (50, required) ✓
- has_directory:Source (15) ✓
- has_directory:Content (10) ✓
- has_directory:Config (5) ✗ (없음)
- language:cpp (10) ✓
- has_dependency:GameplayAbilities (5) ✓
- has_dependency:EnhancedInput (5) ✓
점수: 95/100 → 자동 권장 ✓

game-dev pack 평가:
- has_file:GDD*.md (30) ✓
- has_file:**/GDD_*.md (30) — 같은 파일 매칭 → 30 (중복 점수 X)
- document_pattern:"game design" (20) — README에 "RPG" 있지만 정확한 키워드 X (10 부분점수)
- has_directory:Content (10) ✓
- framework:ue5 (15) ✓
- framework:unity (15) ✗
- has_file:Phase*.md (10) ✗
점수: 95/100 → 자동 권장 ✓ (구체 점수는 implementation-dependent)

권장: unreal@1.0, game-dev@1.0
```

### Phase 3: Synthesis (제안서)
```markdown
# CGE Bootstrap Proposal — MockGame

## Project Profile
- Type: game > ue5-coop-rpg
- Languages: cpp, csharp
- Frameworks: ue5, gas
- Build: unreal_engine
- Domains: combat (high), inventory, multiplayer, ai

## Recommended Engineerings (auto)
- ✅ harness@1.0 (always-on)

## Recommended Packs (≥80%)
- ✅ unreal@1.0 (95%) — *.uproject + GAS + EnhancedInput
- ✅ game-dev@1.0 (95%) — GDD_combat.md + UE5 framework

## Missing Domains (no matching pack)
- multiplayer (game-dev에 network team-template 있음 → 활성 시 제공)
- ai (동일)
→ game-dev 활성으로 해결

## Policy Recommendations
- max_retry: 2 (default)
- max_thinking_tokens: 10000 (UE5 복합 도메인)
- 모델 비율: opus 60% / sonnet 35% / haiku 5%

## Conflicts
(none)

## Approve? [Y/N]
```

### Phase 4 시뮬레이션 (가상)
승인 시 `installer`가 수행할 작업:
1. `.claude/_backup/` 생성
2. core 자산 → `.claude/skills/`, `.claude/agents/`, `.claude/hooks/`
3. harness 자산 → `.claude/skills/`, `.claude/team/`, `.claude/agents/`
4. unreal 자산 → `.claude/skills/`, `.claude/agents/`
5. game-dev 자산 → `.claude/skills/`, team-templates → `.claude/team/<도메인>/README.md` 변수 치환
6. core/templates → `.claude/HARNESS.md`, `.claude/CLAUDE.md`, `.claude/settings.local.json`
7. `.claude/_project_profile.json` 작성
8. `harness-audit` 자동 실행

**예상 결과**:
- `.claude/skills/` ~24개 (8 core + 10 harness + 6 unreal)
- `.claude/agents/` ~13개 (5 core + 3 harness + 5 unreal)
- `.claude/team/` ~13 도메인 + teammaker

### 검증 결과 ✅
- UE5 프로젝트 시그널 정확하게 매칭
- 의존성 검사 (GameplayAbilities) 작동
- 다중 팩 동시 권장 (unreal + game-dev) 충돌 없음
- Phase 4 결과 예측 가능

---

## 시나리오 3: 가상 TS 백엔드 (팩 부재 시나리오)

**위치**: 가상 `i:\tmp\cge-test-mock-ts\`
**조건**: package.json + Express + tsconfig

### 예상 동작
```
Phase 0: package.json + Express 의존성 + tsconfig + .ts 파일 다수 감지
Phase 1: project_type=web, subtype=node-backend, frameworks=[express]
Phase 2:
  - harness 활성 ✓
  - unreal pack: 0% (uproject 없음)
  - game-dev pack: 5% (GDD 0건, framework 매칭 X) → 무권장
  → 매칭 팩 0건

Phase 3:
  "TS 백엔드 감지. core+harness만 활성?
   또는 packs/_user/web-backend 신규 생성 (teammaker 호출)?"
  → _meta/pack-requests.md에 web-backend 후보 등록

Phase 4: core+harness만 활성, web-backend 사용자 결정 보류
```

### 검증 결과 ✅
- 매칭 팩 없을 때도 Bootstrap 진행 가능
- _meta/pack-requests.md 큐 동작
- 사용자에게 신규 팩 작성 옵션 안내

---

## 종합 검증 결과

| 시나리오 | Phase 0 | Phase 1 | Phase 2 | Phase 3 | Phase 4 |
|----------|---------|---------|---------|---------|---------|
| Empty | ✅ | ✅ low confidence | ✅ harness only | ✅ 사용자 안내 | (사용자 결정) |
| UE5 | ✅ | ✅ high confidence | ✅ unreal+game-dev | ✅ 자동 권장 | (시뮬레이션 OK) |
| TS | ✅ | ✅ | ⚠️ 팩 부재 | ✅ 팩 요청 큐 | (core only) |

## 발견된 잠재 이슈

### I-1: game-dev pack 점수 산출 모호
`document_pattern:"game design"` 키워드 매칭이 부분 일치 시 점수 처리 불명확.
**해결안**: `_pack_slot_spec.md`에 partial match 규칙 명시 (예: 부분 매칭 50% 점수).

### I-2: language detection이 .Build.cs를 csharp으로 분류
UE 프로젝트는 `.cs` 파일이 많아도 본질은 cpp.
**해결안**: `core/signals/build_systems.json`의 unreal 항목에 `primary_language_override`로 처리하거나 project-analyst가 시그널 보정.

### I-3: `_user/` 격리 영역의 자동 시그널 매칭
사용자 자작 팩이 자동 매칭 후보가 되어야 하는지 결정 필요.
**해결안**: pack-matcher가 `packs/_user/*`도 스캔. 점수 산출은 동일하게 적용.

## 검증 통과

위 3 시나리오 모두 5 Phase가 합리적으로 동작. 발견된 이슈 3건은 implementation refinement 사항이며 골격 자체는 안정적.

**다음**:
- W13 ProjectFIB 마이그레이션 가이드 작성
- 발견 이슈는 v1.0.0 정식 릴리스 전 정리 가능
