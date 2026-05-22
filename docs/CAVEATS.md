# Operational Caveats — `large-codebase-audit`

Universal caveats that affect how an AI-layer audit plays out in practice. Sourced from the official [Claude Code docs](https://code.claude.com/docs/en), issue tracker, and field experience across real codebases. None of these are project-specific; if anything here turns out to be tied to one stack, move it out.

---

## 1. 🔄 Path-scoped rules trigger on file READ, not on Write/Create

Per the official memory doc: *"Path-scoped rules trigger when Claude reads files matching the pattern, not on every tool use."*

**Implication for audits:** a nested `CLAUDE.md` you place at `subdir/CLAUDE.md` will NOT auto-load when Claude *creates* a brand-new file inside `subdir/`. It loads when Claude *reads* a matching file.

**Mitigations:**
- Have the parent / root `CLAUDE.md` reference the existence of the nested file (pointer-style)
- Duplicate truly load-bearing invariants at root scope (sparingly)
- Issue #23478 tracks the broader behaviour

---

## 2. 🐛 Rules' `paths:` YAML-list form has known parser quirks

Issue #17204 documents that the YAML-list form of `paths:` in rules can fail silently or misparse glob patterns starting with `*` or `{`.

**Does NOT affect skills.** Per the official skills doc, skills' `paths:` is canonical: *"Accepts a comma-separated string or a YAML list. ... Uses the same format as path-specific rules."* Field reports confirm skills' loader handles both forms without the parser issue rules see.

**Mitigations (for rules only):**
- Quote glob patterns that start with `*` or `{`: `paths: ["**/*.ts"]`
- If the list form fails, fall back to the unquoted scalar form: `paths: **/*.ts`
- The community-discovered `globs:` alias also works but is undocumented

---

## 3. 🧾 `description:` field — different role on rules vs skills

| Surface | Is `description:` documented? | Loader effect |
|---|---|---|
| Rules | No | None — loader ignores it |
| Skills | Yes | **Primary trigger field** — drives auto-loading via natural-language matching |

**Implication for audits:**
- For rules: drop `description:` to reduce noise, or keep it as a human-readable comment with the understanding that it doesn't change behaviour
- For skills: invest in the description — make it specific, list trigger phrases, name proactive-use conditions

---

## 4. 💸 Self-improving Stop hooks cost tokens every session-end

If you wire a Stop hook that introspects the conversation and updates rules / skills / CLAUDE.md, it runs once per session termination. Even a minimal hook is a non-zero token cost across many sessions.

**Mitigations:**
- Always provide an opt-out env var (e.g. `CLAUDE_DISABLE_HEADLESS=1`)
- Sample (run on every Nth session-end, not every one) for low-priority diagnostics
- Document the cost in the project's `CLAUDE.md` near the hook reference

---

## 5. 🔁 MCP server changes require Claude Code restart, not `/clear`

`/clear` resets the conversation but does not re-register MCP servers. New entries in `.mcp.json` (or new MCP entries in `.claude/settings.json`) are picked up only on a full Claude Code restart.

**Implication for audits:** if Phase 3 adds or modifies MCP entries, the Phase 4 wrap-up MUST surface a restart instruction to the user as a top-priority action.

---

## 6. 🍴 Forks cannot spawn further forks

Per the official subagents doc: *"A fork cannot spawn further forks."*

**Implication for this skill:** the audit-skill itself must run in the main thread. It orchestrates many forks; if it were a forked skill, it could only dispatch named sub-agents, losing the parallel-cache benefits forks provide.

**For other skills:** `context: fork` in skill frontmatter is the canonical declarative pattern for self-forking — useful for skills that do *one* deep task in isolation, not for orchestrators.

---

## 7. 🛑 Cross-fork write coordination requires disjoint scopes

When Phase 3 dispatches parallel write forks, two forks writing to the same file cause one to lose. The fork-dispatch checklist (one file → one fork) is load-bearing, not advisory.

**Mitigations:**
- Each fork's prompt states its EXCLUSIVE write scope at the top
- Each fork's prompt names the *other* forks running in parallel so it stays in lane
- Defer rule consolidations and rule-to-skill conversions to a `_CONSOLIDATION_PROPOSALS.md` doc for human review

---

## 8. 🎭 Rules vs skills misclassification is the most common drift

The simplest mental model:

- **Rule** = invariant. "Never do X." "Always use Y." Loads automatically (always or path-scoped). No workflow steps.
- **Skill** = workflow. "When the user asks for X, do Y, then Z, then verify W." Loads on description match or `paths:` match.

If a rule contains numbered steps, ordered phases, or "first do A, then B", it's a skill in disguise.

If a skill is just one paragraph saying "use library X for Y", it's a rule in disguise.

---

## 9. 📦 Plugin directory layout

Per the official plugins doc, the canonical plugin layout is:

```
my-plugin/
  .claude-plugin/
    plugin.json        # required manifest
  skills/
  commands/
  agents/
  hooks/
  monitors/
  bin/
  .mcp.json
  .lsp.json
  settings.json
```

There is **no `tooling/` directory** in the official spec. Earlier informal references to `tooling/` were incorrect.

---

## 10. 🧠 Auto-memory is part of the AI layer

`~/.claude/projects/<project-path>/memory/` carries per-project facts across sessions. The official auto-memory subsystem maintains it, but it benefits from periodic pruning:

- Stale entries (>90 days, not referenced in recent sessions) bloat session-start context
- `MEMORY.md` is the index file — keep it under ~200 lines (truncation cutoff)
- Audits should look here, not just at `.claude/`

---

## 11. 📏 Skill-budget knobs in settings.json

The official skill-listing budget controls:

| Setting | Effect |
|---|---|
| `skillListingBudgetFraction` | Fraction of context budget reserved for skill listings (default ~0.10) |
| `maxSkillDescriptionChars` | Truncates each skill's description in the listing |
| `skillOverrides` | Per-skill enable/disable map |

For an "AI layer audit" these are first-class targets: if the project has 47 skills, lowering `skillListingBudgetFraction` to 0.05 may free meaningful context without losing functionality (the truncated skills still load on full match).

---

## 12. ✂️ `claudeMdExcludes` is the monorepo CLAUDE.md trim knob

In monorepos, nested CLAUDE.md proliferation can over-load the root context. The official `claudeMdExcludes` setting (a glob list in `.claude/settings.json`) suppresses specific nested files from auto-loading.

**Audit task:** check for orphan nested CLAUDE.md that exists but doesn't load because of `claudeMdExcludes`, and conversely for nested files that *should* be excluded but aren't.

---

## 13. 🔐 `disableSkillShellExecution` for security

Skills can execute shell via backtick-bang syntax (`` !`command` ``). The `disableSkillShellExecution` setting blocks this entirely.

**When to recommend setting it:** projects that install third-party skills from a marketplace, or projects with security-sensitive build environments. Default is unset (shell allowed).

---

## 14. 🧰 `InstructionsLoaded` hook is the canonical "what loaded?" diagnostic

Instead of manually reading every CLAUDE.md and rule file to figure out what's actually in context, the `InstructionsLoaded` hook reports it directly. Use this as Fork-A's first command in Phase 1.

---

## 15. 🔍 LSP config lives in `.lsp.json`

The official LSP configuration file is `.lsp.json` at the project root (or inside a plugin). Symbol-server installation is separate (e.g. `typescript-language-server` via npm). Both must be present for LSP to function.

---

## 16. 🏢 Multi-person orgs need a Claude Code DRI

The Anthropic article dedicates a section to assigning ownership. Without a named DRI, configuration drifts: nobody updates CLAUDE.md when patterns change, nobody schedules the 3-6 month review cadence, nobody resolves contradictions when two contributors add competing rules.

**Audit task:** if the project is in a multi-person org and the audit finds no DRI signal (no `.claude/OWNERS`, no `CODEOWNERS` entry covering `.claude/`, no CLAUDE.md "Maintainer" line), recommend assigning one in the Phase 4 wrap.

---

## 17. 🗓️ 3-6 month review cadence

The Anthropic article quotes: *"Teams should expect to do a meaningful configuration review every three to six months."*

**Audit task:** the Phase 4 wrap MUST include a "Next review due" date (today + 90 days as a sensible default). Without it the audit is a one-shot, not a cadence.

---

## 18. 📦 Skill bundling — keep supporting files INSIDE the skill directory

If a skill needs supporting docs, schemas, or scripts, they live inside the skill's own directory (`skills/<name>/docs/`, `skills/<name>/references/`, etc.) — never scattered elsewhere. Skills must be portable across machines, repos, and Claude / Codex / Copilot loaders.

The exception is templates that would freeze project-specific shape — those *should not exist* in a universal skill, because they pollute the universal use case.

---

## 🔗 Sources

- [Anthropic — How Claude Code works in large codebases](https://claude.com/blog/how-claude-code-works-in-large-codebases-best-practices-and-where-to-start)
- [Official Claude Code docs](https://code.claude.com/docs/en) — skills, sub-agents, memory, hooks, MCP, plugins
- Issues referenced: #17204 (rules paths parser), #23478 (path-scoped read trigger)
