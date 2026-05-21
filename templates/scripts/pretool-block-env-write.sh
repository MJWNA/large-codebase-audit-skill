#!/usr/bin/env bash
# PreToolUse hook: block writes/edits to .env* files (except .env.example).
# Reason: commit 11bf24a hardened .env handling — never let an agent leak secrets back into the tree.
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
Reason: commit 11bf24a (chore(security): tighten env gitignore) — env values are managed via Vercel + Neon, not in-repo.
If you genuinely need to update .env.example (the only allowed env file), edit that exact path.
EOF
    exit 2
    ;;
esac

exit 0
