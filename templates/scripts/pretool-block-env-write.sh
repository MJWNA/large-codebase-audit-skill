#!/usr/bin/env bash
# PreToolUse hook: block writes/edits to .env* files (except .env.example).
# Reason: env files contain secrets that belong in a secret store, not the repo tree.
set -euo pipefail

PAYLOAD=$(cat || true)
if [ -z "$PAYLOAD" ]; then
  exit 0
fi

if command -v jq >/dev/null 2>&1; then
  FILE_PATH=$(printf '%s' "$PAYLOAD" | jq -r '.tool_input.file_path // empty' 2>/dev/null || true)
else
  FILE_PATH=$(printf '%s' "$PAYLOAD" | sed -n 's/.*"file_path"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -1)
fi

if [ -z "$FILE_PATH" ]; then
  exit 0
fi

BASENAME=$(basename "$FILE_PATH")

# Allow .env.example explicitly.
if [ "$BASENAME" = ".env.example" ]; then
  exit 0
fi

# Block any .env* basename (.env, .env.local, .env.production, .env.vercel, etc.).
case "$BASENAME" in
  .env|.env.*)
    cat >&2 <<EOF
[blocked] $FILE_PATH is a .env file. Writes blocked by project-scope safety hook.
Reason: env values are managed via your secret store / hosting platform, not in-repo.
If you genuinely need to update .env.example (the only allowed env file), edit that exact path.
EOF
    exit 2
    ;;
esac

exit 0
