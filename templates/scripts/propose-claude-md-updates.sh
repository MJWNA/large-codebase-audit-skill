#!/usr/bin/env bash
# Stop hook: reflect on session diff, propose CLAUDE.md / rule updates while context is fresh.
# Appends timestamped review to .claude/session/claude-md-review.md.
# Skip the LLM call if CLAUDE_DISABLE_HEADLESS is set (testing path).
set -euo pipefail

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/../.." && pwd)}"
cd "$PROJECT_DIR" 2>/dev/null || exit 0

# Bail fast if nothing changed in the working tree or staged.
if git diff --quiet HEAD 2>/dev/null && git diff --cached --quiet 2>/dev/null; then
  exit 0
fi

REVIEW_FILE="$PROJECT_DIR/.claude/session/claude-md-review.md"
mkdir -p "$(dirname "$REVIEW_FILE")"

# Capture diff (working tree + staged), cap at ~8K chars so the prompt stays cheap.
DIFF=$( { git diff HEAD 2>/dev/null; git diff --cached 2>/dev/null; } | head -c 8192 || true)
if [ -z "$DIFF" ]; then
  exit 0
fi

TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S %Z')
TOUCHED_FILES=$(git diff --name-only HEAD 2>/dev/null | head -20 || true)

# Test/dry-run path — write a stub and exit so hook can be exercised without burning tokens.
if [ -n "${CLAUDE_DISABLE_HEADLESS:-}" ]; then
  {
    echo
    echo "## $TIMESTAMP (dry-run, CLAUDE_DISABLE_HEADLESS set)"
    echo
    echo "**Files touched:**"
    echo '```'
    echo "$TOUCHED_FILES"
    echo '```'
  } >> "$REVIEW_FILE"
  exit 0
fi

# Require claude CLI; otherwise log skip and exit cleanly.
if ! command -v claude >/dev/null 2>&1; then
  {
    echo
    echo "## $TIMESTAMP (skipped — claude CLI not on PATH)"
  } >> "$REVIEW_FILE"
  exit 0
fi

PROMPT="You are reviewing a session diff to propose CLAUDE.md / .claude/rules/ updates.

Apply the Deletion Test from ~/.claude/rules/claude-md-standards.md to every proposed addition.
Only propose changes when removing them would cause a future Claude session to make a real mistake.

Touched files:
$TOUCHED_FILES

Diff (truncated to 8K chars):
$DIFF

Read CLAUDE.md and the .claude/rules/ files relevant to the touched paths, then output a short markdown review:
- What new convention or gotcha (if any) belongs in CLAUDE.md or a rule
- What stale content should be removed
- Concrete file paths and proposed edits
Keep under 400 words. If nothing warrants a change, say so explicitly."

{
  echo
  echo "## $TIMESTAMP"
  echo
  echo "**Files touched:**"
  echo '```'
  echo "$TOUCHED_FILES"
  echo '```'
  echo
  echo "**Review:**"
  echo
  claude -p --output-format text "$PROMPT" 2>&1 || echo "_(claude -p invocation failed)_"
} >> "$REVIEW_FILE"

exit 0
