# CGE Lessons (Meta-Meta Learning)

여러 프로젝트의 패턴이 합류하면서 본체에 흡수된 교훈. `cge-sync-lessons`가 갱신.

> 단일 프로젝트의 lessons은 그 프로젝트의 `.claude/team/*/HISTORY.md`로.
> 여기는 **3+ 프로젝트가 같은 패턴**일 때 본체에 정착하는 메타-메타 교훈.

---

## 누적 교훈

### Lesson L-001: 도메인 정의 모호 시 harness 효과 약화 (1 프로젝트, 검증 필요)
- **발견**: ProjectFIB
- **내용**: "AI 시스템" 같이 너무 광범위한 도메인은 패턴 적용 모호
- **권고**: 도메인을 더 작게 분해 (combat / encounter / spawn / behavior)
- **검증 필요**: 다른 프로젝트에서 동일 발견 시 정식 정책으로 승격

### Lesson L-002: ≤500줄 정책 효과 (1 프로젝트)
- **발견**: ProjectFIB ui-helper 1482→298줄 분리
- **내용**: SKILL.md 본문 압축 + references 분리 → 트리거 시 토큰 80% 절감
- **권고**: `_template.md`에 ≤500줄 강제, harness-audit B 카테고리에 검사
- **상태**: 정식 정책 (`_template.md` + harness-audit)

### Lesson L-003: PostToolUse 알림 verbosity (1 프로젝트, 검증 필요)
- **발견**: ProjectFIB
- **내용**: 매 편집마다 알림 → 사용자 피로
- **권고**: verbosity 정책 (조용/표준/상세)
- **검증 필요**: 3+ 프로젝트가 같은 의견 시 본체 갱신

---

## 정식 승격 후보

### 후보 P-001: 빈 (현재 단일 프로젝트만)
- 3+ 프로젝트 누적 시 정식 정책으로 승격
- `_meta/promotions.md`로 이동

---

## 갱신 규칙

- `cge-sync-lessons` 실행 시 단일 프로젝트의 history → 본체 흡수 후보
- 같은 교훈이 3+ 프로젝트에서 발견되면 자동 승격 후보로 분류
- 사용자 승인 시 정식 정책에 반영 → `_meta/promotions.md`에 승격 이력 기록
