---
name: agy-harness
description: >
  Drive the Antigravity (Gemini) CLI (`agy` / `agy.exe`) from another agent:
  winget install, one-shot --print, continue conversations, models.
  Triggers: "/agy-harness", agy, antigravity, gemini cli.
author: Tim Sonner
license: MIT
---

# AGY harness (Antigravity / Gemini CLI)

Prefer **`agy --print`** from a host agent (no TUI). Use the TUI only with a real PTY.

Verified against **agy 1.1.13** (`Google.AntigravityCLI`). Re-check `agy --help`
if flags look stale. Binary: `%LOCALAPPDATA%\agy\bin\agy.exe`.

Do **not** invent `terminal()` / `process()` APIs. From Grok or PowerShell, call `agy.exe`.

## Install (Windows)

```powershell
winget install --id Google.AntigravityCLI --accept-source-agreements --accept-package-agreements
```

Refresh PATH in **this** process (sessions started before install will not see `agy`):

```powershell
$env:Path = [System.Environment]::GetEnvironmentVariable('Path','Machine') + ';' +
            [System.Environment]::GetEnvironmentVariable('Path','User')
where.exe agy
agy --version
```

`Google.Antigravity` is the **desktop** IDE, not this CLI. After install you can run
`agy install` to append PATH/aliases in the shell profile.

Auth: first launch may use the enterprise Google account. Optional direct API:
`GEMINI_API_KEY` plus `"modelProvider": "gemini"` in
`~/.gemini/antigravity-cli/settings.json` (see `agy changelog`).

Settings file: `~/.gemini/antigravity-cli/settings.json`.

Headless `--print` cannot prompt. Tools that need confirmation are **soft-denied**
(stderr `jetski: … auto-denied`, exit 0, empty stdout). Workspace reads are
supposed to be auto-allowed; in practice ListDir/`read_file` still asks, so
print mode dies unless `permissions.allow` has the rule.

Keep this **read-only** allowlist in settings (dispatcher also merges it):

```json
{
  "allowNonWorkspaceAccess": true,
  "permissions": {
    "allow": [
      "read_file(*)",
      "command(*)"
    ]
  }
}
```

`command(*)` is required because print-mode AGY prefers Bash (`Get-Location`,
`(Get-Location).Path`, …) and prefix allow-rules never cover the next
expression. Do **not** add `write_file(*)` — writes stay behind
`--dangerously-skip-permissions` / `-AllowTools`.

## Drive from this host (one-shot)

**`--print` consumes the next argument as the prompt.** Put the message immediately
after `--print` / `-p` / `--prompt`. Flags after `--print` become the prompt text
and Gemini just greets you.

```powershell
agy --model gemini-3.7-flash-medium --print "Your question or task"
```

| Flag | Meaning |
|---|---|
| `-p` / `--print` / `--prompt` | Non-interactive; stdout is the reply |
| `--model` | e.g. `gemini-3.7-flash-medium` |
| `--effort` | `low` \| `medium` \| `high` |
| `--mode` | `accept-edits` \| `plan` |
| `--agent` | Agent for this session |
| `-c` / `--continue` | Last conversation in this workspace |
| `--conversation <id>` | Resume a specific conversation |
| `--print-timeout` | Default 5m |
| `--output-format` | `text` \| `json` \| `stream-json` |
| `--disable-slash-commands` | No skill/slash expansion in print mode |
| `--sandbox` | Restrict terminal tools |
| `--dangerously-skip-permissions` | Auto-approve tools (dangerous) |
| `--add-dir` | Extra workspace dir (repeatable) |

History is **scoped to the current working directory**. `cd` first if you need
the same thread. `-c` is last conversation in that dir.

```powershell
agy --continue --print "Follow-up in the same thread"
agy --conversation <uuid> --print "Same thread, pinned id"
```

`--output-format json` includes `conversation_id` — save that and pass `--conversation`.
`--json-schema <file.json>` + `--output-format json` fills `structured_output` (verified).

`--mode plan` writes a plan artifact under `~/.gemini/antigravity-cli/brain/<id>/`
and does **not** create the planned file in cwd (verified: empty folder stayed empty).
`--sandbox` exists; this host already sandboxes terminal tools by default.
`--effort low|medium|high` is accepted on print runs.

Smoke:

```powershell
agy --print "Respond with exactly: AGY_SMOKE_OK"
```

Success = stdout contains `AGY_SMOKE_OK`.

## Models

```powershell
agy models
```

Seen on 1.1.13: `gemini-3.7-flash-{high,medium,low}`, `gemini-3.6-flash-*`,
`gemini-3.5-flash-*`, `gemini-3.1-pro-{high,low}`, `claude-sonnet-4-6`,
`claude-opus-4-6-thinking`, `gpt-oss-120b-medium`.

`agy agents` / `agy agent` lists custom agents (may be empty).

## TUI (human or PTY)

```powershell
agy
agy --continue
agy --conversation <uuid>
```

- **?** or `/help` — slash list (`Esc` closes the picker)
- **Esc Esc** — clear prompt (when not streaming)
- **!** — run a shell command
- **@** — path autocomplete
- `/artifact` or **Ctrl+R** — Artifact Picker
- `/resume` — conversation picker (CLI vs Antigravity desktop import)
- `/fork` (`/branch`) — clone thread (not git)
- `/config` or `/settings` — overlay
- **Ctrl+D twice** — clean exit (`agy -c` / `--conversation=` resume hint)
- `/exit` may open a palette — prefer Ctrl+D twice

Artifact picker: ↑/↓, h/l, p preview, y/n, Shift+A / Shift+R, Enter, Esc.

Need a real PTY. Headless `run_terminal_command` without a TTY is the wrong way
to drive the TUI; use `--print`.

## Other commands

```powershell
agy changelog
agy plugin list
agy update
agy install          # PATH / aliases
```

## Pitfalls

- Bare `agy`, `agy help`, or `agy version` (no `--`) can **open the TUI** and hang
  a non-PTY shell. Use `agy --help` and `agy --version`.
- `--print --model foo "hi"` treats `--model` as the prompt. Flags **before** `--print`.
- PATH stale after winget — refresh Machine+User Path.
- `--dangerously-skip-permissions` skips tool prompts; only when the task is trusted.
- Recurring `jetski` / `read_file` / `command` auto-deny in `--print`: missing
  `permissions.allow` in `~/.gemini/antigravity-cli/settings.json`. Add
  `read_file(*)` and `command(*)`. Do not “fix” it by always passing
  `--dangerously-skip-permissions` (that also auto-approves writes).
- If print mode is idle, fall back to **`opencode run`** for a deterministic one-shot.
- Host is PowerShell: do not put Linux `2>/dev/null` in double-quoted strings
  (see **`wsl-containers`**).
- Product docs: **`opencode/`** is a different harness. This skill is **agy only**.
- Shared job shape: **`harness-offload`**.
