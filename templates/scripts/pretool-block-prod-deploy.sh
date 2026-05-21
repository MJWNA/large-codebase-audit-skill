#!/usr/bin/env bash
# PreToolUse hook for Bash: block production-deploy and destructive DB commands.
# Conservative: only block when we are confident. When uncertain, allow (exit 0).
set -euo pipefail

PAYLOAD=$(cat || true)
if [ -z "$PAYLOAD" ]; then
  exit 0
fi

if command -v jq >/dev/null 2>&1; then
  CMD=$(printf '%s' "$PAYLOAD" | jq -r '.tool_input.command // empty' 2>/dev/null || true)
else
  CMD=$(printf '%s' "$PAYLOAD" | sed -n 's/.*"command"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -1)
fi

if [ -z "$CMD" ]; then
  exit 0
fi

block() {
  cat >&2 <<EOF
[blocked] Command: $CMD
Reason: $1
Pointer: $2
EOF
  exit 2
}

# 1. vercel deploy --prod (any flag spacing)
if printf '%s' "$CMD" | grep -Eq 'vercel[[:space:]]+(([^|;&]+[[:space:]]+)*)deploy[[:space:]]+([^|;&]*--prod\b)'; then
  block "Production Vercel deploys happen via merging a PR to main (Git integration), not ad-hoc CLI." \
        ".claude/rules/vercel-deployment.md"
fi

# 2. prisma migrate reset / prisma db push — destructive against any DB the env points at.
if printf '%s' "$CMD" | grep -Eq '\bprisma[[:space:]]+(migrate[[:space:]]+reset|db[[:space:]]+push)\b'; then
  block "prisma migrate reset / prisma db push are destructive and forbidden — preview DB === prod DB." \
        ".claude/rules/preview-db-equals-prod-db.md"
fi

# 3. git push to main (excluding --dry-run). Match `git push <remote> main` or `... main:main` etc.
if printf '%s' "$CMD" | grep -Eq '\bgit[[:space:]]+push\b' \
   && printf '%s' "$CMD" | grep -Eq '(\borigin[[:space:]]+main\b|\bmain\b[^:]|:main\b)' \
   && ! printf '%s' "$CMD" | grep -Eq '(\-\-dry-run\b|\bremotes?\b)'; then
  block "Direct push to main is disallowed — ship via PR." \
        "memory: feedback_salesdashboard_deploy_flow.md"
fi

exit 0
