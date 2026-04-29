# Conventions

> Observed coding and process conventions for this project.
> The onboarder seeds this on `/onboard`; the reviewer appends new conventions whenever they are observed during `/implement` and confirmed during `/review`.
> Each section keeps a short bootstrap example showing the format. Replace the bootstrap line with real entries as they are discovered.
> Reference as `[memory:conventions#naming]` etc.

---

## Naming

- Bootstrap example — How we observed it: scanned `src/` and saw 38/40 files using `kebab-case.ts`. Convention: filenames are `kebab-case`; React components are `PascalCase` only inside the file (default export).

## Formatting

- Bootstrap example — How we observed it: repo has `.prettierrc` with `printWidth: 100`, `singleQuote: true`, `semi: true`. Convention: respect Prettier defaults from the repo; never reformat untouched files in the same PR.

## Frontend conventions

- Bootstrap example — How we observed it: every page under `app/` has a `page.tsx` plus a colocated `_components/` folder. Convention: keep components colocated under the route that owns them; only promote to `components/shared/` after the second consumer.

## Backend conventions

- Bootstrap example — How we observed it: routes live in `server/routes/<resource>.ts`, each exporting a `router` and registering on a central `app.use("/api", router)` in `server/index.ts`. Convention: one file per resource, no inline handlers in `index.ts`.

## Testing layout

- Bootstrap example — How we observed it: tests live next to source as `<name>.test.ts`; integration tests under `tests/integration/`. Convention: unit tests colocated, integration tests centralized, both run via `npm test`.

## Imports

- Bootstrap example — How we observed it: `tsconfig.json` defines `paths: { "@/*": ["src/*"] }`. Convention: use `@/...` for project-internal imports; relative imports only for siblings inside the same folder.

## Other

- Bootstrap example — How we observed it: every PR title in the last 50 follows `type(scope): subject`. Convention: Conventional Commits, scope optional but encouraged.
