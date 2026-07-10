---
name: wsl-containers
description: Commands, man-style CLI flags, and Microsoft.WSL.Containers API for building/running Linux containers via wslc on Windows (no Docker Desktop required).
author: Tim Sonner
license: MIT
---
# WSL Containers skill

Use this skill when building, running, inspecting, scripting, or troubleshooting **WSL Containers** (`wslc.exe` / `Microsoft.WSL.Containers`) on Windows.

**Primary docs (follow links)**
- Product overview: https://learn.microsoft.com/en-us/windows/wsl/wsl-container
- Tutorial: https://learn.microsoft.com/en-us/windows/wsl/tutorials/wsl-containers
- API reference hub: https://wsl.dev/api-reference/
- C# surface: https://wsl.dev/api-reference/csharp/
- Samples: https://aka.ms/wslc-samples → `microsoft/WSL` `doc/samples/`

**Deep local references (this skill)**
- `references/cli-reference.md` — full **man-style** flagbook for `wslc` 2.9.3.0 (run/create/exec/logs/build/image/network/volume/registry/session)
- `references/api-reference.md` — C# object model (`WslcService` → `Session` → `Container` → `Process`) with property tables + E2E sample
- `references/windows-skill-import.md` — Defender-safe skill import pattern

Also pair with: `wslc-pentest-workflow` for persistent Kali engagement containers + tooling.

Verified host baseline for this skill revision: **WSL / wslc 2.9.3.0**.

---

## 1. What WSL Containers is

Two major surfaces:

