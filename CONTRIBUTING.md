# Contributing to ClaudeGameEngineeringPlugin

CGE에 기여하는 모든 방법.

## 기여 종류

| 종류 | 영향 범위 | 비용 |
|------|-----------|------|
| 버그 리포트 | — | 매우 낮음 |
| 문서 개선 | 모든 사용자 | 낮음 |
| 새 시그널 추가 | Phase 0 정확도 | 중 |
| 새 정책 매개변수 | 활성 엔지니어링 | 중 |
| 새 팩 (`packs/_user/<id>/` → 정식) | 도메인 사용자 | 큼 |
| 새 엔지니어링 (`engineerings/_user/<id>/` → 정식) | 모든 사용자 | 매우 큼 |
| 본체 코어 수정 | 모든 사용자 | 신중 검토 |

## 시작하기

```bash
git clone https://github.com/ChoDuckHwan/ClaudeGameEngineeringPlugin.git
cd ClaudeGameEngineeringPlugin
```

## 단계별 기여

### 1. 버그 리포트
- GitHub Issues에 등록
- 재현 절차 + 환경 (Claude Code 버전, OS, 부착 프로젝트 종류)
- `_project_profile.json` 첨부 (가능하면)

### 2. 문서 개선
- `docs/` 또는 자산별 README.md 수정
- PR로 제출
- 가능한 한 한국어 + 영어 양쪽 보강

### 3. 새 시그널
- `core/signals/*.json` 추가/수정
- 같은 패턴의 시그널이 여러 프로젝트에서 검증됐는지 확인
- 영향 받는 자산(activation_criteria) 동시 갱신

### 4. 새 팩
- 절차: [`docs/pack-authoring.md`](docs/pack-authoring.md)
- `packs/_user/<id>/`에 작성 후 자기 프로젝트로 검증
- 3+ 프로젝트 검증 시 정식 승격 PR

### 5. 새 엔지니어링
- 절차: [`docs/engineering-slot-guide.md`](docs/engineering-slot-guide.md)
- 기존 엔지니어링과 **본질적으로 다른 협업 방식**이어야 함
- 단순 매개변수 차이는 정책 갱신으로 충분 — 신규 엔지니어링 X

### 6. 본체 코어 수정
- `core/` 변경은 **모든 사용자에게 영향**
- 신중한 검토 필요 — 메인테이너와 사전 논의 권장
- Breaking change 시 메이저 버전업

## PR 가이드라인

### 필수 체크
- [ ] 매니페스트 스키마 일치 (engineering.json/pack.json)
- [ ] 자산 트리거 키워드 충돌 0건 (skill-validate V7 통과)
- [ ] README 4섹션 (What/Why/When/How)
- [ ] CHANGELOG.md 항목 추가
- [ ] 한국어 + 영어 핵심 문서 보강 (가능 시)

### PR 제목 형식
```
[<type>] <scope>: <summary>

types: feat, fix, docs, refactor, chore
scope: core, harness, pack:<id>, engineering:<id>, docs
```

예시:
- `[feat] pack:web: 신규 웹 팩 추가 (TS+React 자산군)`
- `[docs] adaptive-bootstrap: Phase 1 정독 절차 보강`
- `[fix] core/agents/installer: 백업 디렉토리 권한 문제`

### 커밋 메시지
- 한국어 또는 영어 자유
- 첫 줄 ≤72자
- 본문에 변경 동기 (Why) 필수

## 자산 명명 규칙

| 자산 | 규칙 | 예 |
|------|------|-----|
| Skill ID | kebab-case | `harness-audit`, `cge-bootstrap` |
| Agent ID | kebab-case | `project-analyst`, `installer` |
| Engineering ID | kebab-case | `harness`, `tdd-strict` |
| Pack ID | kebab-case | `unreal`, `web-frontend` |
| Policy 파일 | `_<name>.md` | `_patterns.md`, `_retry_policy.md` |
| Hook 파일 | `<verb>_<noun>.{ps1,sh}` | `check_handoff.ps1` |

## 충돌 해결

`_meta/promotions.md`에서 같은 ID로 여러 사용자가 PR 시:
1. 메인테이너가 차이점 검토
2. 더 일반화된 버전 우선
3. 다른 ID로 분리 권유 또는 통합 제안

## 라이선스

본 프로젝트는 MIT 라이선스. 기여 시 자동으로 같은 라이선스로 공개.

흡수한 외부 작업 (Apache 2.0 등)은 [`LICENSE`](LICENSE)의 ATTRIBUTIONS 섹션 참조.

## 코드·문서 스타일

### 마크다운
- 본문 한국어 우선 (한국어 원본 프로젝트)
- 영어 README/INSTALL 동시 유지
- 표·코드블록 자유 사용
- 이모지: 시각적 가이드(✅⚠️❌🔴🟡🟢)만, 장식 X

### JSON
- 스키마 변경 시 `$schema` 필드에 의도 명시
- 4 space indent
- 키 순서: id → name → version → description → 메타 → provides → 기타

### 정책 문서
- "What/Why/When/How" 섹션 권장
- 표로 결정 트리 표현 (산문보다)
- 예시 코드 포함 (이론만 X)

## 행동 강령

- 건설적 피드백
- 다른 기여자 존중
- 비기술적 갈등 시 메인테이너 중재 요청

## 메인테이너

- @ChoDuckHwan (origin)

PR/Issue 응답은 best-effort. 1주 응답 없으면 알림 첨부 ping 환영.

## 다음

- [`docs/extending.md`](docs/extending.md) — 사용자 확장 종합
- [`docs/engineering-slot-guide.md`](docs/engineering-slot-guide.md)
- [`docs/pack-authoring.md`](docs/pack-authoring.md)
- [`_meta/promotions.md`](_meta/promotions.md) — 승격 이력
