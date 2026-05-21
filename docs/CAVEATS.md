# Caveats — Things the Anthropic Article Doesn't Tell You

These were discovered by trialing the methodology end-to-end on a real codebase. Each caveat includes the symptom, the root cause, and the mitigation.

---

## A. Path-scoped triggers fire on file READ, not Write/Create

**Symptom:** You create a nested `app/api/CLAUDE.md` with strict conventions. Claude creates a new route under `app/api/products/route.ts`. The nested CLAUDE.md never loads. The new file violates conventions.

**Root cause:** Claude Code issue [#23478](https://github.com/anthropics/claude-code/issues/23478). The path-scope triggers on **opening an existing file**, not on `Write` creating a new one. So progressive disclosure has a write-side blind spot.

**Mitigation:**
- Have Claude **read a sibling file first** before creating a new one in that directory
- For critical invariants that **must** be enforced on writes, also include them in the global rules at user scope (always-loaded)
- For destructive guardrails, use a `PreToolUse` hook instead of a path-scoped rule

---

## B. `paths:` YAML-list form has parser bugs

**Symptom:** You write a skill with:
```yaml
---
name: add-api-route
paths:
  - app/api/**
---
```
The skill never auto-triggers when you open files in `app/api/`.

**Root cause:** Claude Code issue [#17204](https://github.com/anthropics/claude-code/issues/17204). The documented YAML-list array form has parser bugs in some versions.

**Mitigation:**
- Try **unquoted scalar form** first: `paths: app/api/**`
- If that fails, try the undocumented `globs:` field: `globs: app/api/**`
- Quote any glob starting with `*` or `{`: `paths: "**/*.ts"` (issue [#13905](https://github.com/anthropics/claude-code/issues/13905))
- Test by opening a file under the scope and checking if the skill description appears in the active context

---

## C. `description:` has no loader effect for rules

**Symptom:** You add a clever `description:` to a rule file expecting it to influence loading. Nothing changes.

**Root cause:** Per the official spec, `description:` is a decorative field for humans skimming rules. The loader doesn't read it. (For **skills**, `description:` IS used for trigger-word matching — different mechanism entirely.)

**Mitigation:**
- Don't rely on `description:` for rules — use `paths:` (or absence-of-paths for always-loaded)
- For skills, write `description:` carefully because it's load-bearing
- Be explicit in skill descriptions about trigger phrases ("Trigger on phrases like ...")

---

## D. Self-improving Stop hooks cost tokens on every session-end

**Symptom:** Your token usage doubles overnight. You don't know why.

**Root cause:** The Anthropic-recommended self-improving Stop hook fires `claude -p` headlessly to review the session diff against CLAUDE.md. Every session-stop spawns a fresh review. On an active day, that's 20-50 review invocations.

**Mitigation:**
- Support an `CLAUDE_DISABLE_HEADLESS=1` env opt-out (the audit skill bakes this in by default)
- Cap the diff input size (the trial used 8K characters with truncation)
- Only run the hook if the diff is non-empty
- Periodically review and prune `.claude/session/claude-md-review.md` so it doesn't grow unbounded

---

## E. Sub-agent classifier flags hook installs as "self-modification"

**Symptom:** A sub-agent installing the hooks block in `.claude/settings.json` returns a "SECURITY WARNING: Self-Modification of agent config without explicit user authorization" message — even though the user explicitly asked for it.

**Root cause:** The sub-agent's safety classifier doesn't see the parent session's standing authorisation (e.g. a `/goal` directive). It treats every settings.json edit as un-prompted.

**Mitigation:**
- Pre-emptively note in the fork prompt: "Per the user's standing /goal authorization, this fork has explicit consent to add hooks to `.claude/settings.json`"
- Surface the security warning to the user transparently so they can verify
- The classifier is a useful guardrail for **unprompted** hook installs; treat its flag as a "confirm this was intentional" rather than a blocker

---

## F. MCPs require a full Claude Code restart

**Symptom:** You add an MCP server to `.mcp.json`, run `/clear`, but the MCP tools never appear.

**Root cause:** MCP servers are loaded once at process startup. `/clear` only resets the conversation context; it doesn't reload the MCP layer.

**Mitigation:**
- Always tell the user: "Quit Claude Code completely and relaunch" — not `/clear`, not `/init`, full restart
- Check `~/Library/Caches/claude-cli-nodejs/.../mcp-logs-<server>/` for connection errors after restart
- For Slack-style OAuth MCPs, the cached `needs-auth` flag can stick across sessions — see the `slack-messaging.md` rule pattern

---

## G. Many env vars (NEON_API_KEY, etc.) missing at install time

**Symptom:** You generate a `.mcp.json` referencing `${NEON_API_KEY}`. The Neon MCP fails on startup with a cryptic error.

**Root cause:** Project-scope MCP entries often reference env vars that are set per-project (in Vercel) but not at user-scope (in `~/.claude/settings.local.json`).

**Mitigation:**
- The audit skill should **check env presence** before generating MCP entries that reference env vars
- Report the gap to the user: "Neon MCP needs `NEON_API_KEY` in your env block; not currently set"
- Provide the install URL: https://console.neon.tech/app/settings/api-keys

---

## H. Plugins are the distribution layer

**Symptom:** You build a skill and share the SKILL.md file. Recipients struggle to install it correctly (where does it go? user-scope or project-scope? does the path-scope frontmatter even work in their version of Claude Code?).

**Root cause:** Single SKILL.md files lack distribution infrastructure. The Anthropic article positions **plugins** as the canonical distribution path.

**Mitigation:**
- For widely-distributed skills, package as a plugin with a `.claude-plugin/marketplace.json`
- For single-org skills, a `git clone` + `cp` is fine
- Document both install paths

---

## I. Always-loaded rules paid in every session

**Symptom:** Every session starts with a huge context dump. Token cost per session is high before the user even types anything.

**Root cause:** Rules without `paths:` frontmatter are loaded at session start, regardless of relevance. Domain rules left always-loaded carry their full content into every conversation, even unrelated ones.

**Mitigation:**
- During audit, identify always-loaded rules that should be path-scoped
- Reserve always-loaded for **genuinely universal** invariants (timezone, language style, identity)
- Path-scope everything else with `paths:` globs covering the directories where the rule applies

---

## J. Cross-fork write coordination requires disjoint scopes

**Symptom:** Two parallel write forks edit `.claude/settings.json`. The second one overwrites the first. Or worse, both succeed but produce inconsistent state.

**Root cause:** Forks run concurrently with no awareness of each other's writes. The Claude Code harness doesn't lock files across forks.

**Mitigation:**
- Map every fix to **one file owner** before dispatching
- Include other forks' write scopes in each fork's prompt: "Other forks are touching X, Y, Z — stay in your lane"
- If two fixes truly must edit the same file, **sequence them** instead of parallelising

---

## K. Rules vs skills misclassification is the most common drift

**Symptom:** Your `.claude/rules/` contains 32 files. Some are "when adding X, do these 5 things" — that's a **workflow**, not a rule.

**Root cause:** Both rules and skills end up as Markdown files in `.claude/`. The distinction is conceptual:
- **Rule** = invariant ("never put `agent_id` in update blocks")
- **Skill** = workflow ("when adding a Prisma migration, first read X, then create Y, then run Z")

When projects grow organically, workflows accumulate as rules because rules came first.

**Mitigation:**
- During audit, classify each rule: invariant or workflow?
- Convert workflow-shaped rules into skills with `paths:` scoping
- The trial found 4/32 (12.5%) mis-classified — expect a similar ratio in any organically-grown project

---

## L. Sub-project duplicates are surprisingly common

**Symptom:** Your repo contains `app/CLAUDE.md` AND `app/app/CLAUDE.md` (byte-identical). Or a sub-project mirror committed by accident.

**Root cause:** Symlinks gone wrong, git submodule confusion, or copy-paste during refactors. Easy to miss.

**Mitigation:**
- Audit with `find ./ -name CLAUDE.md` to enumerate
- `diff` each pair for byte-identical clones
- Delete duplicates; flag accidental project mirrors to the user (don't auto-delete those)

---

## M. The Anthropic article omits the trial step

**Symptom:** You generalise too early. The skill you build doesn't survive contact with a second codebase.

**Root cause:** The article describes the *what* and the *why* of the methodology, but not the *iteration loop*. Real-world AI-layer audits benefit from a single-codebase trial before being packaged as a reusable skill.

**Mitigation:**
- Always trial on **one codebase first**, capture caveats
- Then turn the trial into a skill
- Then trial the **skill** on a second codebase before publishing

This skill itself was built that way.

---

## N. The 9 strategies map to 7 AI-layer components

**Symptom:** The article lists 9 strategies but doesn't enumerate the components clearly.

**Root cause:** The article is task-oriented (how to use Claude Code in large codebases), not architecture-oriented (here are the components).

**Mitigation:**
- The components are: CLAUDE.md, rules, skills, sub-agents, hooks, MCP servers, LSP
- The strategies are: lean & layered rules, codebase maps, scoped tests, ignore patterns, Stop self-improve hook, SessionStart dynamic context, path-scoped skills, LSP MCP, exploration sub-agents
- Strategies are *how you use* the components

---

## O. Plugin distribution uses a `tooling/` subdirectory

**Symptom:** You package a skill as a plugin. The marketplace install fails.

**Root cause:** The plugin marketplace expects a specific layout:

```
<plugin-name>/
├── .claude-plugin/
│   └── plugin.json
└── tooling/
    ├── skills/
    ├── agents/
    ├── hooks/
    └── commands/
```

The `tooling/` subdirectory is the convention for the actual content.

**Mitigation:**
- For single-skill repos, simple `git clone` + `cp` works
- For multi-component plugins (skill + agents + hooks + MCP), follow the marketplace structure
- See the [Claude Code plugin docs](https://docs.claude.com/en/docs/claude-code/plugins) for the canonical layout
