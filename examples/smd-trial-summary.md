# Example: Trial Run on Sales Metrics Dashboard

The trial that produced this skill. Run on 2026-05-21 against a multi-tenant Next.js 15 + Prisma 7 + Neon dashboard with 865+ TypeScript files.

## Before

| Layer | State |
|---|---|
| Root `CLAUDE.md` | 105 lines, embedded full rule index |
| Nested `CLAUDE.md` | None (only an accidental pixel-agents/pixel-agents/ duplicate) |
| Rules | 32 files, 5 always-loaded heavy |
| Skills | 0 project-scope |
| Sub-agents | 0 |
| Hooks | 0 project-scope (only user-scope notifications) |
| MCP servers | 0 project-scope |
| LSP | typescript-lsp plugin enabled but binary missing |

## What the audit found (6 parallel forks)

1. **CLAUDE.md hierarchy** — 105 → 67 lines achievable; 5 nested CLAUDE.md files missing; 1 byte-identical duplicate in pixel-agents/
2. **Rules** — 5 always-loaded → 2 achievable; 5 consolidation candidates; 4 rules misclassified (should be skills)
3. **Skills + agents** — Entire layer empty; 11 path-scoped skills proposed based on directory structure; 2 read-only sub-agents proposed
4. **Hooks** — Zero project-scope hooks; self-improving Stop hook + SessionStart git context + 3 PreToolUse safety guardrails missing
5. **MCP + LSP** — typescript-language-server binary not installed (1-command fix); Neon + Prisma MCPs missing at project scope; custom MCP not needed
6. **Codebase structure** — Clean 10-line map producible; 6 nested CLAUDE.md placements optimal

## What the fix wave did (8 parallel forks)

| Fork | Owns | Result |
|---|---|---|
| Fix-1 | Root `CLAUDE.md` | 105 → 67 lines, codebase map embedded at top |
| Fix-2 | 6 nested `CLAUDE.md` | All created, 14-19 lines each, pure load-bearing + pointers |
| Fix-3 | `.claude/settings.json` hooks + `.claude/scripts/` | 4 hooks live, 5 scripts created, prod-deploy guard smoke-tested on a real test command |
| Fix-4 | `.claude/skills/` | 11 path-scoped skills, 37-42 lines each |
| Fix-5 | `.claude/agents/` | smd-explorer (117 lines), smd-db-investigator (194 lines) |
| Fix-6 | `.claude/rules/` safe trims | 2 rules path-scoped, cli-smd.md deleted, vercel cron table trimmed, _CONSOLIDATION_PROPOSALS.md drafted |
| Fix-7 | pixel-agents/ duplicate | Byte-identical duplicate deleted, parent trimmed 213 → 155 |
| Fix-8 | LSP + `.mcp.json` | typescript-language-server@5.3.0 installed globally, Neon + Prisma MCP entries created |

## What surprised us (informed the caveats doc)

1. **Path-scoped triggers on READ not Write/Create** — nested CLAUDE.md doesn't load when Claude creates a new file
2. **`paths:` array form has parser bugs** (#17204) — may need to fall back to scalar form
3. **Stop hook is automatic** — fires on every session-end, costs tokens
4. **Classifier flags hook installs as self-modification** — even when user explicitly authorised
5. **pixel-agents/pixel-agents/** was a full accidental project mirror, not just a CLAUDE.md duplicate — flagged for user to triage

## Total time

- Audit phase: ~7 minutes (6 forks in parallel)
- Synthesis: ~2 minutes (main session)
- Fix phase: ~12 minutes (8 forks in parallel)
- Wrap phase: ~3 minutes (1 fork)

**Total: ~24 minutes for a complete AI-layer audit and fix cycle on a real production codebase.**

## Output

`.claude/session/large-codebase-audit-trial.md` — comprehensive takeaways doc covering the 15 caveats now in `docs/CAVEATS.md`.

## Lessons that became the skill

- Always dispatch audit forks **in a single message** for true parallelism
- Map fix forks to **disjoint write scopes** before dispatching
- Defer **structural rule merges** to human review (they break pointers in the same cycle)
- Always **smoke-test hook scripts** before declaring done (the prod-deploy guard caught its own test invocation as a real bug, which proved the wiring worked)
- Surface **caveats at synthesis time**, not just in the takeaways doc
