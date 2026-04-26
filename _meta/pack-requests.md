# Pack Requests

사용자 프로젝트에서 감지됐지만 매칭 팩이 없는 도메인 큐. 정식 팩 작성 우선순위 결정용.

> `cge-bootstrap` Phase 2의 `pack-matcher`가 `missing_domains_queue` 자동 등록.
> `cge-mine-pattern`이 사용자 작업 패턴에서 후보 발굴.

---

## 등록 형식

```markdown
### <pack-id-candidate>
- **요청 출처**: <project-name> (또는 익명)
- **감지 시그널**: <signals>
- **유사 프로젝트 수**: <count>
- **요청 시점**: <date>
- **상태**: queued | promoted | rejected
- **노트**: <comment>
```

---

## 큐

(아직 요청된 팩이 없습니다)

<!-- 첫 부착 시 자동 등록 또는 cge-mine-pattern 결과 -->

---

## 정식 팩 승격 기준

다음 조건 충족 시 `_meta/promotions.md`로 승격 후보:
1. 같은 도메인 후보 **3+ 프로젝트**에서 등록
2. 시그널 명확 (활성 조건 점수 매김 가능)
3. 자산 작성 가능성 검증 (skills + agents 분량)

승격되면 `packs/<id>/` 디렉토리에 정식 추가 + 본체 CHANGELOG 갱신.

---

## 인기 후보 (가설 — 실측 누적 후 갱신)

| 도메인 | 가설 우선순위 | 비고 |
|--------|---------------|------|
| web (TS+React/Next) | 🔴 High | 사용 빈도 가장 높을 것으로 추정 |
| python (FastAPI/Django) | 🟠 Med-High | 백엔드 개발 |
| ml (PyTorch/TF) | 🟡 Med | 데이터 파이프라인 |
| mobile (React Native/Flutter) | 🟡 Med | |
| llm-app (Anthropic/OpenAI SDK) | 🟢 Med | 메타 도메인 — claude-api 스킬 활용 |
| game-godot | 🟢 Low | 대안 게임 엔진 |
| systems (Rust/C++) | 🟢 Low | 시스템 프로그래밍 |
