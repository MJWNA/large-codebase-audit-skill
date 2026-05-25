# Changelog

All notable changes to `large-codebase-audit-skill` are documented here. Format based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/); versioning follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [3.0.3] — 2026-05-25

Polish release. No functional changes; the audit workflow and caveats behave identically. Two cleanup items merged via PR (the v3.0.0–v3.0.2 patches all went direct-to-`main`; this one goes through the PR workflow for review).

### 🧹 Cleanup

- 📐 **G14/G15 file ordering fixed.** v3.0.1 added G14 and v3.0.2 added G15 by inserting *before* G14, so the in-file order became `G1…G13, G15, G14`. The numerical IDs are stable identifiers (all cross-references already resolved correctly), but a reader scanning top-to-bottom hit them out of order. Swapped so the file now reads `G1…G15` in numerical order. Zero content change inside either caveat.

### 📚 Docs

- 📦 **`CONTRIBUTING.md` documents the maintainer symlink pattern.** Replaces user-scope copies with symlinks so every edit propagates instantly without a manual `cp` step. Explicitly flagged as maintainer-only — end users should keep using Option A (cp) or Option C (git submodule) from the README. Also updates the "Development setup" command block to include `docs/CAVEATS.md` (was SKILL.md only).

### 🔧 Bumped

- Version badge: v3.0.2 → v3.0.3

### 🔗 Why this matters

The v3.0.0 through v3.0.2 releases were committed straight to `main`. This patch is the first to land through a feature branch + PR, establishing the convention going forward. Future releases (v3.0.4+) should follow the same pattern — branch, PR, merge — both for review hygiene and so external contributors have a working example to mirror.

---

## [3.0.2] — 2026-05-25

Patch release. Documentation bug fix — caught when the bad doc broke a real user's settings file.

### 🐛 Factual correction (settings-file breaker)

- 🚫 **`skillOverrides` is a per-skill record, not a top-level string.** Three sites in v3.0.0 / v3.0.1 listed the override values (`on` / `name-only` / `user-invocable-only` / `off`) inline alongside the field name without showing the record shape. A user parsed it as "the value to set", wrote `"skillOverrides": "user-invocable-only"` into `.claude/settings.json`, and Claude Code rejected the entire file with `Expected record, but received string`. The override values themselves are correct — they live *inside* a `Record<skillName, override>`, not at the top level.

### ✨ Added

- 🆕 **CAVEAT G15** — full reproduction with correct/wrong examples + Fork E audit one-liner (`jq '.skillOverrides // empty | type'`).
- 🪝 **Fork E audit prompt** now flags any `skillOverrides` value that isn't a JSON object.

### 🔧 Corrected

- 📐 **SKILL.md L43** (surfaces-table cross-cutting knobs section) — now shows `skillOverrides` as `Record<skillName, ...>` with explicit warning that string form is rejected.
- 📐 **SKILL.md Fork E prompt** — `skillOverrides` now flagged as "per-skill record, NOT a top-level string" with cross-reference to G15.
- 📐 **CAVEATS.md G11 table row** — `skillOverrides` description column now shows the record shape: `{ "skill-name": "off" / "name-only" / "user-invocable-only" / "on" }`.

### 🔧 Bumped

- `docs/CAVEATS.md` operational-gotcha count: 14 → 15
- README + SKILL.md caveats summary: new G15 highlight added
- Version badge: v3.0.1 → v3.0.2

### 🔗 Why this matters

Pure docs bug — but a settings-file-breaker, because Claude Code treats the entire settings file as invalid when a typed field fails validation. So a single wrong-typed `skillOverrides` takes down all project-scope settings (permissions, hooks, env, the lot) until corrected. The audit can now catch the wrong type before it lands.

---

## [3.0.1] — 2026-05-22

Patch release: catch a Stop-hook gotcha that doesn't surface until it bites you.

### 🐛 Operational addition

- 🗂️ **`/resume` picker pollution from `claude -p` in hooks.** New CAVEAT G14: any hook (Stop, SessionEnd, PostToolUse, etc.) that calls `claude -p` writes a fresh `sdk-cli` JSONL into the project's session folder every fire. The `/resume` picker filters these out but pages by mtime — once hook invocations outpace real interactive sessions, the picker renders empty. **Mitigation:** add `--no-session-persistence` to every hook-side `claude -p` invocation. One-line script change preserves the hook's behaviour completely.
- 🪝 **Fork D audit gains a picker-pollution check.** The hooks-audit prompt now flags any `claude -p` or `claude --bare -p` in `.claude/settings.json` hooks lacking `--no-session-persistence`.

### 🔧 Bumped

- `docs/CAVEATS.md` operational-gotcha count: 13 → 14
- README + SKILL.md caveats summary: new G14 highlight added
- Version badge: v3.0.0 → v3.0.1

### 🔗 Provenance

