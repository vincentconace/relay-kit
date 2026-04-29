# Lessons

> Persistent log of "When X, do Y because Z" learnings discovered while running MASD.
> The reviewer agent appends here at the end of every `/review`.
> Format per entry: `### L-NNN — <short title>` followed by Context / Lesson / Why.
> Reference from agent outputs as `[memory:lessons#L-001]`.

---

### L-001 — Always re-read project.md after a refactor task

- Context: After a refactor that moved files between folders, subsequent agents kept referring to the old paths.
- Lesson: When a task changes folder layout, the reviewer must recommend `/onboard --refresh` so `project.md` reflects the new structure before the next `/analyze`.
- Why: Stale `project.md` poisons every downstream phase because every agent reads it as ground truth.
