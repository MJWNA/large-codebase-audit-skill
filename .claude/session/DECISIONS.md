# Decisions Log

Architectural and design decisions with reasoning. Append-only, newest first.

---

## 2026-05-25 — First release via PR convention (v3.0.3)

**Chose:** Branch → PR → squash-merge for v3.0.3
**Over:** Continuing direct-to-main commits like v3.0.0-v3.0.2
**Because:** Establishes the workflow pattern external contributors should mirror. Also surfaces the change for review before it lands on main, even though the maintainer self-merges.
**Context:** User asked to "create a pr ready to merge to main so we are all up to date" after observing all v3.0.x patches had landed direct to main without review steps.

---

## 2026-05-25 — Symlink user-scope skill to repo (auto-propagation)

**Chose:** `ln -s` from `~/.claude/skills/large-codebase-audit/{SKILL.md,docs/CAVEATS.md}` to repo files
**Over:** Continuing manual `cp` after every version bump (the pattern v3.0.0/v3.0.1/v3.0.2 each used)
**Because:** Every release was paying the cost of remembering to copy. Symlinks make propagation structurally automatic — edit the repo, user-scope reflects the change immediately. Documented as maintainer-only in CONTRIBUTING.md (end users still use Option A/C in README).
**Context:** User explicitly asked "make sure that every single time we update the skill, the local skill gets updated too". Functional test passed (added marker line to repo → appeared in user-scope, removed marker → both clean).

---

## 2026-05-25 — Leave SMD Stop hook on `claude -p` despite cost research

**Chose:** Keep `claude -p` in `propose-claude-md-updates.sh`; add only `--no-session-persistence` (for picker pollution fix)
**Over:** Switching to `claude --bare -p`, direct Anthropic API + Haiku 4.5, or Gemini via existing GEMINI_API_KEY
**Because:** Annual cost per project is $10-20 — rounding error. The cost-optimisation paths (direct API skipping the Agent SDK pool, Haiku model selection, prompt caching) all save real money but were outweighed by simplicity for a low-volume hook. Picker pollution was the actual bug worth fixing.
**Context:** Investigation included three research forks (claude-code-guide, session-historian, Anthropic docs deep-dive). Found that `--bare` still draws from the same post-June-15 Agent SDK pool; only direct API truly escapes it. User correctly rejected over-engineering for the cost benefit.

---

## 2026-05-22 — Drop "9 official surfaces" framing entirely (v3.0.0)

**Chose:** "The AI-layer surfaces" with no fixed count + `[article]` / `[docs]` provenance tags on each row
**Over:** Keeping the "9 surfaces" count as v2.0.0 had it, or expanding to "11 surfaces" with a different fixed count
**Because:** The synthesis is real but the count was a soft fabrication. v1's "9 strategies → 7 components" was the original fabrication; v2 closed that but introduced "9 official surfaces" which had the same pattern (number + "official" implying Anthropic blessed a list they hadn't). Dropping the count removes the lie without losing utility.
**Context:** Independent audit fork specifically flagged this as a v3 framing issue. Captured in AUDIT-v2.0.0-REVIEW.md.

---

## 2026-05-22 — Phase 3 fix-fork order matches article H3 sequence (v3.0.0)

**Chose:** CLAUDE.md → Hooks → Skills → Plugins → LSP → MCP → Subagents → (docs-only tail: auto-memory, rules)
**Over:** v2's order (CLAUDE.md → Hooks → Skills → Sub-agents → Plugins → LSP → MCP → auto-memory)
**Because:** v2 claimed "the article's stated hierarchy" but its order diverged from the article's actual H3 sequence in §2 (put sub-agents before plugins, added auto-memory which isn't in the article). v3 matches the article literally; where the skill diverges (docs-only surfaces appended), the divergence is owned explicitly.
**Context:** Article-fidelity fork called this out as "partially fabricated".

---

## 2026-05-22 — CAVEATS restructured to 13 gotchas only (v3.0.0)

**Chose:** Split v2's 18 caveats into 13 operational gotchas (stays in CAVEATS.md) + 5 best-practices (moves to new SKILL.md "Best practices" section)
**Over:** Keeping the mixed list of 18
**Because:** Mixing operational gotchas (things that fail under specific conditions) with best-practices (DRI, cadence, skill bundling — policy items) diluted both. Splitting clarifies the audience: CAVEATS is for "watch out for this", SKILL.md best-practices is "do this every cycle".
**Context:** Skill-quality audit fork identified the mix as bloat.

---

## 2026-05-22 — Phase 4 wrap is inline, not a fork (v3.0.0)

**Chose:** Run Phase 4 (verify + write session log + DRI recommendation + cadence) inline in the main thread
**Over:** Dispatching a final wrap fork like v2 did
**Because:** Output IS the deliverable. Forking it loses immediate user context (the user can't see the session log being written) for no benefit. v2 fork-everything bias was over-engineered for this phase.
**Context:** Skill-quality audit fork flagged the wrap fork as unnecessary overhead.

---

## 2026-05-22 — Adaptive Phase 3 dispatch (v3.0.0)

**Chose:** Skip fix forks for surfaces with zero Phase 1 findings
**Over:** v2's fixed 10-fork dispatch regardless of findings
**Because:** A project with no plugin, no LSP, no MCP doesn't need 6 no-op forks per cycle. Adaptive dispatch keeps the model honest about what work actually exists.
**Context:** Skill-quality audit fork flagged disproportionate fork count for small projects.

---
