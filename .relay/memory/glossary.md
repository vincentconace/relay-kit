# Glossary

> Project-specific terms, acronyms, and domain vocabulary.
> The onboarder seeds this on `/onboard`; the reviewer appends new terms when an agent had to disambiguate a word during the run.
> Format per entry: `- **Term** — definition (origin / where it appears).`
> Reference as `[memory:glossary#term]`.

---

- **MASD** — Multi-Agent Spec Development. The methodology relay-kit implements: each phase is owned by a specialized agent that produces a structured artifact for the next agent. Origin: relay-kit framework.
- **`.relay/features/<type>-<slug>/`** — per-feature directory holding the artifacts of one spec (`analysis.md`, `plan.md`, `tasks.md`, `implementation.md`, `review.md`). Created by `/analyze`, paired 1:1 with a git branch `<type>/<slug>`. Multiple features coexist; switching is `git checkout`.
- **`.relay/HEAD`** — single-line file naming the active feature folder, used as fallback when not on a typed git branch.
- **`.relay/memory/`** — append-only knowledge base shared across all relay-kit runs in this project.
