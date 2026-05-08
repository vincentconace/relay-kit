---
description: "MASD · Auto-update — re-pull del framework relay-kit desde GitHub. Preserva memoria y features."
argument-hint: ""
---

# /update

Re-pull the latest version of the relay-kit (MASD) framework from GitHub. Updates **every host detected** on the machine (Claude Code, Antigravity, Cowork) by overwriting their `commands/relay/`, `agents/relay/`, and `templates/relay/` directories. **Never touches** `.relay/memory/*` or `.relay/features/*` — your accumulated project knowledge and active feature folders are preserved.

## Invocation

Run the following in the project root and report the full output back to the user:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/vincentconace/relay-kit/main/update.sh)
```

If the host blocks process substitution, fall back to:

```bash
curl -fsSL https://raw.githubusercontent.com/vincentconace/relay-kit/main/update.sh | bash
```

If `update.sh` is already present locally at the project root, prefer:

```bash
bash update.sh
```

### Targeting a specific host

By default the updater installs into every host present on the machine. To force a single host:

```bash
bash update.sh --host claude        # only ~/.claude
bash update.sh --host antigravity   # only ~/.agents
bash update.sh --host cowork        # only ~/.config/cowork
bash update.sh --host claude,antigravity   # both
```

Use this if a previous install ended up in the wrong host folder (e.g. files landed in `~/.agents/` when you expected `~/.claude/`) — re-run with `--host claude` to correct it.

## Output

- Framework files in each host directory (`<host>/commands/relay/`, `<host>/agents/relay/`, `<host>/templates/relay/`) overwritten with the latest from `main`.
- A success line: `✓ relay-kit actualizado. Tu memoria y features quedaron intactas.`

## Next step

Continue with the active feature (`/plan`, `/tasks`, `/implement`, `/review`) or start a new one with `/analyze "<task>"`.
