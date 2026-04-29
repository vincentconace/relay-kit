#!/usr/bin/env bash
# relay-kit installer
# Implements MASD (Multi-Agent Spec Development) for Claude across Antigravity,
# Claude Code, and Cowork. Installs slash commands, agents, and templates into
# the host directory and bootstraps .relay/{current,archive,memory}/ in the
# project so the 6 MASD phases (/onboard /analyze /plan /tasks /implement /review)
# can run end-to-end.
#
# Usage:
#   bash install.sh [target_project_dir] [--yes]
#   curl -fsSL https://raw.githubusercontent.com/<user>/relay-kit/main/install.sh | bash

set -euo pipefail

# ------------------------------------------------------------------------------
# Resolve script source dir (works for piped curl too — falls back to a temp
# clone of the public repo if the script was streamed via stdin).
# ------------------------------------------------------------------------------
SCRIPT_SOURCE="${BASH_SOURCE[0]:-}"
if [ -n "${SCRIPT_SOURCE}" ] && [ -f "${SCRIPT_SOURCE}" ]; then
  SCRIPT_DIR="$(cd "$(dirname "${SCRIPT_SOURCE}")" && pwd)"
else
  # Streamed via curl | bash — clone the public repo to a temp dir and re-root.
  TMP_CLONE="$(mktemp -d -t relay-kit.XXXXXX)"
  echo "→ relay-kit fue ejecutado por stream; clonando el repo a ${TMP_CLONE}…"
  if ! command -v git >/dev/null 2>&1; then
    echo "ERROR: se requiere 'git' para instalar via curl|bash. Instalalo o cloná el repo manualmente." >&2
    exit 1
  fi
  git clone --depth 1 https://github.com/vincentconace/relay-kit.git "${TMP_CLONE}" >/dev/null
  SCRIPT_DIR="${TMP_CLONE}"
fi

# ------------------------------------------------------------------------------
# Parse args: optional target dir, optional --yes.
# ------------------------------------------------------------------------------
TARGET_DIR=""
ASSUME_YES="no"
for arg in "$@"; do
  case "$arg" in
    --yes|-y) ASSUME_YES="yes" ;;
    --help|-h)
      cat <<'HLP'
relay-kit install.sh — instala el framework MASD en este proyecto.

Uso:
  bash install.sh [target_project_dir] [--yes]

Args:
  target_project_dir    Directorio raíz del proyecto donde se creará .relay/.
                        Default: directorio actual (pwd).
  --yes, -y             No pausar antes de instalar.
  --help, -h            Mostrar esta ayuda.
HLP
      exit 0
      ;;
    *)
      if [ -z "$TARGET_DIR" ]; then
        TARGET_DIR="$arg"
      else
        echo "ERROR: argumento no reconocido: $arg" >&2
        exit 2
      fi
      ;;
  esac
done

if [ -z "$TARGET_DIR" ]; then
  TARGET_DIR="$(pwd)"
fi

if [ ! -d "$TARGET_DIR" ]; then
  echo "ERROR: target_project_dir no existe: $TARGET_DIR" >&2
  exit 2
fi
TARGET_DIR="$(cd "$TARGET_DIR" && pwd)"

# ------------------------------------------------------------------------------
# Detect host: Antigravity → Claude Code → Cowork → generic fallback.
# ------------------------------------------------------------------------------
HOST_NAME=""
HOST_DIR=""

if [ -d "$HOME/.antigravity" ] || [ -d "$TARGET_DIR/.antigravity" ]; then
  HOST_NAME="Antigravity"
  if [ -d "$TARGET_DIR/.antigravity" ]; then
    HOST_DIR="$TARGET_DIR/.antigravity"
  else
    HOST_DIR="$HOME/.antigravity"
  fi
elif [ -d "$HOME/.claude" ] || [ -d "$TARGET_DIR/.claude" ]; then
  HOST_NAME="Claude Code"
  if [ -d "$TARGET_DIR/.claude" ]; then
    HOST_DIR="$TARGET_DIR/.claude"
  else
    HOST_DIR="$HOME/.claude"
  fi
elif [ -d "$HOME/.config/cowork" ]; then
  HOST_NAME="Cowork"
  HOST_DIR="$HOME/.config/cowork"
else
  HOST_NAME="generic-fallback (Claude Code-compatible)"
  HOST_DIR="$TARGET_DIR/.claude"
fi

