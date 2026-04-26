# ProjectFIB → CGE 마이그레이션 가이드

ProjectFIB(이미 자체 하네스 구축된 프로젝트)에 CGE를 정식 부착하는 절차.

> **D-9 결정**: 추후 CGE 플러그인이 안정화되면 ProjectFIB에 적용. **현 시점은 가이드만 작성**, 즉시 적용 X.
> 본 가이드는 [`docs/case-studies/projectfib.md`](projectfib.md)의 후속 — 분리 후 다시 부착할 때.

---

## 마이그레이션이란

ProjectFIB은 이미 누적된 자산이 있다 (`.claude/skills/`, `.claude/team/` 등 130+ 파일).
CGE 부착 = 기존 자산을 CGE 표준으로 정렬 + `_project_profile.json` 생성.

## 일반 신규 부착과 다른 점

| 항목 | 신규 부착 | ProjectFIB 마이그레이션 |
|------|-----------|--------------------------|
| 기존 `.claude/` | 비어있음 | 130+ 파일 존재 |
| 충돌 | 없음 | 다수 (같은 ID 자산) |
| Phase 1 | LLM이 처음 분석 | 기존 CLAUDE.md+HARNESS.md 활용 |
| Phase 4 | 자산 복사 | **자산 매핑** (대부분 이미 존재) |
| 백업 | 빈 `.claude/_backup/` | **반드시 풀 백업** |

## 사전 준비 (마이그레이션 D-day 전)

### Step A: ProjectFIB 측 검증
```bash
# ProjectFIB에서
/harness-audit          # 현재 정합성 OK 확인
/cge list (불가능)       # CGE 미부착 상태이므로 N/A
```

### Step B: CGE 측 호환성 확인
- harness@1.0의 자산 목록과 ProjectFIB의 `.claude/` 파일 목록 비교
- 차이 항목 정리:
  - CGE에만 존재 (cge-bootstrap, cge-install 등) → 신규 부착
  - 양쪽 존재 (harness-audit, harness-evolve 등) → ID 일치 확인 → 유지
  - ProjectFIB에만 존재 (combat-helper, gas-helper 등) → unreal-pack에 동일 자산 있는지 확인

### Step C: 백업
```bash
cp -r .claude/ .claude_pre-cge-backup/
```

---

## 마이그레이션 절차

### Phase 0: Discovery (재실행)
일반 cge-bootstrap과 동일:
- `*.uproject` ✓
- `Source/`, `Content/`, `Config/` ✓
- `GDD_*.md` 11개 ✓
- 기존 `.claude/` 자산 130+ 파일 → `existing_claude_assets` 채움

### Phase 1: Analysis
`project-analyst`가 기존 CLAUDE.md를 정독 → 이미 풍부한 정보:
```json
{
  "project_type": "game",
  "subtype": "co-op-horror",
  "languages": ["cpp", "blueprint"],
  "frameworks": ["ue5", "gas"],
  "domains_detected": [
    "combat", "ai", "audio", "balance", "horror", "interaction",
    "mission", "network", "player", "skill", "ui", "animation"
  ],
  "existing_claude_assets": {
    "skills": [...22개 스킬...],
    "agents": [...8개 에이전트...],
    "teams": [...13 도메인...]
  },
  "confidence": "very_high"
}
```

### Phase 2: Mapping (특수 — 마이그레이션 모드)
**마이그레이션 모드**는 일반 매칭과 다름:
- 새 자산 추가 X (이미 있음)
- **기존 자산 ↔ CGE 자산 매핑 표 작성**

#### 매핑 표 (예상)