Encountered in the wild on a real project running a self-improving Stop hook (the pattern Anthropic's article describes and community plugins like Cole Medin's helpline AI-layer implement): 77 ghost `sdk-cli` sessions accumulated in one day vs 45 real interactive sessions, and the `/resume` picker rendered empty. Neither the article nor the community plugin examples surface the picker side-effect — encoding it here so future audits catch it before the user notices.

---

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

## [2.0.0] — 2026-05-22

Major rewrite. The skill is now aligned with both the [Anthropic article](https://claude.com/blog/how-claude-code-works-in-large-codebases-best-practices-and-where-to-start) and the [official Claude Code docs](https://code.claude.com/docs/en) cross-referenced against the docs' current surfaces.

### ⚠️ Breaking changes

- 🗑️ **Removed `templates/`** — `nested-CLAUDE.md.template`, `path-scoped-skill.template.md`, `settings.json.snippet`, `scripts/`. Templates were freezing project-specific shape and polluting the universal-skill use case. The new SKILL.md describes the *shape* of good CLAUDE.md / skill / hook config inline instead.
- 🗑️ **Removed `examples/trial-workflow.md`** — example workflows from a specific trial codebase either revealed project specifics or got sanitised to uselessness. The Phase 0-4 workflow in SKILL.md is itself the example.
- 🗑️ **Removed `docs/ANTHROPIC-ARTICLE-NOTES.md`** — the article is hyperlinked; a second-hand summary drifts as Anthropic updates the article.
- 🗑️ **Removed install Option C (Templates only — DIY)** — no longer applicable.

### ✨ Added

- 🧱 **9 AI-layer surfaces audited** (was 7): added auto-memory (`~/.claude/projects/<proj>/memory/`) and settings.json budget knobs (`skillListingBudgetFraction`, `maxSkillDescriptionChars`, `claudeMdExcludes`, `disableSkillShellExecution`).
- 🅶 **Phase 1 Fork G — auto-memory audit** (was 6 forks; now 7).
- 🪂 **Phase 0 fork-mode pre-flight check** — verifies `CLAUDE_CODE_FORK_SUBAGENT=1`, falls back to named sub-agents otherwise.
- 🧰 **`InstructionsLoaded` hook recommendation** — canonical diagnostic for "what actually loaded" used as Phase 0 / Fork-A first command.
- 👤 **DRI / ownership deliverable** in Phase 4 (article has an entire H2 dedicated to this).
- 🗓️ **3-6 month cadence — "Next review due" date** in the Phase 4 wrap (article's stated recommendation).
- 🔀 **Explicit Phase 3 fix-fork ordering** — CLAUDE.md → hooks → skills → sub-agents → plugins → LSP → MCP → auto-memory (the article is explicit: *"CLAUDE.md files come first"*).
- 📜 `CHANGELOG.md` (this file).

### 🐛 Corrected

- ❌ **"9 strategies → 7 components" framing was invented.** The article doesn't enumerate 9 strategies — it has 5 H2 sections of guidance. New framing: honest synthesis of article themes plus official-docs surfaces.
- ❌ **`tooling/` plugin subdirectory claim was false.** Official plugin layout per docs: `skills/ commands/ agents/ hooks/ monitors/ bin/ .mcp.json .lsp.json settings.json .claude-plugin/plugin.json`. Removed the false caveat.
- 🐛 **`paths:` parser bug scope was conflated.** Issue #17204 affects rules, not skills. Skills' `paths:` is documented and works as specified.
- 🐛 **`description:` field claim was misleading.** Reworded: undocumented for rules (loader ignores it); for skills it is the primary trigger field.
- 🎭 **Harness-as-thesis emphasis lifted** — the article's actual thesis (*"the harness matters as much as the model"*) is now stated in the opening.

### 🔧 Changed

- 📜 `SKILL.md` rewritten — 163 lines (was ~200 with broken pointers). Frontmatter description updated to reflect the 9 surfaces.
- 📚 `docs/CAVEATS.md` rewritten — 202 lines (was ~150). Includes 18 caveats with citations and mitigations. Added: settings.json budget knobs, `claudeMdExcludes`, `disableSkillShellExecution`, `InstructionsLoaded`, `.lsp.json`, DRI requirement, 3-6 month cadence, skill bundling rule.
- 📦 Repo structure simplified — `SKILL.md` + `docs/CAVEATS.md` are the only operational artefacts.

### 🔗 Sources for corrections

- [Anthropic article](https://claude.com/blog/how-claude-code-works-in-large-codebases-best-practices-and-where-to-start)
- [Official Claude Code docs](https://code.claude.com/docs/en) — skills, sub-agents, memory, hooks, MCP, plugins
- Issues: #17204 (rules `paths:` parser), #23478 (path-scoped read trigger)

---

## [1.0.0] — 2026-05-22

### Added

- 🎉 Initial release. Audit-and-fix workflow for 7 AI-layer components with parallel forked sub-agents.
- 📦 Templates for nested CLAUDE.md, path-scoped skills, settings.json snippets, helper scripts.
- 📖 Trial workflow example from a real codebase.
- 📚 Anthropic article notes and operational caveats.
