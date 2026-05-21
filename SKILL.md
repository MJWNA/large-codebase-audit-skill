---
name: large-codebase-audit
description: Audit and apply Anthropic's "How Claude Code works in large codebases" methodology to any Claude Code project. Uses parallel forked sub-agents to evaluate and fix the 7 AI-layer components — CLAUDE.md hierarchy, rules, path-scoped skills, sub-agents, hooks (self-improving + safety), MCP servers, LSP symbol search. Trigger on phrases like "audit my AI layer", "apply large codebase setup", "audit Claude config", "large codebase audit", "AI layer audit", "Anthropic large codebase", "harness audit", "make my Claude setup better", "tune up my .claude", "scan my AI layer". Use proactively when entering a large codebase that lacks nested CLAUDE.md, when CLAUDE.md exceeds 100 lines, or when the user mentions any of the 7 AI-layer components.
---

# Large Codebase AI-Layer Audit & Fix

Operationalises the 9 strategies from [How Claude Code works in large codebases](https://claude.com/blog/how-claude-code-works-in-large-codebases-best-practices-and-where-to-start) as a single audit-and-fix cycle using parallel forked sub-agents.

## When to use this skill

- User asks to audit, tune, or modernise their Claude Code AI layer
- Entering a large codebase (>50K LOC, >10 subdirectories) for the first time
- CLAUDE.md exceeds 80 lines or contains a rule-file index
- No nested CLAUDE.md files exist
- No project-scope skills, sub-agents, or self-improving hooks exist
- User mentions Anthropic's large-codebase article or wants to apply its methodology

## The 7 AI-Layer components

1. **CLAUDE.md hierarchy** — root + nested for progressive disclosure
2. **Rules** — `.claude/rules/`, always-loaded vs path-scoped
3. **Skills** — `.claude/skills/`, path-scoped workflow walkthroughs
4. **Sub-agents** — `.claude/agents/`, split exploration from editing
5. **Hooks** — `.claude/settings.json`, self-improving + safety guardrails
6. **MCP servers** — project-scope `.mcp.json` for custom tools
7. **LSP symbol search** — typescript-language-server etc. via plugin

## Workflow

### Phase 0 — Pre-flight (1-2 minutes)

1. Confirm you're in a git repository root (or the project root inside a monorepo)
2. Read the existing `CLAUDE.md`, `ARCHITECTURE.md`, `.claude/settings.json`, `.claude/rules/` listing
3. Note line counts and identify the dominant tech stack (Next.js? Rails? Django? etc.)
4. If user said something tight like "just do it" or `--yes`, set autonomy mode high — otherwise plan to confirm before Phase 3

### Phase 1 — Audit (6 parallel read-only forks in ONE message)

Dispatch all 6 in a single message via the `Agent` tool with NO `subagent_type` (forks inherit your context). Each fork:

- **Fork A — CLAUDE.md hierarchy**: read root + all nested CLAUDE.md, report line counts, top-3-by-line-cost sections, derivable content, missing nested files, concrete trim proposals
- **Fork B — Rules**: enumerate `.claude/rules/*.md`, classify always-loaded vs path-scoped, identify consolidation candidates, identify rule-vs-skill misclassifications, deletion candidates
- **Fork C — Skills + agents + commands**: inventory project-scope, propose missing path-scoped skills based on directory structure, propose explorer + db-investigator sub-agents
- **Fork D — Hooks**: inventory current hooks at project + user scope, identify self-improving Stop hook gap, SessionStart dynamic-context gap, PreToolUse safety gaps
- **Fork E — MCP + LSP**: inventory MCP servers, identify LSP plugin status and binary install state, propose project-scope MCPs (Neon, Prisma, etc.)
- **Fork F — Codebase structure**: produce a 10-line codebase map, propose 4-7 nested CLAUDE.md placements (don't over-fragment)

Each fork returns a structured punch list under 800 words with concrete file paths.

### Phase 2 — Synthesise + plan

Once all 6 audit forks return, synthesise into a Phase 3 plan with **explicit, non-overlapping write scopes**. Map every fix to one fork, one set of files. Never let two forks write to the same file.

State the plan to the user as a table:

```
| Fork | Owns (writes to) |
|---|---|
| Fix-1 | CLAUDE.md (root) |
| Fix-2 | nested CLAUDE.md files (×N) |
| Fix-3 | .claude/settings.json hooks + .claude/scripts/ |
| Fix-4 | .claude/skills/ (new dirs) |
| Fix-5 | .claude/agents/ (new files) |
| Fix-6 | .claude/rules/ (safe trims only — defer merges) |
| Fix-7 | duplicate / orphan cleanup |
| Fix-8 | LSP install + .mcp.json |
```

If the user hasn't said "go" / "yes" / `--yes`, confirm before dispatching.

### Phase 3 — Fix (parallel write forks in ONE message)

Dispatch all fix forks in a single `Agent` tool call message. Each fork's prompt must:

1. State its **EXCLUSIVE write scope** at the top — "do NOT touch any file outside this list"
2. Note which other forks are running in parallel and which files they own
3. Include the specific changes (lines to cut, files to create, frontmatter to add)
4. Require self-validation (`jq` for JSON, `bash -n` for scripts, line counts for CLAUDE.md)
5. Report back: files touched, line counts, smoke-test results, surprises

Critical guardrails:

- **Never run two write forks against the same file**
- **Defer rule consolidations** to a `_CONSOLIDATION_PROPOSALS.md` doc for human review (consolidations break pointers in other forks created in the same cycle)
- **Use the documented `paths:` array form for skills** but warn about parser bug #17204; if testing shows skills don't auto-load, convert to unquoted scalar form

### Phase 4 — Wrap

Once all fix forks return, dispatch ONE final wrap fork to:

1. Run verification commands (file counts, `jq` syntax checks, `bash -n`)
2. Write `.claude/session/large-codebase-audit-YYYY-MM-DD.md` — comprehensive takeaways
3. Run `claude-rule-sync` dry-run if available (`~/.codex/skills/claude-rule-sync/scripts/rule_sync.py`)
4. Surface the 5-7 critical "you need to do this BEFORE next session" actions

Then write a final summary to the user with action items.

## Critical caveats (read these BEFORE applying)

The Anthropic article omits these — discovered during trial on a real codebase:

1. **Path-scoped triggers fire on file READ, not Write/Create** (Claude Code issue #23478). Nested CLAUDE.md won't auto-load when Claude *creates* a brand-new file in that dir. Workaround: read a sibling file first, OR duplicate critical invariants at root scope.
2. **`paths:` YAML-list form has parser bugs** (#17204). Documented array form may fail silently. Fallback: unquoted scalar (`paths: **/*.ts`) or undocumented `globs:` alias.
3. **`description:` field has no loader effect for RULES** (it DOES matter for skills' trigger-word matching). Easy to confuse.
4. **Self-improving Stop hooks cost tokens on every session-end**. Always provide `CLAUDE_DISABLE_HEADLESS=1` env opt-out. Make this prominent.
5. **Sub-agent classifier flags hook installation as "self-modification"** even when explicitly authorised. Pre-emptively call out standing authorisation in fork prompts.
6. **MCPs require Claude Code restart** (not `/clear`) to register.
7. **Many env vars (NEON_API_KEY, etc.) missing at install time**. Verify env presence before generating MCP entries that reference them.
8. **Plugins are the distribution layer** per Anthropic. Skills can be packaged as plugins for marketplace install.
9. **Always-loaded rules paid in every session.** Highest-leverage trim: convert always-loaded → path-scoped.
10. **Cross-fork write coordination requires disjoint scopes.** Map writes to files; one file → one fork.
11. **Rules vs skills misclassification is the most common drift.** Rule = invariant ("never do X"). Skill = workflow ("when X, do Y, then Z").
12. **`pixel-agents/`-style sub-project duplicates** are surprisingly common. Audit for byte-identical CLAUDE.md clones.
13. **The Anthropic article omits the trial step.** Always recommend a single-codebase trial before generalising.
14. **The article's 9 strategies map to 7 AI-layer components** but the article doesn't enumerate them as a list.
15. **Plugins use a `tooling/` subdirectory** per the marketplace pattern.

## Fork-dispatch checklist (use mentally before EVERY parallel batch)

- [ ] All forks have **explicit write scopes** (or read-only declaration)?
- [ ] No two forks write to the **same file**?
- [ ] Fork prompts include **other forks' scopes** so they stay in lane?
- [ ] Self-validation step in **each fix fork** (jq, bash -n, line count)?
- [ ] Dispatched in a **single message** for true parallelism?

## Reference materials

- [Anthropic article](https://claude.com/blog/how-claude-code-works-in-large-codebases-best-practices-and-where-to-start)
- `docs/CAVEATS.md` — full caveat list with mitigations
- `docs/ANTHROPIC-ARTICLE-NOTES.md` — distilled article notes
- `templates/` — script + skill + nested-CLAUDE.md templates
- `examples/trial-workflow.md` — the shape of an audit-and-fix cycle on a typical un-tuned codebase
