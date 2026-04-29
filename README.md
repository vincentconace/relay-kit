# relay-kit

Framework multi-agente para Claude que implementa **MASD — Multi-Agent Spec Development**: cada fase del trabajo es de un agente especializado que produce un artefacto estructurado para el siguiente, con memoria persistente del proyecto que compone conocimiento entre tareas.

Compatible con **Google Antigravity**, **Claude Code** y **Cowork**. Instalable con un solo comando.

---

## ¿Qué es MASD?

MASD (Multi-Agent Spec Development) es la metodología que relay-kit codifica. La idea: en lugar de pedirle a un único agente "hacé X", se descompone el trabajo en cinco fases secuenciales, cada una con su propio agente y su propio archivo de salida. La sexta — onboarding — corre una vez al instalar.

```
/onboard      →  onboarder        →  .relay/project.md  +  semilla en memoria
/analyze      →  analyst          →  .relay/current/analysis.md
/plan         →  planner          →  .relay/current/plan.md
/tasks        →  task-maker       →  .relay/current/tasks.md
/implement    →  implementer + sub-agents + skills →  .relay/current/implementation.md
/review       →  reviewer         →  .relay/current/review.md  +  APPEND a .relay/memory/*.md
```

**Diferencias frente a GitHub Spec Kit:**

1. Una **5ª fase de review** que cierra el loop y valida el código contra el plan.
2. **Memoria persistente** (`.relay/memory/`) que toda corrida lee al empezar y el reviewer escribe al terminar — el sistema acumula lecciones, errores, decisiones, convenciones, glosario, referencias y skills entre tareas.
3. Un **implementer orquestador** que despacha a sub-agentes especializados (frontend, backend, tests, docs, refactor) y delega en skills instaladas (docx, pdf, pptx, xlsx, frontend-design).
4. **Distribución empaquetada** vía `install.sh` — adopción en una línea.
5. Un **agente onboarder** que la primera vez analiza el repo y produce `.relay/project.md` (snapshot canónico) más una siembra de la memoria con las convenciones detectadas.

---

## Instalación

### One-liner (curl)

```bash
curl -fsSL https://raw.githubusercontent.com/vincentconace/relay-kit/main/install.sh | bash
```

### Local (clone)

```bash
git clone https://github.com/vincentconace/relay-kit.git
cd relay-kit
bash install.sh /ruta/al/proyecto         # o sin argumento = pwd
```

### Windows (PowerShell)

```powershell
git clone https://github.com/vincentconace/relay-kit.git
cd relay-kit
powershell -ExecutionPolicy Bypass -File .\install.ps1 C:\ruta\al\proyecto
```

El instalador detecta el host (Antigravity → Claude Code → Cowork → fallback genérico), copia los slash commands, agentes y templates al directorio del host, y crea `.relay/{current,archive,memory}/` en el proyecto. **Nunca pisa archivos de memoria existentes.**

Ver [INSTALL.md](INSTALL.md) para detalles, mapeo de paths por host y la opción `npx relay-kit`.

---

## Walkthrough end-to-end (ejemplo concreto)

Vamos a agregar un endpoint `GET /health` a un proyecto Express + TypeScript. El proyecto ya existe.

### 0) Después del `install.sh`, sembrar contexto

```
/onboard
```

El **onboarder** recorre el repo, detecta `Express 4` + `TypeScript 5.4`, mapea `src/server/routes/`, lee `package.json`, y escribe:

- `.relay/project.md` con stack, folder map, comandos (`npm run dev`, `npm test`), entry points (`src/server/index.ts`).
- Apéndice en `.relay/memory/conventions.md` con lo observado (filenames `kebab-case`, rutas en `src/server/routes/<resource>.ts`, tests colocados como `<name>.test.ts`).
- Apéndice en `.relay/memory/decisions.md` con un ADR `D-002 — Express 4 con un router por recurso (Status: Observed)`.

### 1) Analizar el pedido

```
/analyze "agregar endpoint GET /health que devuelva { status: 'ok', uptime } en JSON"
```

El **analyst** lee `project.md` y la memoria, y produce `.relay/current/analysis.md`:

- **Problem statement:** exponer un endpoint público de healthcheck para monitoreo externo.
- **In scope:** ruta `GET /health`, respuesta JSON con `status` y `uptime` (segundos desde el boot del proceso).
- **Out of scope:** auth, métricas Prometheus, dependencias DB.
- **Constraints:** seguir `[memory:conventions#backend-conventions]` (un archivo por recurso bajo `src/server/routes/`).
- **Success criteria:** `curl localhost:3000/health` devuelve `{ "status": "ok", "uptime": <number> }` con HTTP 200.

### 2) Planear

```
/plan
```

El **planner** lee análisis + project + memoria. Antes de elegir el shape de la respuesta, decide consultar la convención IETF para healthchecks usando WebSearch:

> Consultando RFC 6585 y la convención `application/health+json` en `[web:inadarei.github.io](https://inadarei.github.io/rfc-healthcheck/)` para confirmar el shape recomendado. Consultado 2026-04-29.

