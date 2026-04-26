---
name: skill-implement
description: SKILL.md와 references 파일을 실제로 작성합니다. 시나리오, 구조 분석, 개선안을 종합하여 프로젝트에 최적화된 고품질 스킬을 구현합니다. "스킬 구현, 스킬 만들기, 스킬 작성, skill implement, create skill, write skill, SKILL.md 작성" 등을 언급할 때 활성화됩니다.
---

# Skill Implementer

## Instructions

스킬 파일(SKILL.md, references/)을 작성합니다.

### SKILL.md Template

```yaml
---
name: {kebab-case, 디렉토리명과 일치}
description: {자동 활성화 트리거 키워드 포함. 한국어/영어 모두 포함. 사용자의 실제 사용 패턴 반영}
---
```

**필수 섹션:**
1. `# {Skill Name}` — 제목
2. `## Identity` — 전문성과 관점 정의
3. `## Instructions` 또는 `## Core Guidelines` — 핵심 동작 가이드
4. `## Reference System Usage` — references가 있는 경우에만
5. `## Key Patterns` — 프로젝트 소스코드 기반 구현 패턴
6. `## Project File Reference` — 관련 소스 파일 경로 테이블
7. `## Common Mistakes` — 흔한 실수와 방지법

### References Template (선택)

**references/patterns.md:**
```
# Patterns
각 패턴에 When / Why / How + 코드 예시
```

**references/sharp_edges.md:**
```
# Sharp Edges
각 항목에 "하면 안 됨" + "해야 함" 쌍
```

**references/validations.md:**
```
# Validations
체크리스트 형태 검증 규칙
```

### Quality Checklist
- [ ] frontmatter YAML 문법 올바른가
- [ ] name이 kebab-case이고 디렉토리명과 일치하는가
- [ ] description에 트리거 키워드가 충분한가
- [ ] 코드 예시가 실제 프로젝트 소스와 일치하는가
- [ ] FIB prefix가 올바르게 적용되었는가
- [ ] Listen Server 패턴이 올바른가
- [ ] 기존 스킬과 내용이 중복되지 않는가

### File Naming
- 스킬 디렉토리: `kebab-case`
- SKILL.md: 항상 대문자
- references 파일: `lowercase.md`
