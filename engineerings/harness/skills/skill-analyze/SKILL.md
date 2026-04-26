---
name: skill-analyze
description: 기존 스킬과 프로젝트 코드 구조를 분석합니다. 스킬 디렉토리 구성, SKILL.md 패턴, C++ 소스 아키텍처를 파악하여 새 스킬의 통합 기반을 마련합니다. "구조 분석, 스킬 분석, 패턴 분석, 코드 구조, skill structure, analyze skill, 스킬 현황, 구조 파악" 등을 언급할 때 활성화됩니다.
---

# Skill Structure Analyzer

## Instructions

기존 스킬과 소스코드 구조를 체계적으로 분석합니다.

### Step 1: 스킬 디렉토리 스캔
```
.claude/skills/*/SKILL.md     → 모든 스킬 목록
.claude/skills/*/references/  → 참조 문서 유무
```

### Step 2: SKILL.md 패턴 분석
각 스킬의:
- frontmatter 형식 (name, description)
- 본문 섹션 구조 (Identity, Instructions, Examples 등)
- 코드 예시 포함 여부
- references 활용 패턴

### Step 3: 소스코드 구조 매핑
```
Source/ProjectFIB/
├── AbilitySystem/   → gas-helper, combat-helper
├── Inventory/       → inventory-helper
├── Interaction/     → interaction 관련
├── Character/       → player, movement 관련
├── UI/              → ui-helper
├── GameModes/       → experience, game feature 관련
```

### Step 4: 출력
```
## Structure Analysis: [도메인]

### 기존 스킬 현황
- 관련 스킬 / 패턴 / references 유무

### 소스코드 구조
- 핵심 디렉토리 / 클래스 / 상속 계층 / 의존성

### 패턴 분석
- 공통 패턴 / 예외 패턴 / 네이밍 규칙

### 통합 포인트
- 기존 스킬 관계 / 코드 참조 경로

### 구조적 권장사항
- 디렉토리 구조 / references 필요 여부
```

## Known Skill Inventory

| Skill | Domain | Has References |
|-------|--------|---------------|
| gas-helper | GAS Abilities | No |
| combat-helper | Combat System | No |
| inventory-helper | Inventory | No |
| ui-helper | UI/CommonUI | No |
| unreal-build-helper | Build/Compile | No |
| game-design-core | Game Design Theory | Yes (3 files) |
