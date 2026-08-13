---
name: gnome-wayland-rdp
description: >
  Headless GNOME Shell on Wayland with gnome-remote-desktop (GRD) for RDP — the
  GDM/GNOME-native path (not xrdp/X11). Use when packaging or debugging GNOME 46+
  (especially 50+) remote desktop in a container or lab VM: gnome-shell --wayland
  --headless, grdctl --headless, PipeWire streams, FUSE clipboard aborts, black
  RDP after Connect, session bus races, Azure Linux or Fedora-sourced GNOME RPMs,
  or when xrdp cannot run GNOME because --x11 is gone. Companion client UI: skill
  browser-read-bypass. X11/XFCE/Plasma+xrdp: skill linux-desktop-rdp-container.
author: Tim Sonner
license: MIT
---

# GNOME Wayland headless RDP (GRD)

**Stack:** `gnome-shell --wayland --headless` + `gnome-remote-desktop-daemon --headless`  
**Not this stack:** `xrdp` + X11 session (XFCE/Plasma) — see **`linux-desktop-rdp-container`**.

GNOME Shell 46+ dropped classic X11 session flags; Shell **50** is Wayland-oriented.
Remote access is **GRD** (FreeRDP server), not xrdp.

Client automation (mstsc Connect / credentials): **`browser-read-bypass`**.  
Full agent loop (build → connect → drive): **`agent-workstation-drive`**.

### Scripts in this skill

| Path | Purpose |
|---|---|
| `scripts/promote-rdp-monitor.py` | Meta-1 sole primary after GRD attach |
| `scripts/configure-desktop-ui.sh` | Wallpaper, dark theme, dash favorites |
| `scripts/nofuseabort.c` | Source for FUSE `LD_PRELOAD` stub |
| `scripts/libnofuseabort.so` | Prebuilt stub (x86_64 Linux) when present |

Copy into the image as `/usr/local/bin/…` and wire from the session start script.

## Architecture

```text
entrypoint (root)
  ├─ /dev/fuse node if missing (device alone is not enough under seccomp)
  ├─ system dbus, seatd, polkit (best-effort logind/linger)
  └─ runuser → start-gnome-headless-rdp.sh
        ├─ session dbus on $XDG_RUNTIME_DIR/bus  (wait until ListNames works)
        ├─ grdctl --headless rdp: TLS, credentials, port, enable
        ├─ pipewire + wireplumber
        ├─ gnome-shell --wayland --headless --virtual-monitor=WxH
        └─ gnome-remote-desktop-daemon --headless  (+ watchdog restart)
```

| Piece | Role |
|---|---|
| Session D-Bus | Shell and GRD die without it; cold start must **wait for bus**, not race |
| Virtual monitor | Shell creates Meta-* heads; GRD uses **virtual monitors** for remote |
| PipeWire | Screen cast / stream between Mutter and GRD |
| TLS cert/key | Self-signed under user GRD data dir; client must accept |
| FUSE clipboard | CLIPRDR wants `/dev/fuse`; container seccomp often **EPERM** |

## Agent duty order (RDP broken)

1. **Container/server logs first** — do not re-click mstsc in a loop  
2. Confirm **listen** on the RDP port inside the container (`ss` / healthcheck)  
3. Confirm **gnome-shell** and **gnome-remote-desktop-daemon** PIDs  
4. Confirm session bus + `XDG_RUNTIME_DIR`  
5. Only then drive the **client** UI  

Log paths (typical lab): under `/tmp/` for headless shell and GRD (name them clearly in the project). Prefer **append** on GRD restart so connect crashes are not truncated.

## Bring-up checklist

```text
[ ] User home + XDG_RUNTIME_DIR owned by desktop user (e.g. uid 1000)
[ ] Session dbus forking and answering ListNames before shell start
[ ] gnome-shell --wayland --headless --virtual-monitor=<W>x<H> stays up
[ ] grdctl --headless: TLS key/cert, credentials, port, rdp enable
[ ] pipewire + wireplumber running as same user
[ ] GRD daemon listening; healthcheck greps the chosen port
[ ] FUSE strategy decided (below) before promising clipboard
```

### `grdctl` (headless)

Configure as the **desktop user** with session env set:

