# Agent skills

## What it is

This repository is a collection of skills for coding-agent harnesses (Grok, Claude Code, Cursor, OpenCode, and similar). A skill is a directory with a `SKILL.md` file. The YAML frontmatter has `name` and `description`. Some skills also ship `scripts/` and `references/` next to that file.

Clone the repo and point the harness at the clone, or copy the skill directories into the harness skill folder. The agent then reads the playbooks from the files. [AGENTS.md](AGENTS.md) is the cross-harness bootstrap for the graphical workstation loop.

The package is this git repository. It does not build an application, and it does not contain a GNOME or Plasma container image. Supply that image from a separate lab project. Shared skills use placeholders (`<host>`, `<port>`, `<user>`) for lab endpoints.

## Prerequisites

- Git.
- A harness that can read `SKILL.md` or `AGENTS.md`.
- Workstation drive on Windows: Windows PowerShell. `windows-ui-inject/scripts/Invoke-MstscConnect.ps1` prefers Windows PowerShell 5.1 because it uses `Add-Type` and `System.Drawing`. The desktop image is separate from this repo.
- Local Hyprland (`drive-hyprland`): a Hyprland session, `python3`, `hyprctl`, `grim`, `wtype`, and `ydotool` with `ydotoold` and a writable `/dev/uinput`. `drive-hyprland/scripts/install.sh host` installs packages with `omarchy` or `pacman` when one of those is on `PATH`.
- PDF training scripts: Python 3 and PyMuPDF (`import fitz`). OCR is optional (`pytesseract` and Pillow). `to_datum.py`, `train_lora.py`, and `test_finetuned.py` need the Tinker SDK (`pip install tinker`). The skill text records `tinker` 0.23.0 as verified.
- `mcp-server/SKILL.md` is a Python MCP server specification. It documents Python 3.10+ and the MCP Python SDK. This repo does not ship a server package for it.
- `buzz-relay-self-host/scripts/verify-pair-endpoint.sh` needs `curl`. `jq` is optional.

## Install, check, and run

There is no root `package.json`, `Makefile`, lockfile, or test runner. Checks below are the commands the scripts actually accept.

### Clone

```bash
git clone https://github.com/timsonner/agent-skills.git
cd agent-skills
```

### Point Grok at the clone

From `agent-workstation-drive/references/harness-install.md`:

```toml
# ~/.grok/config.toml
[skills]
paths = ["<absolute-path-to-this-clone>"]
```

Claude Code and Cursor can use the same clone if the agent is allowed to read it. Optional copies go to `~/.claude/skills/<name>/SKILL.md` or `~/.cursor/skills/<name>/SKILL.md`.

### Copy the workstation-drive family (Windows)

`agent-workstation-drive/scripts/Install-ToHarness.ps1` copies these directories: `agent-workstation-drive`, `gnome-wayland-rdp`, `kde-wayland-rdp`, `windows-ui-inject`, `browser-read-bypass`, `wsl-containers`.

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\agent-workstation-drive\scripts\Install-ToHarness.ps1 -SourceRoot (Get-Location) -Harness all
```

`-Harness` is `grok`, `claude`, `cursor`, or `all` (default `all`). Destinations are `%USERPROFILE%\.grok\skills`, `%USERPROFILE%\.claude\skills`, and `%USERPROFILE%\.cursor\skills`.

### Hyprland install script

```bash
bash drive-hyprland/scripts/install.sh --help
bash drive-hyprland/scripts/install.sh harness
bash drive-hyprland/scripts/install.sh harness cursor
bash drive-hyprland/scripts/install.sh verify
```

`harness` symlinks this skill into `~/.grok/skills`, `~/.claude/skills`, and `~/.cursor/skills`. The second argument is `grok`, `claude`, `cursor`, or `all` (default `all`).

`verify` checks `hyprctl`, `python3`, `grim`, `wtype`, `ydotool`, `/dev/uinput`, the ydotool socket, and `ydotool.service`.

`host` installs packages, adjusts `/dev/uinput`, and starts the user `ydotool` service. Run it on the Hyprland machine.

### Shell syntax

```bash
find . -name '*.sh' -not -path './.git/*' -print0 | xargs -0 -n1 bash -n
```

### PDF to Tinker data

`chunk_pdf.py` imports PyMuPDF before it parses arguments, so `--help` fails until `fitz` is installed.

```bash
python3 pdf-to-tinker-training/scripts/chunk_pdf.py --pdf <path-to.pdf>
python3 pdf-to-tinker-training/scripts/chunk_pdf.py --pdf <path-to.pdf> --output <out.jsonl> --pages 10
python3 pdf-to-tinker-training/scripts/to_datum.py --input <chunks.jsonl>
python3 pdf-to-tinker-training/scripts/train_lora.py --data <datum.jsonl>
python3 pdf-to-tinker-training/scripts/test_finetuned.py --checkpoint <checkpoint-name>
```

`to_datum.py` also takes `--output` and `--model` (default `thinkingmachines/Inkling`). `train_lora.py` also takes `--model`, `--epochs`, `--lr`, `--batch_size`, and `--checkpoint`. `test_finetuned.py` also takes `--model`, `--prompt`, `--num_samples`, `--max_tokens`, and `--temperature`.

### Buzz pairing check

```bash
bash buzz-relay-self-host/scripts/verify-pair-endpoint.sh https://<buzz-fqdn>
bash buzz-relay-self-host/scripts/set-agent-avatar.sh <path-to-image.png> --name <name> --about <text>
```

`set-agent-avatar.sh` reads `BUZZ_RELAY_URL` and `BUZZ_PRIVATE_KEY` from the environment. With no arguments it prints usage and exits 2. The same is true for `verify-pair-endpoint.sh`.

### Desktop session scripts

Both scripts exit 2 until a password is set in the environment. They are meant to run as the desktop user inside the lab image.

```bash
GNOME_RDP_PASS=<password> bash gnome-wayland-rdp/scripts/start-gnome-headless-rdp.sh
KRDP_PASS=<password> bash kde-wayland-rdp/scripts/start-krdp.sh
```

Optional GNOME variables in `start-gnome-headless-rdp.sh`: `DESKTOP_USER`, `GNOME_WIDTH` (default 1920), `GNOME_HEIGHT` (default 1080), `GNOME_RDP_PORT` (default 3389), `GNOME_RDP_USER`, `GRD_TLS_DIR`.

Optional KRdp variables in `start-krdp.sh`: `DESKTOP_USER` (default `kdeuser`), `KRDP_USER`, `KRDP_PORT` (default 3389), `KWIN_WIDTH`, `KWIN_HEIGHT`, `KRDP_TLS_DIR`, `KRDP_QUALITY` (default 40).

Other scripts in those folders (`configure-desktop-ui.sh`, `promote-krdp-output.sh`, `start-kwin-gl.sh`, and the rest) are invoked by the matching `SKILL.md`. Read that file before running them.

### Windows helpers

Offload one job to `agy`, `opencode`, `copilot`, `codex`, or `hermes`:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\harness-offload\scripts\Invoke-HarnessOffload.ps1 -Worker opencode -Prompt "<prompt>" -Dir (Get-Location)
```

