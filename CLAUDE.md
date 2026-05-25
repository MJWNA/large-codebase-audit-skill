# CLAUDE.md — large-codebase-audit-skill

This repo IS the Claude Code skill it documents. Operational artefacts are `SKILL.md` (workflow) and `docs/CAVEATS.md` (operational gotchas). Everything else is metadata, audit history, or implementation spec.

## 🏁 Session Continuity

This project uses `.claude/session/` for cross-session context.

**On session start:** read `.claude/session/HANDOFF.md` (first entry only) to pick up where the last session left off. Skim DECISIONS.md and LEARNINGS.md headers for recent context.

## 🔧 Maintainer workflow

The user-scope skill at `~/.claude/skills/large-codebase-audit/` is **symlinked** to this repo's `SKILL.md` and `docs/CAVEATS.md`. **Do NOT `cp` after edits** — the symlink propagates instantly. Verify with `readlink ~/.claude/skills/large-codebase-audit/SKILL.md`.

See `CONTRIBUTING.md` → *Maintainer-only: symlink user-scope to the repo* for setup.

## 📦 Release workflow (established v3.0.3)

1. Branch from `main`: `git checkout -b v3.0.X-<short-name>`
2. Edit `SKILL.md` / `docs/CAVEATS.md` / `README.md` / `CHANGELOG.md` / `CONTRIBUTING.md` as needed
3. Bump version badge in `README.md` and add new entry to `CHANGELOG.md`
4. Commit + push branch
5. Open PR via `gh pr create --base main --head <branch>`
6. Merge via `gh pr merge <num> --squash --delete-branch`
7. Pull `main`, tag at the squash commit: `git tag v3.0.X && git push origin v3.0.X`
8. `gh release create v3.0.X --latest --notes-file ...`
9. Confirm user-scope skill reflects new version (`diff` against symlink target)
10. Done — no `cp` step. Symlinks handle propagation.

v3.0.0 through v3.0.2 went direct to `main`. v3.0.3+ follows the PR convention above.

## 📂 Repo layout

```
.
├── SKILL.md                       # The skill workflow itself (~280 lines)
├── docs/CAVEATS.md                # 15 operational gotchas, G1-G15
├── README.md                      # User-facing intro + install options
├── CHANGELOG.md                   # All releases with full notes
├── CONTRIBUTING.md                # Dev setup + maintainer symlink pattern
├── AUDIT-v2.0.0-REVIEW.md         # Independent v2 audit (drove v3.0.0)
├── SPEC-v3.0.0.md                 # Implementation spec that v3.0.0 closed
└── .claude/session/               # Cross-session continuity (this dir)
    ├── HANDOFF.md                 # gitignored — developer-local state
    ├── DECISIONS.md                # tracked — design choices + reasoning
    └── LEARNINGS.md                # tracked — gotchas + workarounds
```

## 🎯 Audit pointers

Whenever you're editing this skill, eat your own dog food:
- `SKILL.md` should match the heuristic it teaches (root CLAUDE.md under ~80 lines, pointers-only)
- New CAVEATS go through CAVEAT G1-Gn naming + appended at the right numerical position (don't insert mid-file — that's how v3.0.1/v3.0.2 created the G14/G15 ordering bug that v3.0.3 fixed)
- Every Fork prompt should be a 200-word template (not a table-row summary)
