---
name: opencode-harness
description: >
  Drive the OpenCode CLI (`opencode`) from another agent or terminal: install,
  one-shot `opencode run`, TUI, models (including opencode/big-pickle), agents.
  Windows winget SST.opencode. Triggers: "/opencode-harness", opencode, big pickle.
author: Tim Sonner
license: MIT
---

# OpenCode harness (CLI)

Offload a coding or Q&A task to the **OpenCode** binary. Prefer **`opencode run`**
from a host agent (no TUI). Use the TUI only when you have a real interactive PTY.

Verified against **opencode 1.18.x** (`SST.opencode` via winget). Re-check
`opencode --help` if flags look stale.

## Install

**Windows (recommended):**

```powershell
winget install --id SST.opencode --accept-source-agreements --accept-package-agreements
```

Refresh **this process** PATH after install (a session started before winget will not see it):

```powershell
$env:Path = [System.Environment]::GetEnvironmentVariable('Path','Machine') + ';' +
            [System.Environment]::GetEnvironmentVariable('Path','User')
where.exe opencode
opencode --version
```

Binary typically lands under
`%LOCALAPPDATA%\Microsoft\WinGet\Packages\SST.opencode_*\opencode.exe`.

Other methods (script, npm, brew, scoop, choco): product skill **`opencode/install`**.
Desktop app id is `SST.OpenCodeDesktop` — that is **not** this CLI.

Auth: `opencode providers login` (alias `opencode auth login`) or provider env vars.

## Drive from this host (one-shot)

Do **not** invent `terminal()` / `process()` APIs. From Grok or PowerShell:

```powershell
opencode run --model opencode/big-pickle --dir <repo> "Your question or task"
```

Useful flags (`opencode run --help`):

| Flag | Meaning |
|---|---|
| `-m` / `--model` | `provider/model` (e.g. `opencode/big-pickle`) |
| `--agent` | `build` (default), `plan`, … — `opencode agent list` |
| `--dir` | Project directory |
| `-c` / `--continue` | Continue last session |
| `-s` / `--session` | Continue a session id |
| `--auto` | Auto-approve permissions (dangerous) |
| `--format json` | Raw events |
| `--thinking` | Show thinking blocks |

List models: `opencode models`. Free OpenCode-hosted ids include `opencode/big-pickle`.

Smoke:

```powershell
opencode run --model opencode/big-pickle "Respond with exactly: OPENCODE_SMOKE_OK"
```

Success = stdout contains `OPENCODE_SMOKE_OK`.

## TUI (human or PTY)

```powershell
opencode <project>          # default
opencode -c                 # continue last
opencode -s <session_id>
```

- **Enter**: submit (twice if needed)
- **Tab**: switch agents
- **Ctrl+P**: command palette
- **Ctrl+X** then **M** / **N** / **L**: model / new / sessions
- **Ctrl+C**: exit — `/exit` is **not** a quit command (opens an agent picker)

Need a real PTY. A headless `run_terminal_command` without a TTY is the wrong way to
drive the TUI; use `opencode run` instead.

## Models

```powershell
opencode models                 # ids
opencode models --verbose       # cost, context, capabilities
opencode models opencode        # filter by provider
```

Per-run switch: `-m provider/model`. TUI: **Ctrl+X** then **M**.
Default in `~/.config/opencode/opencode.jsonc`: `"model": "opencode/big-pickle"`.
Schema: https://opencode.ai/config.json — invalid config **refuses to start**.
Restart OpenCode after editing config (not hot-reloaded).

`opencode models xai` fails until `opencode providers login`. Zen free models
need no local `auth.json` on this host.

## Sessions and stats

Sessions are **per project directory**. List from that dir:

```powershell
Set-Location <repo>
opencode session list -n 15
opencode export <sessionID> --sanitize    # JSON; redacts paths/titles
opencode stats --days 7 --models --project ""
```

`-c` = last session in that dir (wrong if something else ran). Prefer `-s <id>`.
`--fork` copies instead of appending. DB: `opencode db path`
(`~\.local\share\opencode\opencode.db`).

## Headless HTTP server

```powershell
opencode serve --port 4096 --hostname 127.0.0.1
# GET http://127.0.0.1:4096/global/health  → { healthy, version }
# GET http://127.0.0.1:4096/               → HTML
opencode attach http://127.0.0.1:4096
opencode run --attach http://localhost:4096 --model opencode/big-pickle --dir <repo> "…"
```

Verified: `GET /global/health` → `{ healthy: true, version }` and
`opencode run --attach http://127.0.0.1:4097` returned `ATTACHED_OK`.
**Stop the server when done** (`kill` the `opencode serve` process).
Set `OPENCODE_SERVER_PASSWORD` if the port is reachable beyond this box.
Docs: https://opencode.ai/docs/server/

## MCP / plugins / skills OpenCode can see

```powershell
opencode mcp list
opencode mcp add [name] [--url …]   # interactive-ish; do not add unless asked
opencode plugin <npm-module> [-g]
opencode debug skill          # skills OpenCode loaded
opencode debug paths          # data/config/cache
opencode debug config         # resolved config
```

OpenCode auto-loads `~/.claude/skills/*/SKILL.md` (and `~/.agents/skills`).
That tree can be **stale** vs `agent-skills` / `~/.grok/skills` (e.g. still
`browser-read-bypass`). Point it at the clone:

```jsonc
// ~/.config/opencode/opencode.jsonc
{
  "$schema": "https://opencode.ai/config.json",
  "skills": { "paths": ["C:/Users/<you>/agent-skills"] }
}
```

Do not put API keys in committed jsonc.

## Pitfalls

- PATH stale after winget — refresh Machine+User Path in the **current** shell.
- Do not share one `--dir` across parallel `opencode run` writers.
- `--auto` skips permission prompts; only use when the task is trusted.
- Product docs live under **`opencode/`** in this repo; this skill is **how to invoke** it.
- Host is PowerShell: do not put Linux `2>/dev/null` in double-quoted strings
  (see **`wsl-containers`** Host PowerShell vs Linux).
- `opencode serve` without `OPENCODE_SERVER_PASSWORD` prints **unsecured**.
- `debug skill` may show old copies under `~/.claude/skills` — prefer `skills.paths`
  to **`agent-skills`**.
- Shared job shape: **`harness-offload`**.
