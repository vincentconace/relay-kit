#!/usr/bin/env bash
# relay-kit installer
# Implements MASD (Multi-Agent Spec Development) for Claude across Antigravity,
# Claude Code, and Cowork. Installs slash commands, agents, and templates into
# the host directory and bootstraps .relay/{features,archive,memory}/ in the
# project so the 7 MASD slash commands (/onboard /analyze /plan /tasks /implement
# /review /update) can run end-to-end. Each /analyze creates a dedicated
# .relay/features/<type>-<slug>/ folder paired 1:1 with a git branch.
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
# Parse args: optional target dir, --yes, --host.
# ------------------------------------------------------------------------------
TARGET_DIR=""
ASSUME_YES="no"
EXPLICIT_HOSTS=""

while [ $# -gt 0 ]; do
  case "$1" in
    --yes|-y) ASSUME_YES="yes"; shift ;;
    --host) EXPLICIT_HOSTS="${2:-}"; shift 2 ;;
    --host=*) EXPLICIT_HOSTS="${1#--host=}"; shift ;;
    --help|-h)
      cat <<'HLP'
relay-kit install.sh — instala el framework MASD en este proyecto.

Uso:
  bash install.sh [target_project_dir] [--yes] [--host <list>]

Args:
  target_project_dir    Directorio raíz del proyecto donde se creará .relay/.
                        Default: directorio actual (pwd).
  --yes, -y             No pausar antes de instalar.
  --host <list>         Lista separada por comas de hosts a instalar:
                        claude, antigravity, cowork.
                        Default: todos los detectados.
  --help, -h            Mostrar esta ayuda.
HLP
      exit 0
      ;;
    -*)
      echo "ERROR: flag no reconocido: $1" >&2
      exit 2
      ;;
    *)
      if [ -z "$TARGET_DIR" ]; then
        TARGET_DIR="$1"; shift
      else
        echo "ERROR: argumento no reconocido: $1" >&2
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
# Resolve hosts: each entry is "Name|Path".
#   - With --host, the user picks an explicit subset (claude/antigravity/cowork).
#   - Without --host, we install into every host detected on the machine, so a
#     user with both Claude Code and Antigravity gets relay-kit working in both.
#   - If nothing is detected, fall back to creating $TARGET_DIR/.claude.
# Project-local hosts (TARGET_DIR/.claude, TARGET_DIR/.agents) win over the
# user-global ones ($HOME/.claude, $HOME/.agents) when both exist.
# ------------------------------------------------------------------------------
HOSTS=()

resolve_host_dir() {
  # $1 = host name (claude|antigravity|cowork)
  # echoes "Name|Path" (or empty if not resolvable for that name)
  case "$1" in
    claude|claude-code|claudecode)
      if [ -d "$TARGET_DIR/.claude" ]; then
        echo "Claude Code|$TARGET_DIR/.claude"
      else
        echo "Claude Code|$HOME/.claude"
      fi
      ;;
    antigravity)
      if [ -d "$TARGET_DIR/.agents" ]; then
        echo "Antigravity|$TARGET_DIR/.agents"
      else
        echo "Antigravity|$HOME/.agents"
      fi
      ;;
    cowork)
      echo "Cowork|$HOME/.config/cowork"
      ;;
    *)
      return 1
      ;;
  esac
}

if [ -n "$EXPLICIT_HOSTS" ]; then
  IFS=',' read -r -a __requested <<< "$EXPLICIT_HOSTS"
  for req in "${__requested[@]}"; do
    req_lc="$(echo "$req" | tr '[:upper:]' '[:lower:]' | tr -d ' ')"
    entry="$(resolve_host_dir "$req_lc" || true)"
    if [ -z "$entry" ]; then
      echo "ERROR: --host debe ser claude, antigravity o cowork (recibí: $req)" >&2
      exit 2
    fi
    HOSTS+=("$entry")
  done
else
  # Auto-detect every host present on the machine.
  if [ -d "$TARGET_DIR/.claude" ] || [ -d "$HOME/.claude" ]; then
    HOSTS+=("$(resolve_host_dir claude)")
  fi
  if [ -d "$TARGET_DIR/.agents" ] || [ -d "$HOME/.agents" ]; then
    HOSTS+=("$(resolve_host_dir antigravity)")
  fi
  if [ -d "$HOME/.config/cowork" ]; then
    HOSTS+=("$(resolve_host_dir cowork)")
  fi
  if [ "${#HOSTS[@]}" -eq 0 ]; then
    HOSTS+=("Claude Code (fallback)|$TARGET_DIR/.claude")
  fi
