---
name: <kebab-case-name>
description: One-line trigger description that mentions both the action and the file scope. Be specific so it auto-triggers correctly. Example> "Add a new Next.js API route handler under app/api/. Use when creating REST endpoints, webhooks, or admin actions in this codebase."
paths:
  - <glob pattern, quoted if starts with * or {>
---

# <Skill title — what it adds>

## When to use this skill

<2-3 sentences: when this applies, what the user is trying to do, what the deliverable looks like.>

## Steps

1. **Read the canonical rule first**: `.claude/rules/<file>.md` — invariants for this area
2. **<Concrete action>** — with file path and what to create/edit
3. **<Next action>** — ...
4. **<Next action>** — ...
5. **<Next action>** — ...
6. **Verify**: <build/test command, audit check, etc.>

## Common pitfalls

- <pitfall 1> — with file:line ref if applicable
- <pitfall 2> — what makes this hard to get right
- <pitfall 3> — what looks like it works but doesn't

## Pointers

- `.claude/rules/<authoritative-rule>.md` — invariants
- `docs/runbooks/<runbook>.md` — if applicable
- `ARCHITECTURE.md` — if it changes the architectural map

<!--
Caveat: `paths:` YAML-list array form has parser bug #17204. If this skill
doesn't auto-trigger when files matching the scope are opened, try:
  (a) unquoted scalar form: `paths: app/api/**`
  (b) undocumented `globs:` alias: `globs: app/api/**`
Target length: under 60 lines total. Skills are workflows, not rules — keep concise.
-->
