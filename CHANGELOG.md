# Changelog

All notable changes to `large-codebase-audit-skill` are documented here. Format based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/); versioning follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
