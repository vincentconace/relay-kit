---
description: "MASD · Auto-update — re-pull del framework relay-kit desde GitHub. Preserva memoria y features."
argument-hint: ""
---

# /update

Re-pull the latest version of the relay-kit (MASD) framework from GitHub. Updates the host's `commands/relay/`, `agents/relay/`, and `templates/relay/` files in place. **Never touches** `.relay/memory/*` or `.relay/features/*` — your accumulated project knowledge and active feature folders are preserved.

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

## Output

- Framework files in the host directory (`<host>/commands/relay/`, `<host>/agents/relay/`, `<host>/templates/relay/`) overwritten with the latest from `main`.
- A success line: `✓ relay-kit actualizado. Tu memoria y features quedaron intactas.`

## Next step

Continue with the active feature (`/plan`, `/tasks`, `/implement`, `/review`) or start a new one with `/analyze "<task>"`.
