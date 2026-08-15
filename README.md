# Agent Skills Repository

Structured, reusable skills for AI coding agents and harnesses (Grok, Claude Code, Cursor, OpenCode, and similar). Clone this repo, point the harness at it (or copy skills in), and agents can load capabilities without prior session memory.

```bash
git clone https://github.com/timsonner/agent-skills.git
```

**Cross-harness bootstrap:** [AGENTS.md](AGENTS.md)

---

## Table of Contents

- [Agent workstation drive (start here for GUI agency)](#agent-workstation-drive-start-here-for-gui-agency)
- [AI & Agent Harnesses](#ai--agent-harnesses)
- [Developer SDKs & Protocols](#developer-sdks--protocols)
- [System Administration & Virtualization](#system-administration--virtualization)
- [Special Navigation & Browser Helpers](#special-navigation--browser-helpers)
- [Remote Desktop (Linux)](#remote-desktop-linux)
- [OpenCode Platform Skills](#opencode-platform-skills)
- [Penetration Testing Suite](#penetration-testing-suite)
- [Other skills](#other-skills)

---

## Agent workstation drive (start here for GUI agency)

**Intent:** any agent that can clone this repository and run a Windows shell can learn a full **operator loop** — container desktop + RDP + GUI drive — without private session lore.

```text
clone agent-skills
  → load agent-workstation-drive
  → (optional) Install-ToHarness.ps1 or skills.paths = clone
  → point at a GNOME/GRD image project the user provides
  → connect with Invoke-MstscConnect.ps1
  → drive via screenshots + user32 injection
```

| Piece | Path |
|---|---|
| **Entry skill** | [agent-workstation-drive/SKILL.md](agent-workstation-drive/SKILL.md) |
| First-session prompt | [agent-workstation-drive/references/first-session-prompt.md](agent-workstation-drive/references/first-session-prompt.md) |
| Harness install (Grok / Claude / Cursor) | [agent-workstation-drive/references/harness-install.md](agent-workstation-drive/references/harness-install.md) |
| Install script | [agent-workstation-drive/scripts/Install-ToHarness.ps1](agent-workstation-drive/scripts/Install-ToHarness.ps1) |
| Server skill (GNOME Wayland + GRD) | [gnome-wayland-rdp/](gnome-wayland-rdp/) |
| Server skill (Plasma Wayland + KRdp) | [kde-wayland-rdp/](kde-wayland-rdp/) |
| Client skill (mstsc + user32) | [windows-ui-inject/](windows-ui-inject/) |
| Portable mstsc helper | [windows-ui-inject/scripts/Invoke-MstscConnect.ps1](windows-ui-inject/scripts/Invoke-MstscConnect.ps1) |
| Cross-harness notes | [AGENTS.md](AGENTS.md) |

**In this repo:** skills, scripts (promote monitor, desktop UI, FUSE stub sources, mstsc connect), install docs.  
**Not in this repo:** a full GNOME container image/Dockerfile — supply a lab image project separately (skills stay portable: no hard-coded host/port).

Success bar for a new agent: the five criteria in `agent-workstation-drive` (restart desktop stack from docs, open mstsc without human clicks, show an app or full desktop in a screenshot, know which logs to read, no secrets baked into skills).

---

## AI & Agent Harnesses

Workflows for launching and controlling coding-agent CLIs over a terminal/PTY.

### Antigravity (Gemini) CLI Harness
- **Path**: [agy-harness/SKILL.md](agy-harness/SKILL.md)
- **Description**: Launch and control the Gemini / Antigravity CLI harness (`agy`) over a persistent terminal/PTY session (artifacts, slash commands, exit control).

### OpenCode CLI Harness
- **Path**: [opencode-harness/SKILL.md](opencode-harness/SKILL.md)
- **Description**: Drive the OpenCode CLI (`opencode`) programmatically across terminal sessions with PTY-backed control.

### GitHub Copilot CLI Harness
- **Path**: [copilot-harness/SKILL.md](copilot-harness/SKILL.md)
- **Description**: Drive the GitHub Copilot CLI (`copilot`) from another agent: one-shot `-p`/`--prompt`, resume/continue, models, skills. JSON-RPC Python is [copilot-sdk](copilot-sdk/SKILL.md).

### Harness offload
- **Path**: [harness-offload/SKILL.md](harness-offload/SKILL.md)
- **Description**: One job shape for `agy` / `opencode` / `copilot`: worker, dir, prompt, allow_tools, session. Dispatcher: [Invoke-HarnessOffload.ps1](harness-offload/scripts/Invoke-HarnessOffload.ps1). Flags stay in the per-binary harness skills.

### Ralph Wiggum Pattern
- **Path**: [ralph-wiggum-pattern/SKILL.md](ralph-wiggum-pattern/SKILL.md)
- **Description**: Continuous feedback-loop coding: iterate on single items, delegate implementation, self-heal.

---

## Developer SDKs & Protocols

### GitHub Copilot Python SDK
- **Path**: [copilot-sdk/SKILL.md](copilot-sdk/SKILL.md)
- **Description**: Integrate with the GitHub Copilot CLI via a Python JSON-RPC SDK (technical preview). To *invoke* the CLI from another agent, use [copilot-harness](copilot-harness/SKILL.md).

### Model Context Protocol (MCP) Server
- **Path**: [mcp-server/SKILL.md](mcp-server/SKILL.md)
- **Description**: Build production-style MCP servers in Python (resources, tools, prompts, safe stdio).

---

## System Administration & Virtualization

### Proxmox System Administration
- **Path**: [proxmox-system-administration/SKILL.md](proxmox-system-administration/SKILL.md)
- **Description**: Proxmox VE host admin with host-vs-guest least privilege, service accounts, VM/LXC templates.

### Proxmox Stuck Boot Recovery
- **Path**: [proxmox-vm-recovery/SKILL.md](proxmox-vm-recovery/SKILL.md)
- **Description**: Recover UEFI/OVMF stuck VMs (e.g. Windows boot loops), disk mount, EFI repair, config backup.

### WSL Linux Containers
- **Path**: [wsl-containers/SKILL.md](wsl-containers/SKILL.md)
- **Description**: Native WSL Containers via `wslc.exe` — build/run/publish cookbook plus CLI/API references. Replaces the older `wslc-containers` name.

### Podman (Linux + Cockpit)
- **Path**: [podman/SKILL.md](podman/SKILL.md)
- **Description**: Create, run, exec, compose, and tear down Podman containers; Cockpit UI; rootless defaults.

### Buzz Relay Self-Host
- **Path**: [buzz-relay-self-host/SKILL.md](buzz-relay-self-host/SKILL.md)
- **Description**: Self-host Block Buzz (Compose) behind a reverse proxy, WebSockets, mobile pairing, always-on `buzz-acp` agents, optional Hermes. Placeholder-only site inventory.
- **References**: [hermes-gateway](buzz-relay-self-host/references/hermes-gateway.md) · [mobile-pairing](buzz-relay-self-host/references/mobile-pairing.md) · [buzz-acp-bridge](buzz-relay-self-host/references/buzz-acp-bridge.md) · [agent avatar](buzz-relay-self-host/references/agent-profile-avatar.md)

### Buzz ↔ Hermes Gateway
- **Path**: [buzz-hermes-gateway/SKILL.md](buzz-hermes-gateway/SKILL.md)
- **Description**: Connect Hermes Agent gateway to a Buzz community (keys, allowlist, mention rules, authz debugging).

---

## Special Navigation & Browser Helpers

### Windows UI inject
- **Path**: [windows-ui-inject/SKILL.md](windows-ui-inject/SKILL.md)
- **Description**: Inject clicks/keys on Windows via PowerShell and `user32` when computer-use is screenshot-only. Browsers under tier “read” **and** mstsc (Connect vs Learn more, PID-scoped windows, CredUI limits, cmdkey). Script: [Invoke-MstscConnect.ps1](windows-ui-inject/scripts/Invoke-MstscConnect.ps1). Prefer Windows PowerShell 5.1 for `Add-Type` + System.Drawing.

### Canvas Browser Reading
- **Path**: [read-canvas-browser/SKILL.md](read-canvas-browser/SKILL.md)
- **Description**: Visual interaction for canvas/WebGL pages where DOM/a11y trees are empty.

---

## Remote Desktop (Linux)

### GNOME Wayland headless RDP (GRD)
- **Path**: [gnome-wayland-rdp/SKILL.md](gnome-wayland-rdp/SKILL.md)
- **Description**: GNOME-native remote path — `gnome-shell --wayland --headless` + `gnome-remote-desktop` (not xrdp). Session bus, PipeWire, FUSE clipboard aborts, dual-head Meta-0/Meta-1 promote, log-first triage. Scripts under [gnome-wayland-rdp/scripts/](gnome-wayland-rdp/scripts/). Use with **windows-ui-inject** and **agent-workstation-drive**.

### KDE Plasma Wayland + KRdp
- **Path**: [kde-wayland-rdp/SKILL.md](kde-wayland-rdp/SKILL.md)
- **Description**: Latest Plasma on `kwin_wayland --virtual` + `krdpserver --plasma` (not xrdp). OpenGL vs QPainter, vgem/DRM, wslc seccomp, `KWIN_COMPOSE=O2`, mstsc NetworkAutoDetect, titlebar pointer (MOVE-then-button). Scripts under [kde-wayland-rdp/scripts/](kde-wayland-rdp/scripts/). Use with **windows-ui-inject** and **agent-workstation-drive**.

### Linux desktop + xrdp (X11)
- **Not vendored in this repo.** Prefer the separate Grok user skill **`linux-desktop-rdp-container`** (e.g. under `~/.grok/skills/`) for XFCE/Plasma + xrdp OCI images. Do **not** use that stack as a substitute for GNOME Shell 50 Wayland/GRD.

---

## OpenCode Platform Skills

Segmented guides for installing, configuring, and using OpenCode.

### Quick start
- [Intro](opencode/intro/SKILL.md) · [Prerequisites](opencode/prerequisites/SKILL.md) · [Install](opencode/install/SKILL.md) · [Windows](opencode/windows/SKILL.md)

### Project setup
- [Initialize](opencode/initialize/SKILL.md) · [Configure guide](opencode/configure-guide/SKILL.md) · [Providers](opencode/providers/SKILL.md)

### Personalization
- [Customize](opencode/customize/SKILL.md) · [Skill creation](opencode/skill-creation/SKILL.md) · [Plugins](opencode/plugins/SKILL.md)

### Network, server, teams
- [Network](opencode/network/SKILL.md) · [Server](opencode/server/SKILL.md) · [Enterprise](opencode/enterprise/SKILL.md) · [Ecosystem](opencode/ecosystem/SKILL.md) · [Share](opencode/share/SKILL.md)

### Deep dives
- [Agents](opencode/configure/agents/SKILL.md) · [LSP](opencode/configure/lsp/SKILL.md) · [Formatters](opencode/configure/formatters/SKILL.md) · [Go](opencode/go/SKILL.md) · [Add features](opencode/usage/add-features/SKILL.md)

Further OpenCode topics live under [`opencode/`](opencode/) (TUI, usage, configure/*, etc.).

---

## Penetration Testing Suite

Authorized assessment methodology, attack patterns, and tool skills. Use only with explicit permission and scope.

### Core manuals
- [Methodology guide](pentest/pentesting-methodology-guide.md) — PTES/OWASP-aligned process and safety
- [Kali execution](pentest/methodology/SKILL.md) — phased discovery through report
- [Attack patterns](pentest/attack-patterns/SKILL.md) — common web/Windows recipes
- [Defender OPSEC](defender-opsec/SKILL.md) — Defender privacy toggles for authorized labs
- [WSLC pentest workflow](wslc-pentest-workflow/SKILL.md) — pentest tooling inside persistent WSL containers

### Tools
Entry: [pentest/tools/SKILL.md](pentest/tools/SKILL.md). Individual tool skills under `pentest/tools/` (90+), including for example:

- [nmap](pentest/tools/nmap/SKILL.md) · [nuclei](pentest/tools/nuclei/SKILL.md) · [dirsearch](pentest/tools/dirsearch/SKILL.md)
- [burp-suite](pentest/tools/burp-suite/SKILL.md) · [bloodhound](pentest/tools/bloodhound/SKILL.md) · [mimikatz](pentest/tools/mimikatz/SKILL.md)
- [netcat](pentest/tools/netcat/SKILL.md) · [chisel](pentest/tools/chisel/SKILL.md)

---

## Other skills

### PDF to Tinker training
- **Path**: [pdf-to-tinker-training/SKILL.md](pdf-to-tinker-training/SKILL.md)
- **Description**: Pipeline and scripts for turning PDF material into training/finetune-oriented data (chunking, datum conversion, LoRA helpers under `pdf-to-tinker-training/scripts/`).

---

## Conventions

- Skills are directories with a `SKILL.md` (YAML frontmatter `name` + `description`).
- Prefer **placeholders** (`<host>`, `<port>`, `<user>`) over hard-coded lab endpoints in shared skills.
- Optional `scripts/` and `references/` live next to the skill that owns them.
- Workstation-drive **package = this git repo**; harness skill dirs are optional mirrors.
