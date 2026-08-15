---
name: hermes-harness
description: >
  Drive the Nous Hermes Agent CLI (`hermes`) from another agent: official
  install.ps1, one-shot -z / chat -q -Q, resume, --yolo, ACP/MCP.
  Triggers: "/hermes-harness", Hermes CLI, hermes -z, Nous Research hermes.
author: Tim Sonner
license: MIT
---

# Hermes harness (Nous Hermes Agent)

Prefer **`hermes -z`** or **`hermes chat -q -Q`** from a host agent (no TUI).
Use the TUI / classic REPL only with a real PTY.

Verified against **Hermes Agent v0.20.0** (native Windows, official installer).
Re-check `hermes --help` if flags look stale.

Do **not** invent `terminal()` / `process()` APIs. Call `hermes`. Shared job
shape: **`harness-offload`**. Messaging gateway / Buzz: **`buzz-hermes-gateway`**.

## Install (Windows)

```powershell
iex (irm https://hermes-agent.nousresearch.com/install.ps1)
```

Lives under `%LOCALAPPDATA%\hermes` (`config.yaml`, `.env`, `hermes-agent` checkout,
venv `Scripts\hermes.exe`). WSL/Linux uses `~/.hermes` and
`curl -fsSL https://hermes-agent.nousresearch.com/install.sh | bash`.

Refresh PATH, then `hermes --version`. `hermes setup` / `hermes model` pick the
provider. This host: **xAI Grok OAuth**, model `grok-build-0.1`.

Config path: `hermes config path`. Do not commit `.env` or `auth.json`.

## Drive from this host (one-shot)

Two script modes:

| Mode | Stdout | Session id | Approvals |
|---|---|---|---|
| `hermes -z "…"` | Final text only | Hidden (still stored) | Auto-bypassed |
| `hermes chat -q "…" -Q` | Final text | `session_id:` on **stderr** | Use `--yolo` for tools |

`Invoke-HarnessOffload -Worker hermes` uses **`chat -q -Q`** so it can return
`session_id`. Use `-z` when you only need the reply.

```powershell
hermes -z "Respond with exactly: HERMES_SMOKE_OK"
hermes chat -q "Respond with exactly: HERMES_CHAT_OK" -Q
```

History is **per cwd**. `cd` first. Resume:

```powershell
hermes -z "Follow-up" --resume <session_id>
hermes chat -q "Follow-up" -Q --resume <session_id>
hermes -c                         # most recent
```

Session ids look like `20260815_040545_f2d37d`. List:
`hermes sessions list --workspace <dir> --limit 10`.

| Flag | Meaning |
|---|---|
| `-z` / `--oneshot` | Script: final text only |
| `chat -q` / `--query` | One query (pair with `-Q`) |
| `-Q` / `--quiet` | Suppress banner/spinner; keep `session_id:` |
| `--resume` / `-r` | Resume by id |
| `-c` / `--continue` | Resume by name, or latest |
| `-m` / `--model` | Override (e.g. `grok-build-0.1`) |
| `--provider` | Override provider |
| `--yolo` | Bypass dangerous-command prompts |
| `--accept-hooks` | Auto-approve unseen hooks (CI / headless) |
| `--skills` / `-s` | Preload skill names |
| `--ignore-rules` | Skip AGENTS.md / memory / preloaded skills |
| `--usage-file` | Write JSON usage after `-z` |

Verified: `-z` → `HERMES_SMOKE_OK`; `chat -q -Q` prints `session_id:`; both
`--resume` paths work; `chat -q -Q --yolo` wrote `smoke.txt` = `WRITE_OK`.
`-Q` still prints a file-diff preview on writes.

## TUI / REPL (human or PTY)

```powershell
hermes            # default interface (often TUI)
hermes --tui
hermes --cli      # classic REPL
```

Bare `hermes` **opens a UI** and hangs a non-PTY shell. Use `-z` or `chat -q`.

## ACP / MCP

```powershell
hermes acp --check          # verified OK on this host
hermes acp                  # ACP stdio for editors
hermes mcp serve            # Hermes as an MCP server
hermes mcp list
```

Do not add MCP servers or plugins unless asked.

## Other commands

```powershell
hermes status
hermes doctor
hermes model
hermes auth list
hermes config path
hermes sessions list
hermes update
hermes gateway            # messaging — see buzz-hermes-gateway
```

## Pitfalls

- Windows home is **`%LOCALAPPDATA%\hermes`**, not `~/.hermes`.
- `-z` does not print `session_id`; use `chat -q -Q` or `sessions list`.
- `--yolo` only on `chat` / TUI; `-z` already auto-bypasses approvals.
- Gateway/Buzz is **`buzz-hermes-gateway`**, not this skill.
- Host is PowerShell: do not put Linux `2>/dev/null` in double-quoted strings
  (see **`wsl-containers`**).
- Offload: **`harness-offload`**.
