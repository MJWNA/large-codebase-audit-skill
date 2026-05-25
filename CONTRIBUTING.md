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

There's no build step — the skill is `SKILL.md` plus `docs/CAVEATS.md`. To test changes:

```bash
# Copy your in-progress files to user scope
cp SKILL.md ~/.claude/skills/large-codebase-audit/SKILL.md
cp docs/CAVEATS.md ~/.claude/skills/large-codebase-audit/docs/CAVEATS.md

# Invoke from any Claude Code session
> audit my AI layer
```

### Maintainer-only: symlink user-scope to the repo

If you're the maintainer (or a heavy iterator) editing this skill regularly, replace the user-scope copies with **symlinks** so every edit propagates instantly with no `cp` step:

```bash
REPO=$(pwd)  # run from the repo root
rm ~/.claude/skills/large-codebase-audit/SKILL.md
rm ~/.claude/skills/large-codebase-audit/docs/CAVEATS.md
ln -s "$REPO/SKILL.md"           ~/.claude/skills/large-codebase-audit/SKILL.md
ln -s "$REPO/docs/CAVEATS.md"    ~/.claude/skills/large-codebase-audit/docs/CAVEATS.md

# Verify
readlink ~/.claude/skills/large-codebase-audit/SKILL.md
readlink ~/.claude/skills/large-codebase-audit/docs/CAVEATS.md
```

Claude Code's skill loader follows symlinks, so the skill description and content update the moment you save the repo file. Caveat: if you move or delete the repo, the symlinks dangle and the skill silently fails to load — restore by recreating the symlinks at the new path, or `cp` real files in as a fallback.

This is **not recommended for end users** — Option A (cp) and Option C (git submodule) in the README are the right paths for installing the skill on a machine you don't develop it on.

## Style

- Keep `SKILL.md` under 200 lines — it's a workflow, not documentation
- Keep `docs/CAVEATS.md` entries to ~30 lines each (symptom + cause + mitigation)
- Australian English where the author writes (Ronnie Meagher); PR-authors free to use their own
- No em-dashes (—) — use commas or full stops; that's a personal preference of the maintainer

## Maintainer

Ronnie Meagher ([@MJWNA](https://github.com/MJWNA))
