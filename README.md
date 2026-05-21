# 🏗️ Large Codebase AI-Layer Audit

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Claude Code](https://img.shields.io/badge/Claude%20Code-Skill-D97757?logo=anthropic&logoColor=white)](https://docs.claude.com/en/docs/claude-code)
[![Status](https://img.shields.io/badge/Status-Beta-orange)](#status)
[![GitHub stars](https://img.shields.io/github/stars/MJWNA/large-codebase-audit-skill?style=flat)](https://github.com/MJWNA/large-codebase-audit-skill/stargazers)
[![GitHub issues](https://img.shields.io/github/issues/MJWNA/large-codebase-audit-skill)](https://github.com/MJWNA/large-codebase-audit-skill/issues)
[![Last commit](https://img.shields.io/github/last-commit/MJWNA/large-codebase-audit-skill)](https://github.com/MJWNA/large-codebase-audit-skill/commits/main)

> **A Claude Code skill that audits and applies Anthropic's "How Claude Code works in large codebases" methodology to any Claude Code project — using parallel forked sub-agents to evaluate and fix all 7 AI-layer components in one cycle.**

The Anthropic article on [working in large codebases](https://claude.com/blog/how-claude-code-works-in-large-codebases-best-practices-and-where-to-start) lays out 9 strategies for making Claude Code effective on real codebases — lean CLAUDE.md, path-scoped skills, self-improving hooks, LSP-backed symbol search, exploration sub-agents, and more. This skill **operationalises the whole methodology** as a single audit-and-fix workflow that completes in a single Claude Code session.

---

## 📋 Table of contents

- [Why this exists](#-why-this-exists)
- [What it audits](#-what-it-audits)
- [What it fixes](#-what-it-fixes)
- [How it works](#-how-it-works)
- [Quick start](#-quick-start)
- [Installation](#-installation)
- [Output](#-output)
- [Real-world caveats](#-real-world-caveats-from-trial)
- [Requirements](#-requirements)
- [Contributing](#-contributing)
- [Acknowledgements](#-acknowledgements)
- [License](#-license)

---

## 🎯 Why this exists

The Anthropic article and [its YouTube companion](https://www.youtube.com/results?search_query=cole+medin+anthropic+large+codebases) lay out the methodology clearly, but **applying it to a real, organically-grown codebase by hand takes hours and introduces drift between layers**. A typical mid-sized Next.js or Rails project has:

- A bloated root `CLAUDE.md` with embedded rule indexes (re-rots on every rule add)
- Always-loaded rules that should be path-scoped (every session pays the cost)
- Zero path-scoped skills for recurring task shapes
- No self-improving Stop hook
- No sub-agents to keep exploration out of the editing context window
- No LSP-backed symbol search
- MCP servers configured at the wrong scope

This skill walks all 7 layers in **one parallel-forked cycle**, applies fixes with non-overlapping write scopes, and produces a takeaways document you can feed back into the next iteration.

---

## 🔍 What it audits

The skill dispatches **6 parallel read-only forks**, one per AI-layer concern:

| Fork | Audits |
|---|---|
| 📜 **CLAUDE.md hierarchy** | Root file length, nested CLAUDE.md presence/absence, redundancy with `ARCHITECTURE.md` |
| 📋 **Rules** | Always-loaded vs path-scoped, redundancy, rule-vs-skill misclassification |
| 🛠️ **Skills + agents + commands** | Project-scope inventory, path-scope coverage, missing workflow skills |
| 🪝 **Hooks** | SessionStart, Stop (self-improving), PreToolUse safety guardrails |
| 🔌 **MCP + LSP** | Project-scope MCP coverage, missing TS LSP, custom-vs-plugin tradeoff |
| 🗺️ **Codebase structure** | Codebase map content, nested-CLAUDE.md placement recommendations |

Each fork returns a structured punch list — file paths, line counts, proposed actions.

---

## 🔧 What it fixes

After synthesis, **7+ parallel write forks** apply the fixes with **explicit non-overlapping write scopes** to prevent races:

| Layer | Typical fix |
|---|---|
| Root `CLAUDE.md` | Trim to under 80 lines, embed codebase map at top, leave rule pointers |
| Nested `CLAUDE.md` | Create 5-7 files at high-traffic subdirectories with 6-10 load-bearing bullets each |
| Hooks | Install self-improving Stop hook, SessionStart git-context hook, 3+ PreToolUse safety guardrails |
| Skills | Generate path-scoped workflow skills for recurring task shapes (add-api-route, add-cron-job, add-migration, etc.) |
| Sub-agents | Install `explorer` (codebase) + `db-investigator` (read-only DB) sub-agents |
| Rules | Path-scope always-loaded domain rules, delete duplicates, generate `_CONSOLIDATION_PROPOSALS.md` for human review |
| MCP + LSP | Install `typescript-language-server` globally, create project-scope `.mcp.json` with Neon/Prisma/etc. |

---

## ⚙️ How it works

```
┌─────────────────────────────────────────────────────────────────┐
│  User: "audit my AI layer"                                       │
└─────────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────────┐
│  Phase 1 — Audit (6 parallel read-only forks)                   │
│  CLAUDE.md │ Rules │ Skills │ Hooks │ MCP/LSP │ Codebase map    │
│  Each returns a structured punch list → main context             │
└─────────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────────┐
│  Phase 2 — Synthesise + plan                                    │
│  Map fixes to disjoint write scopes. Confirm with user.         │
└─────────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────────┐
│  Phase 3 — Fix (7+ parallel write forks)                        │
│  Each owns ONE write scope. No file collisions.                  │
└─────────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────────┐
│  Phase 4 — Wrap                                                 │
│  Verify counts │ Write takeaways doc │ Smoke-test hooks         │
└─────────────────────────────────────────────────────────────────┘
```

---

## ⚡ Quick start

```bash
# 1. Install the skill (see Installation section below)
git clone git@github.com:MJWNA/large-codebase-audit-skill.git
cp -r large-codebase-audit-skill/SKILL.md ~/.claude/skills/large-codebase-audit/SKILL.md

# 2. Inside any Claude Code session in any project:
> audit my AI layer
> apply Anthropic large-codebase setup
> large codebase audit
```

The skill will fire on those trigger phrases (or close variants). It runs Phase 1 immediately, presents the synthesis, and waits for your confirmation before Phase 3 unless you say "execute" or "go ahead".

---

## 📦 Installation

### Option A — Direct copy (simplest)

```bash
git clone git@github.com:MJWNA/large-codebase-audit-skill.git
mkdir -p ~/.claude/skills/large-codebase-audit
cp large-codebase-audit-skill/SKILL.md ~/.claude/skills/large-codebase-audit/SKILL.md
```

That installs the skill at user scope. Available in every Claude Code session.

### Option B — Project scope

```bash
mkdir -p .claude/skills/large-codebase-audit
cp /path/to/large-codebase-audit-skill/SKILL.md .claude/skills/large-codebase-audit/SKILL.md
```

Useful if you want different audit behaviour per project.

### Option C — Templates only (DIY)

Copy `templates/` into your project to get the hook scripts, nested-CLAUDE.md template, settings.json snippet, etc. — without the skill itself. Useful if you want to hand-apply Anthropic's methodology without the parallel-fork dispatch.

---

## 📄 Output

After a successful run, the skill writes:

```
.claude/session/large-codebase-audit-YYYY-MM-DD.md
```

A comprehensive takeaways document containing:

- Which of the 9 strategies were applied (and which were deferred)
- Full file inventory (counts + paths)
- Per-strategy surprises and mitigations
- Recommended next actions (restart Claude Code, set env vars, etc.)
- `_CONSOLIDATION_PROPOSALS.md` reference for any structural changes deferred to human review
- Codex sync preview (if `~/.codex/skills/claude-rule-sync/` is installed)

This document is **the input you feed back into the skill** for the next iteration — closing the self-improvement loop.

---

## ⚠️ Real-world caveats (from trial)

This skill was **trialed end-to-end on a real production codebase** (multi-tenant Next.js 15 dashboard, 865+ TypeScript files across `app/`, `lib/`, `components/`) before being published. The trial surfaced 15 caveats not covered in the Anthropic article — **read [docs/CAVEATS.md](docs/CAVEATS.md) before running**.

Highlights:

- 🪤 **Path-scoped triggers fire on file READ, not Write/Create** (Claude Code issue [#23478](https://github.com/anthropics/claude-code/issues/23478)) — your nested CLAUDE.md won't load when Claude creates a brand-new file in that dir
- 🪤 **`paths:` YAML-list form has known parser bugs** (issue [#17204](https://github.com/anthropics/claude-code/issues/17204)) — community-tested fallback: unquoted scalar form or undocumented `globs:` alias
- 🪤 **Stop hooks cost tokens on every session-end** — set `CLAUDE_DISABLE_HEADLESS=1` to opt out during review periods
- 🪤 **Sub-agent classifier may flag hook installs as "self-modification"** — pre-emptively note standing user authorisation in fork prompts
- 🪤 **MCPs require a full Claude Code restart** (not `/clear`) to register

Full list in [docs/CAVEATS.md](docs/CAVEATS.md).

---

## 📐 Requirements

| Requirement | Why |
|---|---|
| Claude Code v2.1.117+ | Forked sub-agents (`Agent` tool without `subagent_type`) |
| `CLAUDE_CODE_FORK_SUBAGENT=1` in settings.json | Enable fork mode |
| `gh` CLI (optional) | If you want the skill to inspect GitHub Issues/PRs as part of audit |
| Node 18+ | For npm-installed LSP and MCP servers |
| `jq` | Hook scripts validate `settings.json` syntax |

---

## 🤝 Contributing

PRs welcome. See [CONTRIBUTING.md](CONTRIBUTING.md). The most valuable contributions are:

1. **New caveats** discovered while running this against your codebase — add to `docs/CAVEATS.md`
2. **New AI-layer audit checks** the skill currently misses
3. **Stack-specific skill templates** for languages/frameworks beyond Next.js (Rails, Django, FastAPI, Astro, SvelteKit, etc.)

---

## 🙏 Acknowledgements

- **Anthropic** — for the [large codebase article](https://claude.com/blog/how-claude-code-works-in-large-codebases-best-practices-and-where-to-start) that this skill operationalises
- **Cole Medin** — for the [YouTube walkthrough](https://www.youtube.com/) and the helpline-AI-layer plugin pattern that informed the trial structure
- The Claude Code team — for the forked-sub-agent harness that makes parallel orchestration cheap

---

## 📜 License

[MIT](LICENSE) © 2026 Ronnie Meagher

---

## Status

🟠 **Beta** — Trialed once end-to-end on a real codebase. Caveats documented. Looking for issues from real-world use. File them [here](https://github.com/MJWNA/large-codebase-audit-skill/issues).