Optional switches on that script: `-AllowTools`, `-Session`, `-Model`.

Connect `mstsc` and save screenshots (click Connect, and read the skill before repeating a click):

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\windows-ui-inject\scripts\Invoke-MstscConnect.ps1 -HostAddress <host> -Port <port> -User <user> -Password <password> -ShotDir $env:TEMP\rdp-shots
```

Optional: `-RdpPath`, `-NoClipboard`.

## Usage

1. For a graphical Linux workstation from Windows, read [AGENTS.md](AGENTS.md), then [agent-workstation-drive/SKILL.md](agent-workstation-drive/SKILL.md). The first-session prompt is [agent-workstation-drive/references/first-session-prompt.md](agent-workstation-drive/references/first-session-prompt.md).
2. On a local Hyprland session, load [drive-hyprland/SKILL.md](drive-hyprland/SKILL.md) and use `drive-hyprland/scripts/install.sh`.
3. For any other topic, open the `SKILL.md` in the directory from the layout below. OpenCode topics live under `opencode/`. Tool skills live under `pentest/tools/`.
4. Keep lab hosts, ports, users, and passwords in the environment or in the command you type. Do not commit them into `SKILL.md`.

Authorized assessment notes live under `pentest/`, `defender-opsec/`, and `wslc-pentest-workflow/`. Use them only inside a scope you are allowed to test.

## Layout

| Path | Role |
|---|---|
| `AGENTS.md` | Bootstrap for the workstation-drive loop |
| `agent-workstation-drive/` | End-to-end GNOME Wayland RDP plus Windows GUI drive |
| `gnome-wayland-rdp/` | Headless GNOME Shell with gnome-remote-desktop |
| `kde-wayland-rdp/` | Headless Plasma on `kwin_wayland` with KRdp |
| `windows-ui-inject/` | Windows mouse and keyboard injection, including `mstsc` |
| `browser-read-bypass/` | Alias of `windows-ui-inject` |
| `drive-hyprland/` | Local Hyprland workspaces, click, type, screenshots |
| `wsl-containers/` | `wslc` container build, run, and publish notes |
| `podman/` | Podman create, run, exec, compose, tear down |
| `proxmox-system-administration/` | Proxmox VE host administration |
| `proxmox-vm-recovery/` | Stuck UEFI/OVMF VM boot recovery |
| `agy-harness/` | Drive the Antigravity (`agy`) CLI |
| `opencode-harness/` | Drive the OpenCode CLI |
| `opencode/` | OpenCode install, configure, and usage skills |
| `copilot-harness/` | Drive the GitHub Copilot CLI |
| `copilot-sdk/` | Python JSON-RPC notes for the Copilot CLI |
| `codex-harness/` | Drive the Codex CLI |
| `hermes-harness/` | Drive the Hermes Agent CLI |
| `harness-offload/` | One-job dispatcher for those CLIs |
| `ralph-wiggum-pattern/` | Ralph Wiggum feedback-loop coding notes |
| `mcp-server/` | Python MCP server specification |
| `read-canvas-browser/` | Canvas and WebGL pages with an empty accessibility tree |
| `buzz-relay-self-host/` | Self-host Block Buzz, pairing, and `buzz-acp` |
| `buzz-hermes-gateway/` | Hermes gateway to a Buzz community |
| `pdf-to-tinker-training/` | PDF to Tinker supervised-pair scripts |
| `pentest/` | Methodology guide plus per-tool skills under `pentest/tools/` |
| `defender-opsec/` | Windows Defender privacy settings for an authorized lab |
| `wslc-pentest-workflow/` | Authorized pentest workflow inside WSL containers |

## License

Skill frontmatter sets `license: MIT` on every `SKILL.md` except `pdf-to-tinker-training/SKILL.md`, which has no `license` field. This repository has no root `LICENSE` file.
