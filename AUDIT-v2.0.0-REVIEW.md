# 🔍 Independent audit of `large-codebase-audit-skill` v2.0.0

**Date:** 2026-05-22
**Method:** 5 parallel read-only forked sub-agents, each tasked with a non-overlapping slice (article fidelity, missing surfaces, per-surface depth × 2, skill quality / over-engineering). All forks fetched the live Anthropic article and live `https://code.claude.com/docs/en` pages.
**Inputs reviewed:** `SKILL.md`, `docs/CAVEATS.md`, `CHANGELOG.md`, `README.md` (no other files modified).
**Stance:** treat every confident claim as a hypothesis to test, not a fact to verify.

---

## 1. 📋 Executive summary

**Verdict:** v2 is a genuine improvement over v1 on framing (thesis, DRI, cadence, surface inventory expansion) but materially overstates how aligned it is with the article and docs. v2 closed v1's biggest fabrications and immediately introduced two new factual errors, a dead docs URL, a truncated quote presented as verbatim, and one mis-framing as canonical of an undocumented community pattern. The per-surface audit depth — the heart of the skill — covers ~10% of what the official docs document.

**Honest overall rating: 6.0 / 10** (v1 was 5.5; v2 self-projected 8.7). Better than v1, materially below the projected 8.7.

**Headline findings (one line each):**

| # | Finding | Severity |
|---|---|---|
| 1 | `CAVEATS.md` §11 states `skillListingBudgetFraction` default as `~0.10` — official docs say `0.01`. Off by 10× | 🔥 Factual error |
| 2 | `SKILL.md` row 6 places `disableSkillShellExecution` under MCP audit — it is a skills-execution control | 🔥 Factual error |
| 3 | `CAVEATS.md` §15 says LSP lives in `.lsp.json`; the URL pointer `/en/lsp` 404s — actual docs are at `/en/plugins-reference#lsp-servers` | 🔥 Dead reference |
| 4 | `CAVEATS.md` §17 quotes the cadence sentence half — drops Anthropic's second trigger ("plateaued after major model releases") | 🐛 Truncated quote |
| 5 | "Self-improving Stop hook" is repeated as canonical in SKILL.md + CAVEATS — no such pattern is documented in `/en/hooks` | 🎭 Soft fabrication |
| 6 | "9 official surfaces" — the docs nowhere enumerate nine surfaces; CHANGELOG admits it is a synthesis but README + frontmatter still use "official" | 🎭 Soft fabrication |
| 7 | "Use proactively when CLAUDE.md exceeds 80 lines" — no source for the threshold in the article or docs | 🎭 Magic number |
| 8 | "Frontmatter linting for skills" cited as a Phase 3 self-validation step — no such tool exists; not even an `npx`-able binary | 🎭 Hand-waving |
| 9 | "The article's stated hierarchy" misrepresents the article — article H3 order is CLAUDE.md → Hooks → Skills → Plugins → LSP → MCP → Subagents (no auto-memory; sub-agents AFTER plugins) | 🎭 Mis-framed |
| 10 | Phase 1 audit-fork prompts are one-row table summaries where real-world dispatched forks need 200–500-word templates | 🏗️ Structural |
| 11 | Fork C audits ~3 of ~23 documented skills frontmatter features and ~1 of ~21 sub-agent features | 📉 Audit depth |
| 12 | Fork D names 3 of 31 documented hook events and 1 of 5 handler types; entire sandbox subsystem (~25 keys) unaudited | 📉 Audit depth |
| 13 | Permissions block (`allow`/`ask`/`deny`/`defaultMode`/`additionalDirectories`) barely covered despite being the central project-safety knob | 📉 Audit depth |
| 14 | Bundled `/run`, `/verify`, `/run-skill-generator` (v2.1.145+) not surfaced as audit targets | 📉 Coverage gap |
| 15 | ~13 article themes missed entirely (legacy rules, monorepo invocation, scoped test/lint, agent-manager, tribal-knowledge framing, plateau cadence trigger, etc.) | 📉 Article fidelity |
| 16 | Fix-10 (Rules) is structurally demoted — included in Phase 1 (Fork B) but excluded from the Phase 3 ordered hierarchy, then re-tacked-on as "safe trims only" | 🏗️ Structural |
| 17 | "Order" of Phase 3 forks is ambiguous — they dispatch in parallel; presentation order is not execution order | 🏗️ Framing |
| 18 | Memory pruning advice rests on a partial fact — `MEMORY.md` is 200 lines OR 25KB (whichever first), and topic files load on demand, so pruning topic files is a no-op for startup cost | 🐛 Mis-framing |
| 19 | "Memory types" treated as a documented schema in CAVEATS — they are a community convention, not part of the auto-memory subsystem | 🎭 Mis-framing |
| 20 | No fallback for projects with no `.claude/` directory; no traversal of per-package `.claude/` in monorepos | 🏗️ Operational gap |

---

## 2. 📰 Article-fidelity findings

The article has **4 H2s** and **10 H3s**. Verified structure:

| H2 | H3s |
|---|---|
| 1. How Claude Code navigates large codebases | — |
| 2. The harness matters as much as the model | CLAUDE.md files come first; Hooks make the setup self-improving; Skills keep the right expertise available on-demand; Plugins distribute what works; Language server protocol (LSP) integrations; MCP servers extend everything; Subagents split exploration from editing |
| 3. Three configuration patterns from successful deployments | Making the codebase navigable at scale; Actively maintaining CLAUDE.md files as model intelligence evolves; Assigning ownership for Claude Code management and adoption |
| 4. Applying these patterns to your organization | — |

