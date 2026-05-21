# Example — what a trial run looks like

This is the **shape** of an audit-and-fix cycle on a typical un-tuned codebase. Numbers are illustrative — your run will differ based on stack, size, and how much AI-layer work you've done already.

## Before

A codebase in the "I've been using Claude Code for a few months and just let it grow" state usually looks like:

| Layer | Typical state before audit |
|---|---|
| Root `CLAUDE.md` | 100-200 lines, embedded rule index, gotchas mixed with conventions |
| Nested `CLAUDE.md` | None, or one or two ad-hoc additions |
| Rules (`.claude/rules/`) | 20-40 files, most always-loaded, several misclassified as rules when they're workflows |
| Skills (`.claude/skills/`) | Empty at project scope |
| Sub-agents (`.claude/agents/`) | Empty |
| Hooks | None at project scope (only user-scope notifications) |
| MCP servers (project) | Empty |
| LSP | Plugin enabled, binary not installed, or no plugin at all |

## Phase 1 — Audit (6 parallel read-only forks, ~5-10 min)

Each fork returns a structured punch list. Typical findings:

- **CLAUDE.md** — root file trimmable by 30-50%; 4-7 nested CLAUDE.md missing; sometimes a byte-identical duplicate hiding in a sub-project folder
- **Rules** — 3-5 always-loaded rules should be path-scoped; 2-5 rules are actually workflows (skill candidates); 1-2 rules duplicate content from `ARCHITECTURE.md` or other rules
- **Skills + agents** — entire layer typically empty; 8-12 path-scoped skills proposed based on directory shape (one per recurring task type); 2 read-only sub-agents proposed (explorer + db-investigator)
- **Hooks** — zero project-scope; 1 Stop hook + 1 SessionStart hook + 2-4 PreToolUse safety hooks proposed
- **MCP + LSP** — LSP binary often missing; 1-2 project-scope MCPs missing (DB, ORM); custom MCP usually unnecessary
- **Codebase structure** — clean 8-12-line map producible; 4-7 nested CLAUDE.md placements optimal (avoid over-fragmentation)

## Phase 2 — Synthesis + plan

You (main session) collate the 6 punch lists. Map every fix to one fork, one file, no collisions. Typical fix-fork count: 6-9.

## Phase 3 — Fix (parallel write forks, ~10-15 min)

Typical disjoint write scopes:

| Fork | Owns | Typical result |
|---|---|---|
| Fix-1 | Root `CLAUDE.md` | Trimmed 30-50%, codebase map embedded |
| Fix-2 | Nested `CLAUDE.md` files | 4-7 created, 14-20 lines each, pointers to canonical rules |
| Fix-3 | Hooks + scripts | 4 hooks live, 5 scripts smoke-tested |
| Fix-4 | Skills | 8-12 path-scoped skills, ~40 lines each |
| Fix-5 | Sub-agents | 2 read-only sub-agents (explorer + db-investigator) |
| Fix-6 | Rules safe trims | Path-scope always-loaded rules, delete duplicates, generate `_CONSOLIDATION_PROPOSALS.md` |
| Fix-7 | Duplicate / orphan cleanup | Delete byte-identical CLAUDE.md clones, flag accidental sub-project mirrors |
| Fix-8 | LSP install + `.mcp.json` | Install language server, create project-scope MCP config |

## Phase 4 — Wrap (~3-5 min)

A final wrap fork:

- Verifies file structure (counts, syntax checks, smoke-test results)
- Writes `.claude/session/large-codebase-audit-YYYY-MM-DD.md`
- Runs `claude-rule-sync` dry-run if available
- Surfaces the 5-7 critical "do this before next session" actions

## Total time

**Typical run: 20-30 minutes for a mid-sized codebase (500-2000 source files).**

The parallelism is what makes it fast — 6 audit forks + 8 fix forks in parallel = roughly 14 sub-agent invocations completing in the time of the slowest one in each wave, not the sum.

## Things that commonly surprise people

1. **Path-scoped rules don't fire when Claude creates a new file** — see [CAVEATS.md](../docs/CAVEATS.md#a-path-scoped-triggers-fire-on-file-read-not-writecreate)
2. **The Stop hook costs tokens on every session-end** — there's an opt-out env var
3. **Sub-agent classifier flags the hook installation as "self-modification"** — even when explicitly authorised
4. **MCPs need a full Claude Code restart**, not just `/clear`
5. **A surprising number of codebases have byte-identical duplicate CLAUDE.md files** lurking in sub-project folders

## Output you'll have at the end

```
your-repo/
├── CLAUDE.md                                 (trimmed, codebase map at top)
├── app/{api,(dashboard),...}/CLAUDE.md       (new, nested, ~15 lines each)
├── lib/{sync,data,...}/CLAUDE.md             (new, nested)
├── .claude/
│   ├── settings.json                         (hooks block added)
│   ├── scripts/                              (5 hook scripts)
│   ├── skills/                               (8-12 path-scoped skills)
│   ├── agents/                               (2 read-only sub-agents)
│   ├── rules/                                (path-scoped, trimmed)
│   ├── rules/_CONSOLIDATION_PROPOSALS.md     (pending human review)
│   └── session/large-codebase-audit-YYYY-MM-DD.md  (takeaways)
└── .mcp.json                                 (Neon, Prisma, etc.)
```

Plus an installed `typescript-language-server` (or equivalent) globally, ready to expose symbol-search tools once Claude Code restarts.
