---
name: skill-changelog
description: 스킬 변경 전후를 비교하고 리포트합니다. 디렉토리 구조 변경, 파일별 diff, 영향 분석을 시각적으로 정리합니다. "변경점, 변경 리포트, diff, changelog, 뭐가 달라졌어, 변경사항, 비교, before after, 이전 버전" 등을 언급할 때 활성화됩니다.
---

# Skill Change Reporter

## Instructions

스킬 구조 변경의 전후를 비교하여 명확한 리포트를 생성합니다.

### Report Format

```
## Change Report: [작업명] — [날짜]

### Summary
- 변경 파일 수 (추가/수정/삭제)
- 영향 범위
- 변경 유형

### 디렉토리 구조 변경
Before: (ASCII tree)
After:  (ASCII tree with ← NEW/MODIFIED/DELETED markers)

### 파일별 변경 내역
#### [NEW/MODIFIED/DELETED] path/to/file
- 유형/목적/핵심내용
- diff (핵심 부분만 발췌)

### 주요 변경 하이라이트
| 항목 | Before | After | 이유 |

### 기존 스킬 호환성
| 스킬 | 영향 | 필요 조치 |

### 다음 단계
- 후속 작업 항목
```

### Comparison Techniques
- 디렉토리: ASCII tree로 시각화, 변경 마킹
- 내용: unified diff (`+`/`-`), 핵심만 발췌
- 정량: 라인 수, 섹션 수, references 수 변화

### Rules
- 변경점 누락 없이 전수 보고
- diff는 가독성 우선 (전체 파일이 아닌 변경 부분만)
- "왜" 변경했는지 반드시 포함
- 변경 없는 파일은 포함하지 않음
