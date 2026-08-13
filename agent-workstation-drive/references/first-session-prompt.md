# First-session prompt (give this to a new agent)

Prerequisite: this **agent-skills** repo is cloned (or mounted) where the agent can read it.
All paths below are relative to the **repo root**.

Copy-paste or adapt:

---

You have access to the **agent-skills** repository. Load the workstation-drive family
from this clone: `agent-workstation-drive`, `gnome-wayland-rdp`, `browser-read-bypass`
(and their `scripts/` directories). Do not assume prior session memory.

Your job: gain a **live GNOME Wayland RDP session** and prove you can drive it.

### Constraints

- Do not hard-code host/port/password into skills; read them from the project
  README, `.rdp` file, or ask me once and keep them in this session only.
- On RDP failure: **container logs first**, then client UI.
- mstsc: **Connect**, never **Learn more**. Prefer `Invoke-MstscConnect.ps1`
  under `browser-read-bypass/scripts/` with Windows PowerShell 5.1.
- GNOME 50 uses **GRD headless**, not xrdp.

### Steps

1. Locate the desktop image project (or build from project docs).  
2. Ensure container is running and RDP is listening inside.  
3. Connect with the portable mstsc script; save screenshots.  
4. If wallpaper-only / no apps: run `promote-rdp-monitor.py` in the session.  
5. Open Files or Console so a window is visible in a screenshot.  
6. Report: shot paths, container name, and which logs you checked.

When the five success criteria in `agent-workstation-drive` are met, stop and summarize.

---
