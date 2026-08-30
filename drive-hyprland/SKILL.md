---
name: drive-hyprland
description: >
  Drive a live Hyprland desktop on the local Linux session: list and focus
  windows, switch workspaces, move the cursor, click (ydotool), type (wtype),
  screenshot, and open URLs. Use when the user wants to click around the
  desktop, switch workspace, focus an app, type into a window, take a window
  screenshot, open a site, navigate the compositor, or runs /drive-hyprland.
  Not for editing Hyprland config. Not the Windows/RDP workstation-drive loop.
author: Tim Sonner
license: MIT
---

# Drive Hyprland

Operate the **local** Hyprland compositor (Lua config, Hyprland 0.55+). This is
the Linux counterpart of `windows-ui-inject`. It is **not**
`agent-workstation-drive` (that loop is Windows mstsc + a GNOME/KDE container).

Helper (next to this file): `scripts/hypr-drive`  
After harness install: `~/.grok/skills/drive-hyprland/scripts/hypr-drive`

Legacy `hyprctl dispatch workspace 5` / `focuswindow address:0x…` **fails** on
Lua config. Always dispatch Lua. `hl.dsp.*` returns a **dispatcher table** and
does nothing until `hl.dispatch(...)`.

## Setup (host)

Needs: Hyprland session, `hyprctl`, `python3`, `grim`. Clicks need `ydotool` +
`ydotoold`. Typing needs `wtype`.

```bash
# from this skill directory (clone of agent-skills)
./scripts/install.sh host
./scripts/install.sh verify
```

What `install.sh host` does (and what you must run with sudo when it prints):

1. Packages: `ydotool` `wtype` `grim` (`omarchy pkg add` if present, else `pacman -S`).
2. User in group `input` (`sudo usermod -aG input "$USER"` — **re-login** if newly added).
3. `/dev/uinput` → `0660 root:input`. The package ships
   `/usr/lib/udev/rules.d/80-uinput.rules` but the node often boots as
   `root:root 600`. `udevadm trigger --name-match=uinput` may print
   `Invalid argument`; `chgrp`/`chmod` is the reliable fix.
4. `systemctl --user enable --now ydotool.service`
5. Socket: `$XDG_RUNTIME_DIR/.ydotool_socket` (dotfile; `ls -l` that path).

Manual equivalent:

```bash
# packages
omarchy pkg add ydotool wtype grim   # or: sudo pacman -S --needed ydotool wtype grim

sudo usermod -aG input "$USER"       # then log out/in if this is new
sudo udevadm control --reload
sudo chgrp input /dev/uinput
sudo chmod 0660 /dev/uinput
ls -l /dev/uinput                    # expect crw-rw---- root input

systemctl --user reset-failed ydotool.service
systemctl --user enable --now ydotool.service
ls -l "$XDG_RUNTIME_DIR/.ydotool_socket"
```

`ydotoold` logs `Permission denied` on `/dev/uinput` until step 3. After chmod,
`reset-failed` then `enable --now` if it hit start-limit.

## Install (harness)

Point the harness at this clone, **or** symlink the skill folder:

```bash
./scripts/install.sh harness          # ~/.grok/skills, ~/.claude/skills, ~/.cursor/skills
./scripts/install.sh harness grok     # Grok only
```

Preferred Grok load-from-clone (no copy):

```toml
# ~/.grok/config.toml
[skills]
paths = ["~/agent-skills"]
```

`install.sh harness` creates a **symlink** to this folder so the clone stays
source of truth.

## Inspect

```bash
./scripts/hypr-drive windows
./scripts/hypr-drive workspaces
./scripts/hypr-drive monitors
./scripts/hypr-drive active
```

`hyprctl clients -j`: `class`, `title`, `pid`, `address`, `at` `[x,y]`, `size`
`[w,h]`, `workspace.id` / `.name`, `monitor`, `mapped`, `hidden`, `floating`,
`xwayland`. `at` can be **negative** (monitor left of origin).

## Mutate (verified)

Switch workspace (`change_id` **renames** an id; do not use it to switch):

```bash
hyprctl dispatch 'hl.dsp.focus({ workspace = 1 })'
# or
hyprctl repl 'return hl.dispatch(hl.dsp.focus({ workspace = 1 }))'
```

Focus:

```bash
./scripts/hypr-drive focus-class google-chrome
./scripts/hypr-drive focus-title 'timsonner.com'
./scripts/hypr-drive focus-workspace 1
```

Cursor (layout coords, same space as `at`):

```bash
./scripts/hypr-drive cursor -100 200
```

URL in the existing Chrome/Chromium session (not omnibox typing):

```bash
./scripts/hypr-drive open-url https://example.com
```

Screenshot (grim; negative geometry is valid):

```bash
./scripts/hypr-drive screenshot-class google-chrome
```

Scratchpad: `hyprctl dispatch 'hl.dsp.workspace.toggle_special("scratchpad")'`  
Launch: `hyprctl dispatch 'hl.dsp.exec_cmd("ghostty")'`  
Close: `hl.dispatch(hl.dsp.window.close({ window = w }))`

## Click and type

**Pointer:** move with Hyprland layout coords, then click at the current
pointer. Do **not** `ydotool mousemove --absolute` with Hyprland `at` values
(multi-monitor origin ≠ ydotool origin).

```bash
./scripts/hypr-drive cursor -803 313
./scripts/hypr-drive click left
```

Click codes: left `0xC0`, right `0xC1`, middle `0xC2`.

**Keyboard:** `wtype` (`zwp_virtual_keyboard_v1`) on Hyprland. Focus first.

```bash
./scripts/hypr-drive focus-class google-chrome
./scripts/hypr-drive type 'hello'
./scripts/hypr-drive key Return
./scripts/hypr-drive combo ctrl+l
```

Prefer app IPC (`open-url`, `exec_cmd`) over synthesizing Chrome Ctrl+L.

Related: `~/claude-screen-agent/actuator.py` (`YdotoolActuator`) for evdev
keycodes if you need `ydotool key` (GNOME; optional here). Super = 125.

## Do not

- `hyprctl dispatch workspace 5` or `focuswindow address:0x…`
- Call `hl.dsp.focus(...)` without `hl.dispatch`
- Use `hl.dsp.workspace.change_id` to switch workspaces
- Edit `~/.config/hypr/` from this skill
- Drive this session with `agent-workstation-drive` / `windows-ui-inject`

## Dispatchers

Wiki: https://wiki.hypr.land/Configuring/Basics/Dispatchers/

| Goal | Call |
|---|---|
| Workspace | `hl.dsp.focus({ workspace = N })` also `"+1"`, `"previous"`, `"special:name"` |
| Window | `hl.dsp.focus({ window = w })` |
| Direction | `hl.dsp.focus({ direction = "l" })` — `l`/`r`/`u`/`d` |
| Monitor | `hl.dsp.focus({ monitor = "DP-2" })` |
| Move window to ws | `hl.dsp.window.move({ workspace = 3, window = w, follow = true })` |
| Cursor | `hl.dsp.cursor.move({ x, y })` |
| Shortcut | `hl.dsp.send_shortcut({ mods = "CTRL", key = "L", window = w })` |

After a mutate, re-read `hypr-drive active`. Do not assume focus stuck.
