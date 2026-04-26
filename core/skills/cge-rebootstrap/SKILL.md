---
name: cge-rebootstrap
description: "이미 CGE가 부착된 프로젝트가 변화했을 때(언어 추가, 새 도메인, 프레임워크 변경) 프로파일을 갱신하고 활성 자산을 재구성한다. drift 검출 + 변경 사용자 승인 모드. 사용자가 'rebootstrap', '재부착', '프로젝트 변화 반영', 'CGE 갱신', 'profile 재생성'을 언급할 때 활성화."
---

# CGE Rebootstrap — 변화 반영 재실행

이미 CGE가 부착된 프로젝트의 **변화를 감지하고 활성 자산을 갱신**.

## 트리거

- "/cge rebootstrap"
- "프로젝트 변화 반영해줘"
- "프로파일 갱신"
- "새 도메인 추가됐어, 다시 분석해줘"

## Should-NOT-Trigger

| 입력 | 기대 호출 |
|------|-----------|
| "처음 부착" | cge-bootstrap |
| "특정 자산만 추가" | cge-install |

## 절차

### Step 1: 기존 프로파일 로드

`.claude/_project_profile.json` 읽기. 없으면 → cge-bootstrap 권장 후 종료.

### Step 2: 새 Discovery 실행 (Phase 0 재실행)

`core/signals/*.json` 기반 재스캔.

### Step 3: Drift 검출

기존 프로파일 vs 새 Discovery 결과 비교:
- **새 언어 추가** (예: TypeScript 신규)
- **새 프레임워크** (예: React 도입)
- **새 도메인 디렉토리**
- **사라진 도메인** (디렉토리 삭제)
- **문서 갱신** (PRD 변경, 새 GDD)

### Step 4: 변화 평가

각 drift에 대해:
- 새 팩 활성 권장 가능?
- 비활성 권장 가능 (삭제된 도메인)?
- 정책 매개변수 조정 필요?

### Step 5: 사용자 승인

```markdown
# 🔄 Rebootstrap Drift Report

## 새로 감지된 시그널
- TypeScript 파일 50개 추가 → web-pack 활성 후보
- 새 디렉토리 `src/payment/` → payment-team 후보 (팩 없음 — 큐 등록)

## 사라진 시그널
- (없음)

## 권장 변경
- ➕ web-pack 활성? Y/N
- 📝 _meta/pack-requests.md에 payment-team 등록? Y/N

## 정책 조정
- 다국어 코드베이스 → MAX_THINKING 8000 → 10000 권장
```

### Step 6: 적용

`installer` 에이전트로 변경분만 적용 (전체 재부착 X).

### Step 7: 프로파일 갱신

`last_rebootstrap` 타임스탬프 + 변경 이력 누적.

## Examples

### 예시: 게임 프로젝트가 웹 대시보드 추가
```
기존: project_type=game, packs=[unreal, game-dev]

신규 시그널:
- web/ 디렉토리 추가
- package.json 발견
- Next.js 의존성

권장:
- ➕ web-pack 활성 (없으면 _meta/pack-requests.md)
- subtype: "game" → "game-with-web-companion"
```

## 관련

- [`cge-bootstrap`](../cge-bootstrap/SKILL.md) — 첫 부착
- [`cge-list`](../cge-list/SKILL.md)
