# Engineering Requests

사용자가 요청한 신규 엔지니어링 후보 큐. `cge-mine-pattern`이 발굴 또는 사용자 명시 등록.

> 엔지니어링은 팩보다 큰 단위 — 협업 방식 자체가 새로워야 등록 가치.
> 단순히 새 도메인이면 `pack-requests.md`로.

---

## 등록 형식

```markdown
### <engineering-id-candidate>
- **요청 출처**: <project-name> (또는 익명)
- **차별점**: <기존 엔지니어링과 다른 핵심 메커니즘>
- **유사 요청 수**: <count>
- **요청 시점**: <date>
- **상태**: queued | promoted | rejected
- **노트**: <comment>
```

---

## 큐

(아직 요청된 엔지니어링이 없습니다)

---

## 정식 엔지니어링 승격 기준

1. **본질적 차별**: 기존 엔지니어링과 협업 방식 자체가 다름 (단순 매개변수 차이는 X)
2. **3+ 프로젝트** 또는 강한 단일 케이스 (예: 산업 표준 부상)
3. **`exclusive_with`/공존 가능성 명확**
4. **자산 분량 충분** (최소 4 skills + 2 agents + 2 policies)

---

## 가설 후보 (외부 영감 기반)

이미 관측되는 엔지니어링 패턴들 — 슬롯 후보:

| 후보 | 출처 영감 | 차별점 |
|------|-----------|--------|
| `ecc` | affaan-m/everything-claude-code | Cross-runtime (Codex/Cursor 동시 지원) |
| `archon` | coleam00/Archon | 결정론적 런타임 설정 |
| `tdd-strict` | TDD 커뮤니티 | Red→Green→Refactor 강제 + pre-commit 게이트 |
| `agile-scrum` | 스크럼 방법론 | 스프린트·백로그·데일리 자산화 |
| `domain-driven-design` | DDD | Bounded Context·Aggregate 자산화 |
| `functional-core-imperative-shell` | Gary Bernhardt | 함수형 코어 + 명령형 셸 패턴 |

이 중 일부는 미래 v1.x에서 구현 가능. 사용자 요청 누적되면 우선순위 결정.

---

## 사용자 자작 → 정식 승격 흐름

```
사용자가 _user/<id>/ 작성
    ↓
다른 프로젝트에서도 사용
    ↓
3+ 프로젝트 누적 (cge-sync-lessons로 감지)
    ↓
_meta/promotions.md에 후보 등록
    ↓
PR 또는 메인테이너 검토
    ↓
정식 engineerings/<id>/로 이동
```
