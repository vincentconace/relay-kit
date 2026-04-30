---
description: "MASD · Fase 1 (analyst) — analiza el pedido, crea .relay/features/<type>-<slug>/, escribe analysis.md y propone una rama git."
argument-hint: "\"<task description>\" [--yes] [--no-branch]"
---

# /analyze

Run the relay-kit analyst agent to convert the user's raw request into a precise, scoped problem statement, derive a feature type + slug, create the dedicated feature folder, and propose a matching git branch.

## Invocation

Invoke the agent at `agents/relay/analyst.md`. Pass the user's task description (the quoted string after `/analyze`) plus any flags as the input.

If the user did not pass a task description, prompt once for it; do not invent one.

## Flags

- `--yes` — auto-execute the proposed `git checkout -b <type>/<slug>` (only if the working tree is clean). On a feature folder collision, default to suffixing (`-2`, `-3`, …) instead of overwriting.
- `--no-branch` — skip the git branch step silently. Future phase agents fall back to `.relay/HEAD` to resolve the active feature.

## Preconditions

- `.relay/project.md` exists. If missing AND the repo contains code, instruct the user to run `/onboard` first and halt.
- `.relay/memory/*.md` exist (created by `install.sh`).
- `.relay/features/` exists (created by `install.sh`).

## Output

- Folder: `.relay/features/<type>-<slug>/` (created).
- `.relay/features/<type>-<slug>/analysis.md` (with `feature_id` field at the top).
- `.relay/HEAD` updated to the new `<type>-<slug>`.
- Optional: a new git branch `<type>/<slug>` if confirmed (or `--yes` and a clean tree).

## Next step

`/plan` (consumes `.relay/features/<active>/analysis.md`).
