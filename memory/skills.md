# Skills Registry

<!--
  HOW TO ADD A NEW SKILL TO THIS REGISTRY
  ----------------------------------------
  This file is the single source of truth for which skills relay-kit may invoke.
  The task-maker reads it to assign a `suggested skill` per task; sub-agents
  read it to validate a skill before calling it.

  To register a new skill, append a section using exactly this format:

      ## <skill-name>
      - usar cuando: <trigger condition — be concrete, e.g. "task output is a .docx file">
      - requiere: <prerequisite — host must have the skill installed, env vars, etc.>
      - fallback: <what to do if the skill is unavailable at runtime>

  Rules:
    - Skill names must match the identifier the host environment exposes (e.g. `docx`, not `Word document`).
    - If the skill needs API keys or files, list them in `requiere:`.
    - The `fallback:` field is mandatory; "fail loudly" is a valid fallback but must be stated.
    - Add project-specific skills (internal MCPs, custom tools) below the bootstrap block.
-->

> Bootstrap entries below cover the well-known Anthropic skills. Do not delete them — disable instead by editing `usar cuando: never` so the history is preserved.

---

## docx

- usar cuando: the task's deliverable is a Word document (`.docx`), or the task reads/edits an existing `.docx` file.
- requiere: `docx` skill installed in the host (Antigravity / Claude Code / Cowork) and write access to the output directory.
- fallback: write the content as plain Markdown next to the intended path and flag in `implementation.md` that conversion to `.docx` is pending.

## pdf

- usar cuando: the task must produce, read, merge, split, watermark, or OCR a PDF file.
- requiere: `pdf` skill installed; for OCR an internet-capable runtime or local OCR binary.
- fallback: emit the source content (Markdown / HTML) and note that PDF rendering is deferred; never silently downgrade format without saying so.

## pptx

- usar cuando: the deliverable is a slide deck (`.pptx`), or slides must be parsed/edited.
- requiere: `pptx` skill installed; templates under `templates/decks/` if the project uses a brand layout.
- fallback: produce a Markdown outline (one `##` heading per slide, bullets for body) and flag that deck rendering is pending.

## xlsx

- usar cuando: the deliverable is a spreadsheet (`.xlsx`, `.xlsm`, `.csv`, `.tsv`) or messy tabular data must be cleaned/restructured.
- requiere: `xlsx` skill installed.
- fallback: emit the data as a Markdown table or CSV in `.relay/current/` and flag conversion to `.xlsx` as pending.

## frontend-design

- usar cuando: the task involves designing or generating frontend UI (landing pages, components, layouts) where visual quality matters.
- requiere: `frontend-design` skill installed; design tokens or brand kit if the project has one (link from `project.md`).
- fallback: hand-write semantic HTML + Tailwind classes following `memory/conventions.md#frontend-conventions`; flag in `implementation.md` that the design pass was manual.
