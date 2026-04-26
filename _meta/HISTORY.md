# CGE Plugin History

플러그인 자체의 활동 이력. 각 프로젝트의 `.claude/CLAUDE.md ## Change Log`와 별개 — 여기는 **플러그인 본체**의 이력.

---

## 2026-04-26 — Initial Skeleton (v1.0.0-alpha)

ProjectFIB Tier 1+2+후속 작업 산출물에서 추출 분리.

### 추가
- core/ (8 skills + 5 agents + 3 policies + 4 signals + 6 hooks + 5 templates)
- engineerings/harness/ (10 skills + 3 agents + 4 policies + teammaker 9 + 4 docs)
- packs/unreal/ (6 skills + 5 agents + manifest + activation + post-edit-map)
- packs/game-dev/ (5 skills + 13 team templates + manifest)
- docs/ (8 문서: meta-agent-philosophy, adaptive-bootstrap, engineering-slot-guide, pack-authoring, lifecycle, ecosystem-comparison, extending, case-studies/projectfib)

### 결정
- 3-Layer 분할 (Core ↔ Engineering ↔ Pack)
- 메타-에이전트 우선 (cge-bootstrap 5 Phase)
- Engineering as Slot (P-1)
- 추가/제거 균등성 (P-3) — 모든 자산 같은 lifecycle 인터페이스
- ProjectFIB가 첫 케이스 스터디

### 다음
- ~W11: .claude-plugin/plugin.json~ ✅ 완료
- W12 전 수정 ✅ 완료 — `_user/` 격리 디렉토리 + CONTRIBUTING.md + plugin.json 보완
- W12: 더미 프로젝트 검증
- W13: ProjectFIB 마이그레이션 가이드
- W14: git push to https://github.com/ChoDuckHwan/ClaudeGameEngineeringPlugin

---

## 2026-04-26 (post W11) — W12 전 검토 보완

### Added
- `engineerings/_user/README.md` — 사용자 자작 엔지니어링 격리
- `packs/_user/README.md` — 사용자 자작 팩 격리 + 인기 후보 도메인 가이드
- `CONTRIBUTING.md` — 기여 7 종 + PR 형식 + 명명 규칙

### Changed
- `plugin.json` schema URL → `$schema_note`로 변경 (v2 공식 스펙 확정 전)
- `plugin.json` components에 `_user/` 디렉토리 등록
- `plugin.json` contributing/changelog 필드 추가

---

## 갱신 규칙

- 본체 자산 추가/삭제/변경 시 1행 추가
- 사유 명시 (변경의 동기)
- 누적 50행 초과 시 상단 25행 → `_meta/HISTORY_archive.md`로 회전
