# Errors

> Persistent log of "Tried X, failed because Y, fix: Z" — concrete failure modes the team has hit.
> The reviewer appends here whenever `/implement` produced a deviation, retry, or workaround.
> Format per entry: `### E-NNN — <short title>` with Tried / Failed because / Fix.
> Reference from agent outputs as `[memory:errors#E-001]`.

---

### E-001 — Skill invoked without checking the registry

- Tried: A sub-agent invoked the `pdf` skill directly because the task mentioned "export to PDF".
- Failed because: The skill was not installed in the host environment, so the call returned a missing-tool error and the sub-agent silently fell back to plain text.
- Fix: Sub-agents must validate the skill against `.relay/memory/skills.md` before invoking it; if absent, follow the `fallback:` field declared in the registry.
