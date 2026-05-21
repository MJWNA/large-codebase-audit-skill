# Contributing

This skill is built from a single-codebase trial. The most valuable contributions are **caveats from your own codebases** — things this skill missed or got wrong when applied to your project.

## Reporting issues

Open an [issue](https://github.com/MJWNA/large-codebase-audit-skill/issues) with:

- The codebase shape (language, framework, approximate file count)
- What the audit found / proposed
- What surprised you or went wrong
- What the fix should have been

The caveats doc (`docs/CAVEATS.md`) is the primary place this knowledge lands.

## PR checklist

- [ ] Any new caveats added to `docs/CAVEATS.md` with symptom + root cause + mitigation
- [ ] Any new templates added to `templates/` with a header comment explaining when to use
- [ ] `SKILL.md` updated if behavioural changes (e.g. new fork dispatched, new phase added)
- [ ] `README.md` updated if installation flow or output changes
- [ ] Trial against at least one codebase (note which one in the PR description)

## Development setup

There's no build step — the skill is a single SKILL.md plus reference docs and templates. To test changes:

```bash
# Copy your in-progress SKILL.md to user scope
cp SKILL.md ~/.claude/skills/large-codebase-audit/SKILL.md

# Invoke from any Claude Code session
> audit my AI layer
```

## Style

- Keep `SKILL.md` under 200 lines — it's a workflow, not documentation
- Keep `docs/CAVEATS.md` entries to ~30 lines each (symptom + cause + mitigation)
- Australian English where the author writes (Ronnie Meagher); PR-authors free to use their own
- No em-dashes (—) — use commas or full stops; that's a personal preference of the maintainer

## Maintainer

Ronnie Meagher ([@MJWNA](https://github.com/MJWNA))
