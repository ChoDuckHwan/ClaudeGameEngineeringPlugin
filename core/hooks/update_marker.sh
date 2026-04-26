#!/usr/bin/env bash
# CGE UserPromptSubmit hook (Linux/macOS).

PROJECT_ROOT="${CGE_PROJECT_ROOT:-$(pwd)}"
MARKER="$PROJECT_ROOT/.claude/.session-log-marker"

if [ -f "$MARKER" ]; then
    touch "$MARKER"
else
    mkdir -p "$(dirname "$MARKER")"
    touch "$MARKER"
fi

exit 0
