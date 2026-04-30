---
description: "MASD · Fase 4 (implementer) — orquesta sub-agentes (frontend/backend/tests/docs/refactor) e invoca skills para ejecutar las tareas de la feature activa."
argument-hint: "[T-NNN]"
---

# /implement

Run the relay-kit implementer orchestrator to execute the task list, dispatching to specialized sub-agents and invoking skills validated against the registry.

## Invocation

Invoke the agent at `agents/relay/implementer.md`. The orchestrator resolves the active feature automatically (git branch first, `.relay/HEAD` fallback).

If the user passes a task ID (e.g. `/implement T-003`), execute only that task. Otherwise execute every task in dependency order.

## Preconditions

- An active feature exists. If not, instruct the user to run `/analyze "<task>"` first and halt.
- `.relay/features/<active>/tasks.md` exists. If missing, instruct the user to run `/tasks` first and halt.
- `.relay/memory/skills.md` exists (mandatory — the orchestrator validates every `suggested skill` against it before invocation).

## Output

- Code changes on disk per the task list.
- `.relay/features/<active>/implementation.md` — appended one block per executed task plus an `Aggregate notes` block.

## Next step

`/review` (validates the implementation and commits memory updates).
