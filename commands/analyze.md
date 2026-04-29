---
description: "MASD · Fase 1 (analyst) — convierte el pedido del usuario en un análisis estructurado en .relay/current/analysis.md."
argument-hint: "\"<task description>\""
---

# /analyze

Run the relay-kit analyst agent to convert the user's raw request into a precise, scoped problem statement.

## Invocation

Invoke the agent at `agents/relay/analyst.md`. Pass the user's task description (the quoted string after `/analyze`) as the input.

If the user did not pass a task description, prompt once for it; do not invent one.

## Preconditions

- `.relay/project.md` exists. If missing AND the repo contains code, instruct the user to run `/onboard` first and halt.
- `.relay/memory/*.md` exist (created by `install.sh`).

## Output

- `.relay/current/analysis.md` — overwrites any prior analysis.

## Next step

`/plan` (consumes `analysis.md`).
