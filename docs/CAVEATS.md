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

## G14. 🗂️ Hook-invoked `claude -p` pollutes the `/resume` picker

Any hook (Stop, SessionEnd, PostToolUse, etc.) that runs `claude -p ...` writes a fresh `sdk-cli` JSONL into the project's session folder (`~/.claude/projects/<proj>/`) **every time the hook fires**. The `/resume` picker filters out `sdk-cli` entries but pages by mtime — so when hook firings outpace real interactive sessions, the recent slots in the picker are all rejected ghost entries and the picker renders empty.

**Symptom:** `/resume` shows no sessions in a project that has dozens of real interactive sessions on disk.

**Mitigation:** add `--no-session-persistence` to every `claude -p` invocation inside a hook script:

```bash
claude -p --no-session-persistence --output-format text "$PROMPT"
```

The flag (only valid with `--print`) tells Claude Code to skip writing the subprocess's session JSONL to disk. The hook still runs normally, the prompt still completes, only the session-persistence side-effect is suppressed.

**Real-world data:** a project running a self-improving Stop hook ([the pattern Anthropic's article describes](https://claude.com/blog/how-claude-code-works-in-large-codebases-best-practices-and-where-to-start) and community plugins like Cole Medin's helpline implement) accumulated **77 `sdk-cli` ghosts vs 45 real interactive sessions** in one day on a dirty diff. The picker rendered empty until the ghosts were purged.

**Audit task (Fork D):** for every hook command across `.claude/settings.json` (any event), grep for `claude -p` and `claude --bare -p`. Flag any occurrence that doesn't include `--no-session-persistence`. One-line script addition; preserves the hook's behaviour completely.

**Cleanup recipe** if ghosts already accumulated:

```bash
# Classify by entrypoint and delete only sdk-cli files older than 5 min
python3 -c "
import json, os, glob, time
proj = os.path.expanduser('~/.claude/projects/<cwd-encoded-project>')
for f in glob.glob(f'{proj}/*.jsonl'):
    if time.time() - os.path.getmtime(f) < 300: continue
    with open(f) as fh:
        for i, line in enumerate(fh):
            if i > 30: break
            try: d = json.loads(line)
            except: continue
            if d.get('entrypoint') == 'sdk-cli':
                os.remove(f); break
"
```

---

## 🔗 Sources

- [Anthropic — How Claude Code works in large codebases](https://claude.com/blog/how-claude-code-works-in-large-codebases-best-practices-and-where-to-start)
- [Official Claude Code docs](https://code.claude.com/docs/en) — skills, sub-agents, memory, hooks, MCP, plugins, settings, permissions, sandboxing, worktrees, output-styles, auto-mode, [plugins-reference (LSP)](https://code.claude.com/docs/en/plugins-reference#lsp-servers)
- Issues referenced: #17204 (rules paths parser), #23478 (path-scoped read trigger)
