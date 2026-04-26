# Meta-Agent Philosophy

CGE의 핵심 가치 명제와 그 근거.

## 1. 정적 vs 적응

기존 하네스(Harness, Archon, ECC)는 **고정 자산**을 제공. 부착 시 그대로 활성화.

CGE는 **메타-에이전트**. 부착 시 프로젝트를 읽고 자기 자신을 재구성.

## 2. 왜 메타-에이전트인가

같은 회사 안의 두 프로젝트도 다르다:
- Project A: UE5 + 협동 호러 → game-dev + unreal 활성
- Project B: TS + Express → web-pack 후보 (없으면 신규 생성)

정적 패키지는 둘 다에 같은 자산 강제 → 한쪽엔 무용, 한쪽엔 부족.

메타-에이전트는 **읽고 결정**:
- 무엇을 활성?
- 무엇을 비활성?
- 무엇이 누락? → 사용자 노하우 후보 큐

## 3. 핵심 4 원칙

### P-1: Engineering as Plugin Slot
엔지니어링 방식(harness, ECC, archon, _user)은 `engineerings/<id>/` 격리.
코어는 어떤 방식도 강제 X.

### P-2: Core는 엔지니어링 무관
Core가 하는 일:
- Bootstrap (프로젝트 분석)
- Selector (어느 엔지니어링 활성?)
- Pack Matcher (어느 팩 활성?)
- Lifecycle (install/uninstall/replace)
- 메타-메타 학습

### P-3: 추가/제거의 균등성
모든 자산이 같은 인터페이스:
```
/cge install <type> <id>
/cge uninstall <type> <id>
/cge replace <type> <id>@<old> with <id>@<new>
```

### P-4: Profile은 진실의 원천
`.claude/_project_profile.json` = 활성 자산 단일 진실.
Drift 발생 시 이 파일과 실제 디렉토리 비교.

## 4. 메타-에이전트 5명

| # | 에이전트 | 역할 |
|---|----------|------|
| 1 | project-analyst | 기획·문서 정독 → 프로파일 |
| 2 | engineering-selector | 어느 엔지니어링 활성? |
| 3 | pack-matcher | 어느 팩 활성? |
| 4 | conflict-resolver | 충돌 해결 |
| 5 | installer | 실제 부착·제거 실행 |

## 5. 5-Phase Bootstrap

```
Phase 0: Discovery  → 디렉토리·매니페스트·문서 자동 감지
Phase 1: Analysis   → project-analyst가 정독
Phase 2: Mapping    → engineering-selector + pack-matcher
Phase 3: Synthesis  → 사용자에게 제안서
Phase 4: Activation → installer가 실제 부착
```

[adaptive-bootstrap.md](adaptive-bootstrap.md) 참조.

## 6. 자기 진화 루프

```
프로젝트 사용 → HISTORY.md 누적
    ↓ 5회 활동 마일스톤
harness-evolve → 단일 프로젝트 진화 후보
    ↓ 다중 프로젝트
cge-mine-pattern → 신규 엔지니어링·팩 후보
    ↓ 3+ 프로젝트 공통 패턴
cge-sync-lessons → 본체 _meta/lessons.md 갱신
    ↓
정식 engineerings/ 또는 packs/ 승격
```

부착할수록 사용자 노하우 누적 → 다음 프로젝트가 빠름.

## 7. 한계

- **빈 프로젝트**: Phase 1 분석할 문서 없음 → core만 활성 + 사용자 입력 요청
- **첫 5회**: 데이터 부족 → 진화 메커니즘 미작동
- **컨텍스트 비용**: Phase 1의 LLM 정독은 토큰 사용 — 부착은 1회성이라 정당화

## 8. ECC·Harness와의 차이

| 항목 | Harness | ECC | CGE |
|------|---------|-----|-----|
| 자산 형태 | 고정 6 패턴 | 48 agents + 183 skills | Core + 슬롯 |
| 활성 결정 | 사용자 명시 | 사용자 명시 | **메타-에이전트 자동** |
| 추가/제거 | git pull | npm install | **lifecycle 명령** |
| 노하우 누적 | X | 부분 (lessons) | **mine-pattern + sync-lessons** |
| 다중 엔지니어링 | 단일 | 단일 | **슬롯 모듈** |

## 9. 한 줄

> CGE는 **하네스 엔지니어링의 패키지**가 아니라, **각 프로젝트를 읽고 자기 자신을 재구성하는 메타-에이전트**다.
> 하네스 엔지니어링은 그 안의 첫 번째 탑재 슬롯일 뿐.
