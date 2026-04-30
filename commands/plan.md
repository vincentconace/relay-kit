---
description: "MASD · Fase 2 (planner) — produce un plan concreto, respetando convenciones y decisiones previas, en .relay/features/<active>/plan.md."
argument-hint: ""
---

# /plan

Run the relay-kit planner agent to convert the analysis into a concrete plan.

## Invocation

Invoke the agent at `agents/relay/planner.md`. No arguments required. The planner resolves the active feature automatically (git branch first, `.relay/HEAD` fallback) and operates on `.relay/features/<active>/`.

## Preconditions

- An active feature exists (either you are on a branch named `<type>/<slug>` matching a folder under `.relay/features/`, or `.relay/HEAD` points to one). If neither is true, instruct the user to run `/analyze "<task>"` first and halt.
- `.relay/features/<active>/analysis.md` exists. If missing, instruct the user to run `/analyze` first and halt.
- `.relay/project.md` exists. If missing AND the repo contains code, the planner itself will halt and recommend `/onboard`.

## Output

- `.relay/features/<active>/plan.md` — overwrites any prior plan for this feature.

## Next step

`/tasks` (consumes `.relay/features/<active>/plan.md`).
