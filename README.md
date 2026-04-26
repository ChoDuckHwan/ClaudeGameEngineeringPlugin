# Claude Game Engineering Plugin (CGE)

> 각 프로젝트를 읽고 자기 자신을 재구성하는 **메타-에이전트** 플러그인.
> 하네스 엔지니어링은 그 안의 **첫 번째 탑재 엔지니어링 슬롯**일 뿐이다.

[English](README_EN.md) · 한국어

---

## 무엇이 다른가

기존 하네스 플러그인(Harness, ECC, Archon)은 **고정된 워크플로우·자산**을 제공한다. CGE는 다르다:

1. **부착 시 프로젝트를 분석** — 디렉토리·문서·git을 읽어 프로젝트 종류·도메인·우선순위 파악
2. **엔지니어링 방식을 슬롯으로 모듈화** — `engineerings/<name>/` 단위로 격리, 추가·제거·교체 가능
3. **사용자 노하우 누적** — 사용할수록 패턴 추출 → 신규 엔지니어링 후보 자동 발굴
4. **Claude Code 플러그인 표준** 준수 — `/plugin install` 호환

## 구조 한눈에

```
core/         — 메타-에이전트 (엔지니어링 무관)
engineerings/ — 엔지니어링 슬롯 (harness, ecc, archon, _user/...)
packs/        — 도메인 팩 (unreal, game-dev, web, python, ...)
docs/         — 철학·5 Phase·확장법
_meta/        — 플러그인 자체 학습 루프
```

## 빠른 시작

```bash
# 1. 플러그인 설치 (Claude Code marketplace)
/plugin install ClaudeGameEngineeringPlugin@ChoDuckHwan

# 2. 프로젝트에 부착 (자동 5 Phase Bootstrap 발동)
/cge bootstrap

# 3. 활성 자산 확인
/cge list
```

## 5 Phase Bootstrap

```
Phase 0: Discovery     → 디렉토리·매니페스트·문서 자동 감지
Phase 1: Analysis      → project-analyst가 기획 정독 → 프로파일
Phase 2: Mapping       → 엔지니어링·팩 활성화 결정
Phase 3: Synthesis     → 사용자에게 제안서 + 검토
Phase 4: Activation    → 승인 받은 자산만 .claude/에 부착
```

## Lifecycle 명령

```bash
/cge install engineering harness
/cge install pack unreal
/cge install skill <git-url>
/cge uninstall engineering harness
/cge replace engineering harness@1.0 with harness@2.0
/cge list
/cge mine-pattern         # 사용자 작업 패턴 → 신규 엔지니어링 후보
/cge sync-lessons         # 메타-메타 학습 (다른 프로젝트 노하우 흡수)
```

## 첫 탑재 엔지니어링: harness

ProjectFIB(UE5 협동 호러 게임)에서 추출한 자산. 6 디자인 패턴(Pipeline / Fan-out·Fan-in / Expert Pool / Producer-Reviewer / Supervisor / Hierarchical Delegation), Producer-Reviewer 재시도 캡, 자가개선 정책, 토큰 최적화 정책 포함.

상세: [engineerings/harness/README.md](engineerings/harness/README.md)

## 라이선스

MIT (revfactory/harness 패턴 흡수분은 Apache 2.0 표시)

## 기여

새 엔지니어링·팩 PR 환영. [docs/engineering-slot-guide.md](docs/engineering-slot-guide.md) 참조.
