---
name: wsl-containers
description: >
  Build, run, debug, and publish Linux containers with Microsoft wslc on Windows
  (no Docker Desktop). Covers wslc CLI, no commit (export/import), DNS/apt, Hub
  and ghcr.io publish, system session / privileged, and Microsoft.WSL.Containers
  API. Use when: wslc, wslc.exe, WSL containers, wsl-containers, wslc-containers,
  "/wslc-containers", "/wsl-containers", ghcr.io login with wslc.
author: Tim Sonner
license: MIT
---

# WSL Containers (`wslc`)

Canonical name: **`wsl-containers`**. Older trigger **`wslc-containers`** is this skill.

`wslc.exe` ships with WSL ≥ 2.9.3. Docker-compatible subset. Containers run in a
**dedicated session UVM** (Moby/dockerd), not in your Ubuntu distro.

```text
Windows (wslc.exe / Microsoft.WSL.Containers)
        ▼  Hyper-V sockets
Session utility VM  —  dockerd + OCI  —  not a WSL distro
```

**Deep tables (do not invent Docker-only flags):**

| File | What |
|---|---|
| `references/cli-reference.md` | Man-style flagbook (`run`/`exec`/`build`/network/volume/session) |
| `references/api-reference.md` | C# `WslcService` → `Session` → `Container` → `Process` |
| `references/windows-skill-import.md` | Defender-safe skill import |

