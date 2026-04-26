---
name: skill-validate
description: 작성된 SKILL.md 자체의 품질을 검증합니다 (형식·트리거·코드 정확성·일관성·V7 should/should-NOT). 게임 코드나 하네스 골격이 아닌 **스킬 파일 자체의 QA**. "스킬 품질 검증, SKILL.md QA, skill-validate 실행, 스킬 리뷰, skill test, skill review, 새로 만든 스킬 검증" 등을 언급할 때 활성화됩니다. 코드 검증은 도메인 verifier, 하네스 점검은 harness-audit으로.
---

# Skill Validator

## Instructions

스킬 파일의 품질을 체계적으로 검증합니다.

### Validation Checklist

**V1. Frontmatter**
- [ ] name: kebab-case
- [ ] name == 디렉토리명
- [ ] description: 한 줄, 트리거 키워드 포함
- [ ] YAML 문법 올바름

**V2. 본문 구조**
- [ ] Identity 섹션 존재
- [ ] Instructions/Guidelines 섹션 존재
- [ ] 코드 예시 포함
- [ ] 프로젝트 파일 참조 존재
- [ ] 마크다운 문법 올바름

**V3. 코드 정확성**
- [ ] 클래스명이 실제 소스에 존재 (Grep 확인)
- [ ] 함수 시그니처 일치
- [ ] #include 경로 올바름
- [ ] FIB prefix 올바름
- [ ] UPROPERTY/UFUNCTION 매크로 정확
- [ ] Listen Server 패턴 준수

**V4. References** (해당 시)
- [ ] patterns.md: When/Why/How 포함
- [ ] sharp_edges.md: 문제/해결 쌍
- [ ] validations.md: 체크리스트 형태
- [ ] SKILL.md에서 Reference System Usage 언급

**V5. 일관성**
- [ ] 기존 스킬과 구조적 일관성
- [ ] 코딩 스타일 준수 (K&R, 탭)

**V6. 트리거 품질**
- [ ] 실제 사용 시나리오 커버
- [ ] 다른 스킬과 과도한 중복 없음
- [ ] 한국어/영어 키워드 모두 포함

**V7. 트리거 검증 (should-trigger / should-NOT-trigger)** ★ Tier 1 추가
- [ ] **should-trigger 케이스 ≥3개** — 이 스킬이 반드시 호출되어야 하는 자연어 예시
- [ ] **should-NOT-trigger 케이스 ≥2개** — 비슷해 보이지만 다른 스킬이 호출되어야 하는 예시
- [ ] 18개 스킬 인덱스(`.claude/skills/*/SKILL.md`)와 트리거 키워드 충돌 검사
- [ ] 한·영 양쪽에서 should/should-NOT 동작 일관

#### V7 검증 절차
1. SKILL.md description의 트리거 키워드를 모두 추출
2. 각 키워드를 다른 17개 스킬 description에 Grep
3. 충돌 키워드가 있으면 → 스킬 ID와 함께 WARNING
4. should-trigger 예시를 직접 던져 LLM이 본 스킬을 선택하는지 사고실험
5. should-NOT-trigger 예시(예: 옆 도메인 키워드)를 던져 본 스킬이 선택되지 **않는지** 확인

#### V7 출력 형식
```markdown
### V7 Trigger Validation

#### Should-Trigger (목표 ≥3)
| # | 입력 예시 | 기대 호출 | 통과 |
|---|-----------|-----------|------|
| 1 | "스킬 검증해줘" | skill-validate | ✅ |
| 2 | "QA 해줘" | skill-validate | ✅ |
| 3 | "skill review" | skill-validate | ✅ |

#### Should-NOT-Trigger (목표 ≥2)
| # | 입력 예시 | 기대 호출 | 통과 |
|---|-----------|-----------|------|
| 1 | "스킬 만들어줘" | skill-implement (NOT this) | ✅ |
| 2 | "스킬 분석해줘" | skill-analyze (NOT this) | ✅ |

#### Trigger Conflicts
| 키워드 | 충돌 스킬 | 심각도 | 권고 |
|--------|-----------|--------|------|
| "검증" | skill-validate, harness-audit | WARNING | 컨텍스트 의존 — 둘 다 적합한 경우 명시 |
```

### Output Format

```
## Validation Report: [스킬명]

### Summary
- 상태: PASS ✅ / FAIL ❌ / WARNING ⚠️
- 검증 항목: N개 중 M개 통과

### Results Table
| # | 체크 | 결과 | 상세 |

### Issues (있는 경우)
#### [CRITICAL/WARNING/INFO] 항목ID: 제목
- 위치 / 문제 / 제안
```

### Severity
- **CRITICAL ❌**: 스킬 동작 불가 (깨진 frontmatter, 없는 클래스)
- **WARNING ⚠️**: 동작하지만 품질 저하 (트리거 부족, 예시 부족)
- **INFO ℹ️**: 선택적 개선 (추가 예시 권장)
