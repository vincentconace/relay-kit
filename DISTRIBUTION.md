# Distribución de relay-kit

Esta guía explica cómo subir relay-kit a GitHub, publicar releases con SemVer, y abrir el proyecto a contribuciones. relay-kit es la implementación de referencia de **MASD (Multi-Agent Spec Development)**, así que cualquier fork debería preservar esa identidad o renombrarse explícitamente.

---

## 1) Crear el repo público

```bash
cd /Users/<vos>/Documents/GitHub/relay-kit
git init
git add .
git commit -m "chore: initial relay-kit (MASD framework)"
git branch -M main

# Crear el repo en GitHub (UI o gh CLI)
gh repo create vincentconace/relay-kit --public --source=. --remote=origin --push
```

Si no usás `gh`, creá el repo en `https://github.com/new` con nombre `relay-kit`, descripción "MASD framework for Claude — multi-agent, spec-driven, with persistent project memory", público, sin README/license/.gitignore (ya los traés). Luego:

```bash
git remote add origin https://github.com/vincentconace/relay-kit.git
git push -u origin main
```

A partir de ese momento, la línea de instalación funciona:

```bash
curl -fsSL https://raw.githubusercontent.com/vincentconace/relay-kit/main/install.sh | bash
```

> Importante: el `install.sh` tiene hardcodeado `https://github.com/vincentconace/relay-kit.git` como fallback para el caso `curl | bash`. Si forkeás bajo otro usuario / org, reemplazá esa URL por la tuya en `install.sh`.

---

## 2) Releases con SemVer

Versionado semántico (`MAJOR.MINOR.PATCH`):

- **PATCH** — fixes de copy, typos en prompts, bugs en el installer que no cambian el contrato.
- **MINOR** — nuevo sub-agente, nueva skill bootstrap, nueva sección en un template (sin romper templates existentes).
- **MAJOR** — cambio en la lista de slash commands, cambio en el layout de `.relay/`, cambio en el contrato del installer (paths, flags), cambio incompatible en `agent_prompt_conventions`.

Para publicar `v0.2.0`:

```bash
# 1. Bumpear package.json
npm version minor --no-git-tag-version

# 2. Actualizar el changelog (mantenelo a mano en CHANGELOG.md si querés)
git add package.json
git commit -m "release: v0.2.0"

# 3. Tag y push
git tag -a v0.2.0 -m "v0.2.0 — <resumen>"
git push origin main --tags

# 4. (Opcional) crear release en GitHub
gh release create v0.2.0 --title "v0.2.0" --notes-file RELEASE_NOTES.md
```

El one-liner de instalación apunta a `main` por defecto, pero podés pinear una versión:

```bash
curl -fsSL https://raw.githubusercontent.com/vincentconace/relay-kit/v0.2.0/install.sh | bash
```

---

## 3) Publicar en npm (opcional, habilita `npx`)

```bash
# Loguear si todavía no
npm login

# Verificar que el paquete tiene todo
npm pack --dry-run

# Publicar
npm publish --access public
```

Después de publicar, cualquiera puede correr:

```bash
npx relay-kit            # equivalente a bash install.sh en pwd
npx relay-kit . --yes
```

Tener en cuenta:

- El campo `bin: { "relay-kit": "./install.sh" }` ya está en `package.json`. npm respeta el bit ejecutable, así que `chmod +x install.sh` debe estar aplicado en el commit (revisalo con `git ls-files --stage install.sh` — debe empezar con `100755`).
- El campo `files` de `package.json` excluye lo que no debe ir al tarball (no incluimos `.git`, `node_modules`, etc.).
- Para republicar la misma versión hay que bumpear primero (npm no permite re-publicar tags).

---

## 4) Contribuir / forkear

El repo es MIT, así que cualquiera puede forkear y modificar. Convenciones sugeridas para contribuciones (ya sea PR a este repo o a un fork):

- **Mantener el contrato MASD.** Los 6 slash commands, el layout de `.relay/`, las 8 secciones XML por agente y la regla de "el reviewer es el único que escribe memoria" son invariantes.
- **Idiomas.** Prompts (commands + agents) en inglés. Docs y comentarios en español. Si forkeás para un equipo no hispanohablante, traducí los docs y los comentarios pero conservá el inglés en los prompts (matchea las built-in skills de Anthropic).
- **Skills.** Para agregar una skill nueva al bootstrap, editá `memory/skills.md` siguiendo el formato `## <skill-name>` / `usar cuando` / `requiere` / `fallback`. Documentalo en el PR.
- **Sub-agentes.** Para agregar un sub-agente nuevo, creá `agents/sub/<name>-implementer.md` con las 8 secciones XML y agregá una fila a la `<dispatch_table>` de `agents/implementer.md`.
- **Tests.** Si tu PR cambia el installer, probalo en al menos dos hosts distintos (Antigravity + Claude Code) y agregá una nota en la descripción del PR.

---

## 5) Branding y atribución

Si publicás un fork bajo otro nombre:

- Renombrá `name` en `package.json`.
- Cambiá el header comment de `install.sh` y `install.ps1` (mantené la referencia a MASD si seguís implementando la metodología, sacala si divergís).
- Mantené el `LICENSE` MIT con el copyright original más el tuyo.
- Linkeá al repo original desde el README de tu fork (cortesía mínima).

---

## 6) Seguridad

- `install.sh` usa `set -euo pipefail` y sale con código distinto de cero ante cualquier fallo. Igual, antes de sugerirle a alguien `curl | bash`, asumí que esa persona puede no inspeccionar el script — mantené el script auditable (corto, sin obfuscación, sin descargas binarias, sin sudo).
- No metas secretos en el repo. Las skills que necesiten API keys deben declararlo en su entrada `requiere:` de `memory/skills.md`, no embeberlas.
