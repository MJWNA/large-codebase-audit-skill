#!/usr/bin/env bash
# PreToolUse hook: block edits to migration.sql files that are already on main (deployed).
# When in doubt, allow (exit 0). Only block when the migration directory is committed to main.
set -euo pipefail

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/../.." && pwd)}"
cd "$PROJECT_DIR" 2>/dev/null || exit 0

# Read JSON from stdin; extract tool_input.file_path with grep/sed fallback if jq missing.
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

# Only act on migration.sql files inside prisma/migrations/.
case "$FILE_PATH" in
  */prisma/migrations/*/migration.sql|prisma/migrations/*/migration.sql) : ;;
  *) exit 0 ;;
esac

# Resolve to repo-relative path so we can ask git about it.
REL_PATH="$FILE_PATH"
case "$FILE_PATH" in
  /*) REL_PATH=$(python3 -c "import os,sys; print(os.path.relpath(sys.argv[1], sys.argv[2]))" "$FILE_PATH" "$PROJECT_DIR" 2>/dev/null || echo "$FILE_PATH") ;;
esac

# Is this file (or its containing migration dir) tracked on origin/main? If yes, it's deployed.
MIG_DIR=$(dirname "$REL_PATH")
if git ls-tree -r --name-only origin/main 2>/dev/null | grep -q "^${MIG_DIR}/"; then
  cat >&2 <<EOF
[blocked] $FILE_PATH lives in an already-deployed migration directory on origin/main.
Edits to deployed migrations are forbidden by docs/runbooks/migration-release-contract.md.
Create a NEW migration that forward-fixes the issue instead.
EOF
  exit 2
fi

exit 0
