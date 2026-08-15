---
name: copilot-harness
description: >
  Drive the GitHub Copilot CLI (`copilot` / `copilot.exe`) from another agent:
  winget install, one-shot -p/--prompt, continue/resume sessions, models, skills.
  Triggers: "/copilot-harness", GitHub Copilot CLI, copilot -p, copilot.exe.
author: Tim Sonner
license: MIT
---

# Copilot harness (GitHub Copilot CLI)

Prefer **`copilot -p`** from a host agent (no TUI). Use the TUI only with a real PTY.

Verified against **Copilot CLI 1.0.80** (`GitHub.Copilot` via winget). Re-check
`copilot --help` if flags look stale.

Do **not** invent `terminal()` / `process()` APIs. From Grok or PowerShell, call
`copilot.exe`. This skill is the **CLI**. Programmatic JSON-RPC is **`copilot-sdk`**.

## Install (Windows)

```powershell
winget install --id GitHub.Copilot --accept-source-agreements --accept-package-agreements
```

Refresh PATH in **this** process (sessions started before install will not see `copilot`):

```powershell
$env:Path = [System.Environment]::GetEnvironmentVariable('Path','Machine') + ';' +
            [System.Environment]::GetEnvironmentVariable('Path','User')
where.exe copilot
copilot --version
```

Binary typically lands under
`%LOCALAPPDATA%\Microsoft\WinGet\Packages\GitHub.Copilot_*\copilot.exe`.

`GitHub.Copilot` is this **CLI**, not VS Code Copilot Chat.

Auth (once per machine): `copilot login` (browser on a desktop; `--device-code` if
headless). Token env, in order: `COPILOT_GITHUB_TOKEN`, `GH_TOKEN`, `GITHUB_TOKEN`.
Classic `ghp_` PATs are **not** supported — use a fine-grained PAT with
**Copilot Requests**, or an OAuth token from this CLI / `gh`. Enterprise data
residency: `copilot login --host https://<tenant>.ghe.com`.

Logged-in users live in `~/.copilot/config.json` (`lastLoggedInUser`). User knobs
belong in `~/.copilot/settings.json` (not `config.json`). Override the home with
`COPILOT_HOME`.

## Drive from this host (one-shot)

**Tool-using `-p` needs `--allow-all-tools`** (or `COPILOT_ALLOW_ALL=true`,
`--allow-all`, or `--yolo`). Pure Q&A works without it (verified). A write/shell
prompt without the flag **does not hang** — tools are denied and the model
reports “permission restrictions” / cannot write. `-s` / `--silent` prints only
the agent reply (no stats). `--no-ask-user` keeps it from blocking on questions.

```powershell
copilot -p "Your question or task" --allow-all-tools --no-ask-user -s
```

| Flag | Meaning |
|---|---|
| `-p` / `--prompt` | Non-interactive; exits after the turn |
| `-s` / `--silent` | Reply only (scripting) |
| `--model` | Catalog id or `auto` |
| `--effort` / `--reasoning-effort` | `none` \| `minimal` \| `low` \| `medium` \| `high` \| `xhigh` \| `max` |
| `--mode` | `interactive` \| `plan` \| `autopilot` |
| `--plan` | Plan mode (pair with `--mode autopilot` to implement after approve) |
| `-C <dir>` | `chdir` before anything else |
| `--add-dir` | Extra allowed file-access dir (repeatable) |
| `--continue` | Most recent session |
| `-r` / `--resume[=id\|name]` | Picker, or exact name / id / 7+ hex prefix |
| `--session-id` | Resume that UUID, or pin a new session's UUID |
| `-n` / `--name` | Name a new session |
| `--output-format` | `text` (default) \| `json` (JSONL, one object per line) |
| `--stream` | `on` \| `off` |
| `--share[=path]` | Markdown transcript after `-p` (includes Session ID) |
| `--attachment` | Image/doc on the initial `-p` (repeatable) |
| `--no-custom-instructions` | Skip `AGENTS.md` and related files |
| `--enable-memory` | Memory in prompt mode (off by default for `-p`) |
| `--allow-all` / `--yolo` | Tools + all paths + all URLs (dangerous) |
| `--enable-all-github-mcp-tools` | Full GitHub MCP toolset (not the CLI subset) |
| `--disable-builtin-mcps` | Skip `github-mcp-server` |
| `--agent` | Custom agent name (`~/.copilot/agents/<name>.agent.md`) |
| `--acp` | Agent Client Protocol server (not a one-shot) |