fi

# ------------------------------------------------------------------------------
# Announce.
# ------------------------------------------------------------------------------
echo "========================================"
echo "relay-kit · MASD installer"
echo "========================================"
echo "Hosts a instalar:"
for entry in "${HOSTS[@]}"; do
  name="${entry%%|*}"
  path="${entry#*|}"
  printf "  · %-22s → %s\n" "$name" "$path"
done
cat <<EOF
Proyecto       : ${TARGET_DIR}
Archivos a copiar (por host):
  · commands/relay/   ← commands/*.md
  · agents/relay/     ← agents/*.md + agents/sub/*.md
  · templates/relay/  ← templates/*.md
Bootstrap del proyecto:
  · ${TARGET_DIR}/.relay/{features,archive,memory}/
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
# Install host artifacts (one pass per detected host).
# ------------------------------------------------------------------------------
for entry in "${HOSTS[@]}"; do
  host_name="${entry%%|*}"
  host_dir="${entry#*|}"

  echo ""
  echo "==> ${host_name} (${host_dir})"

  mkdir -p "$host_dir/commands/relay"
  mkdir -p "$host_dir/agents/relay"
  mkdir -p "$host_dir/templates/relay"

  echo "→ commands/"
  for f in "$SCRIPT_DIR/commands/"*.md; do
    [ -e "$f" ] || { echo "ERROR: no se encontraron commands/*.md en $SCRIPT_DIR/commands" >&2; exit 3; }
    copy_file_safe "$f" "$host_dir/commands/relay/$(basename "$f")"
  done

  echo "→ agents/"
  for f in "$SCRIPT_DIR/agents/"*.md; do
    [ -e "$f" ] || { echo "ERROR: no se encontraron agents/*.md en $SCRIPT_DIR/agents" >&2; exit 3; }
    copy_file_safe "$f" "$host_dir/agents/relay/$(basename "$f")"
  done
  if [ -d "$SCRIPT_DIR/agents/sub" ]; then
    for f in "$SCRIPT_DIR/agents/sub/"*.md; do
      [ -e "$f" ] || break
      copy_file_safe "$f" "$host_dir/agents/relay/$(basename "$f")"
    done
  fi

  echo "→ templates/"
  for f in "$SCRIPT_DIR/templates/"*.md; do
    [ -e "$f" ] || { echo "ERROR: no se encontraron templates/*.md en $SCRIPT_DIR/templates" >&2; exit 3; }
    copy_file_safe "$f" "$host_dir/templates/relay/$(basename "$f")"
  done
done

# ------------------------------------------------------------------------------
# Bootstrap the project's .relay/ tree (idempotent — never overwrite memory).
# ------------------------------------------------------------------------------
mkdir -p "$TARGET_DIR/.relay/features"
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
echo ""
echo "========================================"
echo "relay-kit instalado"
echo "========================================"
echo "Hosts:"
for entry in "${HOSTS[@]}"; do
  name="${entry%%|*}"
  path="${entry#*|}"
  printf "  · %-22s → %s\n" "$name" "$path"
done
cat <<EOF
Proy. : ${TARGET_DIR}/.relay/

Si este proyecto YA tiene código, corré /onboard ahora para sembrar el
contexto (escribe .relay/project.md y siembra la memoria) antes de tu
primera tarea. En proyectos greenfield podés saltar /onboard.

Quick start (flujo MASD — 7 slash commands):
  1. /onboard                         (recomendado en proyectos existentes)
  2. /analyze "<tu pedido>"           (crea .relay/features/<type>-<slug>/ + propone rama git)
  3. /plan                            (escribe plan.md en la feature activa)
  4. /tasks                           (escribe tasks.md en la feature activa)
  5. /implement                       (o /implement T-001 para una sola)
  6. /review                          (cierra el loop y actualiza la memoria)
  7. /update                          (re-pull del framework desde GitHub; preserva memoria y features)

Documentación: README.md · INSTALL.md · DISTRIBUTION.md (en español).
========================================
EOF

exit 0
