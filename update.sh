#!/usr/bin/env bash
# relay-kit updater
# Re-corre install.sh desde la última versión publicada en main para actualizar
# el framework MASD (Multi-Agent Spec Development) sin tocar la memoria
# acumulada del proyecto (.relay/memory/*) ni las features (.relay/features/*).
#
# Uso:
#   bash update.sh [target_project_dir] [--host claude|antigravity|cowork]
#   curl -fsSL https://raw.githubusercontent.com/vincentconace/relay-kit/main/update.sh | bash
#
# Comportamiento:
#   - Pasa --yes a install.sh para sobrescribir silenciosamente los archivos del
#     host (commands/agents/templates) sin preguntar.
#   - --host se reenvía a install.sh; sin él, se actualizan todos los hosts
#     detectados en la máquina.
#   - install.sh nunca pisa archivos de memoria existentes ni la carpeta features/.

set -euo pipefail

TARGET_DIR=""
EXTRA_ARGS=()

while [ $# -gt 0 ]; do
  case "$1" in
    --host) EXTRA_ARGS+=("--host" "${2:-}"); shift 2 ;;
    --host=*) EXTRA_ARGS+=("$1"); shift ;;
    --help|-h)
      cat <<'HLP'
relay-kit update.sh — re-pull del framework MASD desde main.

Uso:
  bash update.sh [target_project_dir] [--host <list>]

Args:
  target_project_dir    Directorio raíz del proyecto. Default: pwd.
  --host <list>         Lista separada por comas: claude, antigravity, cowork.
                        Default: todos los hosts detectados.
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

TARGET_DIR="${TARGET_DIR:-$(pwd)}"

if [ ! -d "$TARGET_DIR" ]; then
  echo "ERROR: target_project_dir no existe: $TARGET_DIR" >&2
  exit 2
fi

echo "→ Actualizando relay-kit (MASD) en: $TARGET_DIR"

curl -fsSL https://raw.githubusercontent.com/vincentconace/relay-kit/main/install.sh \
  | bash -s -- --yes "${EXTRA_ARGS[@]+"${EXTRA_ARGS[@]}"}" "$TARGET_DIR"

echo "✓ relay-kit actualizado. Tu memoria y features quedaron intactas."
exit 0