History is **per working directory**. `cd` / `-C` first if you need the same thread.
`--continue` and `--resume=<uuid>` both work on `-p` (verified).

```powershell
copilot --continue -p "Follow-up in the same thread" --allow-all-tools --no-ask-user -s
copilot --resume=<session-id> -p "Same thread, pinned id" --allow-all-tools --no-ask-user -s
```

`--output-format json` is **JSONL**. The last object is
`{"type":"result","sessionId":"<uuid>","exitCode":0,"usage":{…}}` — save
`sessionId` and pass `--resume`. Earlier lines include `user.message`,
`assistant.message` (`data.content`), and with `--model auto` a
`session.auto_mode_resolved` event (`chosenModel`, `availableModels`).

Session files: `~/.copilot/session-state/<uuid>/` (`session.db`, `workspace.yaml`
has `id`, `cwd`, `name`). Index: `~/.copilot/session-store.db`. Logs:
`~/.copilot/logs/` (`--log-dir`, `--log-level`).

A built-in `github-mcp-server` connects on every session unless
`--disable-builtin-mcps`. Read-only GitHub identity works with
`--enable-all-github-mcp-tools` (verified: returned the logged-in login).
No extra MCP config is required for that.

`--plan --mode autopilot` **does** land files (verified: `hello.py` printed
`PLAN_AUTO_OK`). A normal tool-using `-p` also writes and can run tests.

`--share=<path>` writes a markdown transcript that includes **Session ID**.
Slash commands (`/env`, `/session`) are **TUI/ACP**, not `-p` — `-p "/env"`
is sent to the model as ordinary text.

Smoke (verified on 1.0.80, this host authenticated):

```powershell
copilot -p "Respond with exactly: COPILOT_SMOKE_OK" --allow-all-tools --no-ask-user -s --model auto
```

Success = stdout contains `COPILOT_SMOKE_OK`.

## Models

Persisted default: `"model"` in `~/.copilot/settings.json`. Catalog:
`copilot help config` (the `model` setting). Override per run with `--model`
or `COPILOT_MODEL`. `auto` lets Copilot pick.

BYOK / offline: `copilot help environment` and `copilot help providers`
(`COPILOT_PROVIDER_BASE_URL`, `COPILOT_OFFLINE=true` needs a local provider).

## Skills / MCP Copilot can see

```powershell
copilot skill list
copilot skill list --json                # stdout JSON; load errors on stderr
copilot skill add <file-or-url>          # copies into ~/.copilot/skills/<name>/
copilot skill add <directory>            # registers a skills tree in settings.json
copilot skill add --project ./foo/SKILL.md
copilot skill remove <name-or-directory>
copilot mcp list
```

`copilot skill add C:\Users\<you>\agent-skills` writes
`skillDirectories` in `~/.copilot/settings.json`. Copilot walks every
`SKILL.md` under that tree.

`name` in frontmatter must be ASCII letters/digits plus `- _ . space`.
A slash (`configure/acp`) **fails to load** (stderr). Other skills in the
same tree still load. Verified: this clone loaded 45 custom + 2 builtin
after add; only `opencode/configure/*` names with `/` were rejected.

Discovery (do not copy this list into other skills):

- Project: `.github/skills/`, `.agents/skills/`, `.claude/skills/`
- Personal: `~/.copilot/skills/`, `~/.agents/skills/`
- Plugin-bundled skills
- Extra trees: `skillDirectories` via `copilot skill add <dir>`

**Invoke a skill** with `--allow-all-tools` so the `skill` tool can run.
`--output-format json` shows `session.skills_loaded` then
`tool.execution_start` / `toolName: skill` / `arguments.skill`.

