#!/usr/bin/env bash
# relay-kit uninstaller
# Quita commands/relay, agents/relay y templates/relay del directorio del host.
# NUNCA toca .relay/ del proyecto (memoria, snapshot, archivo histórico) —
# ese conocimiento es del usuario, no del framework.

set -euo pipefail

TARGET_DIR=""
ASSUME_YES="no"
for arg in "$@"; do
  case "$arg" in
    --yes|-y) ASSUME_YES="yes" ;;
    --help|-h)
      cat <<'HLP'
relay-kit uninstall.sh — quita relay-kit del host (NO toca .relay/ del proyecto).

Uso:
  bash uninstall.sh [target_project_dir] [--yes]
HLP
      exit 0
      ;;
    *)
      if [ -z "$TARGET_DIR" ]; then TARGET_DIR="$arg"; else echo "ERROR: arg desconocido $arg" >&2; exit 2; fi
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

# Detectar host con la misma lógica del install.
HOST_NAME=""
HOST_DIR=""
if [ -d "$HOME/.antigravity" ] || [ -d "$TARGET_DIR/.antigravity" ]; then
  HOST_NAME="Antigravity"
  if [ -d "$TARGET_DIR/.antigravity" ]; then HOST_DIR="$TARGET_DIR/.antigravity"; else HOST_DIR="$HOME/.antigravity"; fi
elif [ -d "$HOME/.claude" ] || [ -d "$TARGET_DIR/.claude" ]; then
  HOST_NAME="Claude Code"
  if [ -d "$TARGET_DIR/.claude" ]; then HOST_DIR="$TARGET_DIR/.claude"; else HOST_DIR="$HOME/.claude"; fi
elif [ -d "$HOME/.config/cowork" ]; then
  HOST_NAME="Cowork"
  HOST_DIR="$HOME/.config/cowork"
else
  HOST_NAME="generic-fallback (Claude Code-compatible)"
  HOST_DIR="$TARGET_DIR/.claude"
fi

cat <<EOF
========================================
relay-kit · uninstall
========================================
Host detectado : ${HOST_NAME}
Host dir       : ${HOST_DIR}
Voy a borrar:
  · ${HOST_DIR}/commands/relay/
  · ${HOST_DIR}/agents/relay/
  · ${HOST_DIR}/templates/relay/
NO voy a tocar:
  · ${TARGET_DIR}/.relay/   (memoria, snapshot, archivo histórico — propiedad del proyecto)
========================================
EOF

if [ "$ASSUME_YES" != "yes" ]; then
  printf "Continuar? [y/N] "
  read -r ans </dev/tty || ans="n"
  case "$ans" in
    y|Y|yes|YES) ;;
    *) echo "Abortado."; exit 0 ;;
  esac
fi

removed_any="no"
for d in "$HOST_DIR/commands/relay" "$HOST_DIR/agents/relay" "$HOST_DIR/templates/relay"; do
  if [ -d "$d" ]; then
    rm -rf "$d"
    echo "  - $d"
    removed_any="yes"
  fi
done

if [ "$removed_any" = "no" ]; then
  echo "No se encontró nada de relay-kit en ${HOST_DIR}. Nada que hacer."
fi

cat <<EOF

relay-kit removido del host. La carpeta ${TARGET_DIR}/.relay/ quedó intacta;
si querés borrarla también, hacelo manualmente:
  rm -rf "${TARGET_DIR}/.relay"
EOF
exit 0
