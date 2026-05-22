# 🏗️ Large Codebase AI-Layer Audit

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Claude Code](https://img.shields.io/badge/Claude%20Code-Skill-D97757?logo=anthropic&logoColor=white)](https://code.claude.com/docs/en)
[![Version](https://img.shields.io/badge/Version-v2.0.0-blue)](CHANGELOG.md)
[![GitHub stars](https://img.shields.io/github/stars/MJWNA/large-codebase-audit-skill?style=flat)](https://github.com/MJWNA/large-codebase-audit-skill/stargazers)
[![GitHub issues](https://img.shields.io/github/issues/MJWNA/large-codebase-audit-skill)](https://github.com/MJWNA/large-codebase-audit-skill/issues)
[![Last commit](https://img.shields.io/github/last-commit/MJWNA/large-codebase-audit-skill)](https://github.com/MJWNA/large-codebase-audit-skill/commits/main)

> **A Claude Code skill that audits and improves a project's entire AI layer in one cycle, using parallel forked sub-agents. Aligned with the [Anthropic article](https://claude.com/blog/how-claude-code-works-in-large-codebases-best-practices-and-where-to-start) and cross-referenced against the [official Claude Code docs](https://code.claude.com/docs/en).**

The Anthropic article's central thesis is that **the harness matters as much as the model**. This skill audits the harness as a whole — across 9 official surfaces — then applies fixes in the order the article recommends (CLAUDE.md first), with disjoint write scopes so parallel forks never collide.

> 🆕 **Version 2.0.0** brings the skill into alignment with the official docs. See [CHANGELOG.md](CHANGELOG.md) for breaking changes (templates removed, surfaces expanded from 7 to 9, factual corrections).

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

The 9 official AI-layer surfaces, synthesised from Anthropic's article and the [official docs](https://code.claude.com/docs/en):

| # | Surface | Where it lives | Key audit question |
|---|---|---|---|
| 1 | 📜 CLAUDE.md hierarchy | Root + nested `CLAUDE.md` | Root under 80 lines, pointers-only? Nested files at meaningful sub-tree boundaries? |
| 2 | 📋 Rules | `.claude/rules/*.md` | Anything always-loaded that could be path-scoped? Rules that are skills in disguise? |
| 3 | 🎯 Skills | `.claude/skills/*/SKILL.md` | Path-scoped triggers correct? Supporting files bundled inside the skill dir? |
| 4 | 🤖 Sub-agents | `.claude/agents/*.md` | Read-only explorer agent? DB / log inspectors? |
| 5 | 🪝 Hooks | `.claude/settings.json` → `hooks` | Self-improving Stop hook? `InstructionsLoaded` for diagnostics? PreToolUse guardrails? |
| 6 | 🔌 MCP servers | `.mcp.json` | Project-scope MCPs registered? `disableSkillShellExecution` where needed? |
| 7 | 🔎 LSP | `.lsp.json` | Symbol-server configured for the dominant language? Binary installed? |
| 8 | 📦 Plugins | `.claude-plugin/plugin.json` | Is the project itself a plugin? Bundled skills marketplace-ready? |
| 9 | 🧠 Auto-memory | `~/.claude/projects/<proj>/memory/` | Benefitting from auto-memory? Stale entries (>90 days)? |

Plus the settings.json budget knobs that affect all of the above: `skillListingBudgetFraction`, `maxSkillDescriptionChars`, `skillOverrides`, `claudeMdExcludes`.

---

## 🔧 What it fixes

Fixes are dispatched in **the article's stated order** (the article is explicit: *"CLAUDE.md files come first"*):

1. 📜 Root `CLAUDE.md` — trim, restructure, add pointers
2. 📜 Nested `CLAUDE.md` — create at meaningful sub-tree boundaries
3. 🪝 Hooks + settings.json — add self-improving Stop, `InstructionsLoaded`, safety guardrails, tune skill-budget knobs
4. 🎯 Skills — create path-scoped skills for recurring task shapes, fix frontmatter
5. 🤖 Sub-agents — explorer and inspector agents
6. 📦 Plugins — if the project is a plugin, validate the manifest
7. 🔎 LSP — install binary, write `.lsp.json`
8. 🔌 MCP — register project-scope servers in `.mcp.json` (requires Claude Code restart)
9. 🧠 Auto-memory — prune stale entries, surface gaps

Each fix runs in its own forked sub-agent with an **exclusive write scope** — two forks never touch the same file. Rule consolidations and rule-to-skill conversions are *deferred* to a `_CONSOLIDATION_PROPOSALS.md` doc for human review (consolidations break pointers other forks rely on inside the same cycle).

---

## ⚙️ How it works

```
Phase 0 — Pre-flight                  (sequential, ~1-2 min)
   ├─ Verify git repo root
   ├─ Verify fork-mode (CLAUDE_CODE_FORK_SUBAGENT=1) or fall back
   ├─ Read root CLAUDE.md, ARCHITECTURE.md, .claude/settings.json
   ├─ Capture InstructionsLoaded diagnostic (if available)
   └─ Identify dominant tech stack

Phase 1 — Audit                       (7 parallel forks, single message)
   ├─ Fork A: CLAUDE.md hierarchy     │
   ├─ Fork B: Rules                   │
   ├─ Fork C: Skills + agents + cmds  │  All read-only.
   ├─ Fork D: Hooks + settings        │  Each returns a punch list
   ├─ Fork E: MCP + LSP + plugins     │  under 800 words.
   ├─ Fork F: Codebase structure      │
   └─ Fork G: Auto-memory             │

Phase 2 — Synthesise + order          (sequential, ~3-5 min)
   ├─ Merge punch lists
   ├─ Map every fix to one fork, one write scope
   ├─ Order per article hierarchy (CLAUDE.md first)
   └─ Confirm with user unless --yes / standing authorisation

Phase 3 — Fix                         (parallel forks, single message)
   ├─ Fix-1 → root CLAUDE.md          │  Each fork:
   ├─ Fix-2 → nested CLAUDE.md        │   • States exclusive write scope
   ├─ Fix-3 → hooks + settings        │   • Knows other forks' scopes
   ├─ Fix-4 → skills                  │   • Self-validates (jq, bash -n)
   ├─ Fix-5 → sub-agents              │   • Reports back: files,
   ├─ Fix-6 → plugins                 │     line counts, surprises
   ├─ Fix-7 → LSP                     │
   ├─ Fix-8 → MCP                     │
   ├─ Fix-9 → auto-memory prune       │
   └─ Fix-10 → rules (safe trims only)│

Phase 4 — Wrap + cadence              (sequential)
   ├─ Verification commands
   ├─ Write .claude/session/large-codebase-audit-YYYY-MM-DD.md
   ├─ Recommend DRI if multi-person org
   ├─ Set "Next review due" date (today + 90 days)
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

The skill operates on real Claude Code behaviour, not idealised behaviour. Full caveats with citations and mitigations live in [`docs/CAVEATS.md`](docs/CAVEATS.md). Highlights:

- 🔄 Path-scoped rules trigger on file READ, not Write/Create (issue #23478)
- 🐛 Rules' `paths:` YAML-list form has parser quirks (issue #17204) — does NOT affect skills
- 🧾 `description:` is undocumented for rules; for skills it IS the primary trigger field
- 💸 Self-improving Stop hooks cost tokens every session-end — always provide an opt-out env var
- 🔁 MCP changes require Claude Code restart, not `/clear`
- 🍴 Forks cannot spawn further forks — this skill must run in the main thread
- 🛑 Cross-fork write coordination requires disjoint scopes; one file → one fork
- 🎭 Rules vs skills misclassification is the most common drift
- 📦 Plugin layout per official spec — no `tooling/` directory exists

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

---

## 📜 License

[MIT](LICENSE) — use it, fork it, ship it.
