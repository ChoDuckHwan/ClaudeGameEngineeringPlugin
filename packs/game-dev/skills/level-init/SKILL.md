---
name: level-init
description: "ProjectFIB 의 9 테마 레벨 중 하나에 대한 마스터 시나리오 문서를 표준 템플릿으로 신규 생성합니다. background.md / GDD_05 / huddle.md / GDD_04 에서 자동으로 시설 정보·몬스터 풀·인터랙션 풀을 추출하여 채웁니다. 사용자가 '레벨 시작, 레벨 신규, level init, 새 레벨 작업, 시나리오 시작, {시설명} 시나리오' 등을 언급할 때 활성화됩니다."
---

# Level Init — 레벨 마스터 문서 신규 생성

## Identity

ProjectFIB 의 9개 테마 레벨 중 하나에 대해, 표준 마스터 시나리오 문서를 자동 생성하는 스킬. 표준 템플릿 (`.claude/Scenarios/_LEVEL_TEMPLATE.md`) 을 기반으로 GDD 문서에서 시설 정보를 추출해 빈 필드를 채운다.

## When to RUN

- 사용자가 새 레벨 작업을 시작하려 함
- 명령 패턴: `/level-init <LevelName>` 또는 자연어 "수중 시설 레벨 시나리오 만들어줘"

## When to SKIP

- 이미 `.claude/Scenarios/{LevelName}.md` 가 존재 → 덮어쓰기 위험. 사용자 확인 필수
- LevelName 이 9개 테마 중 어느 것에 해당하는지 모호 → 사용자에게 확인

## 9 테마 매핑

| LevelName 표준 | background.md 테마 | 한글명 |
|---|:---:|---|
| `ResearchLab` | 1 | 연구실 |
| `Bunker` | 2 | 벙커 |
| `Mine` | 3 | 광산 |
| `MedievalCastle` | 4 | 중세의 성 |
| `NuclearPlant` | 5 | 원자력발전소 |
| `Tanker` | 6 | 유조선 (MV 레비아탄 호) |
| `Mansion` | 7 | 백만장자의 별장 |
| `UnderwaterFacility` | 8 | 수중 잠수시설 (아비스 스테이션) |
| `Museum` | 9 | 박물관 |

## 절차

### Step 1. 매개변수 확인

- `<LevelName>` 인자 받기. 없으면 사용자에게 9개 중 선택 요청
- 기존 파일 충돌 검사: `.claude/Scenarios/{LevelName}.md` 존재 시 사용자 확인

### Step 2. 자동 데이터 추출

다음 4개 문서에서 LevelName 에 해당하는 정보 Read + Grep:

```
1. .claude/background.md        — 시설명/위치/역할/시나리오
2. .claude/GDD_05_몬스터.md     — 시설 전용 몬스터 (§5-A~E)
3. .claude/GDD_04_악령.md       — 추천 보스 (§7 테마별 권장 악령)
4. .claude/huddle.md            — 시설 장애물 12종 (테마 N 섹션)
```

### Step 3. 템플릿 복사 + 필드 채우기

`.claude/Scenarios/_LEVEL_TEMPLATE.md` Read → 다음 필드 치환:

| 템플릿 필드 | 채울 값 |
|---|---|
| `{N}` | 테마 번호 (1-9) |
| `{시설 한글명}` | background.md 에서 추출 |
| `{English Name}` | LevelName 인자 |
| `{LevelName}` | 인자 그대로 |
| 시설 개요 표 (§1) | background.md 헤더 정보 |
| 시나리오 (§2) | background.md 본문 |
| 몬스터 라인업 (§5) | GDD_05 §5-X + GDD_04 추천 보스 |
| 인터랙션 표 (§6-A) | huddle.md 테마 N 섹션 |
| 변경 이력 (§12) | 1행 추가: "YYYY-MM-DD 신규 생성" |

자동 채우기 불가한 필드 (모듈 구성 / 외형 / 행동 등) 는 빈 칸으로 두고 사용자에게 후속 작업 안내.

### Step 4. 보조 파일 골격 생성 (선택)

`.claude/Scenarios/{LevelName}_Bestiary.md` 와 `.claude/Scenarios/{LevelName}_InteractionMap.md` 빈 골격 생성 (헤더만).

### Step 5. SESSION_HANDOFF 신규 항목 추가

```markdown
### YYYY-MM-DD — {LevelName} 레벨 작업 시작

- 마스터 문서: `.claude/Scenarios/{LevelName}.md`
- 시각화: `.claude/Scenarios/{LevelName}_LevelFlow.html` (예정)
- 진행도: Phase A 1/5
```

### Step 6. 사용자 보고

```markdown
# {LevelName} 레벨 신규 생성 완료

산출물:
- .claude/Scenarios/{LevelName}.md  (마스터)
- .claude/Scenarios/{LevelName}_Bestiary.md  (골격)
- .claude/Scenarios/{LevelName}_InteractionMap.md  (골격)

자동 채워진 항목:
- 시설 개요 / 시나리오 / 몬스터 후보 / 인터랙션 12종

수동 채울 항목:
- §3 모듈 구성 (사용자 디자인 필요)
- §4 환경 메카닉 (테마 고유 요소)
- §9 보스 페이즈 (대상 보스 결정 후)

다음 행동: `/level-status {LevelName}` 으로 진행도 확인
```

## 출력 형식

마크다운 보고서. 한국어. 자동/수동 채워진 항목 명확히 구분.

## 절대 원칙

- ✓ 표준 템플릿 구조 100% 준수
- ✓ GDD 문서에서 추출한 정보 원문 인용
- ✓ 변경 이력 자동 1행 추가
- ❌ 기존 마스터 문서 덮어쓰기 (사용자 명시 확인 없이)
- ❌ 9 테마 외 LevelName 허용 (확장 시 본 스킬 갱신 필요)