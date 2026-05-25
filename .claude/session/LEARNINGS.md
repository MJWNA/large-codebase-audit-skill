# Learnings Log

Gotchas, failed approaches, and edge cases discovered. Append-only, newest first.

---

## 2026-05-25 — `git branch -d` refuses to delete a squash-merged branch

**The gotcha:** After `gh pr merge --squash`, the local feature branch shows as "not fully merged" to `git branch -d` because the squash produced a different SHA than the branch's commits. Git can't tell the content is on main.
**Why:** Squash creates a new commit with combined changes; the original branch commits remain visible only on the branch. Git's "fully merged" check compares commit SHAs, not file content.
**Workaround:** `git branch -D <branch>` (force delete) after verifying remote branch is gone and the squash commit is on main. Safe in this scenario but flagged as destructive in the maintainer's CLAUDE.md, so requires explicit user approval.

---

## 2026-05-25 — `gh pr merge --delete-branch` deletes remote, not local

**The gotcha:** The `--delete-branch` flag on `gh pr merge` only removes the branch from origin. The local feature branch stays around.
**Why:** GitHub's API can only manage remote refs; local branches are out of its scope.
**Workaround:** Add explicit `git branch -D <name>` (or `-d` if the merge wasn't a squash) after `gh pr merge`. Or accept the leftover and clean periodically with `git branch | grep -v main`.

---

## 2026-05-25 — Edit tool refuses files Read'd only via `Bash cat`

**The gotcha:** Using `cat` (via Bash) to view a file does NOT satisfy the Edit tool's "must Read first" requirement. The Edit fails with `File has not been read yet. Read it first before writing to it.`
**Why:** The Read tool registers the file in the session's state-tracking layer; Bash output doesn't. Edit checks that state, not whether the model has seen the content.
**Workaround:** Always use the `Read` tool when planning to `Edit` afterwards. Caused a missing CONTRIBUTING.md change in the v3.0.3 PR — required a follow-up commit to fix.

---

## 2026-05-25 — `skillOverrides` schema crash (settings-file-breaker)

**The gotcha:** Writing `"skillOverrides": "user-invocable-only"` into `.claude/settings.json` makes Claude Code reject the **entire settings file** with `Expected record, but received string`. Not just the bad key — the whole file invalidates.
**Why:** `skillOverrides` is a per-skill record (`Record<skillName, override>`), not a top-level scalar. v3.0.0 / v3.0.1 docs listed the override values inline next to the field name without showing the record shape; a real user (Ronnie) followed the implied schema and broke his settings file.
**Workaround:** Use the record form: `{ "skillOverrides": { "skill-name": "off" } }`. Empty form `{ "skillOverrides": {} }` is also valid. Documented as G15 in CAVEATS.md v3.0.2; Fork E audit prompt now flags wrong types via `jq '.skillOverrides // empty | type'`.

---

## 2026-05-22 — `/resume` picker pollution from hook-spawned `claude -p`

**The gotcha:** Stop hooks that run `claude -p ...` (the self-improving Stop hook pattern) write a fresh `sdk-cli` JSONL into the project's session folder every fire. The `/resume` picker filters out `sdk-cli` entries but pages by mtime — once hook firings outpace real interactive sessions, the picker renders empty even though dozens of real sessions exist.
**Why:** No-one anticipated the mtime-paging interaction. The picker's filter is correct; the per-fire persistence is correct; their combination breaks the UX when hooks fire frequently.
**Workaround:** Add `--no-session-persistence` (only valid with `--print`) to every hook-side `claude -p`. The hook still runs, the prompt still completes, only the JSONL write is suppressed. Documented as G14 in CAVEATS.md v3.0.1; Fork D audit prompt flags any hook `claude -p` lacking the flag. Cleanup recipe for accumulated ghosts also bundled in G14.

---

## 2026-05-22 — `--bare` doesn't change the billing pool

**The gotcha:** Anthropic's `claude --bare -p` flag reduces per-call overhead (skips hook/skill/MCP/CLAUDE.md auto-discovery) but **still draws from the post-June-15 Agent SDK credit pool**, same as plain `claude -p`. The flag is a per-call cost optimisation, not a pool-isolation mechanism.
**Why:** Pool routing is determined by the entry point (CLI vs SDK vs direct API), not by flags within the CLI. Both `claude -p` and `claude --bare -p` route through the Agent SDK pool.
**Workaround:** If you genuinely need to escape the Agent SDK pool, use direct `api.anthropic.com/v1/messages` with `ANTHROPIC_API_KEY` (bills against pay-as-you-go API credits, completely separate). Otherwise `--bare -p` + `--model claude-haiku-4-5-20251001` is the cheapest in-pool option.

---

## 2026-05-22 — Cole Medin's "headless mode" = plain `claude -p`

**The gotcha:** A popular YouTube tutorial on Anthropic's large-codebase article describes hooks running "in headless mode". Watching the demo + reading his actual implementation ([coleam00/helpline](https://github.com/coleam00/helpline)), "headless mode" is just his terminology for `claude -p --output-format text` — no special flag, no distinct invocation mode. His implementation is functionally identical to the SMD Stop hook script.
**Why:** "Headless" is a colloquial term for any non-interactive subprocess. Pre-`--bare`, it was just `-p`. The video predates the `--bare` flag landing.
**Workaround:** When someone says "headless mode" in a Claude Code context, mentally translate to `claude -p` and then ask: with or without `--bare`? With or without `--no-session-persistence`? Those flags are what actually matter.

---

## 2026-05-22 — Article-fidelity audit caught "official surfaces" fabrication

**The gotcha:** v2.0.0 claimed "9 official surfaces" — synthesis presented as an Anthropic-blessed list. The article doesn't enumerate surfaces; v2's own CHANGELOG admitted the synthesis but the framing still used "official" everywhere downstream.
**Why:** v1 had "9 strategies → 7 components" as its fabrication. v2 closed that explicitly but introduced "9 official surfaces" with the same shape (number + "official" implying authority). Pattern: removing one fabrication can install a near-identical one in its place if framing isn't audited.
**Workaround:** Audit synthesis claims for the "what makes this number / label feel authoritative" question. If a count or label implies provenance (article-stated, docs-blessed), trace it back to the source. v3 fix: drop the count, tag each surface `[article]` or `[docs]` for provenance.

---

## 2026-05-22 — Phase 1 fork prompts can't be table-row summaries

**The gotcha:** v2.0.0 listed Phase 1 audit-fork prompts as one-line summaries in a table. In practice, dispatched forks need 200-300 word templates with reading scope, comparison frame, output sections, word limit, and self-validation — otherwise the fork either does too much (no scope) or too little (no guidance).
**Why:** Forks inherit context but not the audit's framing. They need explicit instructions for what to look for and how to report. A one-line prompt produces a generic dump; a 200-word template produces a focused punch list.
**Workaround:** v3 converted all 7 fork prompts to full 200-word templates. Each embeds the audit scope, the doc reference, the output structure, and the word-limit constraint.

---
