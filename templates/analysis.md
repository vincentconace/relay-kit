# Analysis

> Produced by the `analyst` agent on `/analyze "<task>"`. Consumed by the `planner`.

- Task input: <quote the user's raw request>
- Date: <YYYY-MM-DD>

## Problem statement

<2-4 sentences. What is the user actually trying to accomplish? Restate in the project's own vocabulary, citing `[memory:glossary#term]` when relevant.>

## In scope

- <Bullet — concrete, observable.>

## Out of scope

- <Bullet — explicit non-goals so the planner doesn't drift.>

## Assumptions

- <Bullet — what we're taking as true without verifying. Cite `[memory:decisions#D-XXX]` when an existing decision underpins the assumption.>

## Constraints

- Technical: <e.g. must work on Node 20, no new top-level deps>
- Conventions: <cite `[memory:conventions#section]` entries that bind this task>
- Time / scope: <e.g. small change, < 5 files>

## Success criteria

- <Bullet — how we will know we succeeded. Should be testable.>

## Open questions

- <At most 3. Mark as `BLOCKING` if the planner cannot proceed without an answer.>

## Sources

- <`[web:domain](url)` entries if WebSearch was used; otherwise write "Web no consultado.">
