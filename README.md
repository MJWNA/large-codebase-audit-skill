# 🏗️ Large Codebase AI-Layer Audit

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Claude Code](https://img.shields.io/badge/Claude%20Code-Skill-D97757?logo=anthropic&logoColor=white)](https://code.claude.com/docs/en)
[![Version](https://img.shields.io/badge/Version-v3.0.3-blue)](CHANGELOG.md)
[![GitHub stars](https://img.shields.io/github/stars/MJWNA/large-codebase-audit-skill?style=flat)](https://github.com/MJWNA/large-codebase-audit-skill/stargazers)
[![GitHub issues](https://img.shields.io/github/issues/MJWNA/large-codebase-audit-skill)](https://github.com/MJWNA/large-codebase-audit-skill/issues)
[![Last commit](https://img.shields.io/github/last-commit/MJWNA/large-codebase-audit-skill)](https://github.com/MJWNA/large-codebase-audit-skill/commits/main)

> **A Claude Code skill that audits and improves a project's entire AI layer in one cycle, using parallel forked sub-agents. Aligned with the [Anthropic article](https://claude.com/blog/how-claude-code-works-in-large-codebases-best-practices-and-where-to-start) and cross-referenced against the [official Claude Code docs](https://code.claude.com/docs/en).**

The Anthropic article's central thesis is that **the harness matters as much as the model**. This skill audits the harness as a whole — across the AI-layer surfaces the article + docs describe — then applies fixes in the order the article recommends (CLAUDE.md first), with disjoint write scopes so parallel forks never collide.

> 🆕 **Version 3.0.0** closes all 41 findings from the independent v2 audit. See [CHANGELOG.md](CHANGELOG.md) and [AUDIT-v2.0.0-REVIEW.md](AUDIT-v2.0.0-REVIEW.md) for the trace. Breaking changes: dropped the fixed "9 official surfaces" framing, adaptive Phase 3 dispatch, inline Phase 4, CAVEATS restructured.

---

## 📋 Table of contents

- [Why this exists](#-why-this-exists)
- [What it audits](#-what-it-audits)
- [What it fixes](#-what-it-fixes)
- [How it works](#-how-it-works)
- [Quick start](#-quick-start)
- [Installation](#-installation)
- [Output](#-output)
- [Operational caveats](#-operational-caveats)
- [Requirements](#-requirements)
- [Contributing](#-contributing)
- [Acknowledgements](#-acknowledgements)
- [License](#-license)

---

## 🎯 Why this exists

Applying the Anthropic methodology to a real, organically-grown codebase by hand takes hours and introduces drift between layers. A typical mid-sized Next.js, Rails, or Django project has:

- 📜 A bloated root `CLAUDE.md` with embedded rule indexes (re-rots on every rule add)
- 📋 Always-loaded rules that should be path-scoped (every session pays the cost)
- 🎯 Zero path-scoped skills for recurring task shapes
- 🪝 No self-improving Stop hook, no `InstructionsLoaded` diagnostic
- 🤖 No sub-agents to keep exploration out of the editing context window
- 🔎 No LSP-backed symbol search
- 🔌 MCP servers configured at the wrong scope, or missing entirely
- 🧠 Stale or absent auto-memory entries
- 📏 Unbounded skill-listing budget eating context at every session start

This skill walks all 9 surfaces in **one parallel-forked cycle**, applies fixes with non-overlapping write scopes, and produces a session log you can feed back into the next iteration.

---

## 🔍 What it audits

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

---

## 🔧 What it fixes

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

---

## ⚙️ How it works

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

---

## ⚡ Quick start

After [installing](#-installation) the skill:

```
You: audit my AI layer
Claude: [Phase 0: pre-flight checks, fork-mode verify, InstructionsLoaded diagnostic]
        [Phase 1: dispatches 7 read-only audit forks in parallel]
        [returns synthesised plan]
You: yes go ahead
Claude: [Phase 3: dispatches fix forks in ordered, disjoint scopes]
        [Phase 4: writes session log with DRI + next-review-date]
```

Other trigger phrases:
- "audit Claude config"
- "large codebase audit"
- "tune my .claude"
- "apply Anthropic patterns"
- "harness audit"

---

## 📦 Installation

### Option A — User scope (recommended)

Install the skill globally so it's available in every project:

```bash
git clone git@github.com:MJWNA/large-codebase-audit-skill.git /tmp/lca
mkdir -p ~/.claude/skills/large-codebase-audit
cp /tmp/lca/SKILL.md ~/.claude/skills/large-codebase-audit/SKILL.md
mkdir -p ~/.claude/skills/large-codebase-audit/docs
cp /tmp/lca/docs/CAVEATS.md ~/.claude/skills/large-codebase-audit/docs/CAVEATS.md
rm -rf /tmp/lca
```

The skill auto-loads in any Claude Code session via its description's trigger phrases.

### Option B — Project scope

Per-project install (rarely needed — this skill audits projects, so user scope makes more sense):

```bash
mkdir -p .claude/skills/large-codebase-audit/docs
cp /path/to/repo/SKILL.md .claude/skills/large-codebase-audit/SKILL.md
cp /path/to/repo/docs/CAVEATS.md .claude/skills/large-codebase-audit/docs/CAVEATS.md
```

### Option C — Git submodule

If you want to pull updates over time:

```bash
git submodule add git@github.com:MJWNA/large-codebase-audit-skill.git \
  .claude/skills/large-codebase-audit
git submodule update --init
```

> 🚫 The previous `templates/` install option is removed in v2.0.0. Templates were freezing project-specific shape and polluting the universal skill. The new SKILL.md describes good shape inline.

---

## 📄 Output

Each cycle produces:

- 📝 **Session log** at `.claude/session/large-codebase-audit-YYYY-MM-DD.md`
  - Summary of changes per surface
  - Open questions and deferred items
  - Recommended DRI for ongoing Claude Code config management
  - "Next review due" date (today + 90 days per article cadence)
- 📋 **`_CONSOLIDATION_PROPOSALS.md`** in `.claude/` — rule merges and rule-to-skill conversions for human review (not auto-applied)
- ✅ **Verification report** — file counts, JSON syntax, shell-script linting, frontmatter validation results
- 🚨 **Critical actions list** — 3-7 items to address BEFORE the next session (e.g. restart Claude Code for MCP changes)

---

## ⚠️ Operational caveats

The skill operates on real Claude Code behaviour, not idealised behaviour. Full caveats with citations and mitigations live in [`docs/CAVEATS.md`](docs/CAVEATS.md) (15 operational gotchas). Best-practices items (DRI, cadence, skill bundling, `InstructionsLoaded` use, LSP location) live in [`SKILL.md`](SKILL.md) → *Best practices*. Highlights:

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
- 🗂️ Hook-invoked `claude -p` pollutes the `/resume` picker — add `--no-session-persistence` to suppress (CAVEAT G14)
- 🚫 `skillOverrides` is a per-skill **record** (`{ "skill-name": "off" }`), NOT a top-level string — wrong type crashes settings.json validation (CAVEAT G15)

---

## 📐 Requirements

- 🤖 Claude Code v2.1.117+ (for fork-mode support)
- 🪂 `CLAUDE_CODE_FORK_SUBAGENT=1` in `~/.claude/settings.json` (skill falls back to named sub-agents otherwise, with cache-miss cost)
- 🔄 Claude Code restart capability (for MCP changes to register)
- 🐚 Standard Unix tools: `git`, `jq`, `bash`, `find`
- 🔎 Optional: language-specific LSP binary (e.g. `typescript-language-server`) if Fix-7 will install LSP for your project

---

## 🤝 Contributing

PRs welcome. See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines on:

- Adding new audit surfaces (with citation to official docs)
- Updating caveats (each must cite a source: official docs, issue tracker, or field experience)
- Versioning policy (semver — breaking changes bump major, new surfaces bump minor)

When opening an issue, include your Claude Code version (`claude --version`) and whether fork-mode is enabled.

---

## 🙏 Acknowledgements

- Anthropic — for the [large-codebase article](https://claude.com/blog/how-claude-code-works-in-large-codebases-best-practices-and-where-to-start) that sparked this skill
- The Claude Code team — for the [official docs](https://code.claude.com/docs/en) that the v2 rewrite aligns against
- Field reports from the Claude Code community — issue trackers #17204, #23478, and ongoing harness behaviour observations
- The independent v2.0.0 audit that drove the v3.0.0 rewrite — captured in [`AUDIT-v2.0.0-REVIEW.md`](AUDIT-v2.0.0-REVIEW.md)

---

## 📜 License

[MIT](LICENSE) — use it, fork it, ship it.
