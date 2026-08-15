---
name: kde-wayland-rdp
description: >
  Headless KDE Plasma on kwin_wayland --virtual with KRdp (not xrdp/X11). Use when
  packaging or debugging latest Plasma 6.7+ Wayland remote desktop in a container:
  kwin virtual OpenGL vs QPainter, vgem/DRM nodes, wslc seccomp EPERM on /dev/dri,
  KWIN_COMPOSE=O2, KRdp --plasma --virtual-monitor, mstsc CredSSP + FreeRDP
  NetworkAutoDetect RTT drop, PipeWire screencast "Unsupported compositing type",
  titlebar close/min/drag opening Kickoff (fake_input pointer at 0,0).
  Companion client: windows-ui-inject. GNOME/GRD: gnome-wayland-rdp. Plasma+xrdp:
  linux-desktop-rdp-container. Triggers: "/kde-wayland-rdp", "/kde-wayland-container",
  "latest KDE Wayland", "KRdp", "kwin_wayland --virtual".
author: Tim Sonner
license: MIT
---

# KDE Plasma Wayland + KRdp

**Stack:** `kwin_wayland --virtual` + `plasmashell` + `krdpserver --plasma --virtual-monitor`  
**Not this stack:** `xrdp` + `startplasma-x11` — see **`linux-desktop-rdp-container`**.  
**Not this stack:** GNOME Shell + GRD — see **`gnome-wayland-rdp`**.

Latest Plasma remote desktop on Wayland is **KRdp**, not xrdp. Hannah Montana / X11
Plasma images are a different product.

Client automation (mstsc Connect): **`windows-ui-inject`**.  
Container build/run on Windows: **`wsl-containers`**.  
Full drive loop: **`agent-workstation-drive`**.

### Scripts in this skill

