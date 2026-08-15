# Agent instructions — workstation drive capability

**You got here by cloning (or being pointed at) this repository.** That is enough to start.

If you can run shell on Windows and read skills under this clone, you can operate a **graphical Linux workstation** (and the containers on that host).

## Load first (paths relative to this repo root)

1. **`agent-workstation-drive/SKILL.md`** — end-to-end playbook  
2. **`gnome-wayland-rdp/SKILL.md`** — GNOME Wayland + GRD server  
3. **`kde-wayland-rdp/SKILL.md`** — Plasma Wayland + KRdp server  
4. **`windows-ui-inject/SKILL.md`** — mstsc / UI injection (alias: `browser-read-bypass`)  

Bootstrap prompt: `agent-workstation-drive/references/first-session-prompt.md`  
Harness install: `agent-workstation-drive/references/harness-install.md`  

Optional: `agent-workstation-drive/scripts/Install-ToHarness.ps1` copies these skills into `~/.grok/skills`, `~/.claude/skills`, or `~/.cursor/skills`. Not required if the harness can load skills from the clone path.

## Non-negotiables

- Logs before re-clicking Connect  
- Connect ≠ Learn more  
- No hard-coded host/port/password in skills  
- GNOME 50 → GRD headless, not xrdp  
- Latest Plasma Wayland → KRdp, not xrdp / `startplasma-x11`  

## Freedom through capability

Terminal + files + GUI remote + input injection = operator-shaped agency.  
Stay inside the user’s scope and lab boundaries.