- `rdp set-tls-key` / `set-tls-cert`
- `rdp set-credentials <user> <pass>` — from env or secrets, not committed literals in skills
- `rdp set-port <port>` — container-internal (commonly RDP well-known **3389**); host publish is a **run flag**, not a skill constant
- `rdp enable` / gsettings headless enable if needed

### Host publish (no hard-coded ports)

```text
wslc run -d --name <name> -p <host-port>:<container-rdp-port> -m <memory> <image>
```

Document `<host-port>` and credentials in the **project** README/RDP file. Skills use
placeholders only.

## FUSE clipboard (container)

Symptoms:

```text
fuse: failed to open /dev/fuse: Operation not permitted
[FUSE Clipboard] Failed to mount FUSE filesystem
```

`mknod /dev/fuse` is **not** enough if seccomp denies open. GRD starts a FUSE thread that
calls `g_error` on mount failure. After a demoted log, the thread may still **never**
complete `sync_point_start` → peer setup stalls → **black RDP** while mstsc stays "connected".

**Lab fix (proven class of workaround):** `LD_PRELOAD` a small shared object that:

1. Stubs `fuse_session_mount` → success  
2. Stubs `fuse_session_loop` → park the thread  
3. Optionally demotes residual FUSE-related `g_log` ERROR → WARNING  

Clipboard redirection will not work; **frames and input can**. Ship the `.so` in the image
and set `LD_PRELOAD` when starting GRD. Prefer this over requiring privileged FUSE when
the runtime (e.g. wslc) exposes no `--device`/`--cap-add`.

## Dual-head gotcha (wallpaper only on RDP)

Shell often starts with `--virtual-monitor` → **Meta-0**. GRD adds **Meta-1** (remote) beside it as a second head. Apps land on Meta-0; the client shows Meta-1 → wallpaper/empty.

After connect, promote Meta-1 to **sole primary** via Mutter `DisplayConfig.ApplyMonitorsConfig` (see project `promote-rdp-monitor.py`). Loop every few seconds while shell is up.

## Black screen vs dead server

| Observation | Likely cause |
|---|---|
| Nothing listening | Shell/GRD never started; session bus race; entrypoint failure |
| Listen OK, Connect → instant "session ended" | GRD **aborted** (often FUSE `g_error`) |
| Connect OK, black, title shows host | FUSE sync stall or graphics/stream not started; check GRD debug |
| Connect OK, solid color / wallpaper, "First frame" in log | Session healthy; buff UI next |
| `Failed to create EGL thread` | Common without GPU; RFX/software path may still stream via PipeWire |

Healthy connect log signals (names vary slightly by version):

- Creating / accepting RDP session  
- Virtual monitors / layout manager  
- PipeWire stream → **streaming**  
- RDPGFX CapsAdvertise accepted  
- Surface size + **First frame** metrics  

## Graphics / EGL notes

GRD may try HW EGL and log failure without GPU (`Failed to get EGL display`). That alone
is not fatal if PipeWire + RFX/H.264 software paths encode frames. Do not chase GPU in a
CPU-only container until FUSE/session logs are clean.

## GNOME / package source

- Stock Azure Linux core may lack a full DE; lab images often pull **GNOME 50+** RPMs from
  a Fedora version whose repos ship that shell major (pin major with `rpm` check in image build).
- Hard-fail image build if `gnome-shell` major is below the project requirement (e.g. 50).
- Slim install: shell + GRD + seatd + pipewire/wireplumber + mesa dri/egl + fuse3 + fonts + Xwayland as needed — not a full Fedora desktop.

## What not to do

- Do not substitute GNOME 49 when the project requires 50  
- Do not use xrdp `startwm` for GNOME 50 as the primary path  
- Do not hard-code host IPs or published ports in skills or shared snippets  
- Do not skip logs and only re-run mstsc  
- Do not click **Learn more** when testing clients (see **`browser-read-bypass`**)

## Cross-skill map

| Need | Skill |
|---|---|
| Full drive loop / new agent onboarding | `agent-workstation-drive` |
| mstsc / Windows UI injection | `browser-read-bypass` |
| XFCE/Plasma + xrdp containers | `linux-desktop-rdp-container` |
| wslc build/run/push | `wslc-containers` / `wsl-containers` |
| This stack (Wayland headless GNOME + GRD) | **`gnome-wayland-rdp`** |
