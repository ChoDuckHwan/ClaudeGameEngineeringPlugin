---
name: skill-improve
description: 스킬 구조 개선안을 도출합니다. 기존 스킬의 불일치, 누락, 비효율을 식별하고 구체적인 개선안을 제시합니다. "구조 개선, 스킬 개선, 리팩토링, skill improve, 구조 변경, 패턴 개선, 스킬 최적화, 스킬 리팩토링" 등을 언급할 때 활성화됩니다.
---

# Skill Structure Improver

## Instructions

기존 스킬 구조의 문제점을 식별하고 개선안을 제시합니다.

### Improvement Categories

**A. SKILL.md 구조**
- frontmatter 일관성
- description 키워드 최적화
- 본문 섹션 표준화

**B. References 구조**
- patterns.md: 구현 패턴의 구체성
- sharp_edges.md: 함정/위험 요소 커버리지
- validations.md: 검증 규칙 명확성

**C. 스킬 간 관계**
- 중복 제거
- 참조 관계 명확화
- 누락된 도메인 식별

**D. 코드 참조 정확성**
- 코드 예시 ↔ 실제 소스 일치
- 파일 경로/클래스명 최신성
- API 시그니처 정확성

### Output Format

```
## Improvement Report: [대상]

### 발견된 문제점
| # | 카테고리 | 문제 | 심각도 | 위치 |

### 개선안
- 문제 → 제안 → 이유 → 영향범위

### 새 스킬 구조 설계 (해당 시)
- 디렉토리 구조
- SKILL.md 스켈레톤
- 핵심 섹션 목차

### 우선순위
- 즉시 적용 / 다음 단계 / 장기 과제
```

### Quality Target
- game-design-core 수준의 구조적 완성도를 기준으로 함
- 모든 개선안에 반드시 "이유(Why)" 포함
- 기존 패턴을 존중하되 실질적 개선 추구
