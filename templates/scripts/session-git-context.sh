#!/usr/bin/env bash
# SessionStart hook: emit a single block of git context so Claude starts oriented.
# Total runtime budget: ~5s. Optional project-specific checks (e.g. stuck background jobs,
# open PRs, deploy state) can be added by extending this script — leave hooks idempotent.
set -euo pipefail

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/../.." && pwd)}"
cd "$PROJECT_DIR" 2>/dev/null || exit 0

BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")
AHEAD=$(git rev-list --count origin/main..HEAD 2>/dev/null || echo "?")
DIRTY=$(git status --porcelain 2>/dev/null | awk '{print $NF}' | head -8 | paste -sd ',' -)
LAST3=$(git log -n 3 --pretty='%h %s' 2>/dev/null | sed 's/^/  - /')

cat <<EOF
## Git context
- Branch: $BRANCH
- Commits ahead of origin/main: $AHEAD
- Dirty files: ${DIRTY:-none}
- Last 3 commits:
$LAST3
EOF

# --- Project-specific extensions (uncomment and customise) ---
# Example: surface stuck background jobs in your DB
# if [ -n "${DATABASE_URL:-}" ] && command -v psql >/dev/null 2>&1; then
#   STUCK=$(timeout 3 psql "$DATABASE_URL" -tA -c "SELECT COUNT(*) FROM <your_jobs_table> WHERE status='running' AND started_at < NOW() - INTERVAL '10 minutes'" 2>/dev/null || echo "query failed")
#   echo "- Stuck background jobs (>10 min): $STUCK"
# fi
#
# Example: open PRs assigned to you
# if command -v gh >/dev/null 2>&1; then
#   gh pr list --author "@me" --state open --limit 5 2>/dev/null | sed 's/^/  - /'
# fi

exit 0
