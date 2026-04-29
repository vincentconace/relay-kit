---
description: "MASD · Fase 5 (reviewer) — valida la implementación, escribe .relay/current/review.md y APPENDEA a .relay/memory/*.md."
argument-hint: ""
---

# /review

Run the relay-kit reviewer agent to validate the implementation against the plan and acceptance criteria, and to distill new lessons, errors, decisions, conventions, glossary terms, references, and skills into `.relay/memory/*.md`.

## Invocation

Invoke the agent at `agents/relay/reviewer.md`. No arguments required.

## Preconditions

- `.relay/current/{analysis,plan,tasks,implementation}.md` all exist. If any is missing, instruct the user which prior phase to run and halt.
- `git` is available (the reviewer reads `git diff` to cross-check against `implementation.md`).

## Output

- `.relay/current/review.md` (verdict + acceptance criteria + memory updates summary).
- Appended entries in any of `.relay/memory/{lessons,errors,decisions,conventions,glossary,references,skills}.md`.

## Next step

Either `/archive` to snapshot `.relay/current/*` into `.relay/archive/<date>-<slug>/`, or start the next task with `/analyze "<next task>"`.
