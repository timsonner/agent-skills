---
name: opencode-harness
description: "Run the OpenCode CLI harness for coding tasks from a terminal session with interactive PTY support (harness-only)."
author: Tim Sonner
license: MIT
---

# OpenCode Harness (CLI/TUI)

Use this when you want to offload coding tasks to the **OpenCode** CLI harness (`opencode`) from a terminal session using PTY-backed interactive control. This is the **harness-only** workflow (no deep product docs).

## Prerequisites
- `opencode` is installed and on PATH.
- Auth is configured (e.g., `opencode auth login` or provider env vars).
- Use **pty=true** for interactive TUI sessions.

## Launch (interactive)
Use a background PTY so you can send commands programmatically:

```bash
terminal(command="opencode", background=true, pty=true, workdir="/path/to/repo")
# save session_id
```

## Send Prompts
```bash
process(action="submit", session_id="<id>", data="Implement OAuth refresh flow and add tests")
process(action="poll", session_id="<id>")
process(action="log", session_id="<id>")
```

## Exit (clean)
OpenCode does **not** support `/exit` (it opens an agent selector). Use Ctrl+C:

```bash
process(action="write", session_id="<id>", data="\x03")
# or: process(action="kill", session_id="<id>")
```

## One‑Shot Tasks (no TUI)
```bash
terminal(command="opencode run 'Refactor auth module and update tests'", workdir="/path/to/repo")
```

## Keybindings (TUI)
- **Enter**: submit message (press twice if needed)
- **Tab**: switch agents (build/plan)
- **Ctrl+P**: command palette
- **Ctrl+X L**: switch session
- **Ctrl+X M**: switch model
- **Ctrl+X N**: new session
- **Ctrl+X E**: open editor
- **Ctrl+C**: exit

## Resume Sessions
```bash
terminal(command="opencode -c", background=true, pty=true, workdir="/path/to/repo")
terminal(command="opencode -s <session_id>", background=true, pty=true, workdir="/path/to/repo")
```

## Verification
```bash
terminal(command="opencode run 'Respond with exactly: OPENCODE_SMOKE_OK'")
```
Success = output includes `OPENCODE_SMOKE_OK`.

## Pitfalls
- Interactive TUI **requires** `pty=true`.
- `/exit` is **not** valid; use **Ctrl+C**.
- Avoid sharing one workdir across parallel OpenCode sessions.
- If the TUI appears stuck, inspect logs before killing:
  `process(action="log", session_id="<id>")`.