| Path | Purpose |
|---|---|
| `scripts/kwin_wayland_virtual.sh` | Launch `kwin_wayland --virtual --no-lockscreen` with Mesa/DRM env |
| `scripts/start-kwin-gl.sh` | Session env + drop to `$DESKTOP_USER`; exec the wrapper |
| `scripts/start-krdp.sh` | `krdpserver --plasma --virtual-monitor` + autodetect/input preload |
| `scripts/mknod-dri.sh` | Create `/dev/dri` nodes from sysfs when the kernel has a card |
| `scripts/execns.c` | `setns` (mnt/net/ipc/uts/**pid**) + fork; start KWin/KRdp without seccomp |
| `scripts/krdp-autodetect.c` | `LD_PRELOAD`: NetworkAutoDetect + non-zero session size + MOVE-then-button |
| `scripts/promote-krdp-output.sh` | Disable Virtual-0; pin KRdp head at 0,0 |
| `scripts/ensure-plasma-panel.sh` | Recreate a full-width panel on the only live screen |
| `scripts/tune-plasma-perf.sh` | Turn off blur/overview/animations for software compose |
| `scripts/killcomm.c` | Kill leftover `kwin_wayland` / `krdpserver` by comm (host or after execns) |

Copy into the image as `/usr/local/bin/…` and `/usr/local/lib/libkrdp-autodetect.so`.
Compile `execns.c`, `krdp-autodetect.c` (`-shared -fPIC -ldl` → `libkrdp-autodetect.so`),
and `killcomm.c` at image build (or first run). Credentials and host publish come from
the **project** (env, README, `.rdp`) — not this skill.

## Architecture

```text
entrypoint (root)
  ├─ /dev/fuse + /dev/dri mknod from sysfs (if kernel has DRM)
  ├─ system dbus, seatd
  └─ runuser → session bring-up
        ├─ session dbus (wait ListNames)
        ├─ pipewire + wireplumber
        ├─ kwin_wayland --virtual   ← must be OpenGL, not QPainter
        ├─ plasmashell (software Qt Quick is OK)
        ├─ xdg-desktop-portal{,-kde} + kde-authorized permissions
        └─ krdpserver --plasma --virtual-monitor WxH@1
```

KRdp screencast uses KWin's `zkde_screencast_unstable_v1`. That protocol **rejects
QPainter**. Virtual KWin only offers OpenGL when `findRenderDevice()` opens a DRM
node. No `/dev/dri` → QPainter only → client authenticates then logoff / black.

## Why OpenGL fails in a container (class of problem)

| Layer | What happens |
|---|---|
| No DRM in the kernel | Virtual backend supports QPainter only |
| DRM in sysfs, no `/dev/dri` | `mknod` from `/sys/class/drm/*/dev` (see `mknod-dri.sh`) |
| Nodes exist, `open` → **EPERM** | Device cgroup **or** (on wslc) **seccomp**. `mknod` does not lift seccomp. |
| `LIBGL_ALWAYS_SOFTWARE=1` on KWin | EGL picks a device with an empty DRM render-node path; scene init fails |
| `KWIN_COMPOSE=O` | Plasma 6.7 **discards** a working EGL backend. Only `O2` / `O2ES` force OpenGL. |
| `QT_QPA_PLATFORM=wayland` before KWin | KWin tries to nest in a compositor that does not exist |

**DRM source:** a real card, **vgem**, or vkms. WSL2 kernels often ship `CONFIG_DRM_VGEM=m`
on the modules VHD (`/lib/modules/$(uname -r)/…/vgem/vgem.ko`). Load it on the **shared
kernel** (the wslc session / VM), then mknod inside the container. Container
`cap_sys_module` is usually gone.

**Seccomp:** if `grep Seccomp /proc/1/status` is `2`, KWin started *inside* the container
cannot issue `DRM_IOCTL_MODE_CREATE_DUMB` even on `0666` nodes. Start **KWin and KRdp**
from a process that has **no seccomp filter**, then `setns` into the container namespaces
(`scripts/execns.c`: ipc/uts/net/**pid**/mnt, then **fork** so the child is in the
container PID ns). Portals report `UnixProcessIdUnknown` if KRdp is only in the mount ns.
On Docker with `--device /dev/dri` and `seccomp=unconfined`, execns is unnecessary.

**execns target PID** is the container **init as seen from the host** (first pid in
`/sys/fs/cgroup/docker/<full-cid>/cgroup.procs`, often `sleep infinity`). Session
`pid 1` is the wslc VM, not the container.

vgem dumb buffers work on the **primary** node (`card0`), not `renderD128`. KWin already
prefers the vgem primary node.

Mesa for KWin once DRM is open: `MESA_LOADER_DRIVER_OVERRIDE=kms_swrast`. Do **not** set
`LIBGL_ALWAYS_SOFTWARE` on KWin. Plasmashell *clients* may use
`QT_QUICK_BACKEND=software` and `LIBGL_ALWAYS_SOFTWARE=1` so they do not need DRM under
seccomp.

Also: `setcap -r` on `kwin_wayland` (file `cap_sys_nice` + dropped bounding set → EPERM).
`KWIN_WAYLAND_NO_PERMISSION_CHECKS=1` so KRdp gets `zkde_screencast` / `fake_input`
without a `.desktop` launch. `--no-lockscreen`. Recreate the session bus after `pkill`
(stale socket). Do not skip starts based on `pgrep` — zombies look alive.

## Image / packages

Prefer a Fedora release that already has **Plasma ≥ 6.7** (`plasma-workspace`, `kwin`,
`krdp`). Hard-fail the build if `plasma-workspace` is older.

Need: kwin, krdp, plasma-desktop/workspace, pipewire, wireplumber, mesa dri/egl/gbm,
qt6-qtwayland, Xwayland, xdg-desktop-portal, xdg-desktop-portal-kde, seatd, fuse3, fonts.
Internal listen port is whatever the project sets (commonly 3389). Publish with
`wslc run -p <host-port>:<container-rdp-port>`.

## Session start order

1. Session dbus at `$XDG_RUNTIME_DIR/bus` — **wait** until `ListNames` works.  
2. PipeWire + WirePlumber.  
3. KWin via the virtual wrapper. **Unset** `QT_QPA_PLATFORM`. `KWIN_COMPOSE=O2`.  
4. Wait for `$XDG_RUNTIME_DIR/wayland-0` (or `wayland-1`). Then set
   `QT_QPA_PLATFORM=wayland` for **clients**.  
5. `plasmashell` (software Quick OK).  
6. Portals. Pre-authorize `kde-authorized` screencast + remote-desktop for
   `org.kde.krdpserver` (`gdbus` PermissionStore `SetPermission` → `['yes']`).  
7. TLS cert under the user's KRdp data dir.  
8. `krdpserver -u <user> -p <pass> --port <container-rdp-port> --certificate … --certificate-key … --virtual-monitor <W>x<H>@1 --plasma --quality 60`  
   plus `LD_PRELOAD=libkrdp-autodetect.so` if the client is **mstsc** (`--quality` ~40 on vgem).

Healthy KWin log: `OpenGL compositing has been successfully initialized`.  
Healthy KRdp connect: `New client connected` and
`kwin_screencast: "Virtual-…" state changed … → streaming`.  
Healthy encode: `Processed N frames` on motion (idle can be 0). `Processed 0` plus
`Failed to download DMA-BUF` / `empty buffer` means KRdp's GL device does not match KWin.

## Dual virtual heads (wallpaper-only / “dead” desktop)

`kwin --virtual` creates **Virtual-0**. `--virtual-monitor` adds **Virtual-WxH@1** (often at x=1920).
KRdp streams the second head. Panel and windows stay on Virtual-0 → RDP looks empty or glitchy.

After KRdp is up:

```text
kscreen-doctor output.Virtual-0.disable
kscreen-doctor output.Virtual-<W>x<H>@1.position.0,0
```

The KRdp head is created when a **client connects**, not at `krdpserver` start.
Promote **after** connect. Re-run if KRdp restarts (it re-adds the head). Then
`ensure-plasma-panel.sh` so Kickoff/tasks are on the live output, not the disabled one.

## Performance (software / vgem)

This path is **kms_swrast on vgem**, not a real GPU. Do not expect 60 fps.

- Never leave `LIBGL_DEBUG` / `EGL_LOG_LEVEL=debug` / `kwin_*.debug` on KWin (log flood stalls the scene).
- KRdp must use the **same** Mesa device as KWin (`MESA_LOADER_DRIVER_OVERRIDE=kms_swrast`). `LIBGL_ALWAYS_SOFTWARE=1` on KRdp cannot import vgem dmabufs → empty/glitchy frames.
- Disable blur/overview/animations (`tune-plasma-perf.sh` / kwinrc Plugins).
- `--quality` ~40; plasmashell may stay on `QT_QUICK_BACKEND=software`.
- `KWIN_DRM_USE_MODIFIERS=0` avoids empty modifier-negotiated buffers.

## Clients

KRdp is **NLA-only** and **one client**.

| Client | Notes |
|---|---|
| **mstsc** | CredSSP on. Seed **cmdkey** `TERMSRV/<host>`. `.rdp`: `enablecredsspsupport:i:1`, `authentication level:i:0`, `prompt for credentials:i:0`, **`smart sizing:i:1`** when the window is smaller than `--virtual-monitor`. Click **Connect**, never **Learn more** (`windows-ui-inject`). |
| **FreeRDP** | Works without the autodetect preload. Use when debugging the graphics path. |

mstsc after auth that dies at “Configuring remote session…” with server

```text
RTT Measure Response … support was not enabled
transport_check_fds: STATE_RUN_FAILED
```

is FreeRDP `NetworkAutoDetect=0`. Load `scripts/krdp-autodetect.c` (`FreeRDP_NetworkAutoDetect = 137` on FreeRDP 3.x — re-check `settings_keys.h` if the package major changes).

Do not turn CredSSP off to “fix” mstsc — KRdp then reports authentication not enabled.

Self-signed cert: client must accept / `authentication level:i:0`. Distinct `cmdkey` target if loopback already stores another desktop user.

FUSE clipboard is the same class as GRD: reuse **`gnome-wayland-rdp`** `nofuseabort` if CLIPRDR aborts the process. Frames work without clipboard.

## Pointer and titlebar

KRdp injects input with `org_kde_kwin_fake_input`. Motion is `pointer_motion_absolute`
(scaled by `AbstractSession::size()` / `logicalSize()`). Buttons are `button()` with
**no coordinates** — they fire wherever the compositor pointer already is.

If MOVE never updated the seat (or `size()` was 0 so the scale collapsed), the pointer
stays at **0,0**. Kickoff at the top-left of the streamed head then opens on every
titlebar click. Keyboard and Alt+Tab still work.

`scripts/krdp-autodetect.c` (same `.so` as NetworkAutoDetect) does three things:

1. Never return a zero QSize from `size` / `logicalSize` (Qt6: two ints in `rax`).
2. Remember the last non-zero mouse x,y; substitute on a 0,0 button packet.
3. On button-without-MOVE, call `mouseEvent(..., PTR_FLAGS_MOVE)` **then** the
   original flags. Hook `extendedMouseEvent` the same way.

Do **not** OR `PTR_FLAGS_MOVE` (0x0800) into the button flags. KRdp then takes the
MouseMove path and drops the click — close/min/drag become no-ops.

mstsc mapping: `smart sizing:i:0` on a window smaller than `--virtual-monitor`
**crops** the bitmap but still **scales** the mouse to the remote size. The X you
see is not the X KWin hits. Use `smart sizing:i:1`, or match the window to the
virtual monitor.

Verify inside the session (`spectacle -b -n -f -o /tmp/full-desktop.png`). An mstsc
screenshot can be a cropped viewport and hide the panel.

## Agent duty order (RDP broken)

1. **Logs first** — `/tmp/kwin.log`, `/tmp/krdp.log` / execns child log. Do not re-click Connect.  
2. `ss` listen on the container RDP port.  
3. Compositing is OpenGL (not QPainter). `ls /dev/dri`; `Seccomp` of KWin.  
4. PipeWire streaming / screencast state.  
5. Then drive the **client**.

## Symptom table

| Observation | Likely cause |
|---|---|
| No Wayland socket | `QT_QPA_PLATFORM=wayland` on KWin; or KWin died (caps / no bus) |
| KWin up, KRdp logoff / `Unsupported compositing type` | QPainter — no usable DRM or `KWIN_COMPOSE=O` |
| `/dev/dri` missing, `/sys/class/drm/card0` exists | Run `mknod-dri.sh` |
| `open(/dev/dri/card0)` EPERM | seccomp or device cgroup — execns or unconfined + `--device` |
| `CREATE_DUMB` EPERM after open | Same; KWin must not inherit container seccomp |
| EGL inits then “Could not fulfill … KWIN_COMPOSE: 1” | Value was `O` not `O2` |
| mstsc “token supplied to the function is invalid” | CredSSP/NLA mismatch or wrong cached `TERMSRV/` creds |
| mstsc auth OK, then drop on RTT | Missing `libkrdp-autodetect.so` |
| Wallpaper / stream, plasmashell SIGSEGV | Client tried DRM/Vulkan under seccomp — software Quick |
| Titlebar close/min/drag opens Kickoff (or no-ops) | Pointer at 0,0 or MOVE OR'd into the button flags — see **Pointer and titlebar** |
| Portal `UnixProcessIdUnknown` | KRdp not in the container PID ns — execns must `setns` pid then fork |
| Wallpaper-only after connect | Dual head — promote **after** the client is up; re-run panel helper |
| Second client fails | KRdp single session — disconnect the first |

## What not to do

- Do not use xrdp / `startplasma-x11` when the user asked for **latest Wayland**  
- Do not treat Hannah Montana / X11 Plasma as this stack  
- Do not set `KWIN_COMPOSE=O` or `N` for this path  
- Do not set `QT_QPA_PLATFORM=wayland` before KWin  
- Do not force `LIBGL_ALWAYS_SOFTWARE` on KWin once a DRM node exists  
- Do not hard-code host IPs, published ports, or passwords in this skill  
- Do not skip logs and only re-run mstsc  
- Do not OR `PTR_FLAGS_MOVE` into a KRdp button event  
- Do not `execns` into session pid 1 — use the container's host init pid  

## Cross-skill map

| Need | Skill |
|---|---|
| Full drive loop | `agent-workstation-drive` |
| mstsc / Windows UI injection | `windows-ui-inject` |
| GNOME 46+/50 + GRD | `gnome-wayland-rdp` |
| XFCE/Plasma + xrdp (X11) | `linux-desktop-rdp-container` |
| wslc build/run | `wsl-containers` |
| This stack | **`kde-wayland-rdp`** |