| Piece | Role |
|---|---|
| **`wslc.exe`** (alias binary also ships as `container.exe`) | Docker-familiar CLI for build/run/exec/logs/images/networks/volumes |
| **`Microsoft.WSL.Containers`** NuGet | Programmatic host API for Windows apps (C#, C++/WinRT, C `wslcsdk`) |

Architecture (layered):

```text
Windows app / PowerShell / Hermes
        │  wslc.exe or wslcsdk.dll
        ▼
Hyper-V sockets (WSLC_FORK / WSLC_MOUNT / WSLC_UNIX_CONNECT …)
        ▼
Session utility VM  ◄── dedicated UVM, NOT your Ubuntu distro
   - Moby / dockerd
   - OCI containers
   - CDI GPU (microsoft.com/wslc=gpu → /dev/dxg)
   - 9p / virtiofs host shares
```

Defaults observed/documented for a session VM: ~2 vCPU, ~2000 MB RAM, dynamic VHDX (~32 GB documented default), ~5 minute boot timeout. Override via `%LOCALAPPDATA%\wslc\settings.yaml` or `SessionSettings`.

---

## 2. Prerequisites & install

### Check
```powershell
wsl --version          # need a container-capable WSL (this skill: 2.9.3.0+)
wslc version           # should print wslc 2.9.3.0 (or newer)
wslc run --rm hello-world
```

If `wslc` is not on PATH:
```powershell
& "C:\Program Files\WSL\wslc.exe" version
# git-bash / Hermes POSIX shell:
'/c/Program Files/WSL/wslc.exe' version
```

### Update / enable
```powershell
# Admin/shell elevated as needed in older prerelease flows
wsl --update
# If still missing on older guidance channels:
wsl --update --pre-release
wsl --shutdown
```

There is **no separate Docker Desktop / engine install** for the CLI itself — `wslc` is part of the WSL package under `C:\Program Files\WSL\`.

### Settings file
```powershell
wslc settings            # open %LOCALAPPDATA%\wslc\settings.yaml
wslc settings reset      # rewrite commented defaults template
```

Important keys:
- `session.cpuCount`, `session.memorySize`, `session.maxStorageSize`
- `session.defaultBindingAddress` (default published-port bind = **`127.0.0.1`**)
- `credentialStore` = `wincred` | `file`

---

## 3. Agent workflow (how to use this skill)

1. Prefer **live help** when flag uncertainty remains: `wslc <cmd> --help` (or `-?`).
2. Prefer bind mounts for file I/O — **no `wslc cp`**.
3. For long-lived lab/pentest boxes, create **named** containers **without** `--rm`, and use incrementing engagement IDs (see `wslc-pentest-workflow`).
4. For capabilities missing from CLI (`--privileged`, cap-add), use either:
   - SDK `ContainerSettings.Privileged = true`, or
   - `wslc system session run docker run --privileged …`
5. Treat programmatic sessions as isolated from `wslc ps` unless they share the default CLI session.
6. Load man/flag tables from `references/cli-reference.md` and API tables from `references/api-reference.md` instead of inventing Docker-only flags.

### Hermes shell notes
- Hermes `terminal` on this profile is **git-bash / POSIX**, not PowerShell.
- Prefer POSIX paths (`/c/Users/admin/...`) or quoted Windows paths.
- Avoid PowerShell-only pipelines inside Hermes terminal unless you invoke `powershell.exe -NoProfile -Command '…'`.

---

## 4. Everyday CLI recipes

### Smoke test & inspect
```powershell
wslc run --rm hello-world
wslc run --rm -it ubuntu:latest bash -c "echo Hello world from WSL container!"
wslc images
wslc list            # aliases: ls, ps
wslc list -a
wslc stats
wslc container inspect <id>
wslc image inspect <image>
```

### Detached web server (tutorial pattern)
```powershell
wslc run -d --rm -p 8080:80 --name web nginx
curl http://localhost:8080/
wslc exec web cat /etc/os-release
wslc logs web --tail 100 --timestamps
wslc container stop web     # removed automatically because --rm
```

### Persistent container with bind mount
```powershell
wslc run -d --name kali-pentest-002 `
  -v "C:\Users\admin\pentest-workspace\engagement-002:/workspace" `
  kalilinux/kali-rolling sleep infinity

wslc exec kali-pentest-002 bash -lc 'apt-get update && uname -a'
wslc stop kali-pentest-002
wslc start kali-pentest-002
# destructor:
wslc remove -f kali-pentest-002
```

Create-then-start alternate:
```powershell
wslc create --name my-kali -it -v C:\data:/data kalilinux/kali-rolling bash
wslc start -ai my-kali
```

### Build from Dockerfile / Containerfile
```powershell
# from folder that contains Dockerfile or Containerfile
wslc build -t helloworld-django .
wslc build -f Containerfile -t app:dev --build-arg ENV=ci --no-cache .
wslc run -d --rm -p 8000:8000 --name django helloworld-django
wslc logs django
wslc exec django uname
```

### Resources, GPU, env, tmpfs
```powershell
wslc run -d --name heavy --cpus 2 -m 2G --shm-size 256M --tmpfs /tmp `
  -e APP_ENV=prod --env-file .env -w /app `
  --hostname worker1 myimg:latest

# GPU via CDI (microsoft.com/wslc=gpu)
wslc run -d --name ml --gpus all pytorch/pytorch:latest sleep infinity
```

> GPU path is DirectX/`/dev/dxg` style. Tools that hard-require classic OpenCL (often `hashcat`) still fail in many sessions — use CPU alternatives (`john`) or host GPU tooling (see pitfalls).

### Networks & volumes
```powershell
wslc network create labnet
wslc volume create appdata
wslc volume create -d vhd bigcache

wslc run -d --name a --network labnet --network-alias api `
  -v appdata:/var/lib/app alpine sleep infinity

wslc network list
wslc volume list
wslc network inspect labnet
```

### Registry auth
```powershell
echo $env:GHCR_PAT | wslc login -u USER --password-stdin ghcr.io
wslc pull ghcr.io/org/img:tag
wslc logout ghcr.io
```

### Housekeeping
```powershell
wslc container prune
wslc image prune -a
wslc volume prune -a
wslc network prune
wslc rmi -f old:image
wslc remove -f stale-ctr
```

### Export / save / load / import
```powershell
wslc export -o C:\bak\ctr.tar myctr
wslc save -o C:\bak\img.tar myimg:latest
wslc load -i C:\bak\img.tar
wslc import C:\bak\rootfs.tar restored:latest
```

### File copy without `cp`
```powershell
# Preferred: bind-mount and copy on either side of C:\… ↔ /workspace
# Host → container (PowerShell, binary-safe)
Get-Content -AsByteStream -Raw C:\path\file.bin |
  wslc exec -i myctr sh -c 'cat > /tmp/file.bin'

# Container → host
wslc exec myctr cat /etc/os-release > C:\tmp\os-release.txt
```

### Session VM / privileged bridge
```powershell
wslc system session list --verbose
wslc system session shell
wslc system session run docker ps
wslc system session run docker run -d --name priv --privileged `
  kalilinux/kali-rolling sleep infinity
wslc system session run docker exec -it priv id
wslc system session terminate
```

---

## 5. Man-page top-level map (load full tables from CLI reference)

| Command | Purpose |
|---|---|
| `run` / `create` / `start` / `stop` / `kill` / `remove` | Lifecycle |
| `exec` / `attach` / `logs` / `stats` / `list` (`ps`/`ls`) | Interact / observe |
| `build` / `images` / `pull` / `push` / `tag` / `load` / `save` / `import` / `rmi` | Images |
| `inspect` / `export` | Deep detail / filesystem tar |
| `network …` / `volume …` / `registry …` | Infra |
| `system session …` | UVM shell / docker engine bridge / terminate |
| `settings` | Open/reset YAML config |
| `version` | Show version |

### `run` / `create` flags (high-signal)

`--cidfile` · `--cpus` · `-d/--detach` (`run` only) · `--dns` · `--dns-option` · `--dns-search` · `--domainname` · `--entrypoint` · `-e/--env` · `--env-file` · `--gpus` · `-h/--hostname` · `-i/--interactive` · `-l/--label` · `-m/--memory` · `--name` · `--network` · `--network-alias` · `-p/--publish` · `-P/--publish-all` · `--rm` · `--shm-size` · `--stop-signal` · `--tmpfs` · `-t/--tty` · `--ulimit` · `-u/--user` · `-v/--volume` · `-w/--workdir` · `-?/--help`

### Flags **not** on 2.9.3.0 CLI surface
`--privileged` · `--cap-add` · `--device` · `wslc cp` · top-level `port`/`top` · top-level `prune` (use group `container|image|network|volume prune`)

Help always: `wslc <command> -?` (not `-h` at global level).

**Full flagbook:** `references/cli-reference.md`.

---

## 6. Developer API (`Microsoft.WSL.Containers`)

```powershell
dotnet add package Microsoft.WSL.Containers   # samples use 2.9.3
```

```csharp
using Microsoft.WSL.Containers;

// 1) Preconditions
var missing = WslcService.GetMissingComponents();
if (missing.Count > 0) { /* wsl --install / InstallWithDependencies */ }
var ver = WslcService.GetVersion();

// 2) Session = UVM
using var session = new Session(new SessionSettings("MyApp", @"C:\WslcData")
{
    CpuCount = 4,
    MemorySizeInMB = 4096,
    EnableGpu = false
});
session.Start();

// 3) Image
var pull = session.PullImageAsync(new PullImageOptions("docker.io/library/alpine:latest"));
pull.Progress = (_, p) => Console.WriteLine($"{p.Status} {p.CurrentBytes}/{p.TotalBytes}");
await pull;

// 4) Container + init process
var init = new ProcessSettings
{
    CommandLine = new[] { "/bin/echo", "Hello from WSL Container!" },
    OutputMode = ProcessOutputMode.Event
};
using var container = session.CreateContainer(new ContainerSettings("alpine:latest")
{
    Name = "hello-container",
    InitProcess = init,
    EnableAutoRemove = true,
    Privileged = false, // CLI cannot set this; API can
    PortMappings = { new ContainerPortMapping(8080, 80, PortProtocol.TCP) },
    Volumes = { new ContainerVolume(@"C:\data", "/workspace", false) }
});

container.InitProcess.OutputReceived += data =>
    Console.Write(System.Text.Encoding.UTF8.GetString(data));
container.Start();

// 5) Exec-style secondary process
var proc = container.CreateProcess(new ProcessSettings
{
    CommandLine = new[] { "/bin/sh", "-c", "uname -a" },
    OutputMode = ProcessOutputMode.Event
});
proc.Start();

// 6) Cleanup
if (container.State == ContainerState.Running)
    container.Stop(Signal.SIGTERM, TimeSpan.FromSeconds(10));
container.Delete(DeleteContainerOption.None);
session.Terminate();
```

Key types (see API reference for full members):

| Type | Job |
|---|---|
| `WslcService` | `GetMissingComponents`, `GetVersion`, `InstallWithDependencies[Async]` |
| `SessionSettings` | `Name`, `StoragePath`, `CpuCount`, `MemorySizeInMB`, `Timeout`, `EnableGpu`, `VhdRequirements` |
| `Session` | image pull/push/load/import/tag/delete, Authenticate, CreateContainer, VHD volumes, Start/Terminate |
| `ContainerSettings` | image, name, init process, ports, bind/named volumes, GPU, **Privileged**, networking mode, auto-remove |
| `Container` | Start/Stop/Delete/CreateProcess/Inspect/State |
| `ProcessSettings` / `Process` | CommandLine, env, cwd, OutputMode (`Discard|Stream|Event`), events + streams |
| Enums | `Signal`, `ContainerState`, `DeleteContainerOption`, `ContainerNetworkingMode`, `ProcessOutputMode`, `PortProtocol`, `VhdType` |

**Docs drift warning:** Learn page snippets sometimes say `MemoryMB`, `CmdLine`, `DeleteContainerFlags`, `ComponentFlags`. Prefer wsl.dev + IntelliSense:
- C# property: **`MemorySizeInMB`**, **`CommandLine`**, **`DeleteContainerOption`**
- missing components: **list count**, not bitwise flags in the C# projection

**Full API pages:** `references/api-reference.md`.

Official sample matrix:
- C Hello World · C++ Neofetch · C# Nextcloud (port map + bind data) · C# CustomContainerfile QR tool

---

## 7. Networking & ports

- Port publish via `-p` / `ContainerPortMapping`.
- Default host bind is **loopback** (`settings.session.defaultBindingAddress = 127.0.0.1`).
- For LAN reachability: `-p 0.0.0.0:8080:80` or change default bind in settings.
- Session networking modes (design docs): none / NAT / virtio proxy; container networks: bridge / host / none / join-netns (CLI: `network` driver default `bridge`).
- Avoid colliding host ports with Windows services and other WSL distro forwards.

---

## 8. GPU

- CLI: `--gpus all`
- API: `SessionSettings.EnableGpu` and/or `ContainerSettings.EnableGpu`
- Implementation: CDI v0.6.0, kind `microsoft.com/wslc`, device id `microsoft.com/wslc=gpu`, char device `/dev/dxg`, libraries overlaid like WSLg.
- Expect CUDA/DirectML-style stacks that understand WSL GPU; **not** a universal OpenCL guarantee.

---

## 9. Enterprise / policy

- Registry allowlist GPO: `WSLContainerRegistryAllowlist`
- Blocked pulls → `WSLC_E_REGISTRY_BLOCKED_BY_POLICY`
- Applies across CLI, SDK, and plugin paths
- Session **names** are enumerable machine-wide (name, creator SID, creator PID) — never embed secrets in session names

---

## 10. Troubleshooting & pitfalls

| Problem | Fix |
|---|---|
| `wslc` not recognized | `wsl --update`, restart shell, invoke `C:\Program Files\WSL\wslc.exe` |
| Containers from C# not in `wslc ps` | Different session `Name`/`StoragePath` than CLI default (`%LOCALAPPDATA%\wslc\sessions\…`) |
| Port works on localhost only | Expected with default bind — publish on `0.0.0.0` or change settings |
| Need privileged / CAP_NET_ADMIN | API `Privileged=true` **or** `wslc system session run docker run --privileged …` |
| No `wslc cp` | Bind-mount `-v` or stdin/stdout pipeline (see CLI reference) |
| Heredoc / nested quotes via `wslc exec … bash -lc '…'` fail | Write script into host mount; exec the **file path** |
| `system session run` appears to hang | Command finished but stdout not closed — collect output then kill waiters |
| `hashcat` → `CL_PLATFORM_NOT_FOUND_KHR` | OpenCL often absent; use `john` or host GPU path |
| Horizontal disk growth | `container prune`, `image prune -a`, `volume prune -a` |
| NTFS mount + SSH keys `chmod 600` noop | Copy key to container-native fs (`/tmp`) then chmod |
| Policy blocks registry | Check allowlist GPO / use permitted registry |
| Snippet won’t compile against NuGet | Projection renames — see API drift table |

Inspect helpers:
```powershell
wslc container inspect <id>
wslc container logs <id>
wslc image inspect <image>
wslc system session list --verbose
```

Microsoft troubleshooting entry points:
- WSL general: https://learn.microsoft.com/en-us/windows/wsl/troubleshooting
- Tutorial cleanup: `wslc container prune` / `wslc image prune`

---

## 11. Pentest / lab convention (pointer)

For engagement work on this machine, **do not** improvise random container names. Use the dedicated skill:

- Load `wslc-pentest-workflow`
- Workspace: `C:\Users\<user>\pentest-workspace\engagement-<ENG_ID>`
- Container: `kali-pentest-<ENG_ID>` with `/workspace` bind
- Always **increment** `ENG_ID` (never reuse `001`)

---

## 12. Success criteria

- [ ] `wslc version` works (or full path works)
- [ ] Ephemeral `wslc run --rm hello-world` succeeds
- [ ] Can `run -d`, `exec`, `logs`, `stop`, `remove`
- [ ] Bind mount writes appear on the Windows host
- [ ] Know where full flag/API tables live (`references/*`)
- [ ] Know privileged escape hatch + session isolation semantics
- [ ] For app integration: package installs and sample lifecycle compiles against documented type names

---

## 13. Quick command crib

```text
wslc version
wslc run --rm -it alpine sh
wslc run -d --name n -p 8080:80 -v C:\src:/src IMAGE
wslc exec -it n bash
wslc logs -f -n 200 n
wslc ps -a ; wslc images ; wslc stats
wslc build -t app:dev .
wslc stop n ; wslc rm -f n
wslc container prune ; wslc image prune -a
wslc system session run docker ps
wslc system session shell
```

When accuracy matters more than speed: open `references/cli-reference.md` or run `wslc <cmd> --help`.
