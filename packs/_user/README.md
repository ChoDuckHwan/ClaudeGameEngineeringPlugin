# `_user/` — 사용자 자작 팩

본 디렉토리는 **사용자가 자기 도메인에 맞게 만든 팩**을 격리하는 영역.

## 왜 격리하나

- 본체 팩과 충돌·오염 방지
- git pull 시 자기 자산 보존
- 3+ 프로젝트에서 사용 시 정식 `packs/`로 승격 후보

## 작성 절차

1. `packs/_user/<my-id>/` 디렉토리 생성
2. [`../../core/policies/_pack_slot_spec.md`](../../core/policies/_pack_slot_spec.md) 스펙 따라 `pack.json` + `activation_criteria.json` 작성
3. 자산 (skills/agents/team-templates/post-edit-map) 추가
4. `README.md` 작성

## 활성화

자기 프로젝트에서:
```
/cge install pack _user/<my-id>
```

또는 `cge-bootstrap` 시 자동 매칭 후보로 등록 (activation_criteria 점수 ≥80%).

## 정식 승격

같은 도메인 후보가 `_meta/pack-requests.md`에 3+ 누적되면 승격 후보:
- PR로 정식 `packs/<id>/`로 이동
- `_meta/promotions.md`에 이력 등록

## 가이드

- [`docs/pack-authoring.md`](../../docs/pack-authoring.md) — 새 팩 작성 절차
- [`docs/extending.md`](../../docs/extending.md) — 사용자 확장 가이드

## 예상 후보 (사용자 시나리오)

자주 만들어지는 팩 종류:
- `web-frontend` (React/Next/Vue + TypeScript)
- `web-backend` (Express/FastAPI/Django)
- `python-ml` (PyTorch/TensorFlow + Jupyter)
- `mobile` (React Native/Flutter)
- `llm-app` (Anthropic SDK/LangChain)
- `cli-tool` (단일 binary 도구)
- `library-author` (npm/pip/cargo 라이브러리 개발)
