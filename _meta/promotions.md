# CGE Promotions

`_user/` → 정식 `engineerings/` 또는 `packs/` 승격 이력.

> 사용자 자작 자산이 3+ 프로젝트에서 검증되면 정식 슬롯으로 승격.
> 본 파일은 그 이력을 추적.

---

## 등록 형식

```markdown
### <id> @ <date>
- **종류**: engineering | pack
- **출처**: _user/<id> 또는 직접 제출
- **검증 프로젝트 수**: <count>
- **검증 기간**: <start>~<end>
- **승격 결정자**: <maintainer-or-self>
- **변경 사항**: 정식 승격 시 어떤 수정 발생했나
- **노트**:
```

---

## 승격 이력

(아직 승격된 자산이 없습니다 — v1.0.0-alpha)

---

## 첫 케이스 (v1.0.0): harness 엔지니어링

이번 v1.0.0의 `engineerings/harness/`는 **승격이 아니라 초기 이식**:
- 출처: ProjectFIB의 누적 자산
- "승격" 개념은 v1.0.0 이후 신규 자산에 적용
- 본 사례는 [docs/case-studies/projectfib.md](../docs/case-studies/projectfib.md) 참조

---

## 승격 절차

1. **후보 식별**:
   - `cge-sync-lessons`가 3+ 프로젝트에서 같은 `_user/` 자산 발견
   - 또는 사용자 명시 PR

2. **검증**:
   - 자산 매니페스트 표준 준수
   - 트리거 충돌 0건
   - 의존성 명확
   - 문서 (README + What/Why/When/How)

3. **승격**:
   - `_user/` → 정식 `engineerings/` 또는 `packs/`로 이동
   - `engineering.json`/`pack.json` 정식 메타데이터로 갱신
   - CHANGELOG 항목 추가

4. **알림**:
   - 본 파일에 행 추가
   - `_meta/HISTORY.md`에 본체 변경 기록
   - 다음 부착부터 자동 권장 가능

---

## 거꾸로: 정식 → deprecated

3+ 프로젝트에서 6개월간 사용 0회 자산은:
- `_meta/HISTORY.md`에 deprecated 표기
- v 다음 메이저 릴리스에서 제거 또는 `_user/` 강등 가능

이 절차는 본 파일 하단에 "Demoted" 섹션으로 기록 (현재 비어있음).
