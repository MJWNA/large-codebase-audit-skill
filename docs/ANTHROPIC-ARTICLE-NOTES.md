# Anthropic Article — Distilled Notes

Source: https://claude.com/blog/how-claude-code-works-in-large-codebases-best-practices-and-where-to-start

## The headline thesis

> **The harness matters as much as the model.**

Most people obsess over which LLM is best. Anthropic's argument: in large codebases, the *AI layer* around the model — the rules, skills, hooks, sub-agents, MCP servers, LSP integration — matters more than the model itself.

## How Claude Code navigates (default behaviour)

- **Agentic search** — no codebase indexing, no embeddings, no RAG
- Navigates like a human engineer: `ls`, `cat`, `grep`, `find`
- No sync layer to maintain → no drift risk
- But: needs **enough starting context** to know where to look

This is why the AI layer matters: it's the starting context.

## The 9 strategies

| # | Strategy | What it solves |
|---|---|---|
| 1 | Lean & layered global rules | Bloated CLAUDE.md → high token cost + diluted attention |
| 2 | Codebase maps | When `ls` doesn't reveal structure (monorepos, complex naming) |
| 3 | Scoped test/lint commands | Per-subdirectory test commands so Claude doesn't run the wrong suite |
| 4 | Ignore patterns | Stop Claude reading build artefacts |
| 5 | Self-improving Stop hooks | CLAUDE.md drift as the codebase evolves |
| 6 | SessionStart dynamic context | Per-developer, per-branch, per-role context |
| 7 | Path-scoped skills | Specialised workflows that only load when relevant |
| 8 | LSP-backed MCP for symbol search | Grep is string-based; LSP is symbol-based |
| 9 | Sub-agents for exploration | Keep editing context window clean |

## The 7 AI-layer components

The article doesn't enumerate these explicitly, but they fall out:

1. **CLAUDE.md hierarchy** (root + nested) — strategies 1, 2
2. **Rules** (`.claude/rules/`) — strategy 1
3. **Skills** (`.claude/skills/`) — strategy 7
4. **Sub-agents** (`.claude/agents/`) — strategy 9
5. **Hooks** (`.claude/settings.json`) — strategies 5, 6
6. **MCP servers** (project + user) — strategy 8 (LSP wrapper)
7. **LSP integration** (TypeScript / Python / etc.) — strategy 8

Plus a meta-component:

8. **Plugins** — the distribution layer

## Each strategy in one sentence

### 1. Lean & layered global rules
Keep root `CLAUDE.md` under 80 lines; use **nested** CLAUDE.md files in subdirectories for progressive disclosure.

### 2. Codebase maps
When the directory tree doesn't make structure obvious, add a 10-line map to root `CLAUDE.md`.

### 3. Scoped tests/lint
Per-subdirectory tests/lint commands belong in nested `CLAUDE.md`, not root.

### 4. Ignore patterns
Build artefacts, generated files — keep Claude from reading them via `.gitignore` and explicit Claude Code ignore patterns.

### 5. Self-improving Stop hook
At session-end, fire `claude -p` headlessly to review session changes against `CLAUDE.md` and propose updates. Avoids drift.

### 6. SessionStart dynamic context
Per-session context (current branch, dirty files, open PRs, team-specific docs) loaded automatically.

### 7. Path-scoped skills
Specialised workflows (e.g. "add an API route") that only activate when relevant files are open.

### 8. LSP-backed symbol search
Wrap TypeScript Language Server (or equivalent) in an MCP server so Claude can `goto_definition` and `find_references` instead of grepping for strings.

### 9. Exploration sub-agents
Use sub-agents for codebase exploration so the main session's context stays clean. Return only the summary, not the raw search output.

## The marquee insight

The default Claude Code session has:
- Always-loaded rules
- A trigger-word skill layer
- Web search and basic tooling

Adding the **harness**:
- Reduces token cost per session (path-scoping)
- Improves accuracy (LSP > grep)
- Enables continuous improvement (Stop hook)
- Distributes knowledge (plugins)

## What the article doesn't tell you

See [CAVEATS.md](CAVEATS.md) for 15 things discovered in real-world application.

## The implementation pattern

The article's section on **"assigning ownership"** is worth reading carefully:

> Have a small team build the AI layer in a "quiet investment period" before rolling it out broadly. Otherwise individuals evolve their own AI layers and you lose consistency.

This skill operationalises that "quiet investment period" into a single Claude Code session.
