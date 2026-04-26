# Lifecycle Commands — install/uninstall/replace

CGE 자산의 생명주기 명령. P-3 원칙: **추가/제거의 균등성**.

## 명령 목록

| 명령 | 목적 | 위임 에이전트 |
|------|------|---------------|
| `/cge bootstrap` | 첫 부착 (5 Phase) | project-analyst → ... → installer |
| `/cge rebootstrap` | 변화 반영 재실행 | (동일) |
| `/cge install <type> <id>` | 단일 자산 부착 | installer |
| `/cge uninstall <type> <id>` | 자산 제거 | installer (uninstall 모드) |
| `/cge replace <type> <id>@<old> with <id>@<new>` | 교체 + 마이그레이션 | installer (replace 모드) |
| `/cge list` | 활성/비활성 자산 조회 | (직접) |
| `/cge mine-pattern` | 노하우 발굴 | (단독) |
| `/cge sync-lessons` | 메타-메타 학습 | (단독) |

## install 흐름

```
사용자: /cge install engineering harness@1.0
        │
        ▼
[1] 매니페스트 로드 (engineerings/harness/engineering.json)
        │
        ▼
[2] 검증 (스키마·의존성·충돌)
        │
        ├─ 실패 → 사용자에게 사유 보고 후 종료
        ▼
[3] 트리거 충돌 검사 (skill-validate V7)
        │
        ▼
[4] 사용자 승인 (Y/n)
        │
        ├─ 거부 → 종료
        ▼
[5] 백업 (.claude/_backup/<timestamp>/)
        │
        ▼
[6] installer 에이전트 호출 → 자산 복사
        │
        ▼
[7] _project_profile.json 갱신 + Change Log
        │
        ▼
[8] harness-audit 검증
        │
        ├─ 실패 → 롤백
        ▼
[9] 사용자 보고
```

## uninstall 흐름 — 의존성 역검사가 핵심

```
사용자: /cge uninstall engineering harness
        │
        ▼
[1] 자산 식별 (active_engineerings에서)
        │
        ▼
[2] 의존성 역검사
        │ - harness를 의존하는 다른 활성 자산 찾기
        │ - 직접: 다른 매니페스트의 depends_on
        │ - 간접: HISTORY.md 사용 흔적
        ▼
[3] 최근 사용 검사
        │ - 7일 호출 카운트
        │ - 강한 경고 임계 (>10회)
        ▼
[4] 사용자 경고 (충격 표시)
        │
        ├─ 거부 → 종료
        ▼
[5] 자산 제거
        │
        ▼
[6] profile + Change Log 갱신
```

## replace 흐름 — 자동 마이그레이션이 핵심

```
사용자: /cge replace engineering harness@1.0 with harness@2.0
        │
        ▼
[1] old + new 매니페스트 로드
        │
        ▼
[2] 자산 매핑
        │ - 같은 ID → 자동 마이그레이션
        │ - old만 → 사용자 결정 (보존? 제거?)
        │ - new만 → 자동 추가
        ▼
[3] 정책 매개변수 마이그레이션
        │ - max_retry, MAX_THINKING 등
        ▼
[4] 단계적 교체
        │ - new 자산 _staging/에 부착
        │ - 충돌 검사
        │ - old 비활성 → new 활성 (atomic)
        │ - 검증 → 실패 시 롤백
        ▼
[5] 사용자 보고
```

## 실패 시 롤백

모든 lifecycle 명령은 시작 시 `.claude/_backup/<timestamp>/`로 자동 백업.
실패 또는 사용자 거부 시 백업에서 복원.

수동 롤백:
```bash
cp -r .claude/_backup/<timestamp>/* .claude/
```

## Change Log 자동 기록

각 명령 후 `.claude/CLAUDE.md`의 `## Change Log`에 1행:
```
| 2026-04-26 | CGE | install: harness@1.0 | first attachment |
| 2026-04-27 | CGE | install pack: unreal@1.0 | UE5 detected |
| 2026-05-01 | CGE | replace: harness@1.0 → 1.1 | new pattern available |
```

## 호출 예시

### 시나리오 A: 첫 부착
```
$ cd ~/MyProject
$ /cge bootstrap
[Phase 0~3 자동]
[Phase 3 제안서 출력]
승인? Y
[Phase 4 활성화]
✅ Bootstrap Complete
```

### 시나리오 B: 신규 팩 추가
```
$ /cge install pack web
검증... 의존성... 충돌... 승인? Y
✅ web@1.0 활성화
```

### 시나리오 C: 엔지니어링 교체
```
$ /cge replace engineering harness@1.0 with new-engineering@1.0
자산 매핑: 18/22 자동, 4 사용자 결정 필요
... 단계적 교체 ...
✅ Replace Complete
```

### 시나리오 D: 원치 않는 자산 제거
```
$ /cge uninstall pack horror
의존성 역검사: 의존 없음
최근 7일 호출: 0회
승인? Y
✅ horror@1.0 제거됨
```

## 비파괴 원칙

- 모든 명령은 백업 우선
- 사용자 승인 없이 자산 삭제 X
- harness-audit 검증 통과해야 완료
- 실패 시 자동 롤백

## 다음

- [`adaptive-bootstrap.md`](adaptive-bootstrap.md) — 5 Phase 상세
- [`engineering-slot-guide.md`](engineering-slot-guide.md)
- [`pack-authoring.md`](pack-authoring.md)