| ProjectFIB 자산 | CGE 매칭 | 처리 |
|-----------------|----------|------|
| `.claude/skills/harness-audit` | `engineerings/harness/skills/harness-audit` | ID 일치 → **유지** (CGE 버전이 더 최신이면 교체) |
| `.claude/skills/harness-evolve` | 동일 | 유지 |
| `.claude/skills/agent-router` | 동일 | 유지 |
| `.claude/skills/session-log` | 동일 | 유지 |
| `.claude/skills/skill-*` (메타 6) | 동일 | 유지 |
| `.claude/skills/_template.md` | `core/templates/skill-_template.md` | **이동** (`.claude/skills/_template.md` 제거 → 템플릿은 core/) |
| `.claude/skills/{combat,gas,inventory,ui,unreal-build,unreal-engine}-helper` | `packs/unreal/skills/` | unreal-pack 활성 시 자동 일치 |
| `.claude/skills/{gap-analysis,phase-review,progress-check,next-task,game-design-core}` | `packs/game-dev/skills/` | game-dev-pack 활성 시 자동 일치 |
| `.claude/skills/harness-bootstrap` | (없음) | **N/A** (cge-bootstrap이 그 역할) |
| `.claude/agents/{design,security,stress}-*` | `engineerings/harness/agents/` | 유지 |
| `.claude/agents/{gas-ability,interaction,ue-perf,unreal-architect,balance}-*` | `packs/unreal/agents/` | 유지 |
| `.claude/team/_patterns.md, _retry_policy.md, _evolve_policy.md, _token_policy.md` | `engineerings/harness/policies/` | 유지 (이미 같음) |
| `.claude/team/teammaker/` | `engineerings/harness/teams/teammaker/` | 유지 |
| `.claude/team/{13 도메인}/README.md` | `packs/game-dev/team-templates/<도메인>-README.md` | 변수 미치환 상태 → 그대로 유지 (변수는 신규 부착 시만 의미) |
| `.claude/team/{13 도메인}/<도메인>_*.md` (단계 에이전트) | (CGE에 없음) | **유지** — 프로젝트 고유 자산 |
| `.claude/team/<도메인>/HISTORY.md` | (CGE에 없음) | **유지** — 활동 데이터 |
| `.claude/HARNESS.md` | `core/templates/HARNESS.md.template` | 사용자 편집된 상태 → **유지** (template은 신규 부착용) |
| `.claude/CLAUDE.md` | `core/templates/CLAUDE.md.template` | 동일 |
| `.claude/settings.local.json` | `core/templates/settings.local.json.template` | 동일 |
| `.claude/hooks/post_edit_alert.ps1` | `core/hooks/post_edit_alert.ps1` | **이동·일반화** — 매핑은 unreal-pack의 post-edit-map.json 사용 |
| `.claude/_project_profile.json` | (생성) | **신규 작성** — Phase 4에서 |

### Phase 3: Synthesis (마이그레이션 제안서)
```markdown
# CGE Migration Proposal — ProjectFIB

## 현재 상태
- 자산 130+ 파일 (CGE 미부착)
- harness 엔지니어링 자산 이미 90% 호환

## 매핑 결과
- 자동 매핑: 35건
- 사용자 결정 필요: 5건
- 신규 추가 (CGE 코어): 13건 (cge-* 스킬 + project-analyst 등 메타-에이전트)
- 제거 권장: 0건 (모두 보존)

## 사용자 결정 필요
1. `.claude/skills/_template.md` → core/로 이동 (`.claude/`에서 제거)? [Y/N]
2. `.claude/hooks/post_edit_alert.ps1`을 core 일반화 버전으로 교체? [Y/N]
3. `.claude/HARNESS.md` 사용자 편집 보존 (CGE 템플릿 무시)? [Y/N]
4. 13 도메인 README의 변수(${MAX_RETRY} 등) → 실제 값으로 치환? [Y/N]
5. settings.local.json: 기존 권한 + CGE 권장 권한 병합? [Y/N]

## 신규 추가 (CGE 코어)
- core/skills/cge-{bootstrap,rebootstrap,install,uninstall,replace,list,mine-pattern,sync-lessons}
- core/agents/{project-analyst,engineering-selector,pack-matcher,conflict-resolver,installer}
- 위 자산들이 .claude/skills/, .claude/agents/에 추가됨

## 정책 매개변수 (이미 일치)
- max_retry: 2 ✓
- max_thinking_tokens: 10000 ✓
- 모델 비율: 일치 ✓

## 활성 자산 (예상)
- Engineerings: harness@1.0
- Packs: unreal@1.0, game-dev@1.0
- Skills: 30+ (기존 22 + CGE 코어 8)
- Agents: 13 (기존 8 + CGE 메타 5)

## Approve? [Y/N]
```

