# Decisions (ADR-style)

> Architecture and process decisions taken on this project. Append-only.
> Format per entry mirrors a lightweight ADR.
> The planner cites these as `[memory:decisions#D-001]`; the reviewer appends new ones whenever a meaningful choice was locked in during `/implement`.

---

### D-001 — Adopt MASD (Multi-Agent Spec Development) for non-trivial work

- Status: Accepted
- Date: 2026-04-28
- Context: One-shot prompts produced inconsistent results on multi-file changes; intent drifted between phases and conventions were re-invented per task.
- Decision: Use the relay-kit MASD flow (`/onboard` → `/analyze` → `/plan` → `/tasks` → `/implement` → `/review`) for any change touching more than one file or one subsystem.
- Consequences:
  - Positive: explicit handoffs, shared memory, reproducible reviews.
  - Negative: small one-line tweaks should still be done outside the flow to avoid ceremony.
