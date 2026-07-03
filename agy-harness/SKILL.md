---
name: agy-harness
description: "Run the Antigravity (Gemini) CLI agent harness via the agy binary. Includes interactive session control and exit handling."
---

# AGY (Antigravity CLI / Gemini CLI)

Use this when you need to offload work to the Antigravity CLI agent harness (`agy`). It is a TUI and requires a PTY. It can be driven from a terminal session with a background PTY and scripted input.

## Prerequisites
- `agy` binary is installed and on PATH.
- You are signed in (first launch may auto-auth via enterprise account).
- Use a PTY for interactive mode.

## Quick Facts (from local run + docs)
- Antigravity CLI is a lightweight TUI harness for the same agent core as Antigravity 2.0.
- It is optimized for terminal-first workflows and works well over SSH/tmux.
- `/help` opens an in-app command list UI; `Esc` exits the picker back to prompt.
- **Help shortcut:** `?` lists slash commands.
- **Clear prompt:** `Esc` `Esc` clears the prompt box (when not streaming).
- **Run shell commands:** prefix with `!` to run a terminal command directly.
- **Path autocomplete:** `@` triggers path suggestions.
- **Artifacts:** use `/artifact` (or `Ctrl+R` in the prompt) to open the Artifact Picker panel.
- **Artifact Picker keybindings:** see `references/cli-overview-notes.md` (arrow keys, h/l, y/n, Shift+A/Shift+R, Enter, Esc, etc.).
- **Settings:** `/config` or `/settings` opens the settings overlay; config file lives at `~/.gemini/antigravity-cli/settings.json`.
- Exiting: **Ctrl+D twice** cleanly exits and prints a resume hint (`agy -c` or `agy --conversation=...`).

## AGY Harness Workflow (quick offload)
Use this subsection when you want to delegate a task to agy as a **sub-agent** in a harness-style workflow.

1. Start agy in background with PTY:
   ```bash
   terminal(command="agy", background=true, pty=true)
   ```
2. Wait for the prompt with `process(action="poll")`.
3. Optional: open help UI, then dismiss if it traps input:
   ```bash
   process(action="submit", session_id=ID, data="/help")
   process(action="wait", session_id=ID, timeout=10)
   process(action="write", session_id=ID, data="\x1b")
   ```
4. Exit **cleanly** by sending **Ctrl+D twice**:
   ```bash
   process(action="write", session_id=ID, data="\x04")
   process(action="write", session_id=ID, data="\x04")
   process(action="wait", session_id=ID, timeout=10)
   ```

**Pitfalls:**
- `/exit` may open a palette; use **Ctrl+D twice**.
- If the help UI traps input, **Esc** returns to the prompt.
- If AGY accepts input but produces no response for a task, exit cleanly and fall back to an automated harness (e.g., `opencode run '<prompt>'`) to get deterministic output.

## Launch (interactive)
Use a background PTY so you can send commands programmatically:

```bash
terminal(command="agy", background=true, pty=true)
# save session_id
```

## Send Commands
```bash
process(action="submit", session_id="<id>", data="/help")
# if the help picker opens, send Esc to close it
process(action="write", session_id="<id>", data="\x1b")
```

## Navigation + Keybindings (high-signal)
- **↑/↓** navigate lists and menus.
- **h / l** or **←/→** switch/toggle focus between inline row buttons (e.g., open/approve/reject) in the Artifact Picker.
- **p** preview the selected file inline in the Artifact Picker.
- **y / n** approve or reject the selected artifact.
- **Shift+A / Shift+R** approve all / reject all pending items.
- **Enter** activates the focused button (e.g., open → Detail Viewer).
- **Esc** exits overlays and returns focus to the prompt (also submits approvals/rejections from Artifact Picker).
- **Esc Esc** clears the prompt box (when not streaming).
- **?** opens the command list / help.
- **Ctrl+R** opens the Artifact Picker (equivalent to `/artifact`).

## Artifacts (Picker + Detail Viewer)
Artifacts let you review plans, diffs, diagrams, and visual assets before changes are applied.

**Open the Picker:** `/artifact` or **Ctrl+R** (prompt box). A status bar hint appears when artifacts exist (`/artifact to review`).

**Artifact Picker (checklist overlay) keybindings:**
- **↑ / ↓** — scroll through list entries.
- **h / l** (or **← / →**) — switch/toggle focus between inline row buttons.
- **p** — preview selected file inline (12-line truncated, indented block).
- **y / n** — approve / reject selected artifact.
- **Shift+A / Shift+R** — approve all / reject all pending artifacts.
- **Enter** — run focused action (open → Detail Viewer).
- **Esc** — save review state, submit approvals/rejections, return to prompt.

**Artifact Detail Viewer:** full-screen review with inline comments and syntax highlighting (and diagram scaling for visuals).

## Conversations (resume, import, fork)
AGY scopes conversation history to the current working directory to prevent context bleed.

**Resume via picker:**
- Run `/resume` → Conversation Picker overlay
- Type to filter by description/ID
- **↑/↓** navigate, **←/→** page, **Enter** resume, **Esc** cancel
- **Tab** switches between **CLI** and **Antigravity** tabs (desktop imports)
- **F2** renames a conversation (in the picker)

**Import from Antigravity 2.0:**
- `/resume` → **Tab** to **Antigravity** → **Enter** to select
- Confirm import with **Enter** (or **y**)

**Quick resume (CLI flags):**
- `agy --continue` (most recent session in current workspace)
- `agy --conversation <uuid>` (resume specific session)

**Fork a conversation:**
- `/fork` (alias: `/branch`) clones the current thread into a new session
- Use `/resume` to return to the original branch
- Note: `/fork` clones conversation history, **not** your git checkout — use git branches for file isolation

## Exit (clean)
AGY expects **Ctrl+D twice**:

```bash
process(action="write", session_id="<id>", data="\x04")
process(action="write", session_id="<id>", data="\x04")
```

If still stuck, use `process(action="kill", session_id="<id>")` as a last resort.

## Example: Help → Exit
```bash
terminal(command="agy", background=true, pty=true)
# session_id = ...
process(action="submit", session_id="<id>", data="/help")
process(action="write", session_id="<id>", data="\x1b")
process(action="write", session_id="<id>", data="\x04")
process(action="write", session_id="<id>", data="\x04")
```

## Troubleshooting
- If `/help` appears to open a searchable list and you get "No matches", press **Esc** to return to the prompt.
- If the process doesn’t exit after `/exit`, use **Ctrl+D twice**.
- If the TUI freezes, send `Ctrl+C` (`\x03`) or kill the process.
- **Idle/non‑responsive session:** if AGY accepts input but produces no response after a reasonable wait, exit cleanly (Ctrl+D twice) and fall back to a one‑shot `opencode run` for the requested plan/commands.
- If agy accepts input but produces no response, send a short follow-up prompt (e.g., "respond now") and wait; if it stays idle, exit with **Ctrl+D twice** and relaunch, or fall back to a non-interactive run command for deterministic output.

## Verification
- `process(action="wait", session_id="<id>")` returns `status: exited` and `exit_code: 0`.
- Exit message shows `Resume: agy -c` or `agy --conversation=<id>`.
