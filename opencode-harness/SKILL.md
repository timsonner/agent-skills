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

## Pitfalls

- PATH stale after winget — refresh Machine+User Path in the **current** shell.
- Do not share one `--dir` across parallel `opencode run` writers.
- `--auto` skips permission prompts; only use when the task is trusted.
- Product docs live under **`opencode/`** in this repo; this skill is **how to invoke** it.
- Host is PowerShell: do not put Linux `2>/dev/null` in double-quoted strings
  (see **`wsl-containers`** Host PowerShell vs Linux).