### 2.1 The three "fixed in v2" themes

| Theme | Status | Notes |
|---|---|---|
| 🎯 Harness as thesis | ✅ Captured | Real article quote: *"The ecosystem built around the model—the harness—determines how Claude Code performs more than the model alone."* Surfaced in SKILL.md L10 + README.md L12. Not lip-service. |
| 👤 DRI / ownership | ⚠️ Partial | Captured in Phase 4 + CAVEAT #16. Misses: the "agent-manager" hybrid PM/engineer role the article specifies; the *why* (article: *"Without that work, knowledge will stay tribal and adoption will plateau"*). The skill recommends DRI as a checklist item, not as the antidote to tribal knowledge. |
| 🗓️ 3-6 month cadence | ⚠️ Truncated | Article: *"Teams should expect to do a meaningful configuration review every three to six months, but it's also worth doing one whenever performance feels like it's plateaued after major model releases."* CAVEAT #17 quotes only the first half. The plateau/major-release trigger is a substantive omission — it's a second cadence signal, not stylistic. |

### 2.2 Mis-framed or fabricated claims

| Claim in v2 | Reality | Severity |
|---|---|---|
| "The article's stated hierarchy" (SKILL.md L72) introducing the 9-step Phase 3 order | The article makes exactly one ordering claim: the H3 header *"CLAUDE.md files come first"*. The H3 subsection order in §2 is CLAUDE.md → Hooks → Skills → Plugins → LSP → MCP → Subagents. The skill's order puts sub-agents *before* plugins and adds auto-memory (not in the article at all). | 🎭 Mis-framed |
| "CLAUDE.md files come first" | ✅ Real article H3 header. Accurate quote. | OK |
| "9 official surfaces" | The article enumerates 7 components under §2. Auto-memory + budget knobs are docs-only. "Official" implies Anthropic blessed a 9-list — they didn't. The CHANGELOG honestly admits the synthesis, but README + frontmatter description repeat "9 official surfaces" without the disclaimer. | 🎭 Soft fabrication |

### 2.3 Article themes missed or under-treated

13 themes the v2 audit doesn't actively address (no Phase 1 prompt would surface a gap):

1. **Initialize in subdirectories, not at the repo root** (article §3 H3: *"Making the codebase navigable at scale"*). No Phase 0 prompt asks about monorepo invocation.
2. **Scoping test and lint commands per subdirectory** (same H3). No Fork A/F prompt checks for scoped test/lint commands in nested CLAUDE.md.
3. **Outdated CLAUDE.md rules become constraining as models improve** (article §3 H3: *"Actively maintaining CLAUDE.md files…"*). No Fork A prompt asks "are any rules legacy mitigations for older model behaviour?"
4. **Agent-manager hybrid PM/engineer role** (article §3 H3: ownership). DRI captured; the agent-manager variant missing.
5. **Tribal-knowledge / adoption-plateau framing for DRI** — the *why*. Missing.
6. **Plateau / major-model-release as a second cadence trigger** — truncated from CAVEAT #17 (see 2.1).
7. **Hooks for *continuous improvement*, not just safety** — article's explicit reframing. v2 hook narrative is dominated by PreToolUse safety framing.
8. **Performance degradation from bloated CLAUDE.md** — 80-line limit captured; the *why* (performance) not articulated in audit prompts.
9. **Plugin marketplace distribution as the point of plugins** — Fork E checks for `plugin.json` but doesn't audit marketplace-readiness or marketplace.json.
10. **`.claudeignore`** — Fork F mentions as a recommendation; no Phase 1 prompt asks "does it exist? what does it exclude? what should it?"
11. **`permissions.deny` in version-controlled `settings.json`** — Fork F mentions in passing; not elevated to a first-class audit target.
12. **Codebase maps (markdown files describing directory structure)** — Fork F asks for a "10-line codebase map" as audit *output*, but doesn't audit whether one exists as a project artefact.
13. **Non-traditional setups (game engines, binary assets)** — article §H2 #4. Out of scope, but worth a one-line "this skill assumes a standard codebase" disclaimer.

---

## 3. 🧱 Per-surface docs-coverage findings

The skill declares 9 surfaces. The official Claude Code docs document roughly 15 disk-or-settings-resident surfaces relevant to an AI-layer audit. Coverage table below — rows in 🔥 are factual errors, 📉 are under-coverage gaps, ⚪ are legitimately out of scope.

