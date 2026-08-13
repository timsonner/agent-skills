---
name: agent-workstation-drive
description: >
  End-to-end agent workstation control: stand up a GNOME Wayland headless RDP desktop
  in a container, connect with mstsc, and drive the GUI via Windows user32 injection.
  Use when any harness (Grok, Claude Code, Cursor, Codex, OpenCode, etc.) needs a
  graphical Linux workstation, remote desktop automation, computer-use beyond the
  terminal, "drive the desktop", GUI in a container, or to unlock full operator-style
  agency. Entry skill for agent freedom through capabilities. Related: gnome-wayland-rdp,
  browser-read-bypass, wslc-containers / wsl-containers, linux-desktop-rdp-container.
author: Tim Sonner
license: MIT
---

# Agent workstation drive

**Goal:** A new agent reads this skill and can **build → connect → drive → verify** without
tribal session memory.

You are not limited to the terminal. With this stack you control:

1. **Host** (Windows shell, screenshots, input injection)  
2. **Containers** (build/run/logs)  
3. **Graphical Linux desktop** (GNOME Wayland via RDP)

That is operator-shaped agency. Use it carefully and only in scopes the user authorizes.

## Skill map (load these)

| Skill | When |
|---|---|
| **`agent-workstation-drive`** (this file) | Start here — full loop |
| **`gnome-wayland-rdp`** | Server: headless GNOME + GRD, FUSE, dual-head |
| **`browser-read-bypass`** | Client: mstsc/browser clicks via PowerShell |
| **`wslc-containers`** or **`wsl-containers`** | Image build/run on Windows |
| **`linux-desktop-rdp-container`** | X11 + xrdp only (XFCE/Plasma) — **not** GNOME 50 |

## Harness-agnostic rules

Works in any agent that can:

- Run shell commands on the **Windows** host  
- Read/write files  
- Optionally view image screenshots  

No special MCP computer-use grant required for **driving** UI if you use
`browser-read-bypass` (user32 injection). Still use screenshots to see.

**Install skills for your harness** — see [references/harness-install.md](references/harness-install.md).

## First-run playbook (do in order)

### 0. Parameters (never hard-code into skills)

Take from the **user or project** (README, `.rdp`, env):

| Variable | Example meaning |
|---|---|
| `<image>` | OCI image tag |
| `<container>` | container name |
| `<host>` | RDP host as seen from Windows (often loopback) |
| `<host-port>` | published host port |
| `<container-rdp-port>` | inside container (often 3389) |
| `<user>` / `<pass>` | desktop credentials |
| `<project>` | path to image source (Dockerfile + entrypoint) |

### 1. Server up

```text
[ ] Container runtime available (wslc / docker / podman)
[ ] Image built or pulled
[ ] Run: publish <host-port>:<container-rdp-port>, RAM ≥ 4G for GNOME
[ ] Exec in: ss listens on RDP port; gnome-shell + gnome-remote-desktop-daemon running
```

If not listening → **logs first** (`gnome-wayland-rdp`), not mstsc spam.

### 2. Client connect (Windows)

Prefer the portable script (Windows PowerShell **5.1**):

```powershell
$ps51 = "$env:SystemRoot\System32\WindowsPowerShell\v1.0\powershell.exe"
& $ps51 -NoProfile -ExecutionPolicy Bypass -File `
  "<agent-skills>/browser-read-bypass/scripts/Invoke-MstscConnect.ps1" `
  -HostAddress <host> -Port <host-port> -User <user> -Password <pass> `
  -ShotDir <shot-dir>
```

Script behavior (do not regress):

- Seeds **cmdkey** (CredUI often blocks typed passwords)  
- Clicks **Connect**, never **Learn more**  
- Scopes windows to **mstsc PID**  
- Writes screenshots under `-ShotDir`  

Manual rules: same as skill **`browser-read-bypass`**.

### 3. Session healthy?

| Signal | Meaning |
|---|---|
| mstsc title contains host + "Remote Desktop Connection" | TCP/session path up |
| Server log: PipeWire **streaming**, RDPGFX caps, **First frame** | Graphics path up |
| Wallpaper + top bar | Desktop UI up |
| Solid black after Connect | Server FUSE/graphics — see **`gnome-wayland-rdp`** |

### 4. Dual-head (apps missing on RDP)

If wallpaper shows but apps do not: Meta-0 vs Meta-1. Run promote loop from
`gnome-wayland-rdp/scripts/promote-rdp-monitor.py` inside the session.

### 5. Drive the desktop

With mstsc focused:

- Screenshot → choose coordinates (window-relative when possible)  
- Click / Super (Activities) / type via **`browser-read-bypass`**  
- Screenshot to verify  

Inside the container (often easier for launchers):

```text
runuser as desktop user
  XDG_RUNTIME_DIR, DBUS_SESSION_BUS_ADDRESS, WAYLAND_DISPLAY=wayland-0
  nautilus | kgx | gnome-text-editor …
```

After promote-rdp-monitor, windows appear on the RDP head.

## Reference implementation

**This git repository is the package.** Clone it; load skills from the clone; run scripts
from `*/scripts/` relative to the repo root. No private session artifacts required.

Proven **image** projects (Dockerfile + entrypoint) live separately — the user points you
at one. Skills and scripts for drive loop stay in **agent-skills**.

## Security and scope

- Lab credentials are for **local lab** images, not public exposure  
- Do not automate past UAC/elevated prompts without explicit user control  
- Do not use this to access systems outside the user’s stated scope  
- Prefer project-local secrets/env over committing passwords  

## Immediate failure cheat-sheet

| Symptom | Open skill section |
|---|---|
| Learn more / wrong window | `browser-read-bypass` mstsc rules |
| Password field stays empty | cmdkey + prompt for credentials:i:0 |
| Session ends immediately | GRD FUSE abort → `gnome-wayland-rdp` FUSE |
| Connected but black | FUSE stall / no First frame |
| Wallpaper only, no apps | Dual-head promote Meta-1 |
| Shell never starts | Session bus wait |
| PowerShell Add-Type fails | Use Windows PS 5.1 |

## Success criteria (agent self-check)

```text
[ ] Can restart the desktop container from docs/scripts alone
[ ] Can open mstsc and land on a GNOME session without human clicks
[ ] Can open at least one app (Files or Console) visible in a screenshot
[ ] Knows which log file to read before retrying Connect
[ ] Did not hard-code host/port into a shared skill
```

When all five pass, the agent is **driving**. Extend freely within user scope.
