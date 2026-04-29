---
description: "MASD · Fase 3 (task-maker) — descompone el plan en tareas atómicas T-001, T-002, ... con sub-agente y skill sugeridos."
argument-hint: ""
---

# /tasks

Run the relay-kit task-maker agent to decompose the plan into atomic, ordered tasks.

## Invocation

Invoke the agent at `agents/relay/task-maker.md`. No arguments required.

## Preconditions

- `.relay/current/plan.md` exists. If missing, instruct the user to run `/plan` first and halt.
- `.relay/memory/skills.md` exists (mandatory — the task-maker uses it as the registry to validate every `suggested skill`).

## Output

- `.relay/current/tasks.md` — overwrites any prior task list.

## Next step

`/implement` (executes the tasks; pass an optional `T-NNN` to run a single one).
