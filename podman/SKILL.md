---
name: podman
description: "Use when creating, running, exec'ing, composing, or tearing down Podman containers on this host (incl. Cockpit). Prefer Podman over Docker for new work; never confuse with libvirt VMs."
version: 1.1.0
author: Tim Sonner
license: MIT
platforms: [linux]
metadata:
  hermes:
    tags: [Podman, containers, Cockpit, compose, devops, OCI, xrdp, RDP]
    related_skills: [podman-mcp-manager, container-desktop-rdp, persistent-containers, ladybird-build]
prerequisites:
  commands: [podman]
---

# Podman containers

Manage OCI containers with **Podman** on this Linux host. Day-to-day automation is CLI; **Cockpit + cockpit-podman** is the optional web UI.

## Overview

Podman runs the same class of images as Docker (OCI / Docker Hub / GHCR) but is a **separate engine**. It does not control the Docker daemon. Rootless is the default preference on this host.

**This host context (keep current):**

| Stack | Role |
|-------|------|
| **Podman** | Preferred for new app containers (agent-managed) |
| **cockpit-podman** | Containers tab in Cockpit (Podman only) |
| **Docker** | May still be installed — do not assume shared running state |
| **libvirt / cockpit-machines** | Full VMs (e.g. `windows-11`) — not containers |
| **Cockpit URL** | https://localhost:9090 (`cockpit.socket` → port **9090**) |

## When to Use

- Create / start / stop / remove containers
- `exec` commands or a shell inside a container
- Build images, pull, tag, push (when auth allows)
- Compose stacks (`podman compose` / Compose YAML)
- Logs, port checks, volume cleanup
- User mentions Cockpit containers, rootless Podman, or “spin up a service in a container”

**Don't use for:**

- Full OS desktops that need their own kernel, GPU passthrough, or Windows → **libvirt VM**
- Managing containers that were started with **`docker`** (different runtime; list with `docker ps`, not `podman ps`)
- Kubernetes cluster ops (Podman is single-host; `podman play kube` is not a cluster)

## Prerequisites

```bash
# Install engine + Cockpit UI (Ubuntu/Debian)
sudo apt update
sudo apt install -y podman cockpit-podman

# Optional: user API socket (Cockpit / clients)
systemctl --user enable --now podman.socket
# socket: unix:///run/user/$(id -u)/podman/podman.sock

# Sanity
podman version
podman info --format '{{.Host.Security.Rootless}} {{.Host.Arch}}'
```

Completion: `podman version` works without sudo; Cockpit shows a **Podman** / containers section after reload or re-login.

## Operating rules

