---
description: "MASD · Onboarding inicial — analiza el repo, escribe .relay/project.md y siembra la memoria. Soporta --refresh para re-ejecutar de forma incremental."
argument-hint: "[--refresh]"
---

# /onboard

Run the relay-kit onboarder agent to survey the existing codebase, produce `.relay/project.md`, and seed `.relay/memory/{conventions,decisions,glossary,skills}.md`.

## Invocation

Invoke the agent at `agents/relay/onboarder.md` (the path under your host's agents directory after install).

Pass through any user-supplied arguments. Recognized flags:
- `--refresh` — re-survey the repo and surgically update `.relay/project.md` (preserves manual edits to memory files; only appends new entries).

If no flag is passed, treat as a fresh onboarding run.

## Preconditions

- relay-kit is installed in the current project (`commands/relay/`, `agents/relay/`, `templates/relay/` exist in the host directory).
- `.relay/` exists at the project root (created by `install.sh`). If missing, instruct the user to re-run the installer and exit.

## Output

- `.relay/project.md` (created or refreshed).
- Appended entries in `.relay/memory/conventions.md`, `.relay/memory/decisions.md`, `.relay/memory/glossary.md`, `.relay/memory/skills.md`.

## Next step

After `/onboard` completes, the recommended next command in the MASD flow is `/analyze "<task>"`.
