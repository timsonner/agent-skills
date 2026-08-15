---
name: harness-offload
description: >
  Offload one bounded job to agy, opencode, copilot, codex, or hermes via a shared contract
  (worker, dir, prompt, allow_tools, session). Use when the host agent should
  hand a task to another CLI and get back session_id + stdout. Triggers:
  "/harness-offload", offload contract, Invoke-HarnessOffload.
author: Tim Sonner
license: MIT
---

# Harness offload

Host agent stays orchestrator. One worker, one directory, one prompt, then stop.

Flags and install live in the matching `*-harness` skills. This skill is only
the job shape and the dispatcher.

## Contract

| Field | Meaning |
|---|---|
| `worker` | `agy` \| `opencode` \| `copilot` \| `codex` \| `hermes` |
| `dir` | workspace; sessions are per-dir (defaults to cwd) |
| `prompt` | bounded task |
| `allow_tools` | off = Q&A; on = that worker’s documented auto-approve |
| `session` | omit = new; else resume that worker’s id |
| `model` | optional override |

Result (stdout of the script, one JSON object):

```text
worker, session_id, exit_code, stdout, dir, allow_tools, stderr
```

A failed worker still prints JSON. Check `exit_code` (and `stderr`) before trusting `stdout`.

## Invoke

From the **agent-skills** clone:

```powershell
$env:Path = [System.Environment]::GetEnvironmentVariable('Path','Machine') + ';' +
            [System.Environment]::GetEnvironmentVariable('Path','User')

.\harness-offload\scripts\Invoke-HarnessOffload.ps1 `
  -Worker copilot `
  -Dir <dir> `
  -Prompt "Your bounded task"
```

`-AllowTools` only when the task must write/run. Never default it on.
Do **not** pass `--yolo` / `--auto` / `--dangerously-skip-permissions`
yourself — the script maps `-AllowTools` to the matching flag.

The script appends: do not spawn agy / opencode / copilot / codex / hermes. Do not strip that.

## Rules

1. Caller picks the worker. This is not a model router.
2. One writer per `dir`. Do not fan two workers into the same tree.
3. Resume with the returned `session_id` on the **same** worker + `dir`.
4. Need TUI, ACP, MCP, or install help → the matching `*-harness` skill.

## Smoke

```powershell
$tmp = Join-Path $env:TEMP "harness-offload-smoke"
New-Item -ItemType Directory -Force -Path $tmp | Out-Null
$script = ".\harness-offload\scripts\Invoke-HarnessOffload.ps1"

& $script -Worker agy -Dir $tmp -Prompt "Respond with exactly: AGY_SMOKE_OK"
& $script -Worker opencode -Dir $tmp -Prompt "Respond with exactly: OPENCODE_SMOKE_OK"
& $script -Worker copilot -Dir $tmp -Prompt "Respond with exactly: COPILOT_SMOKE_OK"
& $script -Worker codex -Dir $tmp -Prompt "Respond with exactly: CODEX_SMOKE_OK"
& $script -Worker hermes -Dir $tmp -Prompt "Respond with exactly: HERMES_SMOKE_OK"
```

Each JSON `stdout` must contain that worker’s `*_SMOKE_OK` string and a
non-empty `session_id`. Resume: pass `-Session <session_id>` with a
follow-up prompt on the same `-Dir`.
