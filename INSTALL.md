# Instalación de relay-kit

relay-kit (framework MASD — Multi-Agent Spec Development para Claude) se distribuye como un repo público con un único `install.sh` (más su espejo `install.ps1` para Windows). El instalador detecta tu host, copia los artefactos al directorio correcto y bootstrappea `.relay/` en tu proyecto.

---

## Opciones

### 1) `curl | bash` (recomendado)

Desde la raíz del proyecto donde querés instalar relay-kit:

```bash
curl -fsSL https://raw.githubusercontent.com/vincentconace/relay-kit/main/install.sh | bash
```

Para no pausar 3 segundos antes de instalar:

```bash
curl -fsSL https://raw.githubusercontent.com/vincentconace/relay-kit/main/install.sh | bash -s -- --yes
```

### 2) Clone + local

```bash
git clone https://github.com/vincentconace/relay-kit.git
cd relay-kit
bash install.sh /ruta/al/proyecto      # o sin argumento → usa pwd
bash install.sh . --yes                # sin pausa
```

### 3) `npx relay-kit` (opcional)

Si publicaste el paquete en npm (ver [DISTRIBUTION.md](DISTRIBUTION.md)):

```bash
cd /ruta/al/proyecto
npx relay-kit
```

`package.json` declara `bin: { "relay-kit": "./install.sh" }`, así que `npx` ejecuta el mismo script.

### 4) Windows / PowerShell

```powershell
git clone https://github.com/vincentconace/relay-kit.git
cd relay-kit
powershell -ExecutionPolicy Bypass -File .\install.ps1 C:\ruta\al\proyecto
powershell -ExecutionPolicy Bypass -File .\install.ps1 . -Yes
```

---

## Qué hace exactamente el instalador

1. **Resuelve el directorio del proyecto.** Primer argumento posicional o `pwd`.
2. **Detecta el host** en este orden y se queda con el primero que matchee:
   1. `~/.antigravity/` o `<proyecto>/.antigravity/` → **Antigravity**
   2. `~/.claude/` o `<proyecto>/.claude/` → **Claude Code**
   3. `~/.config/cowork/` → **Cowork**
   4. cualquier otro caso → **fallback genérico** (crea `<proyecto>/.claude/`, compatible con cualquier herramienta que entienda el formato Claude Code)
3. **Anuncia** el host detectado y dónde va a instalar. Pausa 3 segundos (saltable con `--yes`).
4. **Copia** al directorio del host (idempotente — pide confirmación antes de sobrescribir un archivo modificado, o lo hace silenciosamente con `--yes`):
   - `commands/*.md` → `<host_dir>/commands/relay/`
   - `agents/*.md` y `agents/sub/*.md` → `<host_dir>/agents/relay/`
   - `templates/*.md` → `<host_dir>/templates/relay/`
5. **Bootstrapea** el proyecto:
   - Crea `<proyecto>/.relay/current/`, `<proyecto>/.relay/archive/`, `<proyecto>/.relay/memory/`.
   - Copia los 7 archivos `memory/*.md` SOLO si no existen — la memoria acumulada del proyecto nunca se pisa.
   - **NO crea `.relay/project.md`** — ese archivo lo produce `/onboard`.
6. **Imprime** un footer con la recomendación de correr `/onboard` si el proyecto ya tiene código, y el Quick Start con los 6 slash commands.

El script usa `set -euo pipefail` y sale con código distinto de cero ante cualquier fallo.

---

## Mapeo de paths por host

| Host                     | Directorio del host (`<host_dir>`)            | Slash commands                          | Agents                                 | Templates                              |
|--------------------------|-----------------------------------------------|-----------------------------------------|----------------------------------------|----------------------------------------|
| **Antigravity**          | `~/.antigravity/` o `<proy>/.antigravity/`    | `<host_dir>/commands/relay/*.md`        | `<host_dir>/agents/relay/*.md`         | `<host_dir>/templates/relay/*.md`      |
| **Claude Code**          | `~/.claude/` o `<proy>/.claude/`              | `<host_dir>/commands/relay/*.md`        | `<host_dir>/agents/relay/*.md`         | `<host_dir>/templates/relay/*.md`      |
| **Cowork**               | `~/.config/cowork/`                           | `<host_dir>/commands/relay/*.md`        | `<host_dir>/agents/relay/*.md`         | `<host_dir>/templates/relay/*.md`      |
| **Fallback genérico**    | `<proy>/.claude/` (nuevo)                     | `<host_dir>/commands/relay/*.md`        | `<host_dir>/agents/relay/*.md`         | `<host_dir>/templates/relay/*.md`      |

En todos los casos, los artefactos se prefijan con `relay/` para no chocar con otros agentes / commands / templates instalados en el host.

---

## Estructura post-instalación en el proyecto

```
<proyecto>/
└── .relay/
    ├── current/        ← efímero, sobrescrito por /analyze
    ├── archive/        ← especs cerrados (mover a mano o vía /archive)
    └── memory/
        ├── lessons.md
        ├── errors.md
        ├── decisions.md
        ├── conventions.md
        ├── glossary.md
        ├── references.md
        └── skills.md
```

`.relay/project.md` aparece después del primer `/onboard`.

---

## Idempotencia y re-instalación

`install.sh` es seguro de re-ejecutar:

- Archivos del host (`commands/`, `agents/`, `templates/`) que difieren del repo: pide confirmación (o sobrescribe con `--yes`). Si son idénticos: no hace nada.
- Archivos de memoria del proyecto: NUNCA se sobrescriben. Para resetear la memoria de un proyecto, borrá manualmente los archivos correspondientes y re-ejecutá el instalador (o un `/onboard --refresh`).

---

## Desinstalación

```bash
bash uninstall.sh /ruta/al/proyecto      # idempotente, pide confirmación
bash uninstall.sh /ruta/al/proyecto --yes
```

Quita `<host_dir>/{commands,agents,templates}/relay/`. **Nunca** toca `<proyecto>/.relay/` — esa carpeta es propiedad del proyecto. Si querés borrarla:

```bash
rm -rf /ruta/al/proyecto/.relay
```

---

## Troubleshooting

- **"git no encontrado" al usar `curl | bash`:** el instalador necesita `git` para clonarse a un temp dir. Instalá `git` o usá la opción 2 (clone + local).
- **El host detectado es el equivocado:** forzá moviendo / creando la carpeta marcador antes de instalar (por ejemplo, `mkdir -p ~/.claude` para forzar Claude Code).
- **`/onboard` no aparece en mi cliente:** verificá que `<host_dir>/commands/relay/onboard.md` exista. Si tu cliente no usa el prefijo `relay/`, copiá los archivos a `<host_dir>/commands/` directamente.
- **Permisos:** `chmod +x install.sh uninstall.sh` si el repo se clonó con el bit ejecutable perdido (raro pero posible en Windows + WSL).
