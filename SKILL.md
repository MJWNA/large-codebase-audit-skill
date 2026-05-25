---
name: large-codebase-audit
description: Audit and improve a Claude Code project's AI layer end-to-end. Covers the AI-layer surfaces — CLAUDE.md hierarchy, codebase navigability, rules, skills, sub-agents, hooks, MCP, LSP, plugins, auto-memory, settings/permissions/sandbox/worktree. Parallel forked audit with 200-word per-fork prompt templates; disjoint-scope adaptive fixes, ordered per the article's H3 hierarchy. Trigger phrases - "audit my AI layer", "audit Claude config", "large codebase audit", "tune my .claude", "apply Anthropic patterns", "harness audit", "improve Claude Code setup", "Anthropic large codebase". Use proactively when CLAUDE.md is heuristically over ~80 lines, when no nested CLAUDE.md exists at meaningful sub-tree boundaries, or when entering a large untuned codebase.
---

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

- `skillListingBudgetFraction` (default `0.01`), `maxSkillDescriptionChars` (default 1536), `skillOverrides` — skill-budget controls. **`skillOverrides` is a per-skill record** (`Record<skillName, "on" \| "name-only" \| "user-invocable-only" \| "off">`), not a top-level string. Setting it as a string crashes settings.json validation — see CAVEAT G15.
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

> Audit `.claude/settings.json` `hooks` block (and any plugin-provided `hooks/hooks.json`) against the 31 documented hook events. Group by category: **Session lifecycle** (`SessionStart`, `Setup`, `SessionEnd`); **User input** (`UserPromptSubmit`, `UserPromptExpansion`, `Stop`, `StopFailure`); **Tool execution** (`PreToolUse`, `PostToolUse`, `PostToolUseFailure`, `PostToolBatch`, `PermissionRequest`, `PermissionDenied`); **Sub-agent/team** (`SubagentStart`, `SubagentStop`, `TeammateIdle`); **Task management** (`TaskCreated`, `TaskCompleted`); **Context/config** (`InstructionsLoaded`, `ConfigChange`, `CwdChanged`, `FileChanged`); **Notifications/elicitation** (`Notification`, `Elicitation`, `ElicitationResult`); **Compaction/worktree** (`PreCompact`, `PostCompact`, `WorktreeCreate`, `WorktreeRemove`). For each used hook: which of the 5 handler types (`command`, `http`, `mcp_tool`, `prompt`, `agent`) — is a `command` replaceable by `prompt` or `agent` for cleaner integration? Are `if:` permission-rule filters used on tool events? Are `async` / `asyncRewake` / `once` flags appropriate? Check exit-code semantics (0 = JSON parse, 2 = block-with-stderr) and `hookSpecificOutput` contracts. **Continuous improvement framing:** the article's main hook value is *continuous improvement* (self-improving Stop hook is a community pattern, not docs canon), not just safety. Identify candidates: `UserPromptSubmit` prompt-shaping reminders, `PreCompact` for context-management automation, `SessionStart`/`SessionEnd` for bootstrap/wrap workflows. Also audit skill-scoped (`hooks:` in SKILL.md frontmatter) and agent-scoped (`hooks:` in agent .md) hooks. Check `disableAllHooks`, `allowedHttpHookUrls`, `httpHookAllowedEnvVars`, `allowManagedHooksOnly`. **Picker-pollution check (CAVEAT G14):** for every hook command containing `claude -p` or `claude --bare -p`, verify it includes `--no-session-persistence`. Without that flag, each hook fire writes a `sdk-cli` JSONL into `~/.claude/projects/<proj>/`, and the `/resume` picker (paged by mtime, filters out `sdk-cli`) eventually renders empty. One-line script addition fixes it permanently. Report a punch list under 800 words. Read-only.

#### Fork E — Settings + permissions + sandbox + worktree

> Audit `.claude/settings.json`, `.claude/settings.local.json`, and (if discoverable) `managed-settings.json` for: **Settings layering** — managed > CLI > local > project > user precedence understood; conflicts surfaced. **`settings.local.json` gitignore status** — if not gitignored, flag immediately (common foot-gun: secrets get committed). **Permissions block** — `allow` / `ask` / `deny` / `defaultMode` (default / acceptEdits / plan / auto / dontAsk / bypassPermissions — which posture matches project intent?) / `additionalDirectories`. Read/Edit rule path anchors (`//absolute`, `~/home`, `/project-root`, `./cwd`). Bash wildcard + process-wrapper stripping semantics. `Agent(Name)` rules to disable specific subagents. MCP permission patterns (`mcp__server`, `mcp__server__*`, `mcp__server__tool`). `WebFetch(domain:...)` rules. **Sandbox subsystem** — `sandbox.enabled`, `filesystem.denyRead/Write`, `network.allowedDomains/deniedDomains`, `bwrapPath` on Linux, weaker mode for macOS — the largest security knob the v2 skill ignored. **Worktree config** — `worktree.baseRef/symlinkDirectories/sparsePaths/bgIsolation` — directly relevant to fork isolation in large codebases. **autoMode classifier rules** (`allow` / `soft_deny` / `hard_deny` / `environment`). **Skill-budget knobs** — `skillListingBudgetFraction` (default `0.01`; lowering to `0.005` for skill-heavy projects can free meaningful context), `maxSkillDescriptionChars` (default 1536), `skillOverrides` (**per-skill record**, NOT a top-level string — Claude Code rejects the whole settings file otherwise; see CAVEAT G15). For any existing `skillOverrides` entry, verify it's `{}` or `{ "name": "off" / "name-only" / "user-invocable-only" / "on" }`. **`claudeMdExcludes`** opportunities. **`disableSkillShellExecution`** — for projects installing third-party skills from a marketplace or in security-sensitive build environments. **`outputStyle`** (does the project pin one?). **Plan-mode `plansDirectory` / `useAutoModeDuringPlan`** — where do plan files land? gitignored? Report a punch list under 800 words. Read-only.

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
- 🗂️ Hook-invoked `claude -p` pollutes `/resume` picker — add `--no-session-persistence` to suppress (CAVEAT G14)
- 🚫 `skillOverrides` is a per-skill **record**, NOT a top-level string — wrong type crashes settings.json validation (CAVEAT G15)

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
- 🚨 [`docs/CAVEATS.md`](docs/CAVEATS.md) — 15 operational gotchas with citations and mitigations
- 🔍 [`AUDIT-v2.0.0-REVIEW.md`](AUDIT-v2.0.0-REVIEW.md) — the audit that drove this v3.0.0