### Phase 4: Activation (마이그레이션 모드)

`installer`의 마이그레이션 모드:

1. **풀 백업**: `.claude_pre-cge-backup/` 외에 추가 `.claude/_backup/<timestamp>/`
2. **신규 자산만 추가**: cge-* 스킬 + 메타-에이전트 5명
3. **기존 자산 유지**: 호환되는 모든 자산 (HISTORY.md 데이터 보존)
4. **사용자 결정 적용**: Phase 3에서 받은 답에 따라
5. **`_project_profile.json` 생성**: 기존 자산 모두 등록
6. **Change Log 갱신**: "CGE 마이그레이션" 1행
7. **harness-audit 실행**: 마이그레이션 후 정합성 검증

### Phase 5: 검증 (마이그레이션 전용 추가 단계)

마이그레이션 후 추가 검증:
- 기존 도메인 팀이 정상 호출되는가? (combat 팀 dry-run)
- harness-evolve가 기존 HISTORY.md 읽을 수 있는가?
- agent-router가 specialist 8명 모두 인식하는가?
- PostToolUse 훅이 unreal-pack 매핑으로 동작하는가?

---

## 위험과 대응

| 위험 | 대응 |
|------|------|
| 사용자 편집된 정책이 CGE 정책과 다름 | Phase 3에서 사용자 결정 — 사용자 편집 우선 |
| HISTORY.md 데이터 손상 | 백업 + 마이그레이션 모드는 HISTORY 절대 수정 X |
| 트리거 키워드 충돌 (cge-* 신규 vs 기존) | skill-validate V7 실행 후 충돌 발견 시 사용자 결정 |
| 깊이 ≤2 위반 새로 발생 | harness-audit이 Phase 5에서 검출 |
| 130+ 파일 매핑 누락 | 매핑 표 자동 생성 + 미매칭 항목 사용자 보고 |

---

## 롤백 절차

마이그레이션 실패 또는 문제 발생 시:

```bash
# 1. CGE 비활성화
/cge uninstall engineering harness   (가능?) — 또는 직접 디렉토리 복원

# 2. 풀 백업 복원
rm -rf .claude/
cp -r .claude_pre-cge-backup/ .claude/

# 3. 동작 확인
/harness-audit (기존 동작 확인)
```

---

## 마이그레이션 적기

다음 조건 충족 시 안전:
1. ✅ CGE v1.0.0 정식 릴리스 (현재 v1.0.0-alpha)
2. ✅ 더미 프로젝트 검증 통과 (W12 완료)
3. ✅ ProjectFIB 측 자체 audit 통과 (현재 OK)
4. ⏳ CGE의 자기 검증 보강 (Phase 5 마이그레이션 검증 절차 명문화 필요)
5. ⏳ 다른 프로젝트 1+개에서 CGE 부착 검증 (현재 0)

**권장 시점**: CGE를 GitHub에 push 후 → 다른 프로젝트(빈 또는 단순)에 1차 부착 → 안정성 확인 후 → ProjectFIB 마이그레이션.

---

## 예상 효과

마이그레이션 후 ProjectFIB이 얻는 것:
- **모든 새 프로젝트와 같은 인터페이스**: `/cge install`, `/cge list` 등 사용
- **신규 엔지니어링·팩 즉시 활용**: 향후 `/cge install pack web`으로 보너스 도메인 추가
- **메타-메타 학습 참여**: ProjectFIB의 노하우가 `_meta/lessons.md`로 흘러 다른 프로젝트 도움
- **드리프트 자동 추적**: `_project_profile.json`이 활성 자산 단일 진실 제공

---

## 관련

- [`projectfib.md`](projectfib.md) — ProjectFIB 케이스 스터디 (분리 전)
- [`docs/lifecycle.md`](../lifecycle.md) — 일반 install/uninstall/replace
- [`core/agents/installer.md`](../../core/agents/installer.md) — 마이그레이션 모드 구현 위치
