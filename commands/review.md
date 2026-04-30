---
description: "MASD · Fase 5 (reviewer) — valida la implementación de la feature activa, escribe review.md y APPENDEA a .relay/memory/*.md."
argument-hint: ""
---

# /review

Run the relay-kit reviewer agent to validate the implementation against the plan and acceptance criteria, and to distill new lessons, errors, decisions, conventions, glossary terms, references, and skills into `.relay/memory/*.md`.

## Invocation

Invoke the agent at `agents/relay/reviewer.md`. No arguments required. The reviewer resolves the active feature automatically (git branch first, `.relay/HEAD` fallback).

## Preconditions

- An active feature exists. If not, instruct the user to run `/analyze "<task>"` first and halt.
- `.relay/features/<active>/{analysis,plan,tasks,implementation}.md` all exist. If any is missing, instruct the user which prior phase to run and halt.
- `git` is available (the reviewer reads `git diff` against the merge-base with `main` to cross-check against `implementation.md`).

## Output

- `.relay/features/<active>/review.md` (verdict + acceptance criteria + memory updates summary).
- Appended entries in any of `.relay/memory/{lessons,errors,decisions,conventions,glossary,references,skills}.md`.

## Next step

Either archive the feature manually once the branch is merged (`mv .relay/features/<active> .relay/archive/<YYYY-MM-DD>-<active>`), or start the next task with `/analyze "<next task>"` (which creates a new feature folder and proposes a new branch).