```powershell
# Explicit (verified: loaded kde-wayland-rdp, answered QPainter / O / 137)
copilot -p "Use the kde-wayland-rdp skill. …" --allow-all-tools --no-ask-user -s

# Inference (verified: Kickoff/titlebar prompt also called skill=kde-wayland-rdp)
copilot -p "Plasma Wayland RDP titlebar close opens Kickoff. …" --allow-all-tools --no-ask-user -s
```

Custom agents: `~/.copilot/agents/<name>.agent.md` (user) or
`.github/agents/` (project). `--agent` is the **filename without**
`.agent.md`. A hard first-line canary proves it stuck; “who are you?”
lets the model answer as generic Copilot (verified: `pentester` ignored
that prompt; `harness-canary` printed `AGENT_CANARY_OK`).

```powershell
Copy-Item .\copilot-harness\agents\harness-canary.agent.md $HOME\.copilot\agents\
copilot --agent harness-canary -p "What is your agent profile name?" --no-ask-user -s
```

Success = first two lines `AGENT_CANARY_OK` / `profile=harness-canary`.
TUI picker: `/agent`. Do not add marketplaces or MCP servers unless asked.

## TUI (human or PTY)

```powershell
copilot
copilot -i "Fix the bug in main.js"
copilot --continue
copilot --resume
copilot --resume=<session-id>
```

Slash list: `copilot help commands`. `/exit` leaves the TUI. `/login` / `/logout`
are interactive.

Need a real PTY. Headless `run_terminal_command` without a TTY is the wrong way
to drive the TUI; use `-p`.

## ACP (drive Copilot as a peer)

`--acp` starts an Agent Client Protocol server (public preview). `--stdio`
is the default (parent owns stdin/stdout NDJSON). `--port N` is **TCP on
127.0.0.1** (not listed in `copilot --help`; verified). Do not pass both.
`--allow-all-tools`, `--model`, `--effort`, `--available-tools` on the
**server** apply to every session; `session/new` only sets `cwd` + MCP.

JSON-RPC 2.0, one object per line. Handshake (verified 1.0.80):

1. `initialize` `{ protocolVersion: 1, clientCapabilities: {}, clientInfo }`
   → `agentInfo.name=Copilot`, `loadSession`, image + embeddedContext,
   MCP http/sse, `sessionCapabilities.close` + `list`.
2. `session/new` `{ cwd, mcpServers: [] }` → `sessionId`,
   `models.availableModels` (ids + `copilotUsage` multipliers), modes.
3. `session/prompt` `{ sessionId, prompt: [{ type: "text", text }] }`
   → `session/update` (`available_commands_update`, `agent_message_chunk`)
   then result `{ stopReason: "end_turn", usage }`.

Slash commands over ACP: send `"/context"` as the prompt text (not `-p`).
TUI-only commands (`/diff`, `/resume`, `/settings`, `/login`) are not ACP.

Need a permission handler if the agent uses tools (`requestPermission`).
Stop the TCP server when done (it outlives the client).

Docs: https://docs.github.com/en/copilot/reference/copilot-cli-reference/acp-server

## Other commands

```powershell
copilot login
copilot init                 # writes .github/copilot-instructions.md
copilot plugin list
copilot update
copilot help [topic]         # config, permissions, environment, logging, …
```

## Pitfalls

- Bare `copilot` (no `-p`) **opens the TUI** and hangs a non-PTY shell. Use
  `copilot --help` and `copilot --version`.
- `-p` without `--allow-all-tools` is fine for Q&A; tool work is denied (no hang).
- `--yolo` / `--allow-all` skip path and URL prompts too; only when the task is trusted.
- PATH stale after winget — refresh Machine+User Path.
- Classic `ghp_` tokens fail; this is not VS Code Copilot Chat.
- Host is PowerShell: do not put Linux `2>/dev/null` in double-quoted strings
  (see **`wsl-containers`**).
- Product JSON-RPC SDK: **`copilot-sdk`**. ACP is **`--acp`** (different protocol).
- `name:` with `/` in a registered skills tree fails that file only.
- `-p "/env"` is not a slash command; use TUI or ACP `session/prompt`.
- `--agent` without a canary in the profile looks like a no-op on identity
  questions. Skill use needs `--allow-all-tools` (tool name `skill`).
- Shared job shape: **`harness-offload`**.
