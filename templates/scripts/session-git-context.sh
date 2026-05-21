#!/usr/bin/env bash
# SessionStart hook: emit a single block of git + deploy context so Claude starts oriented.
# Total runtime budget: ~5s. sync_logs check only runs when DATABASE_URL is set.
set -euo pipefail

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/../.." && pwd)}"
cd "$PROJECT_DIR" 2>/dev/null || exit 0

BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")
AHEAD=$(git rev-list --count origin/main..HEAD 2>/dev/null || echo "?")
DIRTY=$(git status --porcelain 2>/dev/null | awk '{print $NF}' | head -8 | paste -sd ',' -)
LAST3=$(git log -n 3 --pretty='%h %s' 2>/dev/null | sed 's/^/  - /')

STUCK="skipped (DATABASE_URL not set)"
if [ -n "${DATABASE_URL:-}" ]; then
  if command -v psql >/dev/null 2>&1; then
    STUCK=$(timeout 3 psql "$DATABASE_URL" -tA -c "SELECT COUNT(*) FROM sync_logs WHERE status='running' AND started_at < NOW() - INTERVAL '10 minutes'" 2>/dev/null || echo "query failed")
  else
    STUCK="skipped (psql not installed)"
  fi
fi

cat <<EOF
## Git context
- Branch: $BRANCH
- Commits ahead of origin/main: $AHEAD
- Dirty files: ${DIRTY:-none}
- Last 3 commits:
$LAST3
- Stuck sync_logs (running > 10 min): $STUCK
EOF

exit 0