Official: [WSL container](https://learn.microsoft.com/en-us/windows/wsl/wsl-container) ·
[tutorial](https://learn.microsoft.com/en-us/windows/wsl/tutorials/wsl-containers) ·
[API](https://wsl.dev/api-reference/). Prefer live `wslc <cmd> --help` / `-?` when unsure.

Desktop images: **`kde-wayland-rdp`**, **`gnome-wayland-rdp`**, **`linux-desktop-rdp-container`**.
Long-lived Kali labs: **`wslc-pentest-workflow`**.

## Preconditions

```powershell
wsl --version          # container-capable WSL (2.9.3+)
wslc version
where.exe wslc         # typically C:\Program Files\WSL\wslc.exe
wslc run --rm hello-world
```

If missing: `wsl --update` (or `--pre-release` on older channels), then `wsl --shutdown`.
No Docker Desktop. Alias binary: `container.exe`.

Settings: `wslc settings` → `%LOCALAPPDATA%\wslc\settings.yaml`
(`session.cpuCount`, `memorySize`, `defaultBindingAddress` = **127.0.0.1**, `credentialStore`).

## Command map (docker/podman → wslc)

| docker / podman | wslc |
|---|---|
| `pull` / `run` / `exec` | same |
| `ps` | `wslc list` / `ps` / `list -a` |
| `rm -f` | `wslc remove -f` |
| `images` | `wslc images` |
| `build -t` | `wslc build -t … .` |
| `tag` / `push` / `pull` / `login` | same (`login … ghcr.io` for GHCR) |
| **`commit`** | **missing** → `export` + `import` |
| `save` / `load` | `wslc save` / `load` |
| `--restart unless-stopped` | not available |
| `-v path:path:Z` | `-v path:path` (no `:Z`) |
| `--dns` | `--dns 1.1.1.1` |
| `--privileged` / `--cap-add` / `--device` / `cp` | **not** on CLI 2.9.3 — see below |

Global help is `-?` / `--help`, not top-level `-h`.

## Everyday CLI

```powershell
wslc run --rm hello-world
wslc build -t myimage:tag .
wslc list -a
wslc remove -f mycontainer 2>$null
wslc run -d --name mycontainer -p 8080:80 -m 2G myimage:tag
wslc exec mycontainer bash -lc "uname -a"
wslc logs mycontainer --tail 100
wslc stop mycontainer
```

Desktop/RDP images: `-m 4G+`. Prefer **one-line** `wslc run` in PowerShell.

Persistent + bind mount:

```powershell
wslc run -d --name lab -v "C:\src:/src" myimage:tag sleep infinity
```

There is **no `wslc cp`**. Bind-mount, or pipe:

```powershell
Get-Content -AsByteStream -Raw C:\path\file.bin | wslc exec -i lab sh -c 'cat > /tmp/file.bin'
```

### No `commit` — snapshot

```powershell
wslc stop mycontainer
wslc export -o $env:TEMP\snap.tar mycontainer
wslc import $env:TEMP\snap.tar myimage:tag
```

Flattened FS. Prefer a Dockerfile rebuild for anything you publish.

### Port in use

```text
Failed to map port … WSAEADDRINUSE
```

`wslc list -a` then `remove -f` the holder, or pick another host port. Default publish
bind is **loopback**; use `-p 0.0.0.0:HOST:CTR` for LAN.

### Harmless noise

```text
wsl: Your kernel does not support swap limit capabilities or the cgroup is not mounted.
Memory limited without swap.
```

PowerShell may paint this red. If `wslc list` shows **running** and exit code is 0, treat as OK.

## DNS and apt inside containers

Debian slim often has **no** `/etc/apt/sources.list` (deb822 only).
`Temporary failure resolving 'deb.debian.org'`:

1. Entrypoint: write `1.1.1.1` / `8.8.8.8` if resolution fails.
2. Or `wslc run … --dns 1.1.1.1 --dns 8.8.8.8`
3. Or fix `/etc/resolv.conf` inside, then `apt-get update`.

Build stages often wipe `/var/lib/apt/lists/*`. Ship `ping`/`curl`/`iproute2` in desktop images.

## Host PowerShell vs Linux (quoting)

On Windows the agent usually launches `wslc` from **PowerShell**. That string is parsed
**twice**: once by PowerShell, then by bash in the container or the session UVM.

### What PowerShell rewrites

| You meant (Linux) | What happened |
|---|---|
| `$pid`, `$SESSION_MODE`, `$?` | Expanded or emptied on the **host** (`EXIT:True`) |
| `2>/dev/null` | Path `C:\dev\null` (`Could not find a part of the path`) |
| `gdbus … "['yes']"` | Quote matching exploded |
| `pgrep` / `pidof` in a mixed one-liner | PowerShell looks for a **cmdlet** |
| Here-string of bash + CRLF | Linux sees `$'\r': command not found` |

### What `wslc` itself drops

- `wslc system session run` + long path / `sh -c` / CRLF → **`The handle is invalid`**
- `wslc exec … bash -lc '…'` + heredoc, nested quotes, or `$` → quoting hell  
  (same lesson in **`wslc-pentest-workflow`**: write the file, then exec the path)
- Session `run` can **finish without closing stdout** — collect output, do not wait forever

### Do this instead

1. Write a `.sh` on the host with **LF** (UTF-8, no BOM). After copy: `sed -i 's/\r$//'`.
2. Bind-mount or `tee` it in; run `bash /path/script.sh`. Do not inline gdbus/portal JSON.
3. If you must one-line: put the **Linux** script in **single** quotes so PowerShell does
   not expand `$`. Never put `2>/dev/null` inside a double-quoted PowerShell string —
   use `2>&1` or a file.
4. `system session`: short argv only (`/run/ash -c ls`, `/en <host-pid> -d /usr/local/bin/…`).
5. `Add-Type` + `System.Drawing`: Windows PowerShell **5.1** — **`windows-ui-inject`**.

## Privileged / devices / session VM

CLI 2.9.3 has no `--privileged`, `--cap-add`, or `--device`. Escape hatches:

```powershell
wslc system session list --verbose
wslc system session run docker run --privileged --name priv IMAGE sleep infinity
wslc system session run docker exec priv id
```

Or C# `ContainerSettings.Privileged = true` (`references/api-reference.md`).
SDK sessions with a custom `Name`/`StoragePath` **do not** show up in `wslc ps`.

Keep `system session run` commands **short** — see **Host PowerShell vs Linux** above.

GPU: `--gpus all` → CDI `microsoft.com/wslc=gpu` / `/dev/dxg`. Not a universal OpenCL
guarantee (`hashcat` often fails).

## Publish

### Docker Hub

```powershell
wslc login
wslc tag myimage:tag <user>/myrepo:tag
wslc push <user>/myrepo:tag
```

### GHCR

```powershell
wslc login -u <github-user> -p $env:CR_PAT ghcr.io
wslc tag myimage:tag ghcr.io/<github-user>/myrepo:rdp
wslc push ghcr.io/<github-user>/myrepo:rdp
```

| | Hub | GHCR |
|---|---|---|
| Host | `docker.io` | **`ghcr.io`** |
| Image | `<user>/name:tag` | `ghcr.io/<user>/name:tag` (often **lowercase**) |
| Auth | Hub token | **Classic** PAT `write:packages` |

After GHCR push: package page → **Connect repository**; set **Public** if anonymous pulls
matter. `org.opencontainers.image.source` helps new tags, not always old ones.

~10 GB/layer, ~10 min upload — large desktop images may need retry.

### Git of the packaging repo (not the image)

Fine-grained PAT: repo Contents **read/write**. Do not commit tokens.

Published image README: pull-first + credentials table, then build-from-source. Lab
passwords stay in the **project**, not this skill.

## Agent checklist

1. `wslc version` before assuming Docker/Podman.
2. Never invent `wslc commit` or `wslc cp`.
3. After `run`, trust `wslc list` (not only stderr).
4. Hub vs GHCR: different host and token type.
5. Desktop/RDP: also load the desktop skill for that stack; `-m 4G+` for GNOME/Plasma.
6. Need caps/DRM that CLI cannot grant → `system session` or execns from the UVM
   (see **`kde-wayland-rdp`**).

## Pitfalls

| Problem | Fix |
|---|---|
| `wslc` not recognized | Full path under `C:\Program Files\WSL\`; `wsl --update` |
| Port only on localhost | Default bind `127.0.0.1` |
| Need privileged / extra devices | Session `docker run --privileged` or API `Privileged` |
| C# containers missing from `wslc ps` | Different session storage than the CLI |
| `hashcat` OpenCL | Often no platform; use CPU/`john` or host GPU |
| NTFS bind + `chmod 600` | Copy key onto container-native fs first |
| `$'\r': command not found` | Strip CR on scripts copied from Windows |
| `C:\dev\null` | Do not put `2>/dev/null` in a double-quoted PowerShell string |
| `The handle is invalid` | Shorten `system session` argv; no CRLF; no long `sh -c` |

## Cross-skill map

| Need | Skill |
|---|---|
| Plasma Wayland + KRdp | `kde-wayland-rdp` |
| GNOME 50 + GRD | `gnome-wayland-rdp` |
| XFCE/Plasma + xrdp | `linux-desktop-rdp-container` |
| Drive loop / mstsc | `agent-workstation-drive` / `windows-ui-inject` |
| Kali engagement boxes | `wslc-pentest-workflow` |
| This CLI + API | **`wsl-containers`** |