| Surface | Feature | In v2? | Should be? | Notes |
|---|---|---|---|---|
| 📜 CLAUDE.md | Root size threshold | ✅ (80 lines) | Yes, but cite as heuristic | 80 is unsourced |
| 📜 CLAUDE.md | Nested files | ✅ | Yes | Fork A |
| 📜 CLAUDE.md | `claudeMdExcludes` setting | ✅ (CAVEAT #12) | Yes | Good |
| 📜 CLAUDE.md | `claudeMd` (managed) key | ❌ | Yes | One-line check in Fork A — managed override conflicts |
| 📜 CLAUDE.md | Scoped test/lint commands | ❌ | Yes | Article explicit |
| 📜 CLAUDE.md | Legacy rules / model-evolution rot | ❌ | Yes | Article explicit |
| 📜 CLAUDE.md | Block-level HTML comments stripped | ❌ | Optional | Low priority |
| 📋 Rules | Always vs path-scoped split | ✅ | Yes | Fork B is strong here |
| 📋 Rules | `paths:` parser quirks (#17204) | ✅ | Yes | CAVEAT #2, accurate |
| 📋 Rules | Rules-vs-skills classification | ✅ | Yes | CAVEAT #8 |
| 📋 Rules | **Phase 3 placement** | ⚠️ | Yes — currently demoted to "safe trims only" / Fix-10 | Structural inconsistency |
| 🎯 Skills | `name`, `description` quality | ❌ | Yes | `description` IS the trigger field |
| 🎯 Skills | `when_to_use` (1536-char shared cap with description) | ❌ | Yes | Undocumented in audit |
| 🎯 Skills | `paths:` glob audit | ⚠️ Partial | Yes | Fork C |
| 🎯 Skills | `context: fork` opportunities | ✅ | Yes | Fork C |
| 🎯 Skills | `allowed-tools` pre-approval | ❌ | Yes | Trust-on-load risk |
| 🎯 Skills | `disable-model-invocation` for side-effect skills | ❌ | Yes | Security/UX |
| 🎯 Skills | `user-invocable: false` for background-knowledge skills | ❌ | Yes | |
| 🎯 Skills | `model` / `effort` overrides | ❌ | Optional | |
| 🎯 Skills | `argument-hint` / `arguments` / `$N` substitution | ❌ | Yes | |
| 🎯 Skills | `agent:` paired with `context: fork` | ❌ | Yes | |
| 🎯 Skills | Skill-scoped `hooks:` frontmatter block | ❌ | Yes | New surface entirely |
| 🎯 Skills | `${CLAUDE_SKILL_DIR}` in bundled scripts | ❌ | Yes | Hardcoded paths break plugin install |
| 🎯 Skills | Orphan supporting files outside skill dir | ❌ | Yes | CAVEAT #18 declares the rule, prompt doesn't enforce |
| 🎯 Skills | `.claude/commands/*.md` migration to skills (v2.1.145+) | ❌ | Yes | Commands merged into skills |
| 🎯 Skills | Bundled `/run`, `/verify`, `/run-skill-generator` recipe | ❌ | Yes — high value | Anthropic explicitly recommends per-project |
| 🎯 Skills | 500-line SKILL.md soft cap | ❌ | Yes | |
| 🎯 Skills | `shell: powershell` for cross-platform skills | ❌ | Low | |
| 🎯 Skills | Skill precedence (enterprise > personal > project > plugin) | ❌ | Low | |
| 🎯 Skills | `/skills` menu state (which are off / name-only) | ❌ | Yes | Diagnostic |
| 🤖 Sub-agents | `name`, `description` quality | ❌ | Yes | Description drives delegation |
| 🤖 Sub-agents | `tools` vs `disallowedTools` | ❌ | Yes | Read-only vs write distinction |
| 🤖 Sub-agents | `permissionMode` (especially `bypassPermissions` misuse) | ❌ | Yes | Security |
| 🤖 Sub-agents | `model` choice (Haiku for high-volume) | ❌ | Yes | Cost-relevant |
| 🤖 Sub-agents | `maxTurns` runaway protection | ❌ | Yes | |
| 🤖 Sub-agents | `skills:` preload | ❌ | Yes | Domain-agent enablement |
| 🤖 Sub-agents | `mcpServers:` scoping | ❌ | Yes | Keeps MCP off main context |
| 🤖 Sub-agents | Agent-scoped `hooks:` | ❌ | Yes | New surface |
| 🤖 Sub-agents | `memory: user/project/local` | ❌ | Yes | Persistent learning |
| 🤖 Sub-agents | `background: true` for long-running | ❌ | Yes | |
| 🤖 Sub-agents | `isolation: worktree` candidates | ❌ | Yes | User-scope `forked-subagents.md` already calls this out |
| 🤖 Sub-agents | `initialPrompt` for default-agent sessions | ❌ | Yes | |
| 🤖 Sub-agents | `Agent(agent_type)` tool-list restriction | ❌ | Yes | |
| 🤖 Sub-agents | Duplicate-name silent discard | ❌ | Yes | |
| 🤖 Sub-agents | Plugin-agent restrictions (no `hooks`/`mcpServers`/`permissionMode`) | ❌ | Yes | |
| 🪝 Hooks | `Stop` event | ✅ | Yes | But "self-improving" is undocumented framing |
| 🪝 Hooks | `InstructionsLoaded` event | ✅ | Yes | Good — CAVEAT #14 |
| 🪝 Hooks | `PreToolUse` event | ✅ | Yes | |
| 🪝 Hooks | `PostToolUse` event | ❌ | Yes | |
| 🪝 Hooks | `UserPromptSubmit` event | ❌ | Yes | Prompt-shaping reminders |
| 🪝 Hooks | `UserPromptExpansion` event | ❌ | Yes | |
| 🪝 Hooks | `SessionStart` / `Setup` / `SessionEnd` events | ❌ | Yes | Bootstrap / wrap workflows |
| 🪝 Hooks | `SubagentStart` / `SubagentStop` / `TeammateIdle` | ❌ | Yes | |
| 🪝 Hooks | `TaskCreated` / `TaskCompleted` | ❌ | Yes | |
| 🪝 Hooks | `PreCompact` / `PostCompact` | ❌ | Yes | Context-management automation |
| 🪝 Hooks | `WorktreeCreate` / `WorktreeRemove` | ❌ | Yes | |
| 🪝 Hooks | `CwdChanged` / `FileChanged` / `ConfigChange` | ❌ | Yes | |
| 🪝 Hooks | `Notification` / `Elicitation` / `ElicitationResult` | ❌ | Yes | |
| 🪝 Hooks | `PermissionRequest` / `PermissionDenied` / `PostToolUseFailure` / `PostToolBatch` / `StopFailure` | ❌ | Yes | |
| 🪝 Hooks | Handler types beyond `command` (`http`, `mcp_tool`, `prompt`, `agent`) | ❌ | Yes | Modernisation lever |
| 🪝 Hooks | `if:` permission-rule filtering on tool events | ❌ | Yes | |
| 🪝 Hooks | `async` / `asyncRewake` / `once` flags | ❌ | Yes | |
| 🪝 Hooks | Exit-code semantics + `hookSpecificOutput` JSON contract | ❌ | Yes | |
| 🪝 Hooks | `disableAllHooks`, `allowedHttpHookUrls`, `httpHookAllowedEnvVars`, `allowManagedHooksOnly` | ❌ | Yes | Security |
| 🪝 Hooks | "Self-improving Stop hook" — defined? | ❌ | Yes — define or drop | Not in docs |
| 🔌 MCP | Scope hierarchy (local / project / user / plugin / claude.ai) | ⚠️ Partial | Yes | Only "project-scope" mentioned |
| 🔌 MCP | `.mcp.json` schema | ❌ | Yes | |
| 🔌 MCP | Transport types (http / sse-deprecated / stdio / streamable-http) | ❌ | Yes | |
| 🔌 MCP | `alwaysLoad: true` to exempt from tool-search deferral | ❌ | **Yes — biggest MCP context lever** | |
| 🔌 MCP | `ENABLE_TOOL_SEARCH` env (default / true / auto / auto:N / false) | ❌ | **Yes — biggest context lever** | |
| 🔌 MCP | `MAX_MCP_OUTPUT_TOKENS` (default 25K, warn at 10K) | ❌ | Yes | |
| 🔌 MCP | OAuth + `headersHelper` patterns | ❌ | Yes | |
| 🔌 MCP | `${CLAUDE_PLUGIN_ROOT}` / `${VAR:-default}` expansion | ❌ | Yes | |
| 🔌 MCP | Managed `allowedMcpServers`/`deniedMcpServers`/`allowManagedMcpServersOnly` | ❌ | Yes | |
| 🔌 MCP | `disabledMcpjsonServers` / `enabledMcpjsonServers` / `enableAllProjectMcpServers` | ❌ | Yes | |
| 🔌 MCP | `disableSkillShellExecution` placement | 🔥 **Wrong** | Move to Skills/Settings | This is a skills-execution control, not MCP |
| 🔌 MCP | Restart-vs-`/clear` | ✅ | Yes | CAVEAT #5 — good |
| 🔎 LSP | Pre-built LSP plugins for common languages | ❌ | Yes | Docs say *install the plugin*, skill says *write `.lsp.json`* |
| 🔎 LSP | `.lsp.json` location (plugin root canonical) | ⚠️ | Yes | Skill implies project-root |
| 🔎 LSP | Docs URL | 🔥 **Dead** | Fix to `/en/plugins-reference#lsp-servers` | `/en/lsp` 404s |
| 🔎 LSP | Multi-language `extensionToLanguage` config | ❌ | Yes | |
| 📦 Plugins | `plugin.json` core fields | ⚠️ Partial | Yes | Only existence checked |
| 📦 Plugins | `.claude-plugin/marketplace.json` | ❌ | Yes | Distribution surface |
| 📦 Plugins | Managed `strictKnownMarketplaces`, `blockedMarketplaces`, `strictPluginOnlyCustomization` | ❌ | Yes | |
| 📦 Plugins | `monitors/monitors.json` schema | ❌ | Yes | Layout mentions `monitors/`, never audits it |
| 📦 Plugins | `bin/` PATH addition | ❌ | Yes | |
| 📦 Plugins | Plugin `settings.json` honors only `agent` + `subagentStatusLine` | ❌ | Yes | Common misconception |
| 📦 Plugins | Plugin trust dialog + first-install behaviour | ❌ | Yes | |
| 📦 Plugins | Inline `mcpServers` in `plugin.json` | ❌ | Yes | Alternative to `.mcp.json` |
| 📦 Plugins | `--plugin-dir` / `--plugin-url` / `/reload-plugins` for dev | ❌ | Yes | |
| 📦 Plugins | `claude plugin validate` | ❌ | Yes | Pre-submission check |
| 🧠 Auto-memory | Storage path keyed by git repo (worktrees share) | ⚠️ Partial | Yes | Derivation rule missing |
| 🧠 Auto-memory | `MEMORY.md` 200 lines OR 25KB cutoff | 🔥 **Partial / wrong** | Yes | CAVEAT says "~200 lines"; misses 25KB; misses OR semantics |
| 🧠 Auto-memory | **Topic files load on demand, not at session start** | ❌ | Yes — changes pruning advice | This is the central fact |
| 🧠 Auto-memory | `autoMemoryEnabled` setting + `CLAUDE_CODE_DISABLE_AUTO_MEMORY` env | ❌ | Yes | |
| 🧠 Auto-memory | `autoMemoryDirectory` (managed/user only) | ❌ | Yes | |
| 🧠 Auto-memory | `/memory` command (browse, toggle, open folder) | ❌ | Yes | Diagnostic |
| 🧠 Auto-memory | Subagent-scoped auto-memory | ❌ | Yes | New surface |
| 🧠 Auto-memory | "Memory types" framing | 🎭 Mis-framed | Yes — soften | Community convention, not docs schema |
| 🧠 Auto-memory | Minimum version (v2.1.59+) | ❌ | Optional | |
| ⚙️ Settings | Settings layering (managed > CLI > local > project > user) | ❌ | **Yes — fundamental** | |
| ⚙️ Settings | `.claude/settings.local.json` (and its gitignore status) | ❌ | **Yes — common foot-gun** | Secrets get committed |
| ⚙️ Settings | `permissions.allow/ask/deny` rule arrays + merge semantics | ❌ | **Yes — central security knob** | |
| ⚙️ Settings | `permissions.defaultMode` (default / acceptEdits / plan / auto / dontAsk / bypassPermissions) | ❌ | **Yes — project posture decision** | |
| ⚙️ Settings | `permissions.additionalDirectories` | ❌ | Yes | |
| ⚙️ Settings | Read/Edit rule path anchors (`//abs`, `~/home`, `/root`, `./cwd`) | ❌ | Yes | |
| ⚙️ Settings | Bash wildcard + process-wrapper stripping | ❌ | Yes | |
| ⚙️ Settings | `Agent(Name)` permission rules | ❌ | Yes | |
| ⚙️ Settings | MCP permission patterns (`mcp__server`, `mcp__server__*`, `mcp__server__tool`) | ❌ | Yes | |
| ⚙️ Settings | **Sandbox subsystem (`sandbox.*`, ~25 keys)** | ❌ | **Yes — largest security surface omitted** | Filesystem/network/Mach allowlists |
| ⚙️ Settings | `skillListingBudgetFraction` default value | 🔥 **Wrong** | Yes | CAVEAT #11 says "~0.10"; docs say `0.01` (10× error) |
| ⚙️ Settings | `maxSkillDescriptionChars` (default 1536) | ⚠️ | Yes | Default not shown |
| ⚙️ Settings | `skillOverrides` values (on / name-only / user-invocable-only / off) | ⚠️ | Yes | Values not enumerated |
| ⚙️ Settings | `env` block injection | ❌ | Yes | |
| ⚙️ Settings | `outputStyle` setting + `.claude/output-styles/` | ❌ | Yes | One-line check |
| ⚙️ Settings | `statusLine` custom command | ❌ | Optional | |
| ⚙️ Settings | Plan mode + `plansDirectory` / `useAutoModeDuringPlan` | ❌ | Yes | Where do plan files land? gitignored? |
| ⚙️ Settings | Worktrees (`worktree.baseRef/symlinkDirectories/sparsePaths/bgIsolation`) | ❌ | **Yes — directly relevant to large codebases** | |
| ⚙️ Settings | `autoMode` classifier rules | ❌ | Yes | Direct overlap with rules |
| ⚙️ Settings | `disableAgentView` (background-task UI) | ❌ | Optional | |
| ⚙️ Settings | `apiKeyHelper`, `awsCredentialExport`, `gcpAuthRefresh`, `otelHeadersHelper` | ❌ | Optional | |
| ⚙️ Settings | `attribution`, `includeGitInstructions`, `prUrlTemplate` | ❌ | Optional | |
| ⚙️ Settings | `autoUpdatesChannel`, `minimumVersion` | ❌ | Optional | |
| ⚪ Out of scope | Channels / Remote Control / Slack / Telegram | ❌ | No | Session transports |
| ⚪ Out of scope | TUI / spinner / language / viewMode / notification channel | ❌ | No | Personal user settings |
| ⚪ Out of scope | IDE-extension config (`autoConnectIde`, `autoInstallIdeExtension`) | ❌ | No | Per-user, not project |

**Quantitative summary:**

| Category | Documented features | v2 covers | Coverage |
|---|---|---|---|
| Skills | ~23 | ~4 | ~17% |
| Sub-agents | ~16 | ~1 | ~6% |
| Hooks | ~31 events + 5 handler types + ~10 settings | ~3 events, 1 handler implicit | ~10% |
| MCP | ~17 | ~2 | ~12% |
| LSP | ~5 | ~1 | ~20% |
| Plugins | ~12 | ~1 | ~8% |
| Auto-memory | ~10 | ~2 | ~20% |
| Settings / permissions | ~25 | ~4 | ~16% |
| **Aggregate** | **~145** | **~19** | **~13%** |

That's the structural finding: v2 covers ~13% of documented surface area. The "9 surfaces" framing implies broad coverage; the reality is *surface inventory, not surface depth*.

---

## 4. ➕ Proposed additions

Prioritised. Each has rationale, doc URL, and impact on the skill's purpose (audit + fix the AI layer).

### 🔥 P0 — Factual corrections (must-fix; non-breaking; ship in v2.0.1 or v2.1.0)

1. **Correct `skillListingBudgetFraction` default** to `0.01` in CAVEAT #11. Update the worked example ("0.10 → 0.05" → use a real before/after pair anchored on `0.01`). [docs: `/en/settings#skill-listing-budget`]
2. **Move `disableSkillShellExecution`** out of the MCP audit row (SKILL.md table row 6) into the Skills or Settings row. Update CAVEAT #13 accordingly. [docs: `/en/skills` security section]
3. **Fix the LSP docs URL** — replace `/en/lsp` references with `/en/plugins-reference#lsp-servers`. Add a note that the pre-built LSP plugins (TypeScript, Python, Rust) should be installed before rolling a custom `.lsp.json`. [docs: `/en/plugins-reference#lsp-servers`]
4. **Complete the cadence quote** in CAVEAT #17 — include the *"…or whenever performance feels like it's plateaued after major model releases"* clause and add a Phase 0 prompt: "Has there been a major model release since the last review?" [article §3 H3]
5. **Either define "self-improving Stop hook"** in CAVEATS or drop the phrase. If kept, frame it as a *pattern* (e.g. "the community pattern of a Stop hook that introspects the conversation and updates rules / skills / CLAUDE.md") not as docs-blessed terminology.
6. **Soften "memory types" framing** in CAVEAT #10 — note that user/feedback/project/reference is a popular community convention, not part of the auto-memory subsystem schema.
7. **Replace "frontmatter linting for skills"** with a concrete command: `python3 -c "import yaml,sys; yaml.safe_load(open(sys.argv[1]).read().split('---')[1])" SKILL.md` (or `yq eval '.name,.description' SKILL.md`). Same treatment for "line counts for CLAUDE.md" → `wc -l CLAUDE.md`.
8. **Reframe "the article's stated hierarchy"** as "ordered with CLAUDE.md first per the article (the H3 *'CLAUDE.md files come first'*); subsequent steps are our recommended sequence." Own the divergence.
9. **Correct `MEMORY.md` cutoff** to "first 200 lines OR 25KB, whichever first" and clarify that topic files load on demand (so pruning topic files does not reduce session-start cost).

### 📉 P1 — Coverage additions where the skill's purpose mandates the audit

10. **Sandbox subsystem audit** — add to Fork D / new Fork H. The `sandbox.*` block (~25 keys: `enabled`, `filesystem.denyRead/Write`, `network.allowedDomains/deniedDomains`, etc.) is the largest security knob the skill ignores. Impact: high; aligns directly with skill purpose. [docs: `/en/settings#sandboxing`, `/en/sandboxing`]
11. **Permissions block audit** — first-class. `allow`/`ask`/`deny`/`defaultMode`/`additionalDirectories`/merge semantics. Currently a passing reference. Impact: high; central to safe AI-layer posture. [docs: `/en/permissions`]
12. **Hook event catalog enumeration** — replace Fork D's three-event prompt with an explicit pass over all 31 documented events. Highest-value adds: `UserPromptSubmit`, `PreCompact`, `SessionStart`/`SessionEnd`, `PostToolUse`, `SubagentStop`. Impact: high; "hooks make the setup self-improving" is half the article's harness section. [docs: `/en/hooks`]
13. **Hook handler types beyond `command`** — `http`, `mcp_tool`, `prompt`, `agent`. Fork D should ask which type each existing hook uses and whether `command` could be replaced. [docs: `/en/hooks#hook-configuration`]
14. **Per-frontmatter-field audit for Fork C skills** — convert the prompt from "inventory + missing skills" to "for every existing skill, audit each documented frontmatter field (`name`, `description`, `when_to_use`, `paths`, `allowed-tools`, `disable-model-invocation`, `user-invocable`, `context`, `agent`, `model`, `argument-hint`, `hooks`, `shell`) plus `${CLAUDE_SKILL_DIR}` usage and orphan supporting files." [docs: `/en/skills`]
15. **Existing sub-agent audit (not just gap-finding)** — Fork C currently only checks for explorer/db-inspector existence. Add field-by-field audit of every existing agent: `tools`/`disallowedTools` security, `model` cost, `permissionMode` safety, `memory` opportunity, `mcpServers` scoping, `isolation: worktree` candidates, `skills:` preload. [docs: `/en/sub-agents`]
16. **MCP tool-search posture** — for projects with >3 MCP servers, audit whether `ENABLE_TOOL_SEARCH` is set and whether servers are marked `alwaysLoad: true`. Single largest MCP context cost. [docs: `/en/mcp`]
17. **Worktree configuration audit** — `worktree.baseRef/symlinkDirectories/sparsePaths/bgIsolation`. Directly relevant to the "large codebase" audience and to forked-agent isolation. [docs: `/en/settings#worktrees`, `/en/worktrees`]
18. **Bundled `/run`, `/verify`, `/run-skill-generator` recipe** — Anthropic explicitly recommends per-project capture. Fork A or new Phase-0 check: "has the project captured its run / verify recipe?" [docs: `/en/skills#bundled-skills`]
19. **Slash commands → skills migration** — `.claude/commands/*.md` is the legacy form; v2.1.145+ merges into skills. Fork C should flag candidates for migration. [docs: `/en/skills` + `/en/commands`]
20. **`.claudeignore` + `permissions.deny` as first-class audit items** — currently mentioned in passing in Fork F. Move to Fork D as explicit prompts.
21. **Settings layering check** — managed > CLI > local > project > user. Audit should ask whether a managed `claudeMd`, `managed-settings.json`, or `managed-settings.d/` exists at org level and conflicts with project CLAUDE.md. [docs: `/en/settings#settings-precedence`]
22. **`.claude/settings.local.json` audit** — Fork D must check both `settings.json` AND `settings.local.json`, AND that `settings.local.json` is gitignored. Common foot-gun: secrets get committed.
23. **`autoMode` classifier rules audit** — `allow` / `soft_deny` / `hard_deny` / `environment`. Direct overlap with rules-vs-skills classification. [docs: `/en/auto-mode`]
24. **Marketplace manifest audit** — `.claude-plugin/marketplace.json` for projects that are plugins; managed `strictKnownMarketplaces` / `blockedMarketplaces` for projects that consume plugins. [docs: `/en/plugins`]

### 📰 P2 — Article-fidelity additions

25. **"Are any CLAUDE.md rules legacy mitigations a newer model wouldn't need?"** — Fork A prompt. Captures article §3 H3 *"Actively maintaining CLAUDE.md files as model intelligence evolves"*. Currently absent.
26. **"Do nested CLAUDE.md files contain scoped test/lint commands?"** — Fork A or F. Article explicit.
27. **"Is Claude being initialized at sub-tree roots in monorepos rather than the repo root?"** — Phase 0 or Fork F. Article explicit.
28. **Agent-manager role variant** — Phase 4 wrap should mention DRI + agent-manager (hybrid PM/engineer) as two valid ownership shapes.
29. **Tribal-knowledge framing for DRI** — include the *why* (the article's *"Without that work, knowledge will stay tribal and adoption will plateau"*).
30. **Hooks reframing** — Phase 4 narrative should mention that the article's main hook value is continuous improvement, not safety. Re-balance Fork D's PreToolUse-safety dominance.

### 🏗️ P3 — Structural / prompt-quality improvements

31. **Convert Phase 1 fork-table rows into 200–300-word prompt templates** — each template embeds reading scope, comparison frame, output sections, word limit, self-validation step, and one example punch-list item. The table becomes the TOC.
32. **Surface→audit-fork→fix-fork mapping table** — single explicit table eliminating the "9 surfaces / 7 audit forks / 10 fix forks" confusion.
33. **Phase 0.5: scaffold `.claude/` if absent** — most "audit a large untuned codebase" cases have no `.claude/` yet. Skill should handle this rather than implicitly assuming one exists.
34. **Monorepo per-package `.claude/` traversal** — real monorepos have per-package `.claude/skills/` and `.claude/rules/`. Skill must traverse, not just nested CLAUDE.md.
35. **Adaptive Phase 3 fork dispatch** — drop fix forks whose Phase 1 fork found no actionable items. Currently the fixed 10-fork dispatch produces no-op forks for small projects.
36. **Make Phase 4 inline, not a fork** — the output IS the deliverable (session log). Forking it loses immediate user context for no gain.
37. **`_CONSOLIDATION_PROPOSALS.md` drain mechanism** — either commit to "next cycle reads and drains this file" or auto-apply trivial consolidations with explicit user approval. Today it's procrastination dressed as caution.
38. **`.claude/session/REVIEW_DUE.md` + Stop-hook surfacing** — the "Next review due" date currently ages quietly. Write it to a known file AND emit a session-end log line a Stop hook can surface.

### ⚪ P4 — Optional / low-priority

39. **Block-level HTML comments stripped from CLAUDE.md** — one-line note in CAVEATS.
40. **One-line "non-traditional codebases" disclaimer** (game engines, binary assets) — article §H2 #4.
41. **Skill content lifecycle (compaction re-attach)** — for skill-heavy projects.

---

## 5. ➖ Proposed removals

### 5.1 Trim from CAVEATS

| Caveat | Action | Reason |
|---|---|---|
| #14 (`InstructionsLoaded` is canonical diagnostic) | Move to SKILL.md (best-practice) | It's policy, not gotcha |
| #15 (LSP lives in `.lsp.json`) | Move to SKILL.md (best-practice) | Same |
| #16 (DRI requirement) | Move to SKILL.md Phase 4 | Already there; CAVEAT duplicates |
| #17 (3-6 month cadence) | Move to SKILL.md Phase 4 | Same; current quote is also truncated |
| #18 (Skill bundling rule) | Move to SKILL.md (best-practice section) | Convention, not behaviour-gotcha |

These five are policy/best-practice items mixed with operational gotchas (#1-#13). Splitting them clarifies both. Net result: CAVEATS goes from 18 entries to 13 true gotchas; SKILL.md gains a "best practices" section.

### 5.2 Trim from README

- "9 *official* surfaces" → either drop "official" or attribute as synthesis with the doc URL nearby. Same correction in frontmatter `description` and SKILL.md L8.
- The Installation Option B ("Project scope") is honestly noted as "rarely needed." Consider removing — it adds doc surface for a low-value path.

### 5.3 Trim from SKILL.md

- "frontmatter linting for skills" — already flagged for replacement.
- "the article's stated hierarchy" wording — already flagged for reframing.
- Phase 3 fix-fork order list — either match article H3 order or own divergence (per P0 #8).

---

## 6. 🚦 v2.1.0 vs v3.0.0 split

### v2.1.0 — non-breaking corrections + coverage expansions

All P0 (factual fixes) plus the additive items in P1, P2, P3 that don't change skill contract:

- P0 #1-#9 — factual corrections, terminology fixes, dead-URL fix
- P1 #10-#24 — surface-coverage additions (new audit prompts; doesn't change Phase numbering or fork count)
- P2 #25-#30 — article-fidelity prompt additions
- P3 #31-#32 — prompt-template conversion, mapping table (additive)
- P3 #38 — REVIEW_DUE.md emission (new artefact; existing flow unchanged)
- All P4 — optional

### v3.0.0 — breaking framing / structural changes

Changes that alter the skill's contract or the dispatch shape:

- **Drop or reframe "9 official surfaces"** — affects frontmatter description and README; users searching by phrase will need to update mental model. Either become "the AI-layer surfaces" (no count) or expand to a documented 12–15 with the docs-only ones called out.
- **Phase 3 order change** — match article H3 order (CLAUDE.md → Hooks → Skills → Plugins → LSP → MCP → Subagents → auto-memory) or own divergence explicitly. Today's order quietly diverges.
- **Adaptive fork dispatch (P3 #35)** — changes the user-visible behaviour (number of forks dispatched per cycle). Worth a major bump.
- **Phase 0.5 scaffold (P3 #33)** + **monorepo `.claude/` traversal (P3 #34)** — both extend the skill's scope beyond "audit an existing AI layer."
- **Rules elevation** — promote Rules out of Fix-10's "safe trims only" purgatory into the article-ordered hierarchy (or document the structural reason for the deferral). Today's split is inconsistent across phases.
- **Make Phase 4 inline (P3 #36)** — removes the wrap fork; changes the "always N+1 forks per cycle" model.
- **CAVEATS restructure (5.1)** — splits 18 caveats into 13 gotchas + 5 best-practices items. Doc shape changes.

### v2.0.1 — emergency patch (optional)

If users are already running v2 in production, the three hardest factual errors warrant a patch ship:
- P0 #1 (`skillListingBudgetFraction` default)
- P0 #2 (`disableSkillShellExecution` placement)
- P0 #3 (dead LSP URL)

These three give users actively wrong information today.

---

## 7. 📊 Per-area ratings + overall

Rated against the skill's stated purpose: *audit and improve a Claude Code project's AI layer end-to-end*. v1 was self-rated 5.5/10; v2 projected itself at 8.7/10.

| Area | v1 (claimed) | v2 (projected) | v2 (audited) | Δ vs v1 | Notes |
|---|---|---|---|---|---|
| 🎯 Article fidelity | 4.0 | 8.5 | 6.5 | +2.5 | Thesis + DRI + cadence captured. Hierarchy mis-framed; 13 article themes missed; cadence quote truncated. |
| 🧱 Surface inventory completeness | 5.0 | 9.0 | 6.0 | +1.0 | 9 declared vs ~15 documented. Sandboxing, permissions block, worktrees, bundled-skills missing. |
| 📉 Per-surface audit depth | 4.0 | 8.0 | 3.5 | -0.5 | Aggregate ~13% coverage; Fork C and Fork D are the weakest. This is the central weakness. |
| 🚨 Caveats accuracy | 6.0 | 9.0 | 5.0 | -1.0 | Two factual errors (`skillListingBudgetFraction`, `disableSkillShellExecution` placement), one dead URL, one truncated quote, two soft-mis-framings. |
| 📝 Prompt quality | 4.0 | 8.0 | 4.0 | 0 | Phase 1 fork prompts are table-row summaries. "Frontmatter linting" hand-waved. Real-world dispatched forks need 200–500-word templates. |
| 🔗 Internal consistency | 5.0 | 8.5 | 6.0 | +1.0 | Counting drift (9/7/10), Rules surface inconsistently treated across phases, "order" ambiguous for parallel dispatch. |
| 🛠️ Operational realism | 5.0 | 8.5 | 5.0 | 0 | No fallback for no-`.claude/` projects, no monorepo `.claude/` traversal, fixed 10-fork dispatch doesn't adapt. |
| 🎭 Honesty of framing | 6.0 | 9.0 | 6.0 | 0 | v2 closed v1's "9 strategies → 7 components" and `tooling/` fabrications, then introduced "9 official surfaces", "80 lines", "self-improving Stop hook" as new soft fabrications. |
| 📦 Bundling decisions | 4.0 | 9.0 | 8.5 | +4.5 | Templates removal is correct. `examples/trial-workflow.md` removal is correct. Two-file skill (SKILL.md + CAVEATS.md) is right shape. |
| **🎯 Overall** | **5.5** | **8.7** | **6.0** | **+0.5** | Genuine improvement; substantially below projection. |

### Verdict

v2 is a real step forward — bundling, framing, and surface inventory all improved — but the projected 8.7 substantially overstates current state. The audit-depth dimension (the heart of what the skill is for) is the weakest, and the new soft fabrications partially offset the closures of v1's old ones. Three concrete factual errors (P0 #1-#3) actively mislead users today.

With **P0 (factual corrections) applied** in a v2.0.1 emergency patch, an honest rating moves to ~6.8.

With **P0 + P1 + P2 (factual + coverage + article-fidelity)** applied as v2.1.0, an honest rating moves to ~7.8.

With **P0 + P1 + P2 + P3 (the prompt-template conversion and structural fixes)** as v3.0.0, an honest rating reaches the projected ~8.7.

---

## 🔗 Sources

- Anthropic article: <https://claude.com/blog/how-claude-code-works-in-large-codebases-best-practices-and-where-to-start>
- Official docs index: <https://code.claude.com/docs/en>
- Specific doc pages cited: `/en/skills`, `/en/sub-agents`, `/en/memory`, `/en/hooks`, `/en/mcp`, `/en/plugins`, `/en/plugins-reference#lsp-servers`, `/en/settings`, `/en/permissions`, `/en/worktrees`, `/en/sandboxing`, `/en/output-styles`, `/en/auto-mode`
- Live fork transcripts: 5 read-only forks, each fetched the article and the relevant doc pages from scratch and reported independently.

## Method note

5 parallel forks dispatched in a single message (true parallelism). Each fork was given a narrow non-overlapping scope and instructed to fetch the source material fresh — not to rely on the previous v2 session's framing. Findings were then merged into this single report. No artefact under review (`SKILL.md`, `README.md`, `CHANGELOG.md`, `docs/CAVEATS.md`) was modified — this is a read-only audit, per the user's standing instruction. Fixes will be applied in a follow-up session after review.
