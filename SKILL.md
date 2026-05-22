---
name: large-codebase-audit
description: Audit and improve a Claude Code project's AI layer end-to-end. Covers the 9 official surfaces (CLAUDE.md hierarchy, rules, skills, sub-agents, hooks, MCP, LSP, plugins, auto-memory) plus settings.json budget knobs. Parallel forked audit, disjoint-scope fixes, ordered per Anthropic's stated hierarchy. Trigger phrases - "audit my AI layer", "audit Claude config", "large codebase audit", "tune my .claude", "apply Anthropic patterns", "harness audit", "improve Claude Code setup", "Anthropic large codebase". Use proactively when CLAUDE.md exceeds 80 lines, when no nested CLAUDE.md exists, or when entering a large untuned codebase.
---

# Large Codebase AI-Layer Audit & Fix

A single audit-and-fix cycle for any Claude Code project. Implements the patterns described in [How Claude Code works in large codebases](https://claude.com/blog/how-claude-code-works-in-large-codebases-best-practices-and-where-to-start) and cross-referenced against the [official Claude Code docs](https://code.claude.com/docs/en).

The article's thesis is that **the harness matters as much as the model**. This skill audits the harness as a whole, not as a checklist of components.

## 🎯 When to use this skill

- 🔧 User asks to audit, tune, or modernise their Claude Code AI layer
- 📥 Entering a large codebase (>50K LOC, >10 subdirectories) for the first time
- 📏 CLAUDE.md exceeds 80 lines or contains an inline rule index
- 🚫 No nested CLAUDE.md, no project-scope skills, no project-scope sub-agents
- 📰 User references Anthropic's large-codebase article
- 🗓️ Last configuration review is more than 3-6 months old (the article's stated cadence)

## 🧱 The 9 AI-layer surfaces this skill audits

Anthropic's article and the official docs together describe these surfaces. The article doesn't enumerate them as a list; this is a synthesis.

| # | Surface | Where it lives | Key audit question |
|---|---|---|---|
| 1 | 📜 CLAUDE.md hierarchy | Root + nested `CLAUDE.md` | Is the root under 80 lines, pointers-only? Are there nested files at meaningful sub-tree boundaries? |
| 2 | 📋 Rules | `.claude/rules/*.md` | Is anything always-loaded that could be path-scoped? Are any rules really skills in disguise? |
| 3 | 🎯 Skills | `.claude/skills/*/SKILL.md` | Path-scoped triggers correct? Bundled supporting files? Use `context: fork` where appropriate? |
| 4 | 🤖 Sub-agents | `.claude/agents/*.md` | Read-only explorer agent? DB / log inspectors that the main thread shouldn't carry? |
| 5 | 🪝 Hooks | `.claude/settings.json` → `hooks` | Self-improving Stop hook? `InstructionsLoaded` for diagnostics? PreToolUse safety guardrails? |
| 6 | 🔌 MCP servers | `.mcp.json` or `.claude/settings.json` | Project-scope MCPs registered? `disableSkillShellExecution` set where needed? |
| 7 | 🔎 LSP | `.lsp.json` + plugin install | Symbol-server configured for the dominant language? Binary available? |
| 8 | 📦 Plugins | `.claude-plugin/plugin.json` | Is the project itself a plugin? Are bundled skills marketplace-ready? |
| 9 | 🧠 Auto-memory | `~/.claude/projects/<proj>/memory/` | Is the project benefitting from auto-memory? Stale entries (>90 days)? |

Two settings-level knobs sit alongside these:

- `skillListingBudgetFraction`, `maxSkillDescriptionChars`, `skillOverrides` — skill-budget controls
- `claudeMdExcludes` — monorepo CLAUDE.md trim knob

## 🔄 Workflow

### Phase 0 — Pre-flight (1-2 minutes)

1. ✅ Confirm git repo root (or project root inside a monorepo)
2. 🪂 Check fork-mode availability: `echo $CLAUDE_CODE_FORK_SUBAGENT` should return `1`
   - If unset, fall back to dispatching named sub-agents with `subagent_type: general-purpose` (accept cache-miss cost)
3. 📜 Read root `CLAUDE.md`, `ARCHITECTURE.md` (if present), `.claude/settings.json`, list `.claude/rules/`, `.claude/skills/`, `.claude/agents/`
4. 🔍 If `InstructionsLoaded` hook is available in this Claude Code version, capture what actually loaded — it's the canonical diagnostic
5. 🧭 Identify dominant tech stack (Next.js? Rails? Django? Go?) — informs LSP and tech-specific skills
6. 🚦 Note the user's autonomy level: explicit "go" / "just do it" / `--yes` → high autonomy; otherwise plan to confirm before Phase 3

### Phase 1 — Audit (parallel read-only forks in ONE message)

Dispatch all forks in a single `Agent`-tool message. Forks (no `subagent_type`) inherit context; named sub-agents are the fallback if fork-mode is off. Each fork is **read-only** and reports a punch list under 800 words.

| Fork | Audits | Reports |
|---|---|---|
| 🅰️ CLAUDE.md hierarchy | Root + all nested `CLAUDE.md` | Line counts, top-3 line-cost sections, derivable content, missing nested files, concrete trim proposals |
| 🅱️ Rules | `.claude/rules/*.md` | Always-loaded vs path-scoped split, consolidation candidates, rule-vs-skill misclassifications, deletion candidates per the Deletion Test |
| 🅲 Skills + agents + commands | `.claude/skills/`, `.claude/agents/`, `.claude/commands/` | Inventory, missing path-scoped skills based on directory structure, missing explorer / db-inspector sub-agents, `context: fork` opportunities |
| 🅳 Hooks + settings | `.claude/settings.json` (project + user scope) | Hook inventory, self-improving Stop hook gap, `InstructionsLoaded` gap, PreToolUse safety gaps, skill-budget knob settings, `claudeMdExcludes` opportunities |
| 🅴 MCP + LSP + plugins | `.mcp.json`, `.lsp.json`, `.claude-plugin/plugin.json` | Server inventory, LSP binary install state, plugin manifest presence, env-var gaps that block proposed MCPs |
| 🅵 Codebase structure | Repo tree | 10-line codebase map, 4-7 proposed nested CLAUDE.md placements (don't over-fragment), `.claudeignore` / `permissions.deny` recommendations |
| 🅶 Auto-memory | `~/.claude/projects/<proj>/memory/` | Memory entry count, stale entries (>90 days), gaps where memory should exist, MEMORY.md index health |

### Phase 2 — Synthesise and order fixes

Once all 7 audit forks return, synthesise into a Phase 3 plan with **explicit, non-overlapping write scopes**. Map every fix to one fork and one set of files. Two forks must never write to the same file.

**Order the fix forks per the article's stated hierarchy** (the article is explicit: *"CLAUDE.md files come first"*):

```
1. CLAUDE.md (root)
2. Nested CLAUDE.md
3. Hooks + settings.json
4. Skills
5. Sub-agents
6. Plugins (if project is a plugin)
7. LSP
8. MCP
9. Auto-memory pruning
```

State the plan to the user as a table:

```
| Fork | Owns (exclusive write scope) |
|---|---|
| Fix-1 | CLAUDE.md (root only) |
| Fix-2 | Nested CLAUDE.md files (specific paths listed) |
| Fix-3 | .claude/settings.json + .claude/scripts/ |
| Fix-4 | .claude/skills/ (new dirs + path-scoped frontmatter) |
| Fix-5 | .claude/agents/ (new files only) |
| Fix-6 | .claude-plugin/ (if applicable) |
| Fix-7 | .lsp.json + LSP binary install |
| Fix-8 | .mcp.json |
| Fix-9 | auto-memory pruning (specific files listed) |
| Fix-10 | Rules (safe trims only - defer merges to a proposals doc) |
```

If the user has not said "go" / "yes" / `--yes`, confirm the plan before dispatching.

### Phase 3 — Fix (parallel write forks in ONE message)

Dispatch fix forks in a single `Agent` message. Each fork's prompt must:

1. 🚧 State its **EXCLUSIVE write scope** at the top: "do NOT touch any file outside this list"
2. 👯 Name the other forks running in parallel and their write scopes (so each fork stays in lane)
3. 📝 Include the specific changes (lines to cut, files to create, frontmatter to add)
4. ✅ Require self-validation: `jq` for JSON, `bash -n` for shell scripts, line counts for CLAUDE.md, frontmatter linting for skills
5. 📤 Report back: files touched, line counts, validation results, surprises

Critical guardrails:

- ❌ Never run two write forks against the same file
- 🛑 Defer rule consolidations and rule-to-skill conversions to a `_CONSOLIDATION_PROPOSALS.md` doc for human review (consolidations break pointers that other forks may rely on within the same cycle)
- 🪪 For skills' `paths:` frontmatter, use the documented form (comma-separated string or YAML list); the parser bug at issue #17204 affects *rules*, not skills
- 🔁 If MCP entries are added or changed, note that the user must **restart Claude Code** (not `/clear`) before they register

### Phase 4 — Wrap + cadence

Dispatch ONE final wrap fork to:

1. ✅ Run verification commands (file counts, `jq` syntax, `bash -n`, frontmatter validation)
2. 📝 Write `.claude/session/large-codebase-audit-YYYY-MM-DD.md` with:
   - Summary of changes per surface
   - Open questions and deferred items (link to `_CONSOLIDATION_PROPOSALS.md`)
   - **Recommended DRI** for ongoing Claude Code config management (the article has an entire section on assigning ownership)
   - **Next review due** date: today + 90 days (the article recommends 3-6 month cadence)
3. 🧹 If `claude-rule-sync` (or equivalent cross-platform sync tool) is available, run dry-run only — do not auto-write
4. 🚨 Surface the 3-7 critical "do this BEFORE next session" actions
5. ♻️ If the user is in a multi-person org and no DRI exists, recommend assigning one explicitly

## 🚨 Critical operational caveats (summary)

Full versions with citations and mitigations live in [`docs/CAVEATS.md`](docs/CAVEATS.md). Highlights:

- 🔄 Path-scoped rules trigger on file READ, not Write/Create (issue #23478)
- 🐛 Rules' `paths:` YAML-list form has parser quirks (issue #17204) — does NOT affect skills
- 🧾 `description:` is undocumented for rules; for skills it IS the primary trigger field
- 💸 Self-improving Stop hooks cost tokens every session-end — provide `CLAUDE_DISABLE_HEADLESS=1` opt-out
- 🔁 MCP changes require Claude Code restart, not `/clear`
- 🍴 Forks cannot spawn further forks — this skill must run in the main thread
- 🛑 Cross-fork write coordination requires disjoint scopes; one file → one fork
- 🎭 Rules vs skills misclassification is the most common drift: rule = invariant ("never do X"); skill = workflow ("when X, do Y, then Z")
- 📦 Plugin layout per official spec: `skills/ commands/ agents/ hooks/ monitors/ bin/ .mcp.json .lsp.json settings.json .claude-plugin/plugin.json`

## ✅ Fork-dispatch checklist (run mentally before EVERY parallel batch)

- [ ] All forks have **explicit write scopes** (or read-only declaration)?
- [ ] No two forks write to the **same file**?
- [ ] Fork prompts include **other forks' scopes** so they stay in lane?
- [ ] Self-validation step in **each fix fork** (jq, bash -n, line count, frontmatter lint)?
- [ ] Dispatched in a **single message** for true parallelism?
- [ ] Phase 3 dispatched in the article's stated order (CLAUDE.md first)?

## 📚 Reference materials

- 📰 [Anthropic article — How Claude Code works in large codebases](https://claude.com/blog/how-claude-code-works-in-large-codebases-best-practices-and-where-to-start)
- 📖 [Official Claude Code docs](https://code.claude.com/docs/en)
- 🚨 [`docs/CAVEATS.md`](docs/CAVEATS.md) — operational caveats with citations and mitigations