1. **Prefer rootless** (`podman` as the user). Only use `sudo podman` / rootful when the workload requires it (privileged ports &lt;1024 without redirect, some devices) — say so before doing it.
2. **Name everything** — `--name` on run; consistent compose project names. Never leave anonymous one-offs without a label if they outlive the command.
3. **Publish ports explicitly** — `-p HOST:CONTAINER`. Prefer high host ports when rootless (e.g. `8080:80`).
4. **Persist data in volumes or bind mounts** — not container writable layer — for anything the user might care about after recreate.
5. **Tear down completely** when asked to “remove/break down”: stop → rm container → remove unused vols/networks **only** if they were created for that workload (don't global-prune by default).
6. **VMs stay VMs** — never “fix” a libvirt domain with a container destroy. Check `virsh` / Cockpit Machines only when the user asked about VMs.
7. **Docker coexistence** — if both exist, state commands must use the matching CLI. Confirm with `podman ps -a` and, only if relevant, `docker ps -a`.

## Core workflow

### 0) Discover

```bash
podman ps -a --format 'table {{.Names}}\t{{.Status}}\t{{.Image}}\t{{.Ports}}'
podman images
podman volume ls
podman network ls
podman info
```

Done when you know what already exists and won't collide on name/port.

### 1) Run (one-shot or detached service)

```bash
# detached named service, port publish, restart policy
podman run -d \
  --name SERVICE \
  --restart unless-stopped \
  -p HOSTPORT:CONTAINERPORT \
  -v VOL_OR_PATH:/data:Z \
  -e KEY=value \
  IMAGE:TAG

# foreground / one-shot (auto-remove)
podman run --rm -it IMAGE:TAG CMD
```

Notes:

- SELinux hosts: `:Z` / `:z` on binds when needed; on Ubuntu often unnecessary.
- Rootless + host port &lt;1024 often fails — use higher host port or rootful deliberately.

Done when `podman ps` shows the container healthy/up and `podman port SERVICE` matches intent.

### 2) Exec / send commands

```bash
podman exec SERVICE CMD [ARGS...]
podman exec -it SERVICE /bin/sh    # or bash if present
podman logs -f --tail 200 SERVICE
podman top SERVICE
```

Done when exit code and stdout/stderr are captured for the user (or error explained).

### 3) Lifecycle

```bash
podman stop SERVICE
podman start SERVICE
podman restart SERVICE
podman rm SERVICE              # must be stopped unless -f
podman rm -f SERVICE           # force
podman image rm IMAGE
```

### 4) Compose

```bash
# from directory with compose.yaml / docker-compose.yml
podman compose up -d
podman compose ps
podman compose logs -f
podman compose exec SERVICE CMD
podman compose down            # containers + default network
podman compose down -v         # also volumes — only if user wants data gone
```

If `podman compose` is missing, try `podman-compose` or install compose support; don't silently fall back to Docker Compose against dockerd unless the user asked for Docker.

Done when services are up (or fully down) per `podman compose ps` / `podman ps`.

### 5) Build

```bash
podman build -t NAME:TAG -f Containerfile .
# Dockerfile works too
podman build -t NAME:TAG .
```

### 6) Inspect / debug

```bash
podman inspect SERVICE --format '{{.State.Status}} {{.RestartCount}}'
podman inspect SERVICE --format '{{json .NetworkSettings}}' | head -c 2000
podman events --filter container=SERVICE --since 10m
ss -lntp | grep HOSTPORT || true
curl -sS -o /dev/null -w '%{http_code}\n' http://127.0.0.1:HOSTPORT/ || true
```

## Networking cheat sheet

| Goal | Flag / action |
|------|----------------|
| Publish port | `-p 8080:80` |
| Host network (Linux) | `--network host` (less isolation) |
| User-defined network | `podman network create NAME` then `--network NAME` |
| DNS between containers | same custom network; use container **names** |
| Rootless port issues | higher host port; or `net.ipv4.ip_unprivileged_port_start` |

## Volumes

```bash
podman volume create APP-data
podman run -v APP-data:/var/lib/app:Z ...
podman volume inspect APP-data
# bind mount
podman run -v /home/tim/app-data:/data:Z ...
```

Destroy path: `podman rm` then `podman volume rm APP-data` only if disposable.

## systemd inside a container

Needed for multi-service “mini VMs” when services expect PID 1 systemd. Prefer a **custom entrypoint** for xrdp (see RDP section) — rootless `--systemd=always` is flaky (`systemctl is-system-running` hangs; dbus zombies).

```bash
podman run -d --name arch-sys \
  --systemd=always \
  --hostname arch-sys \
  -p 13389:3389 \
  archlinux:latest
```

Prefer a purpose-built image + entrypoint over long manual exec sessions when repeating.

## Desktop RDP container (proven on this host)

**Goal:** remote XFCE desktop over RDP into a **persistent** Podman container. Client tested: `wlfreerdp3`.

### Base image choice

| Base | xrdp | Notes |
|------|------|--------|
| **Ubuntu 24.04** | `apt install xrdp xorgxrdp` | **Preferred** — packages in universe |
| **Arch** | AUR only (`xrdp` / `xorgxrdp`) | XFCE via pacman is fine; AUR build is slow/fragile in containers |

Do **not** fight Arch AUR for first RDP — use Ubuntu.

### Persistence pattern (required for durable desktops)

1. Install packages + write `/usr/local/bin/rdp-entrypoint.sh` (starts dbus, xrdp-sesman, xrdp, then `sleep infinity`)
2. `podman commit` → e.g. `localhost/rdp-xfce:persistent` with `ENTRYPOINT` set
3. Named volumes: `rdp-home` → `/home/USER`, `rdp-xrdp-etc` → `/etc/xrdp`
4. Run with `--restart unless-stopped` and high host port (rootless): `-p 13389:3389`
5. Host: `loginctl enable-linger $USER` so rootless containers return after reboot
6. Optional note file: `~/Documents/rdp-container.md`

```bash
podman volume create rdp-home
podman volume create rdp-xrdp-etc
podman run -d --name rdp --hostname rdp --restart unless-stopped \
  -p 13389:3389 \
  -v rdp-home:/home/tim \
  -v rdp-xrdp-etc:/etc/xrdp \
  localhost/rdp-xfce:persistent
```

**Recreate keeps data** if volumes are kept; only image/entrypoint need reinstall if you `rm -f` without volumes.

### Entrypoint essentials

- `startwm.sh` / `.xsession` → `startxfce4` / `xfce4-session`
- `unset DBUS_SESSION_BUS_ADDRESS` and `XDG_RUNTIME_DIR` before session (avoids black screen)
- Start `/usr/sbin/xrdp-sesman --nodaemon` then `/usr/sbin/xrdp --nodaemon` in background; PID 1 = `sleep infinity` (or systemd if it works)
- Create login user + password inside image **and** ensure volume-mounted `/home` gets `.xsession` on first boot

### Connect

```bash
wlfreerdp3 /v:127.0.0.1:13389 /u:tim /p:PASSWORD /cert:ignore
# optional: /size:1920x1080 /network:auto
```

### Port / concurrency pitfalls (hard lessons)

1. **One host port owner** — only one container may publish `13389`. Arch with `--restart unless-stopped` will **steal the port** after reboot/kill and block `rdp` start (`pasta: Address already in use`).
2. Fix: `podman update --restart=no OTHER`; `podman stop OTHER`; free pasta with `fuser -k 13389/tcp` if needed; then `podman start rdp`.
3. **Exit 137** during heavy `apt` is often OOM-kill of the **exec** or cgroup pressure — retry install; host may still show free RAM.
4. **Stale apt locks** after interrupted installs: clear `/var/lib/dpkg/lock*` inside container, `dpkg --configure -a`, re-run apt.
5. TCP probe to 3389 is **not** a full RDP handshake — `libxrdp_force_read` errors in logs from `bash /dev/tcp` are expected; use `wlfreerdp3` to validate.
6. Building large apps (e.g. Ladybird) → put source under the **home volume**; install Qt 6.9+ via `aqtinstall` if distro Qt is &lt; 6.9; use `clang-21` + Kitware CMake ≥ 3.30 (see **ladybird-build** skill).

### This host’s current RDP stack (keep current)

| Item | Value |
|------|--------|
| Container | `rdp` |
| Image | `localhost/rdp-xfce:persistent` |
| Port | **13389** |
| Volumes | `rdp-home`, `rdp-xrdp-etc` |
| Restart | `unless-stopped` |
| User | `tim` (password set at create time) |
| Docs | `~/Documents/rdp-container.md` |

## Cockpit

- URL: **https://localhost:9090**
- Package: `cockpit-podman`
- UI manages **Podman only** (not Docker, not libvirt)
- Agent still prefers CLI for automation; mention UI when user is clicking around

Install reference also lives at `~/Documents/cockpit-install.md` on this machine.

## Decision: container vs VM

| Need | Choose |
|------|--------|
| App/service, API, DB, CLI toolchain | **Podman container** |
| Full desktop + RDP (toy/sandbox) | **Ubuntu container + xrdp** (persistence pattern); VM if daily driver / GPU |
| Windows, other kernel, GPU passthrough, nested virt | **libvirt VM** (Cockpit Machines) |
| Kernel modules, custom kernel | **VM** |

## Safety

- Do not expose RDP/SSH/DB ports to `0.0.0.0` on untrusted networks without saying so; prefer localhost publish or firewall.
- Do not `podman system prune -a --volumes` unless the user explicitly wants a wide cleanup — it deletes unused images and volumes.
- Do not remove Docker resources with Podman or vice versa.
- Secrets: prefer env files with restricted perms or podman secrets; avoid pasting long-lived tokens into image layers.

## Common pitfalls

1. **`podman` not found** — install `podman` (and `cockpit-podman` if UI wanted); recheck PATH.
2. **Container “missing” in Cockpit** — it was started with Docker, or rootful vs rootless mismatch (root sees different containers than user).
3. **Permission denied on port** — rootless binding low port; remap host port ≥1024.
4. **Data vanished after recreate** — forgot volume; always mount before declaring the service durable.
5. **Using `docker` commands out of habit** — only when user wants Docker; default new work to Podman once installed.
6. **Assuming Arch/Ubuntu container = that distro’s kernel** — always host kernel.
7. **Force-rm production-looking names without confirm** — if name suggests user data (`*prod*`, `*db*`, `windows*`), confirm scope first. `windows-11` is a **VM**, not a container.
8. **RDP port stolen by another container’s restart policy** — disable restart on competitors; only one publisher per host port.
9. **Arch for xrdp** — AUR-only; prefer Ubuntu image for desktop RDP unless user insists on Arch.
10. **Ephemeral desktop** — packages lost on `rm` without commit/volumes; always use persistence pattern above for RDP.

## Verification checklist

After any create/change:

- [ ] `podman ps -a` shows expected name and status
- [ ] Ports: `podman port NAME` and/or local curl/connect test
- [ ] Logs clean enough to explain failures (`podman logs --tail 100 NAME`)
- [ ] Persistent paths use volumes/binds when required
- [ ] Teardown (if requested): container gone; named vols/networks removed only as agreed
- [ ] Did not touch libvirt VMs or Docker resources unless asked

## One-shot recipes

### Smoke test

```bash
podman run --rm hello-world
podman run --rm -d --name nginx-smoke -p 8080:80 docker.io/library/nginx:alpine
curl -sS -o /dev/null -w '%{http_code}\n' http://127.0.0.1:8080/
podman rm -f nginx-smoke
```

### Ephemeral shell

```bash
podman run --rm -it docker.io/library/alpine:latest /bin/sh
```

### Tear down one named service hard

```bash
podman stop SERVICE 2>/dev/null; podman rm -f SERVICE
# optional: podman volume rm SERVICE-data
```

### Persistent RDP desktop (summary)

```bash
# after image localhost/rdp-xfce:persistent exists (see Desktop RDP section)
podman run -d --name rdp --restart unless-stopped -p 13389:3389 \
  -v rdp-home:/home/tim -v rdp-xrdp-etc:/etc/xrdp \
  localhost/rdp-xfce:persistent
wlfreerdp3 /v:127.0.0.1:13389 /u:tim /p:PASSWORD /cert:ignore
```

## Agent completion style

When the user asks to manage containers: run real commands, report names/ports/status from tool output, and leave the system in the state they asked for (up or fully down). Prefer exact command echoes in summaries when they like brief/command-oriented replies.
