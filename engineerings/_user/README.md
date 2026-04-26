# `_user/` — 사용자 자작 엔지니어링

본 디렉토리는 **사용자가 자기 환경에 맞게 만든 엔지니어링**을 격리하는 영역.

## 왜 격리하나

- 본체 자산과 충돌·오염 방지
- git pull 시 자기 자산 보존
- 3+ 프로젝트에서 사용 시 정식 `engineerings/`로 승격 후보

## 작성 절차

1. `engineerings/_user/<my-id>/` 디렉토리 생성
2. [`../../core/policies/_engineering_slot_spec.md`](../../core/policies/_engineering_slot_spec.md) 스펙 따라 `engineering.json` 작성
3. 자산(skills/agents/policies/teams) 추가
4. `README.md`에 What/Why/When/How 작성

## 활성화

자기 프로젝트에서:
```
/cge install engineering _user/<my-id>
```

## 정식 승격

3+ 프로젝트에서 검증되고 다른 사용자도 가치 있다면:
- PR로 정식 `engineerings/<id>/`로 이동
- `_meta/promotions.md`에 승격 이력 등록

## 가이드

- [`docs/engineering-slot-guide.md`](../../docs/engineering-slot-guide.md) — 새 엔지니어링 추가 절차
- [`docs/extending.md`](../../docs/extending.md) — 사용자 확장 가이드
