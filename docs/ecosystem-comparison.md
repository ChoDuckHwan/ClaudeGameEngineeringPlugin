# Ecosystem Comparison — CGE vs Harness vs ECC vs Archon

Claude Code 하네스 생태계에서 CGE의 위치.

## 한눈 비교

| 항목 | CGE | revfactory/harness | affaan-m/ECC | coleam00/Archon |
|------|-----|--------------------|--------------|------------------|
| **Layer** | L3 메타-에이전트 | L3 팀 아키텍처 | L2 cross-harness | L3 런타임 설정 |
| **자산 형태** | Core+슬롯 모듈 | 6 패턴 자산 | 48 agents+183 skills | 결정론적 워크플로우 |
| **활성 결정** | **메타-에이전트 자동** | 사용자 명시 | 사용자 명시 | 사용자 명시 |
| **추가/제거** | **lifecycle 명령** | git pull | npm install | 설정 파일 편집 |
| **노하우 누적** | **mine-pattern + sync-lessons** | X | 부분 (lessons.md) | X |
| **다중 엔지니어링** | **슬롯 모듈 (P-1)** | 단일 | 단일 | 단일 |
| **첫 부착 분석** | **5 Phase 자동** | 없음 | 없음 | 설정 파일 입력 |
| **언어 지원** | 다언어 (시그널 카탈로그) | UE5 중심 | 12 언어 | runtime 무관 |
| **Stars (참고)** | (신규) | 2.9k | 167k | (변동) |

## 위치 다이어그램

```
L2 (Cross-Harness 어댑터)
    └─ ECC                     ← Codex/Cursor/Claude Code 동시 지원
                                  ↑ 위에서 여러 하네스를 감쌈

L3 (Harness Factory) ─────────────────────────
    ├─ CGE (this)              ← 메타-에이전트 + 슬롯 모듈
    ├─ revfactory/harness      ← 정적 6 패턴
    └─ Archon                  ← 결정론적 런타임 설정

L4 (Domain Teams)
    └─ ProjectFIB의 13 도메인 팀 (CGE harness 엔지니어링이 제공한 표준 따름)

L5 (Knowledge)
    └─ GDD / Phase / Architecture / RFC
```

## 무엇을 흡수했나

### From revfactory/harness (Apache 2.0)
- ✅ 6 디자인 패턴 분류 개념 → `engineerings/harness/policies/_patterns.md`
- ✅ Producer-Reviewer 재시도 개념 → `_retry_policy.md`
- ❌ 흡수 안 함: 정적 자산 패키징 방식 (CGE는 슬롯 모듈)

### From affaan-m/ECC (MIT)
- ✅ 토큰 최적화 가이드 (Sonnet 기본·MAX_THINKING·compaction) → `_token_policy.md`
- ✅ PostToolUse 훅 개념 → `core/hooks/post_edit_alert.ps1`
- ✅ 메모리 지속 (Stop/UserPromptSubmit) → `core/hooks/check_handoff.ps1`
- ❌ 흡수 안 함: 다국어 규칙 카탈로그 (UE5/단일 도메인 환경엔 과잉)
- ❌ 흡수 안 함: 명령어→스킬 마이그레이션 (CGE는 처음부터 스킬 기반)
- ❌ 흡수 안 함: 48 agents·183 skills 라이브러리 (도메인 특화 자산이 더 적합)

### From Archon
- ❌ 흡수 안 함: 결정론적 런타임 설정 (메타-에이전트 적응형과 본질적 다름)

## 무엇이 CGE 고유한가

### 1. 메타-에이전트 (P-1+P-2)
다른 하네스는 "어떤 자산을 쓸까?"를 사용자가 결정. CGE는 LLM이 프로젝트를 읽고 결정.

### 2. 엔지니어링 슬롯 (P-1)
다른 하네스는 자기 방식이 진리. CGE는 슬롯 — harness는 첫 슬롯, 더 좋은 게 나오면 추가.

### 3. 추가/제거 균등성 (P-3)
스킬·에이전트·팩·엔지니어링 모두 같은 lifecycle 명령. 다른 하네스는 자산별 추가 절차 다름.

### 4. 노하우 누적 자동화
- `cge-mine-pattern`: 단일 프로젝트에서 패턴 발굴
- `cge-sync-lessons`: 다중 프로젝트 합류 → 본체 진화

### 5. Profile 진실 원천 (P-4)
`.claude/_project_profile.json` 단일 파일이 활성 자산 모두 추적. Drift 검출 가능.

## 공존 가능성

CGE는 다른 하네스와 **공존 가능**:

```
CGE (L3 메타-에이전트)
    └─ engineerings/
        ├── harness/        ← 우리 첫 슬롯
        ├── ecc/            ← (미래) ECC 패턴 일부 흡수
        └── archon/         ← (미래) Archon 결정론적 모드
```

각 엔지니어링은 `exclusive_with`로 공존 불가능 명시 가능.

## 어느 것을 선택해야 하나

| 시나리오 | 권장 |
|----------|------|
| 정적 6 패턴이면 충분 + 단일 프로젝트 | revfactory/harness 직접 |
| Codex·Cursor 동시 사용 | ECC |
| 결정론적 운영 환경 (배포 게이트) | Archon |
| **다중 프로젝트 + 노하우 누적 + 적응형** | **CGE (this)** |
| **새 엔지니어링·팩 자주 추가** | **CGE (this)** |

## 핵심 차별 명제

> **다른 하네스는 "이 워크플로우를 따르세요" — 메서드 강요.**
> **CGE는 "이 프로젝트엔 무엇이 맞을까?" — 메타-결정자.**

CGE 위에서 다른 하네스 방식들이 슬롯으로 협업할 수 있다. CGE는 그 위에서 "어느 것이 이 프로젝트에 맞나"를 판단.

## 다음

- [`meta-agent-philosophy.md`](meta-agent-philosophy.md)
- [`adaptive-bootstrap.md`](adaptive-bootstrap.md)
- [`engineering-slot-guide.md`](engineering-slot-guide.md)
