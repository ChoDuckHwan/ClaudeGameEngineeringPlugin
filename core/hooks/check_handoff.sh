#!/usr/bin/env bash
# CGE Stop Hook (Linux/macOS).
# Detect substantive turn (file changes in watched dirs) and require SESSION_HANDOFF.md update.

set -e

PROJECT_ROOT="${CGE_PROJECT_ROOT:-$(pwd)}"
MARKER="$PROJECT_ROOT/.claude/.session-log-marker"
HANDOFF="$PROJECT_ROOT/.claude/SESSION_HANDOFF.md"
PROFILE="$PROJECT_ROOT/.claude/_project_profile.json"

# Watch dirs from profile, fallback to defaults
WATCH_DIRS=()
if [ -f "$PROFILE" ] && command -v jq >/dev/null 2>&1; then
    while IFS= read -r dir; do
        WATCH_DIRS+=("$PROJECT_ROOT/$dir")
    done < <(jq -r '.watch_dirs[]?' "$PROFILE" 2>/dev/null)
fi

if [ ${#WATCH_DIRS[@]} -eq 0 ]; then
    for d in Source src app lib Content Config; do
        if [ -d "$PROJECT_ROOT/$d" ]; then
            WATCH_DIRS+=("$PROJECT_ROOT/$d")
        fi
    done
fi

# First run — create marker, pass
if [ ! -f "$MARKER" ]; then
    mkdir -p "$(dirname "$MARKER")"
    touch "$MARKER"
    exit 0
fi

MARKER_MTIME=$(stat -c %Y "$MARKER" 2>/dev/null || stat -f %m "$MARKER" 2>/dev/null)

# Detect substantive change
SUBSTANTIVE=0
for dir in "${WATCH_DIRS[@]}"; do
    [ -d "$dir" ] || continue
    if find "$dir" -type f -newer "$MARKER" -print -quit 2>/dev/null | grep -q .; then
        SUBSTANTIVE=1
        break
    fi
done

if [ $SUBSTANTIVE -eq 0 ]; then
    touch "$MARKER"
    exit 0
fi

# Handoff updated since marker?
HANDOFF_UPDATED=0
if [ -f "$HANDOFF" ]; then
    HANDOFF_MTIME=$(stat -c %Y "$HANDOFF" 2>/dev/null || stat -f %m "$HANDOFF" 2>/dev/null)
    if [ "$HANDOFF_MTIME" -gt "$MARKER_MTIME" ]; then
        HANDOFF_UPDATED=1
    fi
fi

if [ $HANDOFF_UPDATED -eq 1 ]; then
    touch "$MARKER"
    exit 0
fi

# Block: ask Claude to update handoff
REASON=$(cat <<EOF
이번 턴에서 watched 디렉토리 하위 파일이 수정되었지만 SESSION_HANDOFF.md 가 갱신되지 않았습니다.
session-log 스킬의 Update Procedure 에 따라 다음을 수행하세요:
1) SESSION_HANDOFF.md 크기 확인 (>50KB 면 Rotation 먼저)
2) 이번 턴의 변경/결정/다음 작업/블로커를 활성 파일 끝에 append
3) 최상단 "마지막 업데이트" 타임스탬프 갱신
4) 완료 후 한 줄 요약 출력
EOF
)

touch "$MARKER"

cat <<EOF
{"decision":"block","reason":$(printf '%s' "$REASON" | python3 -c 'import json,sys; print(json.dumps(sys.stdin.read()))' 2>/dev/null || echo "\"\"")}
EOF
exit 0
