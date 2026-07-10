# Agent Skills Repository

Welcome to the Agent Skills Repository! This workspace houses a large collection of automated agent skills, systems administration workflows, security penetration testing manuals, and developer SDK configurations. These skills are designed to equip AI models and developers with structured, reusable, and reproducible capabilities.

---

## Table of Contents

- [AI & Agent Harnesses](#ai--agent-harnesses)
- [Developer SDKs & Protocols](#developer-sdks--protocols)
- [OpenCode Platform Skills](#opencode-platform-skills)
- [Penetration Testing Suite](#penetration-testing-suite)
- [System Administration & Virtualization](#system-administration--virtualization)
- [Special Navigation & Browser Helpers](#special-navigation--browser-helpers)

---

## AI & Agent Harnesses

These skills define interaction workflows for launching and managing AI coding agents and harness setups inside a terminal or PTY session.

### Antigravity (Gemini) CLI Harness
- **Path**: [agy-harness/SKILL.md](agy-harness/SKILL.md)
- **Description**: Launch and control the Gemini / Antigravity CLI harness (`agy`) over a persistent terminal/PTY session, utilizing artifact picking, slash commands, configurations, and reliable exit control.

### OpenCode CLI Harness
- **Path**: [opencode-harness/SKILL.md](opencode-harness/SKILL.md)
- **Description**: Drive the OpenCode CLI harness (`opencode`) programmatically across terminal sessions for automated, interactive coding tasks using PTY-backed control.

### Ralph Wiggum Pattern
- **Path**: [ralph-wiggum-pattern/SKILL.md](ralph-wiggum-pattern/SKILL.md)
- **Description**: Execute a continuous feedback-loop coding setup. Employs iterating on single items, delegating implementation authority to the agent, and self-healing mechanisms.

---

## Developer SDKs & Protocols

Guidelines and frameworks for integrating directly with AI agent platforms and protocols.

### GitHub Copilot Python SDK
- **Path**: [copilot-sdk/SKILL.md](copilot-sdk/SKILL.md)
- **Description**: Integrate programmatically with the GitHub Copilot CLI via a Python JSON-RPC SDK in technical preview.

### Model Context Protocol (MCP) Server Specification
- **Path**: [mcp-server/SKILL.md](mcp-server/SKILL.md)
- **Description**: Learn how to build standard, production-ready MCP servers using Python. Focuses on exposing resources, tools, prompts, and handling stdio safely without writing raw stdout.

---

## OpenCode Platform Skills

An extensive and highly segmented guide collection for learning, installing, configuring, and customize the OpenCode platform.

### Quick Start & Installation
- **Intro Specification**: [opencode/intro/SKILL.md](opencode/intro/SKILL.md) — Fundamental overview of what OpenCode is and how to get started.
- **Prerequisites Guide**: [opencode/prerequisites/SKILL.md](opencode/prerequisites/SKILL.md) — Software pre-requirements, terminal choices, and initial API key configs.
- **Platform Installation**: [opencode/install/SKILL.md](opencode/install/SKILL.md) — Multiple deployment and installation methods (scripts, npm/Node.js, Homebrew, Arch Linux, and Windows).
- **Windows Implementation**: [opencode/windows/SKILL.md](opencode/windows/SKILL.md) — Specific guidelines and setups for installing and optimizing OpenCode on Windows systems natively or utilizing WSL.

### Project Onboarding & Setup
- **Initialization Guide**: [opencode/initialize/SKILL.md](opencode/initialize/SKILL.md) — Preparing folders for OpenCode development and setting up custom agents.
- **General Configuration**: [opencode/configure-guide/SKILL.md](opencode/configure-guide/SKILL.md) — Setting up language models and passing correct keys.
- **Provider Setup**: [opencode/providers/SKILL.md](opencode/providers/SKILL.md) — Detailed specifications for major LLM providers.

### Personalization & Growth
- **Customization Guide**: [opencode/customize/SKILL.md](opencode/customize/SKILL.md) — Adjusting UI themes, configuring keyboard mapping, formatting configurations, and custom commands.
- **Skill Creation**: [opencode/skill-creation/SKILL.md](opencode/skill-creation/SKILL.md) — Standardized guidelines for creating new OpenCode-compatible skills.
- **Plugins Engine**: [opencode/plugins/SKILL.md](opencode/plugins/SKILL.md) — Searching, introducing, and testing extensions and plugins in OpenCode.

### Network, Servers & Teams
- **Network Configuration**: [opencode/network/SKILL.md](opencode/network/SKILL.md) — Handling proxies, offline environments, and network troubleshooting.
- **Server Deployment**: [opencode/server/SKILL.md](opencode/server/SKILL.md) — Setting up a dedicated OpenCode Server for API-based team integrations and webhooks.
- **Enterprise Settings**: [opencode/enterprise/SKILL.md](opencode/enterprise/SKILL.md) — Hardened multi-tenant workflows, access-control patterns, and advanced corporate deployments.
- **Ecosystem Integration**: [opencode/ecosystem/SKILL.md](opencode/ecosystem/SKILL.md) — Community ecosystems and linking third-party tooling with OpenCode.
- **Sharing Output**: [opencode/share/SKILL.md](opencode/share/SKILL.md) — Sharing chat sessions, histories, and collaborative flows with team members.

### Technical Deep Dives
- **Agent Roles**: [opencode/configure/agents/SKILL.md](opencode/configure/agents/SKILL.md) — Aligning specific prompts and persona-based capabilities.
- **LSP Integrations**: [opencode/configure/lsp/SKILL.md](opencode/configure/lsp/SKILL.md) — Customizing the Language Server Protocol configurations.
- **Code Formatters**: [opencode/configure/formatters/SKILL.md](opencode/configure/formatters/SKILL.md) — Injecting autoformat, linters, and checkers (Prettier, Black, etc.).
- **Go Support**: [opencode/go/SKILL.md](opencode/go/SKILL.md) — Specific best practices and optimizations for writing Go applications.
- **Workflow - Adding Features**: [opencode/usage/add-features/SKILL.md](opencode/usage/add-features/SKILL.md) — Complete execution workflow for creating new features sustainably.

---

## Penetration Testing Suite

A suite of highly granular guides and references for conducting authorized cybersecurity assessments, vulnerability scanning, and red team engagements.

### Core Manuals & Methodology
- **General Methodology**: [pentest/pentesting-methodology-guide.md](pentest/pentesting-methodology-guide.md) — Clean, PTES/OWASP-aligned high-level processes and safety principles.
- **Kali Linux Execution Guide**: [pentest/methodology/SKILL.md](pentest/methodology/SKILL.md) — Concrete step-by-step phases of discovery, scan, leverage, elevation, and report using standard tool structures.
- **Attack Payload Book**: [pentest/attack-patterns/SKILL.md](pentest/attack-patterns/SKILL.md) — Ready-to-go reference recipes for common vulnerabilities, including Web (LFI, XXE, SSRF, XSS), Command Injection, SQL Injection, Windows Exploitation, and Reverse Shells.
- **Defender OPSEC Hardening**: [defender-opsec/SKILL.md](defender-opsec/SKILL.md) — Harden Windows Defender privacy settings for authorized pentest engagements, disabling background telemetry, automatic sample submissions, and cloud protection to preserve confidentiality.
- **WSLC Pentest Workflow**: [wslc-pentest-workflow/SKILL.md](wslc-pentest-workflow/SKILL.md) — Run authorized pentest workflows inside persistent WSL containers (`wslc`), isolating tooling, mapping actions to methodology, and saving persistent artifacts to the host.

### Pentest Tools Directory
The repository defines over 90 distinct penetration testing tool sub-skills. The main entry point is [pentest/tools/SKILL.md](pentest/tools/SKILL.md), which is supplemented by highly detailed, individual tool guidelines:
- **Port/Service Scanners**: [pentest/tools/nmap/SKILL.md](pentest/tools/nmap/SKILL.md) (Nmap for active recon and port scanning)
- **Vulnerability Scanner**: [pentest/tools/nuclei/SKILL.md](pentest/tools/nuclei/SKILL.md) (Nuclei scanning for fast templated-based discovery)
- **Directory Discovery**: [pentest/tools/dirsearch/SKILL.md](pentest/tools/dirsearch/SKILL.md) (Brute-forcing hidden directories and web paths)
- **Web App Analysis**: [pentest/tools/burp-suite/SKILL.md](pentest/tools/burp-suite/SKILL.md) (Burp Suite for interception and manual analysis)
- **Active Directory Mapping**: [pentest/tools/bloodhound/SKILL.md](pentest/tools/bloodhound/SKILL.md) (BloodHound domain relationships and privilege path visualizations)
- **Memory/Credential Harvesting**: [pentest/tools/mimikatz/SKILL.md](pentest/tools/mimikatz/SKILL.md) (Mimikatz usage for LSASS extraction and token analysis)
- **Network Helpers**: [pentest/tools/netcat/SKILL.md](pentest/tools/netcat/SKILL.md) (Netcat data transfers and socket testing)
- **Secure Tunneling**: [pentest/tools/chisel/SKILL.md](pentest/tools/chisel/SKILL.md) (Chisel TCP/UDP tunneling and reverse port forwards)

*And many dozens of others listed under the nested `pentest/tools/` subdirectories.*

---

## System Administration & Virtualization

Guides for configuring, hardening, recovering, and virtualizing systems and container deployments.

### Proxmox System Administration
- **Path**: [proxmox-system-administration/SKILL.md](proxmox-system-administration/SKILL.md)
- **Description**: Administrate Proxmox VE hosts utilizing a strict least-privilege boundary model (host vs guest), hardened service accounts, and modular VM/LXC template instantiation.

### Proxmox Stuck Boot Recovery
- **Path**: [proxmox-vm-recovery/SKILL.md](proxmox-vm-recovery/SKILL.md)
- **Description**: Walkthrough diagnosing and repairing UEFI/OVMF stuck VMs (such as Windows 11 stuck loops), handling disk-mount, EFI partition recovery, and config backups safely.

### WSL Linux Containers
- **Path**: [wsl-containers/SKILL.md](wsl-containers/SKILL.md)
- **Description**: Native WSL Containers via `wslc.exe` + `Microsoft.WSL.Containers` — man-style CLI flags, sessions, volumes/networks/GPU, and C# API reference (preview 2.9.3+).

---

## Special Navigation & Browser Helpers

Workarounds and tools for when models encounter unique terminal limits or application rendering blocks.

### Browser Read Bypass
- **Path**: [browser-read-bypass/SKILL.md](browser-read-bypass/SKILL.md)
- **Description**: Workaround for browser-interaction blocks (e.g., tier "read-only") inside Chrome/Edge. Injects clicks and raw keyboard inputs at the Windows API layer using PowerShell, `user32.dll`, and `System.Windows.Forms`.

### Canvas Browser Reading
- **Path**: [read-canvas-browser/SKILL.md](read-canvas-browser/SKILL.md)
- **Description**: Specialized visual interaction guidelines to handle canvas-rendered or WebGL-driven web pages where standard HTML DOM tree and accessibility engines return blank nodes.