Produce `.relay/current/plan.md`:

- **High-level approach:** un nuevo router `health.ts` registrado en `src/server/index.ts`. Sin dependencias nuevas.
- **Files to touch:**
  - `src/server/routes/health.ts` — nuevo router con `GET /`.
  - `src/server/index.ts` — registrar `app.use('/health', healthRouter)`.
  - `src/server/routes/health.test.ts` — test de integración con supertest.
- **Deviations from existing conventions:** Ninguna.
- **Sources:** entrada inline `[web:inadarei.github.io]` y URL completa en `## Sources` para que el reviewer la promueva a `memory/references.md`.

### 3) Atomizar

```
/tasks
```

El **task-maker** lee plan + `memory/skills.md` y produce `.relay/current/tasks.md` con:

- **T-001** — Crear `src/server/routes/health.ts` con handler. Sub-agente `backend-implementer`. Skill `none`.
- **T-002** — Registrar el router en `src/server/index.ts`. Sub-agente `backend-implementer`. Depende de T-001.
- **T-003** — Test de integración. Sub-agente `tests-implementer`. Depende de T-002.

### 4) Implementar

```
/implement
```

El **implementer** orquesta. Para T-001 y T-002 valida que la skill sugerida está en `memory/skills.md` (es `none`, ok), y dispatcha al `backend-implementer`. Para T-003 dispatcha al `tests-implementer`. El backend-implementer abre `project.md`, ve que el router por recurso es la convención, y escribe el handler en 12 líneas.

(Si en otro proyecto la tarea fuera "exportar el reporte mensual a PDF", el orquestador despacharía al `docs-implementer`, que **invocaría la skill `pdf` desde el registro** — exactamente lo que dice `memory/skills.md` bajo `## pdf`. Esa es la pieza que conecta sub-agentes con skills instaladas.)

`implementation.md` queda con un bloque por tarea, `Status: done`, archivos cambiados, y una nota agregada `Sources consulted: [web:inadarei.github.io](...)` heredada del planner.

### 5) Revisar y aprender

```
/review
```

El **reviewer** corre `git diff`, valida los criterios de aceptación con `curl` y con el output del test, y produce `.relay/current/review.md` con verdict `pass`. Crucialmente, **appendea a la memoria**:

- `memory/references.md` — la URL del RFC healthcheck que consultó el planner.
- `memory/lessons.md` — `L-002 — En endpoints de healthcheck, devolver siempre uptime en segundos enteros para que sea grafable sin parseo.`
- `memory/conventions.md` — sin cambios (no surgió convención nueva).
- `memory/skills.md` — sin cambios.

La próxima vez que `/analyze` corra para "agregar `/readiness`", el analyst ya partirá de esa lección.

---

## Estructura del repo

```
relay-kit/
├── README.md          ← este archivo
├── INSTALL.md         ← opciones de instalación + paths por host
├── DISTRIBUTION.md    ← cómo publicar en GitHub y npm
├── LICENSE            ← MIT
├── .gitignore         ← para proyectos que USAN relay-kit
├── install.sh         ← bash, idempotente, detecta host
├── install.ps1        ← espejo PowerShell
├── uninstall.sh       ← quita el framework (preserva .relay/)
├── package.json       ← bin: relay-kit
├── commands/          ← 6 slash commands (markdown)
├── agents/            ← 6 main + sub/ con 5 sub-agentes
├── templates/         ← 6 esqueletos markdown
└── memory/            ← 7 archivos bootstrap (lessons, errors, decisions, conventions, glossary, references, skills)
```

Ver [INSTALL.md](INSTALL.md) para el mapeo a `~/.antigravity/`, `~/.claude/`, `~/.config/cowork/`.

---

## Convenciones internas

- **Idioma de prompts (commands + agents):** inglés. Mejor performance de Claude y matchea las built-in skills.
- **Idioma de docs y comentarios:** español.
- **Memoria:** sólo markdown, append-only, escrita exclusivamente por el reviewer.
- **Skills:** se invocan desde sub-agentes, nunca desde el orquestador. El orquestador es delgado a propósito.
- **Onboarder:** es el único agente exento de leer `.relay/project.md` (lo produce). Todos los demás lo listan como input requerido.

---

## Quick Start (los 6 slash commands del flujo MASD)

```
1. /onboard                         (la primera vez en proyectos existentes)
2. /analyze "<tu pedido>"           (analyst → analysis.md)
3. /plan                            (planner → plan.md)
4. /tasks                           (task-maker → tasks.md)
5. /implement                       (implementer + sub-agents → implementation.md)
6. /review                          (reviewer → review.md + memoria actualizada)
```

Para correr una sola tarea: `/implement T-002`.
Para archivar el spec activo: mover `.relay/current/*` a `.relay/archive/<fecha>-<slug>/`.

---

## Licencia

[MIT](LICENSE). Forkealo, modificalo, distribuilo. Ver [DISTRIBUTION.md](DISTRIBUTION.md) si querés publicar tu propio fork.
