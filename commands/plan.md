---
description: "MASD · Fase 2 (planner) — produce un plan concreto, respetando convenciones y decisiones previas, en .relay/current/plan.md."
argument-hint: ""
---

# /plan

Run the relay-kit planner agent to convert the analysis into a concrete plan.

## Invocation

Invoke the agent at `agents/relay/planner.md`. No arguments required.

## Preconditions

- `.relay/current/analysis.md` exists. If missing, instruct the user to run `/analyze "<task>"` first and halt.
- `.relay/project.md` exists. If missing AND the repo contains code, the planner itself will halt and recommend `/onboard`.

## Output

- `.relay/current/plan.md` — overwrites any prior plan.

## Next step

`/tasks` (consumes `plan.md`).
