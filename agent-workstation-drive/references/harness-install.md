# Install workstation-drive skills on any harness

## Intent (replicability)

**Any agent should be able to clone this repository and begin driving.**

The **package is the git repo** (`agent-skills`), not a private session or a one-off install on one machine. Harness skill folders (`~/.grok/skills`, etc.) are optional convenience copies; the source of truth is always the clone.

```text
git clone <this-repo> agent-skills
cd agent-skills
# Point harness at the clone OR run Install-ToHarness.ps1
# Load agent-workstation-drive → follow the playbook
```

Everything required to drive is **in-repo**:

| Path | Role |
|---|---|
| `AGENTS.md` | Cross-harness bootstrap |
| `agent-workstation-drive/` | Entry skill + first-session prompt |
| `gnome-wayland-rdp/` + `scripts/` | Server skill + promote/UI/FUSE |
| `windows-ui-inject/` + `scripts/Invoke-MstscConnect.ps1` | Client drive script |
| `agent-workstation-drive/scripts/Install-ToHarness.ps1` | Optional copy into Grok/Claude/Cursor |

A lab **desktop image project** (Dockerfile for GNOME+GRD) is separate; point the agent at whichever image project the user provides. Skills stay portable (no hard-coded host/port).

## Layout after clone

```text
agent-skills/   # this repo
  agent-workstation-drive/
  gnome-wayland-rdp/
  windows-ui-inject/
  AGENTS.md
  …
```

## Grok Build / Grok CLI

**Preferred:** add the clone path so skills load without duplicating files:

```toml
# ~/.grok/config.toml
[skills]
paths = ["~/agent-skills"]   # or absolute path to the clone
```

**Or** copy into user skills:

```powershell
# From the clone root:
.\agent-workstation-drive\scripts\Install-ToHarness.ps1 -SourceRoot (Get-Location) -Harness grok
```

Reload: new session or skills auto-reload on file change.

## Claude Code

```text
~/.claude/skills/<name>/SKILL.md
# or project: <repo>/.claude/skills/<name>/SKILL.md
```

Copy the three skill folders (and scripts subdirs) into either location.

## Cursor

```text
~/.cursor/skills/<name>/SKILL.md
# or <repo>/.cursor/skills/
```

Same copy pattern. Ensure the agent can run PowerShell and `wslc`/`docker`.

## Codex / OpenCode / other

Any harness that:

1. Loads `SKILL.md` (or equivalent) from a skills path, **or**  
2. Gets `AGENTS.md` / project instructions that **point at** these paths  

…can use the playbook. Minimum: paste or `@`-include:

- `agent-workstation-drive/SKILL.md`  
- paths to the two helper skills  

## Verification (any harness)

Ask the agent:

> Load agent-workstation-drive. List the five success criteria and the skill map.

Then (if a lab image exists):

> Connect RDP using Invoke-MstscConnect.ps1 with project host/port/user and save shots.

Pass if shots show GNOME UI and the agent cites log paths on failure.

## Do not

- Vendor one-off absolute ports/IPs into `SKILL.md`  
- Strip the `scripts/` directories when copying  
- Point GNOME 50 work at `linux-desktop-rdp-container` (xrdp/X11) as the primary path  