# ------------------------------------------------------------------------------
# Announce.
# ------------------------------------------------------------------------------
cat <<EOF
========================================
relay-kit · MASD installer
========================================
Host detectado : ${HOST_NAME}
Host dir       : ${HOST_DIR}
Proyecto       : ${TARGET_DIR}
Archivos a copiar:
  · commands/relay/   ← commands/*.md
  · agents/relay/     ← agents/*.md + agents/sub/*.md
  · templates/relay/  ← templates/*.md
Bootstrap del proyecto:
  · ${TARGET_DIR}/.relay/{current,archive,memory}/
  · memory/*.md (sólo si no existen)
========================================
EOF

if [ "$ASSUME_YES" != "yes" ]; then
  echo "Continúo en 3 segundos. Cancelá con Ctrl-C si querés revisar."
  sleep 3
fi

# ------------------------------------------------------------------------------
# Helper: copy a file, asking before overwrite (idempotent).
# ------------------------------------------------------------------------------
copy_file_safe() {
  local src="$1"
  local dst="$2"
  if [ -f "$dst" ]; then
    if cmp -s "$src" "$dst"; then
      return 0
    fi
    if [ "$ASSUME_YES" = "yes" ]; then
      cp "$src" "$dst"
      echo "  ↻ overwrite (--yes): $dst"
    else
      printf "  ? %s ya existe y difiere. Sobrescribir? [y/N] " "$dst"
      read -r ans </dev/tty || ans="n"
      case "$ans" in
        y|Y|yes|YES) cp "$src" "$dst"; echo "  ↻ overwrite: $dst" ;;
        *) echo "  · skip: $dst" ;;
      esac
    fi
  else
    cp "$src" "$dst"
    echo "  + $dst"
  fi
}

copy_file_no_overwrite() {
  local src="$1"
  local dst="$2"
  if [ -f "$dst" ]; then
    echo "  · skip (preserve existing memory): $dst"
  else
    cp "$src" "$dst"
    echo "  + $dst"
  fi
}

# ------------------------------------------------------------------------------
# Install host artifacts.
# ------------------------------------------------------------------------------
mkdir -p "$HOST_DIR/commands/relay"
mkdir -p "$HOST_DIR/agents/relay"
mkdir -p "$HOST_DIR/templates/relay"

echo "→ commands/"
for f in "$SCRIPT_DIR/commands/"*.md; do
  [ -e "$f" ] || { echo "ERROR: no se encontraron commands/*.md en $SCRIPT_DIR/commands" >&2; exit 3; }
  copy_file_safe "$f" "$HOST_DIR/commands/relay/$(basename "$f")"
done

echo "→ agents/"
for f in "$SCRIPT_DIR/agents/"*.md; do
  [ -e "$f" ] || { echo "ERROR: no se encontraron agents/*.md en $SCRIPT_DIR/agents" >&2; exit 3; }
  copy_file_safe "$f" "$HOST_DIR/agents/relay/$(basename "$f")"
done
if [ -d "$SCRIPT_DIR/agents/sub" ]; then
  for f in "$SCRIPT_DIR/agents/sub/"*.md; do
    [ -e "$f" ] || break
    copy_file_safe "$f" "$HOST_DIR/agents/relay/$(basename "$f")"
  done
fi

echo "→ templates/"
for f in "$SCRIPT_DIR/templates/"*.md; do
  [ -e "$f" ] || { echo "ERROR: no se encontraron templates/*.md en $SCRIPT_DIR/templates" >&2; exit 3; }
  copy_file_safe "$f" "$HOST_DIR/templates/relay/$(basename "$f")"
done

# ------------------------------------------------------------------------------
# Bootstrap the project's .relay/ tree (idempotent — never overwrite memory).
# ------------------------------------------------------------------------------
mkdir -p "$TARGET_DIR/.relay/current"
mkdir -p "$TARGET_DIR/.relay/archive"
mkdir -p "$TARGET_DIR/.relay/memory"

echo "→ memory bootstrap (preserve existing files)"
for f in "$SCRIPT_DIR/memory/"*.md; do
  [ -e "$f" ] || { echo "ERROR: no se encontraron memory/*.md en $SCRIPT_DIR/memory" >&2; exit 3; }
  copy_file_no_overwrite "$f" "$TARGET_DIR/.relay/memory/$(basename "$f")"
done

# Note: .relay/project.md is NOT created here — `/onboard` produces it.

# ------------------------------------------------------------------------------
# Footer / Quick start.
# ------------------------------------------------------------------------------
cat <<EOF

========================================
relay-kit instalado
========================================
Host  : ${HOST_NAME} (${HOST_DIR})
Proy. : ${TARGET_DIR}/.relay/

Si este proyecto YA tiene código, corré /onboard ahora para sembrar el
contexto (escribe .relay/project.md y siembra la memoria) antes de tu
primera tarea. En proyectos greenfield podés saltar /onboard.

Quick start (flujo MASD):
  1. /onboard                         (recomendado en proyectos existentes)
  2. /analyze "<tu pedido>"
  3. /plan
  4. /tasks
  5. /implement                       (o /implement T-001 para una sola)
  6. /review                          (cierra el loop y actualiza la memoria)

Documentación: README.md · INSTALL.md · DISTRIBUTION.md (en español).
========================================
EOF

exit 0
