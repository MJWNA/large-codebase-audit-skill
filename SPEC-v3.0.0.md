# Implementation Spec — large-codebase-audit-skill v3.0.0

**Spec ID:** SPEC-v3.0.0
**Date:** 2026-05-22
**Base:** v2.0.0 (commit `ae879b3`)
**Target:** v3.0.0 (single release; supersedes the audit's v2.0.1 / v2.1.0 / v3.0.0 split)
**Driven by:** [`AUDIT-v2.0.0-REVIEW.md`](AUDIT-v2.0.0-REVIEW.md) — all 41 numbered findings closed here
**Scope:** Comprehensive — every audit finding addressed in one cycle.

This spec is the executable plan. A follow-up session reads it, applies the target content verbatim to `SKILL.md` and `docs/CAVEATS.md`, applies the targeted diffs to `README.md` and `CHANGELOG.md`, runs the verification commands, and ships v3.0.0.

---

## 0. 📋 Goals (mapped to audit findings)

| Audit ID | Goal | Status in spec |
|---|---|---|
| P0 #1 | Correct `skillListingBudgetFraction` default to `0.01` | §4.2 (CAVEAT G11) |
| P0 #2 | Move `disableSkillShellExecution` from MCP to Skills/Settings | §4.1 (Surfaces table + Fork C) |
| P0 #3 | Replace dead `/en/lsp` URL with `/en/plugins-reference#lsp-servers` | §4.1 + §4.2 (B-P3) |
| P0 #4 | Complete the cadence quote (add plateau/major-release trigger) | §4.1 (Best-practices §B-P5) |
| P0 #5 | Define "self-improving Stop hook" as community pattern, not docs term | §4.1 (Fork D), §4.2 (G4) |
| P0 #6 | Drop "9 official surfaces" framing → "the AI-layer surfaces" | §4.1, §4.3, §4.4 |
| P0 #7 | Mark "80 lines" as a heuristic, not a sourced threshold | §4.1 (frontmatter + Fork A) |
| P0 #8 | Replace "frontmatter linting" with a concrete command | §4.1 (Phase 3 self-validation) |
| P0 #9 | Reframe "the article's stated hierarchy" | §4.1 (Phase 3 ordering) |
| P0 (extra) | Correct `MEMORY.md` cutoff and topic-file load behaviour | §4.2 (G10) |
| P0 (extra) | Soften "memory types" framing | §4.2 (G10) |
| P1 #10 | Sandbox subsystem audit | §4.1 (Fork E) |
| P1 #11 | Permissions block audit | §4.1 (Fork E) |
| P1 #12 | Hook event catalog enumeration (31 events) | §4.1 (Fork D) |
| P1 #13 | Hook handler types beyond `command` | §4.1 (Fork D) |
| P1 #14 | Per-frontmatter Fork C skills audit | §4.1 (Fork C) |
| P1 #15 | Existing sub-agent audit (field-by-field) | §4.1 (Fork C) |
| P1 #16 | MCP tool-search posture (`ENABLE_TOOL_SEARCH`, `alwaysLoad`) | §4.1 (Fork F) |
| P1 #17 | Worktree configuration audit | §4.1 (Fork E) |
| P1 #18 | Bundled `/run` `/verify` `/run-skill-generator` recipe | §4.1 (Phase 0) |
| P1 #19 | Slash-commands → skills migration | §4.1 (Fork C) |
| P1 #20 | `.claudeignore` + `permissions.deny` first-class | §4.1 (Fork A, Fork E) |
| P1 #21 | Settings layering check | §4.1 (Fork E) |
| P1 #22 | `settings.local.json` audit + gitignore check | §4.1 (Fork E) |
| P1 #23 | `autoMode` classifier rules | §4.1 (Fork E) |
| P1 #24 | Marketplace manifest audit | §4.1 (Fork F) |
| P2 #25 | "Legacy rules a newer model wouldn't need" prompt | §4.1 (Fork A + Fork B) |
| P2 #26 | Scoped test/lint commands per nested CLAUDE.md | §4.1 (Fork A) |
| P2 #27 | Monorepo sub-tree invocation | §4.1 (Phase 0) |
| P2 #28 | Agent-manager role variant | §4.1 (Phase 4) |
| P2 #29 | Tribal-knowledge framing for DRI | §4.1 (Phase 4) |
| P2 #30 | Hooks reframing (continuous improvement, not just safety) | §4.1 (Fork D opening) |
| P3 #31 | Phase 1 forks as 200-word templates | §4.1 (Phase 1) |
| P3 #32 | Surface→audit-fork→fix-fork mapping table | §4.1 (§7) |
| P3 #33 | Phase 0.5 scaffold `.claude/` if absent | §4.1 (Phase 0) |
| P3 #34 | Monorepo per-package `.claude/` traversal | §4.1 (Phase 0 + Fork A) |
| P3 #35 | Adaptive Phase 3 dispatch | §4.1 (Phase 3) |
| P3 #36 | Phase 4 inline, not a fork | §4.1 (Phase 4) |
| P3 #37 | `_CONSOLIDATION_PROPOSALS.md` drain mechanism | §4.1 (Phase 4 + Phase 0) |
| P3 #38 | `REVIEW_DUE.md` + Stop-hook surfacing | §4.1 (Phase 4) |
| P4 #39 | Block-level HTML comments stripped from CLAUDE.md | §4.1 (Fork A note) |
| P4 #40 | Non-traditional codebases disclaimer | §4.1 (top) |
| P4 #41 | Skill content lifecycle (compaction re-attach) | §4.2 (G13) |

---

## 1. 🎯 Decisions taken

These resolve the audit's ambiguities into concrete choices. Stated up front so the rest of the spec is unambiguous.

| # | Decision | Rationale |
|---|---|---|
| D1 | **Single v3.0.0 release.** Not the audit's v2.0.1/v2.1.0/v3.0.0 split | User asked for "comprehensive fix… in full". One release is simpler to ship and review. |
| D2 | **Drop "9 official surfaces" entirely.** Frontmatter says "the AI-layer surfaces" with no count. Body lists ~11 surfaces with each labelled as `[article]` or `[docs]` for provenance. | The synthesis is real; the count is a fabrication. Removing the count removes the lie without losing utility. |
| D3 | **Phase 3 order matches the article's H3 order**: CLAUDE.md → Hooks → Skills → Plugins → LSP → MCP → Subagents → (then docs-only surfaces: settings/sandbox/auto-memory/rules). | Eliminates the "stated hierarchy" mis-framing. Where the skill diverges, it owns the divergence explicitly. |
| D4 | **Phase 4 is inline, not a fork.** | Output IS the deliverable; forking it loses immediate user context for no gain. |
| D5 | **Adaptive Phase 3 dispatch.** Fix forks for surfaces with no Phase 1 findings are skipped, not dispatched as no-ops. | Disproportional fixed dispatch was a v2 over-engineering issue. |
| D6 | **CAVEATS.md restructured into 13 operational gotchas only.** The 5 best-practices items (current #14-#18: `InstructionsLoaded`, `.lsp.json` location, DRI, cadence, skill bundling) move into a new `## Best practices` section in SKILL.md. | Mixing gotchas with policy dilutes both. |
| D7 | **Rules is promoted out of "safe trims only".** Phase 3 includes a real Rules fix fork with explicit scope (path-scoping conversion, deletion-test trims). Consolidations still defer to `_CONSOLIDATION_PROPOSALS.md`, but with a documented drain mechanism. | Audit found Rules was structurally demoted — included in Phase 1 audit, excluded from Phase 3 hierarchy. |
| D8 | **Bundled-skills recipe check** (`/run`, `/verify`, `/run-skill-generator`) added to Phase 0. | Anthropic explicitly recommends per-project capture; absence is a real gap any audit should flag. |
| D9 | **`.claude/session/REVIEW_DUE.md` + Stop-hook surfacing** is part of Phase 4 deliverables. | The "Next review due" date currently ages quietly; this gives it a mechanism. |
| D10 | **`_CONSOLIDATION_PROPOSALS.md` drain mechanism**: Phase 0 reads it as the first action. Any unprocessed items from a prior cycle are surfaced to the user as "carry-over" before this cycle's audit dispatches. | Today the file is procrastination dressed as caution. |
| D11 | **Concrete validation commands** for Phase 3 self-validation. No more "frontmatter linting". | Audit flagged "frontmatter linting for skills" as hand-waving. |
| D12 | **Two-file repo structure preserved**: `SKILL.md` + `docs/CAVEATS.md` remain the only operational artefacts. No new files committed. | Audit endorsed the v2 bundling decision. Don't proliferate. |
| D13 | **Surfaces in scope are 11**, mapped to 7 audit forks and up to 10 fix forks. The mapping table makes the relationship explicit. | Resolves the v2 "9 surfaces / 7 forks / 10 fix forks" counting drift. |
| D14 | **Hook coverage**: name all 31 events in the audit prompt (Fork D template) but ask the right *question* rather than enumerate one prompt per event. | Audit found Fork D covers ~10% of hook surface. Enumeration is the fix. |
| D15 | **`disableSkillShellExecution` moves to Fork C (skills) and CAVEAT placement updated.** | Factual error in v2 — it's a skills control, not MCP. |
| D16 | **Sandbox subsystem audit** lives in Fork E alongside settings + permissions + worktree. All four are settings.json blocks. | Audit found sandboxing was entirely unaudited; grouping with adjacent settings keeps fork count stable. |

---

## 2. 🗂️ Surfaces and fork map (canonical)

The single source of truth for surface→fork mapping. The spec writes this table verbatim into SKILL.md (§7 in the new content) — it replaces v2's three inconsistent tables.

| # | Surface | Source | Phase 1 fork | Phase 3 fix-fork |
|---|---|---|---|---|
| 1 | 📜 CLAUDE.md hierarchy (root + nested) | article | A | Fix-1 (root), Fix-2 (nested) |
| 2 | 🗺️ Codebase navigability (`.claudeignore`, scoped test/lint, codebase maps, monorepo invocation) | article | A | Fix-1 / Fix-2 (companion edits) |
| 3 | 📋 Rules (`.claude/rules/`) | docs | B | Fix-10 (trims + path-scoping; consolidations deferred) |
| 4 | 🎯 Skills (`.claude/skills/`) + slash commands migration | article (skills) + docs (commands) | C | Fix-4 |
| 5 | 🤖 Sub-agents (`.claude/agents/`) | article | C | Fix-5 |
| 6 | 🪝 Hooks (`.claude/settings.json` → `hooks`) — 31 events × 5 handler types + skill/agent-scoped | article + docs | D | Fix-3 |
| 7 | ⚙️ Settings + permissions + sandbox + worktree (`.claude/settings.json` + `.local.json` + managed) | docs | E | Fix-3 (companion edits) |
| 8 | 🔌 MCP (`.mcp.json` + tool-search posture) | article | F | Fix-8 |
| 9 | 🔎 LSP (pre-built plugin first, `.lsp.json` fallback) | article | F | Fix-7 |
| 10 | 📦 Plugins (`.claude-plugin/plugin.json` + `marketplace.json` + `monitors/`) | article | F | Fix-6 |
| 11 | 🧠 Auto-memory (`~/.claude/projects/<proj>/memory/`) | docs | G | Fix-9 |

**Forks:** 7 audit (A-G), up to 10 fix (Fix-1…Fix-10), but Phase 3 is adaptive — fix forks for surfaces with zero Phase 1 findings are skipped.

**Article H3 order for Phase 3:** Fix-1 → Fix-2 → Fix-3 → Fix-4 → Fix-5 → Fix-6 → Fix-7 → Fix-8 → Fix-9 → Fix-10.

This matches the article's section §2 H3 order (CLAUDE.md → Hooks → Skills → Plugins → LSP → MCP → Subagents) with docs-only surfaces appended (auto-memory, rules). Where the skill diverges from article order, the divergence is noted in the SKILL.md body.

---

## 3. 🚦 Versioning + release plan

**v3.0.0 — major bump.** Breaking because:
- "9 official surfaces" framing dropped (anyone scripting against that phrase needs to update)
- Phase 3 fork dispatch is adaptive (number of forks per cycle is variable)
- Phase 4 wrap is inline (one fewer fork per cycle)
- CAVEATS structure changed (gotchas separated from best-practices)
- Phase 3 order rewritten to match article H3

**Commit message:**
```
feat!: v3.0.0 — close all 41 audit findings; restructure to match article + docs

Breaking:
- Drop "9 official surfaces" framing; replace with provenance-tagged surface list
- Phase 3 dispatch is adaptive; fork count varies by Phase 1 findings
- Phase 4 wrap is inline (no longer a fork)
- CAVEATS restructured: 13 gotchas + best-practices moved to SKILL.md
- Phase 3 order matches article H3

Factual fixes:
- skillListingBudgetFraction default is 0.01, not ~0.10
- disableSkillShellExecution moved from MCP to Skills/Settings
- LSP docs URL fixed (/en/plugins-reference#lsp-servers)
- Cadence quote completed (adds plateau/major-release trigger)
- "Self-improving Stop hook" framed as community pattern

Coverage additions:
- Sandbox subsystem audit (Fork E)
- Permissions block (allow/ask/deny/defaultMode)
- 31 hook events + 5 handler types
- Per-frontmatter audit for skills + sub-agents
- Worktree configuration (worktree.*)
- MCP tool-search posture (ENABLE_TOOL_SEARCH / alwaysLoad)
- Bundled /run /verify /run-skill-generator recipe check
- .claude/commands/ migration to skills
- Settings layering (managed > CLI > local > project > user)
- .claude/settings.local.json gitignore check
- Marketplace manifest, monitors.json

See AUDIT-v2.0.0-REVIEW.md for full finding-to-fix trace.
```

**Tag:** `v3.0.0`. No emergency v2.0.1 patch — the comprehensive fix lands in one ship.

---

## 4. 📁 File-by-file specification

Four files change. Two get full rewrites (target content below verbatim). Two get targeted diffs.

### 4.1 SKILL.md — REWRITE

**Action:** Replace entire file with the content in this section. Final line count target: ~280-310 lines (vs v2's 163, but the increase is real content — 200-word fork prompt templates, new surfaces, best-practices section, mapping table).

**Frontmatter `description` rewrite:** Replace the v2 description (which says "9 official surfaces") with:
```
description: Audit and improve a Claude Code project's AI layer end-to-end. Covers the AI-layer surfaces — CLAUDE.md hierarchy, codebase navigability, rules, skills, sub-agents, hooks, MCP, LSP, plugins, auto-memory, settings/permissions/sandbox/worktree. Parallel forked audit with 200-word per-fork prompt templates; disjoint-scope adaptive fixes, ordered per the article's H3 hierarchy. Trigger phrases - "audit my AI layer", "audit Claude config", "large codebase audit", "tune my .claude", "apply Anthropic patterns", "harness audit", "improve Claude Code setup", "Anthropic large codebase". Use proactively when CLAUDE.md is heuristically over ~80 lines, when no nested CLAUDE.md exists at meaningful sub-tree boundaries, or when entering a large untuned codebase.
```

Note: "heuristically over ~80 lines" — the threshold stays but is explicitly marked as a heuristic, not a sourced number.

**Full target body content (after frontmatter):**

```markdown
# Large Codebase AI-Layer Audit & Fix

A single audit-and-fix cycle for any Claude Code project. Implements the patterns described in [How Claude Code works in large codebases](https://claude.com/blog/how-claude-code-works-in-large-codebases-best-practices-and-where-to-start) and cross-referenced against the [official Claude Code docs](https://code.claude.com/docs/en).

The article's thesis is that **the harness matters as much as the model**. This skill audits the harness as a whole, not as a checklist of components.

> **Scope:** This skill assumes a conventional source-code project. Non-traditional setups (game engines with binary asset pipelines, generated-only repos, etc.) may need a tailored audit; the workflow below is the universal case.

## 🎯 When to use this skill

- 🔧 User asks to audit, tune, or modernise their Claude Code AI layer
- 📥 Entering a large codebase (>50K LOC, >10 subdirectories) for the first time
- 📏 Root `CLAUDE.md` heuristically over ~80 lines or containing an inline rule index
- 🚫 No nested `CLAUDE.md`, no project-scope skills, no project-scope sub-agents
- 📰 User references Anthropic's large-codebase article
- 🗓️ Last configuration review is more than 3-6 months old, OR performance feels like it's plateaued after a major model release (the article's two cadence triggers)

## 🧱 The AI-layer surfaces this skill audits

Each surface is tagged by source: `[article]` if the Anthropic article explicitly discusses it, `[docs]` if it's in the official docs but not the article. No fixed surface count — new docs surfaces may emerge between major model releases.

| # | Surface | Source | Where it lives | Key audit question |
|---|---|---|---|---|
| 1 | 📜 CLAUDE.md hierarchy | [article] | Root + nested `CLAUDE.md` | Root concise, pointers-only? Nested files at sub-tree boundaries? Any rules legacy for older model behaviour? |
| 2 | 🗺️ Codebase navigability | [article] | `.claudeignore`, codebase maps, monorepo invocation, scoped test/lint in nested CLAUDE.md | Is Claude invoked at sub-tree roots in monorepos? Do nested files scope test/lint commands? |
| 3 | 📋 Rules | [docs] | `.claude/rules/*.md` | Always-loaded that could be path-scoped? Rules that are skills in disguise? Legacy mitigations? |
| 4 | 🎯 Skills + slash commands | [article] + [docs] | `.claude/skills/*/SKILL.md`, `.claude/commands/*.md` | Per-frontmatter-field audit; orphan supporting files; `.claude/commands/*` migration candidates; bundled `/run` `/verify` `/run-skill-generator` recipe captured? |
| 5 | 🤖 Sub-agents | [article] | `.claude/agents/*.md` | Field-by-field audit of every agent: `tools` allowlist, `permissionMode`, `model` cost, `memory` opportunity, `mcpServers` scoping, `isolation: worktree` candidates |
| 6 | 🪝 Hooks | [article] | `.claude/settings.json` → `hooks` | Which of the 31 documented events are used? Handler types beyond `command`? Skill/agent-scoped hooks? Continuous-improvement opportunities, not just safety? |
| 7 | ⚙️ Settings + permissions + sandbox + worktree | [docs] | `.claude/settings.json`, `.local.json`, `managed-settings.json` | Permissions `defaultMode`? Sandbox enabled where untrusted code runs? Worktree config for monorepos? Settings layering (managed > CLI > local > project > user) coherent? `settings.local.json` gitignored? |
| 8 | 🔌 MCP | [article] | `.mcp.json` + `~/.claude.json` local scope | Project-scope registered? `ENABLE_TOOL_SEARCH` / `alwaysLoad` posture for multi-server projects? `MAX_MCP_OUTPUT_TOKENS`? |
| 9 | 🔎 LSP | [article] | Pre-built plugin first; `.lsp.json` fallback | Pre-built LSP plugin installed for dominant language? If custom `.lsp.json`, is `extensionToLanguage` correct? Binary present? |
| 10 | 📦 Plugins | [article] | `.claude-plugin/plugin.json`, `marketplace.json`, `monitors/` | If the project is a plugin: manifest fields complete? Marketplace-ready? Inline `mcpServers` vs `.mcp.json`? Monitors defined? |
| 11 | 🧠 Auto-memory | [docs] | `~/.claude/projects/<proj>/memory/` | `MEMORY.md` first 200 lines OR 25KB cutoff respected? Topic files (load on demand) curated? `autoMemoryEnabled` set? |

Two cross-cutting settings.json knobs sit alongside these surfaces:

- `skillListingBudgetFraction` (default `0.01`), `maxSkillDescriptionChars` (default 1536), `skillOverrides` (`on` / `name-only` / `user-invocable-only` / `off`) — skill-budget controls
- `claudeMdExcludes` — monorepo CLAUDE.md trim knob

## 🔄 Workflow

### Phase 0 — Pre-flight (2-3 minutes)

1. ✅ Confirm git repo root (or project root inside a monorepo)
2. 🪂 Check fork-mode: `echo $CLAUDE_CODE_FORK_SUBAGENT` should return `1` — if unset, fall back to `subagent_type: general-purpose` (cache-miss cost)
3. 🩹 **Drain carry-over:** if `.claude/_CONSOLIDATION_PROPOSALS.md` exists from a prior cycle, surface its unprocessed items to the user as "carry-over from last cycle" — do not start a new cycle with stale proposals still queued
4. 🏗️ **Scaffold check:** if no `.claude/` directory exists, create it during Phase 3 with the minimum viable shape (no rules/skills/agents yet, just the directory and a stub `settings.json`)
5. 📜 Read root `CLAUDE.md`, `ARCHITECTURE.md` (if present), `.claude/settings.json`, `.claude/settings.local.json` (check gitignore status), list `.claude/rules/`, `.claude/skills/`, `.claude/agents/`, `.claude/commands/`, `.claude/output-styles/`
6. 🔍 Capture the `InstructionsLoaded` hook output if available — canonical "what actually loaded" diagnostic
7. 🧭 Identify dominant tech stack (Next.js? Rails? Django? Go?) — informs LSP plugin choice
8. 📦 **Bundled-skills check:** has the project captured `/run` / `/verify` / `/run-skill-generator` recipes? Absence is a real gap to surface in Fork A's punch list
9. 🌳 **Monorepo check:** if multiple `package.json` / `Cargo.toml` / `go.mod` exist at sub-tree roots, note this — Fork A's prompt expands to traverse per-package `.claude/` directories and check whether Claude is being invoked at sub-tree roots vs the repo root
10. 🚦 Note the user's autonomy level: explicit "go" / "just do it" / `--yes` → high autonomy; otherwise plan to confirm before Phase 3

### Phase 1 — Audit (7 parallel read-only forks in ONE message)

Dispatch all forks in a single `Agent`-tool message. Forks (no `subagent_type`) inherit context; named sub-agents are the fallback if fork-mode is off. Each fork is **read-only**, uses a full 200-word prompt template (below), and reports a punch list under 800 words.

#### Fork A — CLAUDE.md hierarchy + codebase navigability

> Audit the root `CLAUDE.md`, every nested `CLAUDE.md`, and codebase-navigability artefacts. For the root: line count and top-3 line-cost sections (`wc -l`, scan for embedded rule indexes), derivable content (paths, defaults a model already knows), pointer hygiene. For nested files: are they at meaningful sub-tree boundaries, do they scope test/lint commands per the article, do they contain any legacy mitigations a current model wouldn't need (e.g. "don't use X because the model can't handle Y" where Y is solved)? For navigability: does `.claudeignore` exist? What does it exclude? What *should* it exclude given the repo tree? Is there a codebase map (markdown describing directory structure) — and if not, propose where one would live. For monorepos: is Claude being invoked at sub-tree roots or at the repo root (the article specifically recommends the former)? Note: HTML block-level comments are stripped from CLAUDE.md by the loader — if any nested file uses them for structure, flag. Report a punch list under 800 words: concrete trim proposals with line ranges, missing-nested-file proposals (4-7 at most — don't over-fragment), `.claudeignore` recommendations, legacy-rule deletion candidates with rationale. Read-only.

#### Fork B — Rules

> Audit `.claude/rules/*.md` for: always-loaded vs path-scoped split (which currently-always-loaded rules could be path-scoped to specific file extensions or directories?); consolidation candidates (rules covering the same topic that could merge); rule-vs-skill misclassifications (rules with numbered steps or ordered phases are skills in disguise; one-paragraph "use library X for Y" skills are rules in disguise); deletion candidates per the Deletion Test ("if I delete this rule, what changes? if 'nothing measurable', it's a candidate"); legacy mitigations a current model wouldn't need. For each `paths:` frontmatter, verify it's the comma-separated string or YAML list form (issue #17204 affects rules' `paths:` parser; quote globs starting with `*` or `{`). Note: `description:` is undocumented for rules — flag any rule whose `description:` is doing real work as a candidate for skill conversion. Report a punch list under 800 words: path-scoping proposals (rule → suggested `paths:` value), consolidation candidates (defer to `_CONSOLIDATION_PROPOSALS.md` for human review), deletion candidates with rationale. Do NOT propose immediate consolidations — those break pointers other forks rely on this cycle. Read-only.

#### Fork C — Skills + sub-agents + slash commands

> Three sub-audits in one fork because they share `.claude/` neighbours and frequently cross-reference each other. **Skills:** for each existing `.claude/skills/*/SKILL.md`, audit every documented frontmatter field — `name`, `description` (the trigger field; specific? lists trigger phrases? names proactive-use conditions?), `when_to_use` (combined with `description` under 1536 chars?), `paths:`, `allowed-tools` (pre-approval audit — trust-on-load risk for side-effect skills), `disable-model-invocation` (set for deploy/commit-style skills?), `user-invocable: false` (for background-knowledge skills the user shouldn't see in `/skills`?), `context: fork` opportunities (deep one-shot tasks that flood main context?), `agent:` paired with `context: fork`, `model` / `effort` overrides, `argument-hint`, skill-scoped `hooks:` frontmatter block. Also check `${CLAUDE_SKILL_DIR}` usage in bundled scripts (hardcoded paths break plugin install), orphan supporting files outside the skill dir, 500-line SKILL.md soft cap. **Sub-agents:** for each existing `.claude/agents/*.md`, field-by-field — `tools` allowlist vs `disallowedTools` denylist (read-only vs write distinction), `permissionMode` (especially `bypassPermissions` misuse), `model` (Haiku-cheap for high-volume?), `maxTurns` runaway protection, `skills:` preload (domain-agent enablement), `mcpServers:` scoping (keeps MCP off main context), agent-scoped `hooks:`, `memory: user/project/local`, `background: true` candidates, `isolation: worktree` candidates, `Agent(agent_type)` tool-list restriction for coordinators. **Slash commands:** `.claude/commands/*.md` is the legacy form; v2.1.145+ merges commands into skills. Flag candidates for migration. Also check whether the bundled `/run`, `/verify`, `/run-skill-generator` recipes have been captured. Report a punch list under 800 words. Read-only.

#### Fork D — Hooks

> Audit `.claude/settings.json` `hooks` block (and any plugin-provided `hooks/hooks.json`) against the 31 documented hook events. Group by category: **Session lifecycle** (`SessionStart`, `Setup`, `SessionEnd`); **User input** (`UserPromptSubmit`, `UserPromptExpansion`, `Stop`, `StopFailure`); **Tool execution** (`PreToolUse`, `PostToolUse`, `PostToolUseFailure`, `PostToolBatch`, `PermissionRequest`, `PermissionDenied`); **Sub-agent/team** (`SubagentStart`, `SubagentStop`, `TeammateIdle`); **Task management** (`TaskCreated`, `TaskCompleted`); **Context/config** (`InstructionsLoaded`, `ConfigChange`, `CwdChanged`, `FileChanged`); **Notifications/elicitation** (`Notification`, `Elicitation`, `ElicitationResult`); **Compaction/worktree** (`PreCompact`, `PostCompact`, `WorktreeCreate`, `WorktreeRemove`). For each used hook: which of the 5 handler types (`command`, `http`, `mcp_tool`, `prompt`, `agent`) — is a `command` replaceable by `prompt` or `agent` for cleaner integration? Are `if:` permission-rule filters used on tool events? Are `async` / `asyncRewake` / `once` flags appropriate? Check exit-code semantics (0 = JSON parse, 2 = block-with-stderr) and `hookSpecificOutput` contracts. **Continuous improvement framing:** the article's main hook value is *continuous improvement* (self-improving Stop hook is a community pattern, not docs canon), not just safety. Identify candidates: `UserPromptSubmit` prompt-shaping reminders, `PreCompact` for context-management automation, `SessionStart`/`SessionEnd` for bootstrap/wrap workflows. Also audit skill-scoped (`hooks:` in SKILL.md frontmatter) and agent-scoped (`hooks:` in agent .md) hooks. Check `disableAllHooks`, `allowedHttpHookUrls`, `httpHookAllowedEnvVars`, `allowManagedHooksOnly`. Report a punch list under 800 words. Read-only.

#### Fork E — Settings + permissions + sandbox + worktree

> Audit `.claude/settings.json`, `.claude/settings.local.json`, and (if discoverable) `managed-settings.json` for: **Settings layering** — managed > CLI > local > project > user precedence understood; conflicts surfaced. **`settings.local.json` gitignore status** — if not gitignored, flag immediately (common foot-gun: secrets get committed). **Permissions block** — `allow` / `ask` / `deny` / `defaultMode` (default / acceptEdits / plan / auto / dontAsk / bypassPermissions — which posture matches project intent?) / `additionalDirectories`. Read/Edit rule path anchors (`//absolute`, `~/home`, `/project-root`, `./cwd`). Bash wildcard + process-wrapper stripping semantics. `Agent(Name)` rules to disable specific subagents. MCP permission patterns (`mcp__server`, `mcp__server__*`, `mcp__server__tool`). `WebFetch(domain:...)` rules. **Sandbox subsystem** — `sandbox.enabled`, `filesystem.denyRead/Write`, `network.allowedDomains/deniedDomains`, `bwrapPath` on Linux, weaker mode for macOS — the largest security knob the v2 skill ignored. **Worktree config** — `worktree.baseRef/symlinkDirectories/sparsePaths/bgIsolation` — directly relevant to fork isolation in large codebases. **autoMode classifier rules** (`allow` / `soft_deny` / `hard_deny` / `environment`). **Skill-budget knobs** — `skillListingBudgetFraction` (default `0.01`; lowering to `0.005` for skill-heavy projects can free meaningful context), `maxSkillDescriptionChars` (default 1536), `skillOverrides`. **`claudeMdExcludes`** opportunities. **`disableSkillShellExecution`** — for projects installing third-party skills from a marketplace or in security-sensitive build environments. **`outputStyle`** (does the project pin one?). **Plan-mode `plansDirectory` / `useAutoModeDuringPlan`** — where do plan files land? gitignored? Report a punch list under 800 words. Read-only.

#### Fork F — MCP + LSP + plugins

> Audit MCP, LSP, and plugin surfaces. **MCP:** inventory `.mcp.json` and `~/.claude.json` local scope (the default scope, often forgotten). Check transport types (`http`, `sse` deprecated, `stdio`, `streamable-http`). **Tool-search posture** — for projects with >3 MCP servers, is `ENABLE_TOOL_SEARCH` set (default / `true` / `auto` / `auto:N` / `false`)? Are servers marked `alwaysLoad: true`? This is the single largest MCP context cost. `MAX_MCP_OUTPUT_TOKENS` (default 25K, warn at 10K). OAuth + `headersHelper` patterns. `${CLAUDE_PLUGIN_ROOT}` / `${VAR:-default}` expansion. Managed `allowedMcpServers`/`deniedMcpServers`/`allowManagedMcpServersOnly`. **LSP:** is there a pre-built LSP plugin (TypeScript, Python, Rust) for the dominant language? The docs prefer installing the plugin over rolling a custom `.lsp.json`. If custom: schema (`command`, `args`, `extensionToLanguage`), location (plugin root canonical), binary install state. **Plugins:** if the project is a plugin, validate `.claude-plugin/plugin.json` (name, description, version, author, homepage, repository, license). Check `.claude-plugin/marketplace.json` for distribution. `monitors/monitors.json` schema (name, command, description, when). `bin/` PATH addition. Plugin `settings.json` honors only `agent` + `subagentStatusLine`. Inline `mcpServers` vs `.mcp.json` choice. For projects that *consume* plugins: managed `strictKnownMarketplaces`, `blockedMarketplaces`, `strictPluginOnlyCustomization`. Report a punch list under 800 words. Read-only.

#### Fork G — Auto-memory

> Audit `~/.claude/projects/<project-path>/memory/`. Storage path keyed by git repo (worktrees share). **`MEMORY.md` load behaviour:** first 200 lines OR 25KB (whichever first) load at session start; topic files (everything else in the directory) load **on demand**, not at session start — so pruning topic files does NOT reduce session-start cost, only relevance noise. Audit `MEMORY.md` content for: items that should be moved into a topic file (so they don't pay startup cost), stale pointers to topic files that no longer exist, missing `[[name]]` links to existing topic files. Audit topic files for: entries the user has corrected since (cross-reference recent session if available), redundant duplicates, type drift (the user-convention of typing memories as user/feedback/project/reference is a community pattern, not a docs schema — but if the project uses it, prune by type). Check `autoMemoryEnabled` setting (can be silently disabled at managed/user level) and `CLAUDE_CODE_DISABLE_AUTO_MEMORY` env. Per-subagent auto-memory exists separately at `~/.claude/projects/<proj>/agents/<agent>/memory/` — check if present. Minimum Claude Code version: v2.1.59+. Report a punch list under 800 words: items to move from MEMORY.md to topic files, items to remove from MEMORY.md, stale topic files to delete. Read-only.

### Phase 2 — Synthesise and order fixes (sequential, 3-5 min)

Once all 7 audit forks return, synthesise into a Phase 3 plan with **explicit, non-overlapping write scopes**. Map every fix to one fork and one set of files. Two forks must never write to the same file.

**Adaptive dispatch:** if Fork X reports zero actionable items, skip Fix-X. Don't dispatch no-op forks.

**Order the fix forks per the article's H3 hierarchy** in §2 ("The harness matters as much as the model"). The article H3 order is: CLAUDE.md → Hooks → Skills → Plugins → LSP → MCP → Subagents. The skill appends docs-only surfaces (auto-memory, rules) at the end. Where this ordering diverges from earlier versions of the skill, the divergence is intentional and matches the article.

```
1. Fix-1   — CLAUDE.md (root)                          [article]
2. Fix-2   — Nested CLAUDE.md + codebase navigability  [article]
3. Fix-3   — Hooks + settings + permissions + sandbox  [article + docs]
4. Fix-4   — Skills + slash-commands migration         [article + docs]
5. Fix-5   — Sub-agents                                [article]
6. Fix-6   — Plugins (if project is a plugin)          [article]
7. Fix-7   — LSP (install plugin or write .lsp.json)   [article]
8. Fix-8   — MCP (.mcp.json + tool-search posture)     [article]
9. Fix-9   — Auto-memory pruning + topic-file moves    [docs]
10. Fix-10 — Rules (path-scoping + deletion-test trims; consolidations deferred to _CONSOLIDATION_PROPOSALS.md) [docs]
```

State the plan to the user as a write-scope table:

```
| Fork  | Owns (exclusive write scope)                             |
|-------|----------------------------------------------------------|
| Fix-1 | CLAUDE.md (root only)                                    |
| Fix-2 | Nested CLAUDE.md (specific paths) + .claudeignore        |
| Fix-3 | .claude/settings.json + .claude/scripts/                 |
| Fix-4 | .claude/skills/ (new dirs + frontmatter) + .claude/commands/ migration |
| Fix-5 | .claude/agents/ (new files + edits to existing)          |
| Fix-6 | .claude-plugin/                                          |
| Fix-7 | .lsp.json + LSP binary install                           |
| Fix-8 | .mcp.json                                                |
| Fix-9 | ~/.claude/projects/<proj>/memory/ (specific files)       |
| Fix-10| .claude/rules/ (path-scoping + safe trims; consolidations deferred) |
```

If the user has not said "go" / "yes" / `--yes`, confirm the plan before dispatching.

### Phase 3 — Fix (adaptive parallel write forks in ONE message)

Dispatch the active fix forks in a single `Agent` message. Each fork's prompt must:

1. 🚧 State its **EXCLUSIVE write scope** at the top: "do NOT touch any file outside this list"
2. 👯 Name the other forks running in parallel and their write scopes (so each fork stays in lane)
3. 📝 Include the specific changes (lines to cut, files to create, frontmatter to add)
4. ✅ Require self-validation using concrete commands:
   - JSON: `jq empty .claude/settings.json && echo OK`
   - Shell scripts: `bash -n .claude/scripts/*.sh`
   - CLAUDE.md size: `wc -l CLAUDE.md` — flag if root exceeds the project's heuristic
   - Skill/agent frontmatter: `python3 -c "import yaml,sys; yaml.safe_load(open(sys.argv[1]).read().split('---')[1])" path/to/SKILL.md` (or `yq eval '.name,.description' path/to/SKILL.md`)
   - Plugin manifest: `jq empty .claude-plugin/plugin.json && jq '.name,.description,.version' .claude-plugin/plugin.json`
5. 📤 Report back: files touched, line counts, validation results, surprises

Critical guardrails:

- ❌ Never run two write forks against the same file
- 🛑 Defer rule consolidations and rule-to-skill conversions to `.claude/_CONSOLIDATION_PROPOSALS.md` for human review. Phase 0 of the *next* cycle drains this file as its first action.
- 🪪 For skills' `paths:` frontmatter, use the documented form (comma-separated string or YAML list). The parser bug at issue #17204 affects *rules*, not skills.
- 🔁 If MCP entries are added or changed, the wrap notes the user must **restart Claude Code** (not `/clear`) before they register.
- 🔥 Settings layering reminder: managed settings always win; if a managed `claudeMd` or managed permissions exist, fix forks must not propose changes that conflict.

### Phase 4 — Wrap + cadence (inline, ~5 min)

Run inline — this is the deliverable; don't fork it.

1. ✅ Run verification commands (file counts, `jq` syntax, `bash -n`, frontmatter parse).
2. 📝 Write `.claude/session/large-codebase-audit-YYYY-MM-DD.md` with:
   - Summary of changes per surface
   - Open questions and deferred items (link to `_CONSOLIDATION_PROPOSALS.md`)
   - **Recommended DRI variant** for ongoing Claude Code config management:
     - *DRI* (the minimum viable: one person with ownership over the Claude Code configuration, settings, permissions, marketplace, CLAUDE.md conventions); OR
     - *Agent-manager* (hybrid PM/engineer role the article describes for orgs running more parallel agent work)
     - Frame the *why*: per the article, without ownership *"knowledge will stay tribal and adoption will plateau"*.
   - **Next review due** date: today + 90 days (article's 3-6 month cadence; the lower bound). Note the article's *second* cadence trigger: *"whenever performance feels like it's plateaued after major model releases"* — record any recent Anthropic model release date for context.
3. 📅 Write `.claude/session/REVIEW_DUE.md` with the next-review-due date as a single line. A Stop hook can read this and surface it once per session if the date has passed.
4. 🧹 If `claude-rule-sync` (or equivalent cross-platform sync tool) is available, run dry-run only — do not auto-write.
5. 🚨 Surface the 3-7 critical "do this BEFORE next session" actions (e.g. "restart Claude Code for new MCP entries", "review `_CONSOLIDATION_PROPOSALS.md` before next audit").
6. ♻️ If the user is in a multi-person org and no DRI signal exists (no `.claude/OWNERS`, no `CODEOWNERS` entry covering `.claude/`, no `CLAUDE.md` "Maintainer" line), recommend assigning one explicitly. Offer both DRI and agent-manager framings.

## 📐 Best practices (lifted from the article + docs, not gotchas)

These are policy items rather than operational gotchas. Apply them every cycle.

### B-P1 — `InstructionsLoaded` is the canonical "what loaded?" diagnostic

Instead of manually reading every CLAUDE.md and rule file to figure out what's actually in context, the `InstructionsLoaded` hook reports it directly. Use this as Phase 0 step 6 / Fork A's first command.

### B-P2 — LSP config lives in `.lsp.json` (or pre-built plugin)

The canonical location is `.lsp.json` inside a plugin root. Pre-built LSP plugins for common languages (TypeScript, Python, Rust) exist and are recommended — install the plugin before rolling a custom `.lsp.json`. Symbol-server binary install is separate.

Docs: [`/en/plugins-reference#lsp-servers`](https://code.claude.com/docs/en/plugins-reference#lsp-servers).

### B-P3 — Multi-person orgs need a Claude Code owner

The Anthropic article dedicates an H3 to assigning ownership. Two valid shapes:

- **DRI** — minimum viable: one person with authority over settings, permissions policy, marketplace choices, CLAUDE.md conventions.
- **Agent-manager** — for orgs running more parallel agent work, a hybrid PM/engineer role.

Without a named owner: configuration drifts, nobody schedules the 3-6 month review, contradictions accumulate. The article frames it sharply: *"Without that work, knowledge will stay tribal and adoption will plateau."*

If a multi-person-org audit finds no ownership signal (no `.claude/OWNERS`, no `CODEOWNERS` entry covering `.claude/`, no `CLAUDE.md` "Maintainer" line), Phase 4 should recommend assigning one.

### B-P4 — Cadence: 3-6 months, or whenever performance plateaus after a major model release

Full article quote: *"Teams should expect to do a meaningful configuration review every three to six months, but it's also worth doing one whenever performance feels like it's plateaued after major model releases."*

Two triggers, not one. Phase 4 should record both: the time-based next-review date and the latest known Anthropic model release date for context.

### B-P5 — Skill bundling: everything inside the skill directory

If a skill needs supporting docs, schemas, or scripts, they live inside the skill's own directory (`skills/<name>/docs/`, `skills/<name>/references/`, `skills/<name>/scripts/`) — never scattered elsewhere. Skills must be portable across machines, repos, and Claude / Codex / Copilot loaders. Use `${CLAUDE_SKILL_DIR}` in bundled scripts, never hardcoded paths.

The exception is project-specific templates — those should not exist in a universal skill at all, because they pollute the universal use case.

## 🚨 Critical operational caveats (summary)

Full versions with citations and mitigations live in [`docs/CAVEATS.md`](docs/CAVEATS.md). Highlights:

- 🔄 Path-scoped rules trigger on file READ, not Write/Create (issue #23478)
- 🐛 Rules' `paths:` YAML-list form has parser quirks (issue #17204) — does NOT affect skills
- 🧾 `description:` is undocumented for rules; for skills it IS the primary trigger field
- 💸 Stop hooks that introspect the conversation and update rules/skills (community pattern; not docs canon) cost tokens every session-end — always provide an opt-out env var
- 🔁 MCP changes require Claude Code restart, not `/clear`
- 🍴 Forks cannot spawn further forks — this skill must run in the main thread
- 🛑 Cross-fork write coordination requires disjoint scopes; one file → one fork
- 🎭 Rules vs skills misclassification is the most common drift
- 📦 Plugin layout per official spec — there is no `tooling/` directory
- 📜 Block-level HTML comments are stripped from CLAUDE.md by the loader — don't use them for structure
- 🧠 `MEMORY.md` is first 200 lines OR 25KB (whichever first); topic files load on demand

## ✅ Fork-dispatch checklist (run mentally before EVERY parallel batch)

- [ ] All forks have **explicit write scopes** (or read-only declaration)?
- [ ] No two forks write to the **same file**?
- [ ] Fork prompts include **other forks' scopes** so they stay in lane?
- [ ] Self-validation step in **each fix fork** with a concrete command (jq, bash -n, wc -l, yaml parse)?
- [ ] Dispatched in a **single message** for true parallelism?
- [ ] Phase 3 dispatched in the article's H3 order (CLAUDE.md → Hooks → Skills → Plugins → LSP → MCP → Subagents → docs-only)?
- [ ] Adaptive: forks with zero Phase 1 findings skipped?

## 📚 Reference materials

- 📰 [Anthropic article — How Claude Code works in large codebases](https://claude.com/blog/how-claude-code-works-in-large-codebases-best-practices-and-where-to-start)
- 📖 [Official Claude Code docs](https://code.claude.com/docs/en) — skills, sub-agents, memory, hooks, MCP, plugins, settings, permissions, sandboxing, worktrees, output-styles, auto-mode, plugins-reference (LSP)
- 🚨 [`docs/CAVEATS.md`](docs/CAVEATS.md) — 13 operational gotchas with citations and mitigations
- 🔍 [`AUDIT-v2.0.0-REVIEW.md`](AUDIT-v2.0.0-REVIEW.md) — the audit that drove this v3.0.0
```

**End of SKILL.md target content.**

---

### 4.2 docs/CAVEATS.md — REWRITE

**Action:** Replace entire file. Restructured to 13 operational gotchas only; the 5 best-practices items (`InstructionsLoaded`, LSP location, DRI, cadence, skill bundling) are moved to SKILL.md's new Best Practices section.

**Full target content:**

```markdown
# Operational Caveats — `large-codebase-audit`

Operational gotchas that affect how an AI-layer audit plays out in practice. Sourced from the official [Claude Code docs](https://code.claude.com/docs/en), issue tracker, and field experience across real codebases. **Gotchas only** — best practices (DRI, cadence, skill bundling, `InstructionsLoaded` use, LSP location) live in [`SKILL.md`](../SKILL.md) → *Best practices*.

---

## G1. 🔄 Path-scoped rules trigger on file READ, not on Write/Create

Per the official memory doc: *"Path-scoped rules trigger when Claude reads files matching the pattern, not on every tool use."*

**Implication for audits:** a nested `CLAUDE.md` you place at `subdir/CLAUDE.md` will NOT auto-load when Claude *creates* a brand-new file inside `subdir/`. It loads when Claude *reads* a matching file.

**Mitigations:**
- Have the parent / root `CLAUDE.md` reference the existence of the nested file (pointer-style)
- Duplicate truly load-bearing invariants at root scope (sparingly)
- Issue #23478 tracks the broader behaviour

---

## G2. 🐛 Rules' `paths:` YAML-list form has known parser quirks

Issue #17204 documents that the YAML-list form of `paths:` in rules can fail silently or misparse glob patterns starting with `*` or `{`.

**Does NOT affect skills.** Per the official skills doc, skills' `paths:` is canonical: *"Accepts a comma-separated string or a YAML list. ... Uses the same format as path-specific rules."* Field reports confirm skills' loader handles both forms without the parser issue rules see.

**Mitigations (for rules only):**
- Quote glob patterns that start with `*` or `{`: `paths: ["**/*.ts"]`
- If the list form fails, fall back to the unquoted scalar form: `paths: **/*.ts`
- The community-discovered `globs:` alias also works but is undocumented

---

## G3. 🧾 `description:` field — different role on rules vs skills

| Surface | Is `description:` documented? | Loader effect |
|---|---|---|
| Rules | No | None — loader ignores it |
| Skills | Yes | **Primary trigger field** — drives auto-loading via natural-language matching |

**Implication for audits:**
- For rules: drop `description:` to reduce noise, or keep it as a human-readable comment with the understanding that it doesn't change behaviour
- For skills: invest in the description — make it specific, list trigger phrases, name proactive-use conditions

---

## G4. 💸 "Self-improving Stop hook" is a community pattern, not docs canon

The phrase "self-improving Stop hook" is widely used in field reports for a Stop hook that introspects the conversation and updates rules / skills / CLAUDE.md. **It is not documented in `/en/hooks` as an Anthropic-blessed pattern.** The `Stop` event exists; no self-refinement template ships with it.

**Implications:**
- Don't cite "self-improving Stop hook" as if it were docs terminology — frame it as a community pattern.
- The pattern is real and useful, but its cost (tokens at every session-end) and reliability (hooks fail silently) are *not* docs-managed.

**Mitigations:**
- Always provide an opt-out env var (e.g. `CLAUDE_DISABLE_HEADLESS=1`)
- Sample (run on every Nth session-end, not every one) for low-priority diagnostics
- Document the cost in the project's `CLAUDE.md` near the hook reference

---

## G5. 🔁 MCP server changes require Claude Code restart, not `/clear`

`/clear` resets the conversation but does not re-register MCP servers. New entries in `.mcp.json` (or new MCP entries in `.claude/settings.json`) are picked up only on a full Claude Code restart.

**Implication for audits:** if Phase 3 adds or modifies MCP entries, the Phase 4 wrap MUST surface a restart instruction to the user as a top-priority action.

---

## G6. 🍴 Forks cannot spawn further forks

Per the official subagents doc: *"A fork cannot spawn further forks."*

**Implication for this skill:** the audit-skill itself must run in the main thread. It orchestrates many forks; if it were a forked skill, it could only dispatch named sub-agents, losing the parallel-cache benefits forks provide.

**For other skills:** `context: fork` in skill frontmatter is the canonical declarative pattern for self-forking — useful for skills that do *one* deep task in isolation, not for orchestrators.

---

## G7. 🛑 Cross-fork write coordination requires disjoint scopes

When Phase 3 dispatches parallel write forks, two forks writing to the same file cause one to lose. The fork-dispatch checklist (one file → one fork) is load-bearing, not advisory.

**Mitigations:**
- Each fork's prompt states its EXCLUSIVE write scope at the top
- Each fork's prompt names the *other* forks running in parallel so it stays in lane
- Defer rule consolidations and rule-to-skill conversions to a `_CONSOLIDATION_PROPOSALS.md` doc for human review. The next cycle's Phase 0 drains the file as its first action.

---

## G8. 🎭 Rules vs skills misclassification is the most common drift

The simplest mental model:

- **Rule** = invariant. "Never do X." "Always use Y." Loads automatically (always or path-scoped). No workflow steps.
- **Skill** = workflow. "When the user asks for X, do Y, then Z, then verify W." Loads on description match or `paths:` match.

If a rule contains numbered steps, ordered phases, or "first do A, then B", it's a skill in disguise.

If a skill is just one paragraph saying "use library X for Y", it's a rule in disguise.

---

## G9. 📦 Plugin directory layout

Per the official plugins doc, the canonical plugin layout is:

```
my-plugin/
  .claude-plugin/
    plugin.json        # required manifest
    marketplace.json   # optional, for distribution
  skills/
  commands/            # legacy; new plugins prefer skills/
  agents/
  hooks/
  monitors/
  bin/                 # added to PATH while plugin enabled
  .mcp.json
  .lsp.json
  settings.json        # honors only `agent` and `subagentStatusLine`
```

There is **no `tooling/` directory** in the official spec. Earlier informal references to `tooling/` were incorrect.

A plugin can declare `mcpServers` inline in `plugin.json` instead of a separate `.mcp.json`.

---

## G10. 🧠 Auto-memory: `MEMORY.md` is 200 lines OR 25KB; topic files load on demand

Two facts that shape pruning advice:

1. **`MEMORY.md` cutoff:** the loader reads the first 200 lines OR 25KB, **whichever comes first**. Past either limit, content is silently truncated.
2. **Topic files load on demand**, not at session start. They pay zero session-start tokens. Pruning a topic file does not reduce startup cost — only relevance noise (and the chance of irrelevant content being pulled in mid-session).

**Implication for audits:**
- Items eating session-start cost live in `MEMORY.md`. To free startup tokens, move content from `MEMORY.md` into topic files (not the other way round).
- Items eating mid-session relevance live in topic files. Pruning these helps avoid the LLM pulling in stale or wrong context.

**Memory types caveat:** the user-convention of typing memories as `user` / `feedback` / `project` / `reference` is a popular community structuring pattern, **not part of the auto-memory subsystem schema**. The loader doesn't read the `type:` frontmatter as anything other than metadata. Audit by recency and by `MEMORY.md` presence, not by type — unless the project explicitly uses the typed convention.

Other auto-memory facts the audit should know:

- Storage path is keyed by git repo, so worktrees share memory across the same project
- `autoMemoryEnabled` setting + `CLAUDE_CODE_DISABLE_AUTO_MEMORY` env can silently disable the subsystem at managed / user level
- `autoMemoryDirectory` is managed-only or user-only (never project — prevents repo redirection attacks)
- Sub-agents can maintain their own auto-memory at `~/.claude/projects/<proj>/agents/<agent>/memory/`
- Minimum Claude Code version for auto-memory: v2.1.59+

---

## G11. 📏 Skill-budget knobs — defaults and effect

The official skill-listing budget controls:

| Setting | Default | Effect |
|---|---|---|
| `skillListingBudgetFraction` | **`0.01`** (1%) | Fraction of context budget reserved for skill listings. Lower for skill-heavy projects to free context. |
| `maxSkillDescriptionChars` | `1536` | Truncates each skill's `description` + `when_to_use` (combined) in the listing |
| `skillOverrides` | unset | Per-skill state: `on` / `name-only` / `user-invocable-only` / `off` |

For an "AI layer audit" these are first-class targets: if the project has 47 skills, lowering `skillListingBudgetFraction` from `0.01` to `0.005` may free meaningful context without losing functionality — truncated skills still load on full description match. Going the other direction (`0.02`+) trades startup context for fewer auto-load misses; defensible for skill-light projects where the budget is dominated by something else.

---

## G12. ✂️ `claudeMdExcludes` is the monorepo CLAUDE.md trim knob

In monorepos, nested CLAUDE.md proliferation can over-load the root context. The official `claudeMdExcludes` setting (a glob list in `.claude/settings.json`) suppresses specific nested files from auto-loading.

**Audit task:** check for orphan nested CLAUDE.md that exists but doesn't load because of `claudeMdExcludes`, and conversely for nested files that *should* be excluded but aren't.

---

## G13. 🔐 `disableSkillShellExecution` — security knob for skills, not MCP

Skills can execute shell via backtick-bang syntax (`` !`command` ``) inside SKILL.md content. The `disableSkillShellExecution` setting blocks this entirely. **This controls skills, not MCP servers** — a common misconception (v2 of this skill placed it under MCP audit, which was wrong).

**When to recommend setting it:** projects that install third-party skills from a marketplace, or projects with security-sensitive build environments. Default is unset (shell allowed).

**Note on skill content lifecycle:** when context is compacted, skills loaded via `!`command`` may need to re-execute to refresh their dynamic content. Skill-heavy projects should be aware of the re-attach cost after compaction.

---

## 🔗 Sources

- [Anthropic — How Claude Code works in large codebases](https://claude.com/blog/how-claude-code-works-in-large-codebases-best-practices-and-where-to-start)
- [Official Claude Code docs](https://code.claude.com/docs/en) — skills, sub-agents, memory, hooks, MCP, plugins, settings, permissions, sandboxing, worktrees, output-styles, auto-mode, [plugins-reference (LSP)](https://code.claude.com/docs/en/plugins-reference#lsp-servers)
- Issues referenced: #17204 (rules paths parser), #23478 (path-scoped read trigger)
```

**End of CAVEATS.md target content.**

---

### 4.3 README.md — MODIFY

**Action:** Targeted edits. No full rewrite — most of the file is correct.

#### Edit 1 — Update version badge and intro paragraph (lines 5-14)

**Before:**
```markdown
[![Version](https://img.shields.io/badge/Version-v2.0.0-blue)](CHANGELOG.md)
[![GitHub stars](https://img.shields.io/github/stars/MJWNA/large-codebase-audit-skill?style=flat)](https://github.com/MJWNA/large-codebase-audit-skill/stargazers)
[![GitHub issues](https://img.shields.io/github/issues/MJWNA/large-codebase-audit-skill)](https://github.com/MJWNA/large-codebase-audit-skill/issues)
[![Last commit](https://img.shields.io/github/last-commit/MJWNA/large-codebase-audit-skill)](https://github.com/MJWNA/large-codebase-audit-skill/commits/main)

> **A Claude Code skill that audits and improves a project's entire AI layer in one cycle, using parallel forked sub-agents. Aligned with the [Anthropic article](https://claude.com/blog/how-claude-code-works-in-large-codebases-best-practices-and-where-to-start) and cross-referenced against the [official Claude Code docs](https://code.claude.com/docs/en).**

The Anthropic article's central thesis is that **the harness matters as much as the model**. This skill audits the harness as a whole — across 9 official surfaces — then applies fixes in the order the article recommends (CLAUDE.md first), with disjoint write scopes so parallel forks never collide.

> 🆕 **Version 2.0.0** brings the skill into alignment with the official docs. See [CHANGELOG.md](CHANGELOG.md) for breaking changes (templates removed, surfaces expanded from 7 to 9, factual corrections).
```

**After:**
```markdown
[![Version](https://img.shields.io/badge/Version-v3.0.0-blue)](CHANGELOG.md)
[![GitHub stars](https://img.shields.io/github/stars/MJWNA/large-codebase-audit-skill?style=flat)](https://github.com/MJWNA/large-codebase-audit-skill/stargazers)
[![GitHub issues](https://img.shields.io/github/issues/MJWNA/large-codebase-audit-skill)](https://github.com/MJWNA/large-codebase-audit-skill/issues)
[![Last commit](https://img.shields.io/github/last-commit/MJWNA/large-codebase-audit-skill)](https://github.com/MJWNA/large-codebase-audit-skill/commits/main)

> **A Claude Code skill that audits and improves a project's entire AI layer in one cycle, using parallel forked sub-agents. Aligned with the [Anthropic article](https://claude.com/blog/how-claude-code-works-in-large-codebases-best-practices-and-where-to-start) and cross-referenced against the [official Claude Code docs](https://code.claude.com/docs/en).**

The Anthropic article's central thesis is that **the harness matters as much as the model**. This skill audits the harness as a whole — across the AI-layer surfaces the article + docs describe — then applies fixes in the order the article recommends (CLAUDE.md first), with disjoint write scopes so parallel forks never collide.

> 🆕 **Version 3.0.0** closes all 41 findings from the independent v2 audit. See [CHANGELOG.md](CHANGELOG.md) and [AUDIT-v2.0.0-REVIEW.md](AUDIT-v2.0.0-REVIEW.md) for the trace. Breaking changes: dropped the fixed "9 official surfaces" framing, adaptive Phase 3 dispatch, inline Phase 4, CAVEATS restructured.
```

#### Edit 2 — "What it audits" table (lines 55-69)

**Before:** the 9-row table with the "9 official AI-layer surfaces" framing.

**After:** replace the lead-in sentence and the table with:

```markdown
The AI-layer surfaces synthesised from Anthropic's article and the [official docs](https://code.claude.com/docs/en). Each surface is tagged `[article]` if the article explicitly discusses it, `[docs]` if it's docs-only:

| # | Surface | Source | Where it lives | Key audit question |
|---|---|---|---|---|
| 1 | 📜 CLAUDE.md hierarchy | [article] | Root + nested `CLAUDE.md` | Root concise, pointers-only? Nested at sub-tree boundaries? Legacy rules a current model wouldn't need? |
| 2 | 🗺️ Codebase navigability | [article] | `.claudeignore`, codebase maps, monorepo invocation, scoped test/lint | Is Claude invoked at sub-tree roots in monorepos? Do nested files scope test/lint? |
| 3 | 📋 Rules | [docs] | `.claude/rules/*.md` | Always-loaded that could be path-scoped? Rules that are skills in disguise? |
| 4 | 🎯 Skills + slash commands | [article] + [docs] | `.claude/skills/*/SKILL.md`, `.claude/commands/*.md` | Per-frontmatter audit; orphan supporting files; `.claude/commands/` migration; bundled `/run` `/verify` recipe captured? |
| 5 | 🤖 Sub-agents | [article] | `.claude/agents/*.md` | Field-by-field — `tools`, `permissionMode`, `model`, `memory`, `mcpServers`, `isolation: worktree` candidates |
| 6 | 🪝 Hooks | [article] | `.claude/settings.json` → `hooks` | Which of 31 events used? Handler types beyond `command`? Continuous improvement, not just safety? |
| 7 | ⚙️ Settings + permissions + sandbox + worktree | [docs] | `.claude/settings.json`, `.local.json`, managed | `defaultMode`? Sandbox where untrusted code runs? Worktree config? `settings.local.json` gitignored? |
| 8 | 🔌 MCP | [article] | `.mcp.json` + `~/.claude.json` local scope | `ENABLE_TOOL_SEARCH` / `alwaysLoad` posture for multi-server projects? `MAX_MCP_OUTPUT_TOKENS`? |
| 9 | 🔎 LSP | [article] | Pre-built plugin or `.lsp.json` fallback | Pre-built plugin for dominant language? Binary present? |
| 10 | 📦 Plugins | [article] | `.claude-plugin/` | If plugin: `plugin.json` complete? Marketplace-ready? `monitors/` schema? |
| 11 | 🧠 Auto-memory | [docs] | `~/.claude/projects/<proj>/memory/` | `MEMORY.md` 200-lines-or-25KB cutoff? Topic-file curation? |

Plus the settings.json budget knobs (`skillListingBudgetFraction` default **`0.01`**, `maxSkillDescriptionChars`, `skillOverrides`, `claudeMdExcludes`) which affect all of the above.
```

#### Edit 3 — "What it fixes" section (lines 73-87)

**Before:** numbered 1-9 list, then the trailing "Each fix runs in its own forked sub-agent…" paragraph.

**After:** keep the structure but renumber and re-anchor to article H3 order:

```markdown
Fixes are dispatched in **the article's H3 order** (article §2 H3: *"CLAUDE.md files come first"* etc.), with docs-only surfaces appended:

1. 📜 Root `CLAUDE.md` — trim, restructure, add pointers
2. 📜 Nested `CLAUDE.md` + codebase navigability — `.claudeignore`, scoped test/lint
3. 🪝 Hooks + settings + permissions + sandbox — add `InstructionsLoaded`, `UserPromptSubmit` shaping, `PreCompact` automation, sandbox where appropriate, permissions block
4. 🎯 Skills + slash-commands migration — create path-scoped skills, fix frontmatter, migrate `.claude/commands/*.md`
5. 🤖 Sub-agents — explorer / inspector agents, field-by-field edits to existing
6. 📦 Plugins — if the project is a plugin, validate manifest + marketplace
7. 🔎 LSP — install pre-built plugin or write `.lsp.json`
8. 🔌 MCP — register project-scope servers, set tool-search posture (requires Claude Code restart)
9. 🧠 Auto-memory — move startup-cost items from `MEMORY.md` to topic files, prune stale entries
10. 📋 Rules — path-scoping + deletion-test trims (consolidations deferred to `_CONSOLIDATION_PROPOSALS.md` for human review; next cycle's Phase 0 drains the file)

Each fix runs in its own forked sub-agent with an **exclusive write scope** — two forks never touch the same file. **Adaptive dispatch:** fix forks for surfaces with zero Phase 1 findings are skipped, not dispatched as no-ops. Rule consolidations and rule-to-skill conversions are *deferred* to a `_CONSOLIDATION_PROPOSALS.md` doc for human review (consolidations break pointers other forks rely on inside the same cycle).
```

#### Edit 4 — "How it works" diagram (lines 92-134)

Replace the v2 diagram with:

```
Phase 0 — Pre-flight                  (sequential, ~2-3 min)
   ├─ Verify git repo root + fork-mode (CLAUDE_CODE_FORK_SUBAGENT=1)
   ├─ Drain _CONSOLIDATION_PROPOSALS.md from prior cycle (if any)
   ├─ Scaffold .claude/ if absent (stub settings.json)
   ├─ Read CLAUDE.md, settings.json, settings.local.json (check gitignore)
   ├─ Capture InstructionsLoaded diagnostic (if available)
   ├─ Check bundled /run, /verify, /run-skill-generator recipes
   ├─ Monorepo check — multiple package.json / Cargo.toml / go.mod at sub-tree roots?
   └─ Identify dominant tech stack

Phase 1 — Audit                       (7 parallel forks, single message)
   ├─ Fork A: CLAUDE.md hierarchy + navigability  │
   ├─ Fork B: Rules                               │
   ├─ Fork C: Skills + sub-agents + commands      │  All read-only.
   ├─ Fork D: Hooks (31 events × 5 handler types) │  Each returns a
   ├─ Fork E: Settings/permissions/sandbox/worktree│ punch list under
   ├─ Fork F: MCP + LSP + plugins                 │  800 words.
   └─ Fork G: Auto-memory                         │

Phase 2 — Synthesise + order          (sequential, ~3-5 min)
   ├─ Merge punch lists
   ├─ Map every fix to one fork, one write scope
   ├─ Order per article H3 hierarchy + docs-only tail
   ├─ Adaptive: skip fix forks with no Phase 1 findings
   └─ Confirm with user unless --yes / standing authorisation

Phase 3 — Fix                         (adaptive parallel forks, single message)
   ├─ Fix-1 → root CLAUDE.md          │  Each fork:
   ├─ Fix-2 → nested CLAUDE.md + nav  │   • States exclusive write scope
   ├─ Fix-3 → hooks/settings/sandbox  │   • Knows other forks' scopes
   ├─ Fix-4 → skills + commands mig.  │   • Self-validates (jq, bash -n,
   ├─ Fix-5 → sub-agents              │     wc -l, yaml parse)
   ├─ Fix-6 → plugins                 │   • Reports back: files,
   ├─ Fix-7 → LSP                     │     line counts, surprises
   ├─ Fix-8 → MCP                     │
   ├─ Fix-9 → auto-memory             │
   └─ Fix-10 → rules (safe trims)     │

Phase 4 — Wrap + cadence              (sequential, INLINE — not a fork)
   ├─ Verification commands
   ├─ Write .claude/session/large-codebase-audit-YYYY-MM-DD.md
   ├─ Recommend DRI or agent-manager (multi-person org)
   ├─ Frame the "why" — tribal-knowledge / adoption plateau (article)
   ├─ Set "Next review due" (today + 90 days) + note latest model release
   ├─ Write .claude/session/REVIEW_DUE.md for Stop-hook surfacing
   └─ Surface critical "before next session" actions
```

#### Edit 5 — Quick start trigger (lines 142-150)

Keep as is — the quick-start example is fine.

#### Edit 6 — Installation Option B (lines 178-186)

Keep but flag for removal. Decision D12 says preserve two-file structure; the Option B path is honestly noted as "rarely needed", and there's no strong reason to remove it. Leave as-is.

#### Edit 7 — Operational caveats summary (lines 217-229)

**Before:** the 9-bullet caveats list.

**After:**

```markdown
The skill operates on real Claude Code behaviour, not idealised behaviour. Full caveats with citations and mitigations live in [`docs/CAVEATS.md`](docs/CAVEATS.md) (13 operational gotchas). Best-practices items (DRI, cadence, skill bundling, `InstructionsLoaded` use, LSP location) live in [`SKILL.md`](SKILL.md) → *Best practices*. Highlights:

- 🔄 Path-scoped rules trigger on file READ, not Write/Create (issue #23478)
- 🐛 Rules' `paths:` YAML-list form has parser quirks (issue #17204) — does NOT affect skills
- 🧾 `description:` is undocumented for rules; for skills it IS the primary trigger field
- 💸 "Self-improving Stop hook" is a community pattern (not docs canon); always provide an opt-out env var
- 🔁 MCP changes require Claude Code restart, not `/clear`
- 🍴 Forks cannot spawn further forks — this skill must run in the main thread
- 🛑 Cross-fork write coordination requires disjoint scopes; one file → one fork
- 🎭 Rules vs skills misclassification is the most common drift
- 📦 Plugin layout per official spec — there is no `tooling/` directory
- 🔐 `disableSkillShellExecution` is a skills control, not MCP
- 🧠 `MEMORY.md` cutoff is 200 lines OR 25KB; topic files load on demand
- 📏 `skillListingBudgetFraction` default is **`0.01`** (1%), not 10%
```

#### Edit 8 — Acknowledgements (lines 256-260)

Add a line about the v2 audit:

**Before:**
```markdown
- Field reports from the Claude Code community — issue trackers #17204, #23478, and ongoing harness behaviour observations
```

**After:**
```markdown
- Field reports from the Claude Code community — issue trackers #17204, #23478, and ongoing harness behaviour observations
- The independent v2.0.0 audit that drove the v3.0.0 rewrite — captured in [`AUDIT-v2.0.0-REVIEW.md`](AUDIT-v2.0.0-REVIEW.md)
```

---

### 4.4 CHANGELOG.md — APPEND

**Action:** Insert a new v3.0.0 entry at the top, above the existing v2.0.0 entry.

**Content to insert (after the existing `# Changelog` header + Keep-a-Changelog reference, before `## [2.0.0]`):**

```markdown
## [3.0.0] — 2026-05-22

Comprehensive close-out of all 41 findings from the independent v2.0.0 audit. See [`AUDIT-v2.0.0-REVIEW.md`](AUDIT-v2.0.0-REVIEW.md) for the trace.

### ⚠️ Breaking changes

- 🎭 **Dropped "9 official surfaces" framing.** Frontmatter `description` and README + SKILL.md now reference "the AI-layer surfaces" with each surface labelled `[article]` (Anthropic article) or `[docs]` (docs-only). The synthesis is real; the count was a soft fabrication.
- 🚦 **Phase 3 dispatch is adaptive.** Fix forks for surfaces with zero Phase 1 findings are skipped, not dispatched as no-ops. Fork count per cycle is variable, not fixed at 10.
- 📝 **Phase 4 wrap is inline, not a fork.** Output IS the deliverable; forking it loses context for no gain.
- 📚 **`docs/CAVEATS.md` restructured.** Now 13 operational gotchas only. The 5 best-practices items (`InstructionsLoaded` use, LSP location, DRI, 3-6 month cadence, skill bundling) moved into a new `## Best practices` section in `SKILL.md`.
- 🧭 **Phase 3 order matches the article's H3 sequence:** CLAUDE.md → Hooks → Skills → Plugins → LSP → MCP → Subagents → (docs-only: auto-memory, rules). Where the skill diverges from earlier orderings, the divergence is now explicit.

### 🐛 Factual corrections

- 🔥 **`skillListingBudgetFraction` default corrected** to `0.01` (was stated as `~0.10` in v2 CAVEAT #11 — off by 10×; a user "trimming from 0.10 to 0.05" based on the v2 guidance was actually raising the budget).
- 🔥 **`disableSkillShellExecution` moved** from the MCP audit row to Skills/Settings. It is a skills-execution control (blocks `` !`command` `` inside SKILL.md), not an MCP setting.
- 🔥 **LSP docs URL fixed.** The v2 caveat implied `/en/lsp` exists; it 404s. LSP is documented at [`/en/plugins-reference#lsp-servers`](https://code.claude.com/docs/en/plugins-reference#lsp-servers). Pre-built LSP plugins for common languages (TypeScript, Python, Rust) are the preferred path; custom `.lsp.json` is a fallback.
- 🗓️ **Cadence quote completed.** v2 CAVEAT #17 quoted the article's first cadence trigger (3-6 months) but dropped the second: *"…or whenever performance feels like it's plateaued after major model releases"*. Phase 4 now records both triggers.
- 🎭 **"Self-improving Stop hook" reframed** as a community pattern, not docs canon. The phrase is widely used in field reports; the docs don't bless it.
- 🧠 **`MEMORY.md` cutoff corrected** to "first 200 lines OR 25KB, whichever first" (v2 said "~200 lines"). Topic files load on demand, not at session start — pruning topic files does NOT reduce session-start cost.
- 🧠 **"Memory types" framing softened** — user/feedback/project/reference is a community convention, not part of the auto-memory subsystem schema.
- 📏 **"Frontmatter linting for skills" replaced** with a concrete command: `python3 -c "import yaml,sys; yaml.safe_load(open(sys.argv[1]).read().split('---')[1])" SKILL.md` (or `yq eval`).
- 📏 **"80 lines" CLAUDE.md threshold** marked as a heuristic, not a sourced number. The Anthropic article does not state this threshold.
- 🧭 **"The article's stated hierarchy" reframed** — the article makes exactly one ordering claim (the H3 *"CLAUDE.md files come first"*). The skill's full order is owned as the skill's recommended sequence, with the article's H3 order matched where possible.

### ✨ Added — coverage expansions

- 🔥 **Sandbox subsystem audit** (Fork E). `sandbox.enabled`, `filesystem.denyRead/Write`, `network.allowedDomains/deniedDomains`, `bwrapPath`. Largest security surface v2 ignored.
- 🛡️ **Permissions block audit** (Fork E). `allow` / `ask` / `deny` / `defaultMode` / `additionalDirectories`, Read/Edit path anchors, Bash wildcard semantics, `Agent(Name)` rules, MCP permission patterns.
- 🪝 **Hook event catalog** (Fork D) — all 31 documented events grouped by category (session lifecycle, user input, tool execution, sub-agent, task management, context/config, notifications, compaction/worktree).
- 🪝 **Hook handler types** beyond `command` — `http`, `mcp_tool`, `prompt`, `agent`.
- 🎯 **Per-frontmatter skills audit** — every documented frontmatter field audited for misuse: `name`, `description`, `when_to_use`, `paths`, `allowed-tools`, `disable-model-invocation`, `user-invocable`, `context`, `agent`, `model`, `argument-hint`, skill-scoped `hooks`. Plus `${CLAUDE_SKILL_DIR}` usage and orphan supporting files.
- 🤖 **Existing sub-agent audit** — not just gap-finding. `tools` / `disallowedTools`, `permissionMode`, `model`, `maxTurns`, `skills:` preload, `mcpServers:` scoping, `memory: user/project/local`, `background: true`, `isolation: worktree`, `initialPrompt`, `Agent(agent_type)` restriction.
- 🔌 **MCP tool-search posture audit** — `ENABLE_TOOL_SEARCH`, `alwaysLoad: true`, `MAX_MCP_OUTPUT_TOKENS`. Single largest MCP context cost.
- 🌲 **Worktree configuration audit** — `worktree.baseRef` / `symlinkDirectories` / `sparsePaths` / `bgIsolation`. Directly relevant to the "large codebase" audience and fork isolation.
- 📦 **Bundled-skills recipe check** (Phase 0) — has the project captured `/run`, `/verify`, `/run-skill-generator`?
- 🔄 **Slash-commands migration** (Fork C) — `.claude/commands/*.md` is legacy; v2.1.145+ merges into skills.
- 🗺️ **`.claudeignore` + `permissions.deny`** as first-class audit items.
- 🏛️ **Settings layering check** — managed > CLI > local > project > user precedence; conflict detection.
- 🔐 **`.claude/settings.local.json` audit** — including a gitignore-status check. Common foot-gun: secrets get committed.
- 🤖 **`autoMode` classifier rules audit** — `allow` / `soft_deny` / `hard_deny` / `environment`.
- 🛍️ **Marketplace manifest audit** — `.claude-plugin/marketplace.json`, `strictKnownMarketplaces`, `blockedMarketplaces`.
- 📜 **Legacy-rules check** — "Are any CLAUDE.md rules legacy mitigations a newer model wouldn't need?"
- 🧪 **Scoped test/lint commands** — "Do nested CLAUDE.md files contain scoped test/lint commands?" (article explicit).
- 🌳 **Monorepo invocation check** — "Is Claude initialized at sub-tree roots rather than the repo root?" (article explicit).

### ✨ Added — structural / DX

- 📐 **Phase 1 forks as 200-word prompt templates** (not table-row summaries). Each template embeds reading scope, comparison frame, output sections, word limit, self-validation.
- 🗺️ **Surface → audit-fork → fix-fork mapping table** — single source of truth. Eliminates the v2 "9 surfaces / 7 forks / 10 fix forks" counting drift.
- 🏗️ **Phase 0.5 scaffold step** — creates `.claude/` if absent. Most "audit a large untuned codebase" cases have no `.claude/` yet.
- 🌳 **Monorepo per-package `.claude/` traversal** — real monorepos have per-package `.claude/skills/` and `.claude/rules/`, not just nested CLAUDE.md.
- 🚦 **Adaptive Phase 3 dispatch** — skip fix forks for surfaces with zero Phase 1 findings.
- 📝 **Phase 4 inline** — `.claude/session/large-codebase-audit-YYYY-MM-DD.md` + `.claude/session/REVIEW_DUE.md` written without a fork.
- 🔄 **`_CONSOLIDATION_PROPOSALS.md` drain mechanism** — next cycle's Phase 0 reads it as the first action. No more procrastination dressed as caution.
- 👤 **DRI vs agent-manager framing** — Phase 4 offers both ownership shapes per the article, with the tribal-knowledge / adoption-plateau "why".
- 🪝 **Hooks reframing** — Fork D opens with "continuous improvement, not just safety" per the article's main hook value. PreToolUse-safety framing is no longer dominant.
- 💻 **Concrete validation commands** — `jq empty`, `bash -n`, `wc -l`, `yaml.safe_load`. No more "frontmatter linting".

### ✨ Added — best practices section in SKILL.md

(Lifted from CAVEATS where they were mixed with operational gotchas. Now standalone.)

- B-P1 — `InstructionsLoaded` is the canonical "what loaded?" diagnostic
- B-P2 — LSP config: install pre-built plugin first; `.lsp.json` as fallback
- B-P3 — Multi-person orgs need a Claude Code owner (DRI or agent-manager)
- B-P4 — Cadence: 3-6 months OR plateau after major model release
- B-P5 — Skill bundling: everything inside the skill directory; use `${CLAUDE_SKILL_DIR}`

### 🔗 Sources for changes

- [Anthropic article](https://claude.com/blog/how-claude-code-works-in-large-codebases-best-practices-and-where-to-start)
- [Official Claude Code docs](https://code.claude.com/docs/en) — skills, sub-agents, memory, hooks, MCP, plugins, settings, permissions, sandboxing, worktrees, output-styles, auto-mode, plugins-reference (LSP)
- [`AUDIT-v2.0.0-REVIEW.md`](AUDIT-v2.0.0-REVIEW.md) — full finding-to-fix trace
- Issues: #17204 (rules `paths:` parser), #23478 (path-scoped read trigger)

---
```

---

## 5. 🗂️ Runtime artefacts produced by the skill (not committed)

These artefacts are produced by the skill at runtime, not by this spec. Listed here for completeness so the next session knows the full surface of what each cycle produces:

| Artefact | Location | Lifetime |
|---|---|---|
| Session log | `.claude/session/large-codebase-audit-YYYY-MM-DD.md` | Permanent in project |
| Review-due marker | `.claude/session/REVIEW_DUE.md` | Overwritten each cycle |
| Consolidation proposals | `.claude/_CONSOLIDATION_PROPOSALS.md` | Drained by next cycle's Phase 0 |
| Verification report | (in session log; not separate) | — |
| Critical actions list | (in session log; not separate) | — |

No new artefacts are committed by this spec.

---

## 6. 🚀 Implementation order for the next session

The next session executes this spec. Recommended order — single message dispatch where possible, sequential where dependencies exist:

### Step 1 — Read everything

Sequential. Single message of parallel Read calls is fine:

```
Read SPEC-v3.0.0.md (this file)
Read AUDIT-v2.0.0-REVIEW.md (for context)
Read SKILL.md (current v2 baseline)
Read docs/CAVEATS.md (current v2 baseline)
Read README.md (current v2 baseline)
Read CHANGELOG.md (current v2 baseline)
```

### Step 2 — Apply the four file changes in parallel

Single message with four parallel forked Agent calls (each fork gets one file, with its target content from this spec inline in the prompt):

```
Agent A: REWRITE SKILL.md with the content from §4.1 of SPEC-v3.0.0.md
Agent B: REWRITE docs/CAVEATS.md with the content from §4.2 of SPEC-v3.0.0.md
Agent C: APPLY the 8 targeted edits to README.md per §4.3 of SPEC-v3.0.0.md
Agent D: APPEND the v3.0.0 entry to CHANGELOG.md per §4.4 of SPEC-v3.0.0.md
```

Each fork's write scope is exclusive (one file each). No conflicts.

### Step 3 — Verify (sequential, inline)

Run the verification commands from §7. If any fail, fix and re-run.

### Step 4 — Commit

Single commit with the message from §3 above. Tag `v3.0.0`. Push.

### Step 5 — Optional: open a follow-up issue or PR

If this is being shipped publicly, optionally open a "v3.0.0 release notes" issue referencing both `AUDIT-v2.0.0-REVIEW.md` and `SPEC-v3.0.0.md`.

---

## 7. ✅ Verification commands

Run after Step 2 in §6. All should pass before commit.

### 7.1 Markdown sanity

```bash
# Files exist
ls -la SKILL.md docs/CAVEATS.md README.md CHANGELOG.md AUDIT-v2.0.0-REVIEW.md SPEC-v3.0.0.md

# No accidental binary inclusion
file SKILL.md docs/CAVEATS.md | grep -v "ASCII\|UTF-8\|Unicode" && echo "BINARY DETECTED" || echo "TEXT OK"

# Line counts roughly match targets
wc -l SKILL.md          # Expect: 280-310 lines
wc -l docs/CAVEATS.md   # Expect: 160-180 lines (down from 202 — 5 caveats moved out)
wc -l README.md         # Expect: 270-280 lines (small increase from 266)
wc -l CHANGELOG.md      # Expect: 180-200 lines (was 57)
```

### 7.2 Frontmatter parses

```bash
python3 -c "
import yaml
with open('SKILL.md') as f:
    parts = f.read().split('---')
    if len(parts) < 3:
        raise SystemExit('SKILL.md frontmatter missing')
    fm = yaml.safe_load(parts[1])
    assert fm['name'] == 'large-codebase-audit', f'name wrong: {fm[\"name\"]}'
    assert '9 official surfaces' not in fm['description'], 'description still says 9 official surfaces'
    assert 'the AI-layer surfaces' in fm['description'], 'description should mention the AI-layer surfaces'
    print('SKILL.md frontmatter OK')
"
```

### 7.3 Factual-error fixes landed

```bash
# Old wrong default ~0.10 must NOT appear; new 0.01 must appear
grep -F '~0.10' docs/CAVEATS.md && echo "FAIL: old wrong default still present" || echo "OK: skillListingBudgetFraction old default removed"
grep -F '0.01' docs/CAVEATS.md > /dev/null && echo "OK: skillListingBudgetFraction new default present" || echo "FAIL: new default missing"

# disableSkillShellExecution should NOT appear in MCP context
! grep -B2 -A2 'disableSkillShellExecution' SKILL.md | grep -i 'mcp' && echo "OK: disableSkillShellExecution decoupled from MCP" || echo "FAIL: disableSkillShellExecution still near MCP"

# LSP URL fixed
grep -F 'plugins-reference#lsp-servers' docs/CAVEATS.md SKILL.md > /dev/null && echo "OK: LSP URL fixed" || echo "FAIL: LSP URL not updated"
! grep -F '/en/lsp' docs/CAVEATS.md SKILL.md README.md && echo "OK: dead LSP URL removed" || echo "FAIL: dead /en/lsp URL still present"

# Cadence quote completed
grep -F 'plateaued after major model releases' SKILL.md > /dev/null && echo "OK: plateau cadence trigger present" || echo "FAIL: cadence quote still truncated"

# 9 official surfaces dropped from headline copy
! grep -F '9 official surfaces' SKILL.md README.md && echo "OK: 9 official surfaces dropped" || echo "FAIL: 9 official surfaces still present"

# MEMORY.md cutoff corrected
grep -F '200 lines OR 25KB' docs/CAVEATS.md > /dev/null && echo "OK: MEMORY.md cutoff corrected" || echo "FAIL: MEMORY.md cutoff not corrected"
```

### 7.4 New surfaces covered

```bash
# Sandbox audit present
grep -i 'sandbox' SKILL.md | head -3 && echo "(sandbox mentions found)"

# 31 hook events context present
grep -i '31 documented hook events\|31 documented event\|31 events' SKILL.md > /dev/null && echo "OK: 31-event enumeration referenced" || echo "FAIL: hook event catalog not referenced"

# Permissions block as a first-class audit target
grep -i 'permissions block\|permissions\..*allow\|defaultMode' SKILL.md > /dev/null && echo "OK: permissions block audited" || echo "FAIL: permissions not first-class"

# Worktree config audit
grep -i 'worktree\.' SKILL.md > /dev/null && echo "OK: worktree config audited" || echo "FAIL: worktree config not audited"

# Bundled skills recipe check
grep -F 'run-skill-generator' SKILL.md > /dev/null && echo "OK: bundled skills referenced" || echo "FAIL: bundled skills not referenced"
```

### 7.5 Structural additions

```bash
# Phase 0.5 / scaffold check
grep -i 'scaffold\|no \.claude/ directory exists' SKILL.md > /dev/null && echo "OK: Phase 0.5 scaffold present" || echo "FAIL: scaffold step missing"

# Adaptive Phase 3
grep -i 'adaptive\|skip fix forks' SKILL.md > /dev/null && echo "OK: adaptive dispatch present" || echo "FAIL: adaptive dispatch missing"

# Best practices section in SKILL.md
grep -F '## 📐 Best practices' SKILL.md > /dev/null && echo "OK: Best practices section present" || echo "FAIL: Best practices section missing"

# Surface→fork mapping table
grep -F 'Phase 1 fork' SKILL.md | head -1 > /dev/null && echo "OK: mapping table content present" || echo "FAIL: mapping table missing"

# REVIEW_DUE.md mechanism
grep -F 'REVIEW_DUE.md' SKILL.md > /dev/null && echo "OK: REVIEW_DUE.md mechanism present" || echo "FAIL: REVIEW_DUE.md missing"
```

### 7.6 CHANGELOG entry

```bash
grep -F '## [3.0.0]' CHANGELOG.md > /dev/null && echo "OK: v3.0.0 entry present" || echo "FAIL: v3.0.0 entry missing"
grep -F 'AUDIT-v2.0.0-REVIEW.md' CHANGELOG.md > /dev/null && echo "OK: CHANGELOG references audit" || echo "FAIL: audit reference missing"
```

### 7.7 Aggregate

If any of the above print `FAIL`, the spec was not applied correctly. Re-read the relevant §4 section and re-apply.

---

## 8. ✅ Acceptance criteria

The next session can mark v3.0.0 ready-to-ship when ALL of these hold:

- [ ] All 7 verification command groups (§7) pass with no `FAIL` output
- [ ] `git diff --stat` shows exactly 4 modified files: `SKILL.md`, `docs/CAVEATS.md`, `README.md`, `CHANGELOG.md`
- [ ] No new files in the diff except `SPEC-v3.0.0.md` and `AUDIT-v2.0.0-REVIEW.md` (already present)
- [ ] Frontmatter `description` in `SKILL.md` does not contain "9 official surfaces"
- [ ] `CAVEATS.md` is 13 caveats (count `^## G` headers — should return `13`)
- [ ] `SKILL.md` has a `## 📐 Best practices` section with 5 sub-headers (`### B-P1` through `### B-P5`)
- [ ] Every audit-finding ID (P0 #1 through P4 #41) maps to at least one closed item per the table in §0 of this spec
- [ ] `git log -1 --format=%B` on the v3.0.0 commit matches the message in §3
- [ ] `git tag --list v3.0.0` returns `v3.0.0`

---

## 9. ⚠️ Risks + open questions

### 9.1 Risks

| Risk | Severity | Mitigation |
|---|---|---|
| Next session's reading of this spec drifts during application (skips a paragraph, mis-counts surfaces) | Med | §7 verification commands catch the headline-level errors; §8 acceptance checklist forces a second pass |
| The article changes after this spec was written, invalidating a quote we reference | Low | Quotes in this spec match the article as of 2026-05-22; if Anthropic updates the article, the cadence + harness-thesis quotes may need re-verification |
| Anthropic ships a new docs surface between this spec and the v3.0.0 commit | Low | The "no fixed surface count" framing (D2) accommodates new surfaces; updating just means adding a row to the surfaces table |
| `claudeMd` managed-only key, `autoMode`, sandbox subsystem details change in docs | Med | Each is referenced descriptively, not with a pinned doc snapshot; field-test before commit |
| `.claude/settings.local.json` gitignore check produces a false positive (project genuinely commits it) | Low | Audit prompt flags it as "verify"; the user confirms intent |
| The adaptive Phase 3 dispatch (D5) is harder to communicate than the fixed dispatch | Low | The mapping table (§7 in new SKILL.md) makes the maximum-shape explicit; adaptive is described as "skip forks with zero findings" — a small delta |

### 9.2 Open questions (none blocking)

1. Should v3.0.0 also rename the GitHub repo's "v2.0.0" badge in the README, or leave it as-is and let the badge service pick up the new tag automatically? — **Decision (D17, additive to D1-D16):** the spec includes the version bump in Edit 1 of §4.3. The badge service picks up the tag automatically, but the inline version reference is updated for clarity.
2. Should `SPEC-v3.0.0.md` itself be committed, or treated as a one-shot scratchpad? — **Decision (D18):** committed. The spec is part of the audit trail and useful for future cycles to reference.
3. Should we ship a v2.0.1 patch first (just the three hard factual errors) and v3.0.0 later? — **Already decided (D1):** No. Single v3.0.0 release per the user's "comprehensive fix in full" directive.

### 9.3 Out of scope for v3.0.0

Items intentionally excluded — captured here so a future v3.1.0 or v4.0.0 can pick them up:

- TUI / spinner / language / viewMode (personal user settings, not project AI layer)
- Channels / Remote Control / Slack / Telegram (session transports, not on-disk config)
- IDE-extension config (per-user, lives in `~/.claude.json`)
- Per-trigger localisation of fork prompts (current prompts are English-only)
- Automated detection of "performance plateau after major model release" — for now, the audit asks the user; future versions could query the Anthropic API for recent model releases
- The v2 audit's P4 #41 (skill content lifecycle / compaction re-attach) — captured in CAVEATS G13 as a one-liner; richer treatment deferred

---

## 10. 🔗 References

- [Anthropic article](https://claude.com/blog/how-claude-code-works-in-large-codebases-best-practices-and-where-to-start)
- [Official Claude Code docs](https://code.claude.com/docs/en)
- [`AUDIT-v2.0.0-REVIEW.md`](AUDIT-v2.0.0-REVIEW.md) — the audit this spec closes
- [`CHANGELOG.md`](CHANGELOG.md) — release history
- Issues: #17204, #23478

---

## 11. 📝 Spec metadata

- **Author:** Independent v2.0.0 audit + synthesis
- **Reviewed:** Pending — user will trigger the next session that applies this
- **Status:** Ready to apply
- **Estimated next-session time:** 15-25 minutes (4 parallel write forks + verification + commit)
- **Risk level:** Low — all changes are content/documentation; no executable code; rollback is `git revert`

This spec, the audit report, and the commit message together form the complete v3.0.0 paper trail. A future audit of v3.0.0 (the same exercise this spec closes for v2.0.0) can use these three artefacts as the baseline.
