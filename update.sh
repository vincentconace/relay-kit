#!/usr/bin/env bash
# relay-kit updater
# Re-corre install.sh desde la última versión publicada en main para actualizar
# el framework MASD (Multi-Agent Spec Development) sin tocar la memoria
# acumulada del proyecto (.relay/memory/*) ni las features (.relay/features/*).
#
# Uso:
#   bash update.sh [target_project_dir]
#   curl -fsSL https://raw.githubusercontent.com/vincentconace/relay-kit/main/update.sh | bash
#
# Comportamiento:
#   - Pasa --yes a install.sh para sobrescribir silenciosamente los archivos del
#     host (commands/agents/templates) sin preguntar.
#   - install.sh nunca pisa archivos de memoria existentes ni la carpeta features/.

set -euo pipefail

TARGET_DIR="${1:-$(pwd)}"

if [ ! -d "$TARGET_DIR" ]; then
  echo "ERROR: target_project_dir no existe: $TARGET_DIR" >&2
  exit 2
fi

echo "→ Actualizando relay-kit (MASD) en: $TARGET_DIR"

curl -fsSL https://raw.githubusercontent.com/vincentconace/relay-kit/main/install.sh \
  | bash -s -- --yes "$TARGET_DIR"

echo "✓ relay-kit actualizado. Tu memoria y features quedaron intactas."
exit 0
