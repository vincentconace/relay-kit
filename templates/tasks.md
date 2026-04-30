# Tasks

> Produced by the `task-maker` agent on `/tasks`. Consumed by the `implementer`.

- Linked plan: `.relay/features/<active>/plan.md`
- Date: <YYYY-MM-DD>

## Conventions

- IDs are `T-001`, `T-002`, … in dependency order.
- Each task is atomic: one commit-sized change.
- `suggested skill` MUST come from `.relay/memory/skills.md`. If no registered skill fits, write `none`.
- `suggested sub-agent` is one of: `frontend-implementer`, `backend-implementer`, `tests-implementer`, `docs-implementer`, `refactor-implementer`, or `self` (orchestrator handles directly).

---

## T-001 — <short title>

- Intent: <1 sentence. Why this task exists.>
- Files: `<path>`, `<path>`
- Acceptance criteria:
  - <Testable bullet.>
  - <Testable bullet.>
- Dependencies: <`none` or `T-XXX, T-YYY`>
- Suggested sub-agent: <one of the values above>
- Suggested skill: <name from `memory/skills.md` or `none`>

## T-002 — <short title>

- Intent: …
- Files: …
- Acceptance criteria:
  - …
- Dependencies: T-001
- Suggested sub-agent: …
- Suggested skill: …
