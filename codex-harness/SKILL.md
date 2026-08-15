---
name: codex-harness
description: >
  Drive the OpenAI Codex CLI (`codex` / `codex exec`) from another agent:
  official Windows installer, one-shot exec --json, resume, sandbox.
  Triggers: "/codex-harness", Codex CLI, codex exec.
author: Tim Sonner
license: MIT
---

# Codex harness (OpenAI Codex CLI)

Prefer **`codex exec`** from a host agent (no TUI). Use the TUI only with a real PTY.

Verified against **codex-cli 0.147.0** via the official Windows installer.
Re-check `codex exec --help` if flags look stale.

Do **not** invent `terminal()` / `process()` APIs. From Grok or PowerShell, call
`codex`. Shared job shape: **`harness-offload`**. Not the ChatGPT desktop app
(`codex app`). Do **not** install winget `OpenAI.Codex` or `jcv8000.Codex`.

## Install (Windows)

```powershell
$env:CODEX_NON_INTERACTIVE = '1'   # skip "Start Codex now?"
powershell -ExecutionPolicy Bypass -c "irm https://chatgpt.com/codex/install.ps1 | iex"
```

That writes `codex.exe` **and** `codex-code-mode-host.exe` to
`%LOCALAPPDATA%\Programs\OpenAI\Codex\bin` (junction into
`~/.codex/packages/standalone/current/bin`) and prepends that dir to User PATH.
`codex update` works on this layout.

Refresh PATH in **this** process, then:

```powershell
$env:Path = [System.Environment]::GetEnvironmentVariable('Path','Machine') + ';' +
            [System.Environment]::GetEnvironmentVariable('Path','User')
where.exe codex
codex --version
```

There is no `codex-cli` command. Use `codex`.

## Auth

ChatGPT device login (desktop / headless):

```powershell
codex login --device-auth
# open https://auth.openai.com/codex/device and enter the one-time code
codex login status
codex doctor --summary
```

API key (automation; do not persist in skills). `CODEX_API_KEY` is honored on
**`codex exec`**. ChatGPT login may still require a paid plan that includes
Codex. `--oss` is local (`lmstudio` / `ollama`), not ChatGPT.

Home: `~/.codex/` (`CODEX_HOME`). Do not commit `auth.json`.

## Drive from this host (one-shot)

This machine is **host-native**. `~/.codex/config.toml`:

```toml
sandbox_mode = "danger-full-access"
approval_policy = "never"
```

Do **not** set `[windows] sandbox = "unelevated"` or `"elevated"` — those pick a
Windows restricted-token sandbox, not “run as me.” Stock `exec` with no user
config is read-only; **this host is not stock.** `Invoke-HarnessOffload
-AllowTools` passes `--sandbox danger-full-access`.

`codex exec` prints the final message on stdout, progress on stderr. `--json`
is JSONL. Non-git cwd needs `--skip-git-repo-check` or exec refuses.

```powershell
codex exec --json --skip-git-repo-check -C <dir> "Your question or task"
```

| Flag | Meaning |
|---|---|
| `exec` / `e` | Non-interactive |
| `--json` | JSONL events on stdout |
| `-o` / `--output-last-message` | Also write the final text |
| `-C` / `--cd` | Workspace root (not valid on `exec resume`) |
| `-m` / `--model` | Model id |
| `-s` / `--sandbox` | `read-only` \| `workspace-write` \| `danger-full-access` |
| `--approve-for-me` | Auto-reviewed approvals (0.147+) |
| `--dangerously-bypass-approvals-and-sandbox` | Per-run unsandbox (this host already is) |
| `--skip-git-repo-check` | Allow a non-git dir |
| `--ephemeral` | Do not persist session files |
| `--output-schema` | Constrain the final message |
| `--search` | Enable web search |

`-a` / `--ask-for-approval` is **TUI only**. Passing it to `exec` errors.
`--full-auto` is gone (0.147).

`codex debug models` (this account): `gpt-5.6-terra`, `gpt-5.6-luna`,
`gpt-5.5`, `gpt-5.4-mini`, `codex-auto-review`.

Resume:

```powershell
codex exec resume --json --skip-git-repo-check <session-id> "Follow-up"
codex exec resume --last --json --skip-git-repo-check "Follow-up"
```

`--json` includes `thread.started.thread_id` — that is the resume id.

```json
{"type":"thread.started","thread_id":"<uuid>"}
{"type":"item.completed","item":{"type":"agent_message","text":"…"}}
{"type":"turn.completed","usage":{…}}
```

Smoke:

```powershell
codex exec --json --skip-git-repo-check -C <dir> "Respond with exactly: CODEX_SMOKE_OK"
```

Success = an `agent_message` whose `text` contains `CODEX_SMOKE_OK`.

## TUI (human or PTY)

```powershell
codex
codex resume --last
codex resume <session-id>
```

Bare `codex` **opens the TUI** and hangs a non-PTY shell. Use `codex --help`
and `codex exec`.

## Structured output / review / MCP

`--output-schema <schema.json>` + `-o out.json` constrains the final message
(verified: `{"token":"SCHEMA_OK","ok":true}`).

```powershell
codex review --uncommitted          # git repo; do not also pass a prompt arg
codex review --base main
codex review --commit <sha>
```

`--uncommitted` cannot take a prompt argument (including `-` / stdin).
Verified: flagged a wrong `add()` as P1.

`codex mcp-server` is stdio MCP (`protocolVersion` 2024-11-05). Tools:

| Tool | Role |
|---|---|
| `codex` | New session. Required `prompt`. Optional `cwd`, `model`, `sandbox`, `approval-policy`. Returns `threadId` + `content`. |
| `codex-reply` | Continue. `prompt` + `threadId` (legacy `conversationId`). |

That is the peer offload path (same job as `exec` / `exec resume`).

Bundled skills live under `~/.codex/skills/.system/` (`openai-docs`,
`review-agent`, `skill-creator`, …). `codex debug prompt-input` shows them
injected as `<skills_instructions>`.

## Other commands

```powershell
codex login status
codex logout
codex mcp list                 # none configured on this host
codex plugin list              # openai-curated marketplace; install only if asked
codex features list
codex debug models             # JSON catalog
codex doctor --summary
codex update
```

## Pitfalls

- Official installer only — not winget `OpenAI.Codex` / `jcv8000.Codex`.
- Do not `--disable code_mode_host` — file tools fail closed.
- Non-git cwd needs `--skip-git-repo-check`.
- `--json` makes stdout JSONL; parse it or use `-o`.
- `exec resume` does not take `-C`; `cd` first (the dispatcher already does).
- Host is PowerShell: do not put Linux `2>/dev/null` in double-quoted strings
  (see **`wsl-containers`**).
- Offload: **`harness-offload`**. MCP peer: `codex mcp-server`.
