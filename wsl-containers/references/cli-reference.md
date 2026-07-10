# wslc(1) — Windows Subsystem for Linux Container CLI

**Source of truth for flag surface:** live `wslc.exe` help on WSL **2.9.3.0**  
(`C:\Program Files\WSL\wslc.exe`, also shipped as `container.exe`).

Official overviews:
- [WSL container](https://learn.microsoft.com/en-us/windows/wsl/wsl-container)
- [Get started with WSL container](https://learn.microsoft.com/en-us/windows/wsl/tutorials/wsl-containers)

Global help forms:
```text
wslc --help | wslc -?
wslc <COMMAND> --help | wslc <COMMAND> -?
wslc version | wslc -v | wslc --version
```

> There is **no** top-level `-h`. Use `-?` / `--help`.

---

## NAME
`wslc` — manage and interact with WSL-hosted Linux containers.

## SYNOPSIS
```text
wslc [<command>] [<options>]
```

## DESCRIPTION
`wslc` is the Windows-side Docker-compatible CLI shipped with WSL. It talks over Hyper-V sockets to a dedicated session utility VM that runs a Moby/`dockerd`-class engine. Containers are **not** extra WSL distros.

Binary locations (typical):
```text
C:\Program Files\WSL\wslc.exe
C:\Program Files\WSL\container.exe   # alias binary
```

Settings path (user):
```text
%LOCALAPPDATA%\wslc\settings.yaml
```
Open with `wslc settings`; restore template with `wslc settings reset`.

Default CLI session storage (observed):
```text
%LOCALAPPDATA%\wslc\sessions\wslc-cli-<username>\
```

---

## COMMAND MAP

| Domain | Commands / aliases |
|---|---|
| **Lifecycle (top-level)** | `run`, `create`, `start`, `stop`, `kill`, `remove` (`rm`/`delete`), `attach`, `exec`, `logs`, `stats`, `list` (`ls`/`ps`), `export`, `inspect` |
| **Images (top-level)** | `build`, `images`, `pull`, `push`, `tag`, `load`, `save`, `import`, `rmi` |
| **Grouped** | `container …`, `image …`, `network …`, `volume …`, `registry …`, `system session …`, `settings …` |
| **Auth** | `login`, `logout` (also under `registry`) |
| **Meta** | `version`, `settings` |

Top-level and grouped forms are generally equivalent, e.g.:
```text
wslc run …            ≡  wslc container run …
wslc images …         ≡  wslc image list …
wslc list / ps / ls   ≡  wslc container list / ps / ls
wslc rmi …            ≡  wslc image remove …
```

**Not present in 2.9.3.0 preview CLI (important):**
- `wslc cp` (no host↔container copy command)
- top-level `port`, `top`
- top-level `prune` (use `container prune` / `image prune` / `network prune` / `volume prune`)
- explicit `--privileged` / `--cap-add` / `--device` on `run`/`create` (privileged is available via SDK `ContainerSettings.Privileged` and via `wslc system session run docker …`)

---

## SETTINGS FILE

`%LOCALAPPDATA%\wslc\settings.yaml` (all keys comment-out defaults on first create):

| Key | Meaning | Default notes |
|---|---|---|
| `session.cpuCount` | vCPUs for the default session | all available CPUs |
| `session.memorySize` | session memory limit | half of available memory (examples use `2GB`) |
| `session.maxStorageSize` | max disk image size | `1TB` |
| `session.defaultBindingAddress` | host bind when `-p` omits address | `127.0.0.1` |
| `credentialStore` | `wincred` or `file` | `wincred` |

String value `"default"` means built-in default.

---

## GLOBAL OPTIONS

| Flag | Meaning |
|---|---|
| `-v`, `--version` | Show version |
| `-?`, `--help` | Show help for current command |

---

# LIFECYCLE COMMANDS

## wslc run
```text
wslc run [<options>] <image> [<command>] [<arguments>...]
wslc container run [<options>] <image> [<command>] [<arguments>...]
```
Runs a container. Foreground by default; use `-d/--detach` for background.

| Flag | Long form | Description |
|---|---|---|
| | `--cidfile <path>` | Write container ID to file |
| | `--cpus <n>` | CPU quota (`0.5`, `1`, `2.5`) |
| `-d` | `--detach` | Detached mode |
| | `--dns <ip>` | DNS nameserver in resolv.conf |
| | `--dns-option <opt>` | DNS options |
| | `--dns-search <domain>` | DNS search domains |
| | `--domainname <name>` | Container NIS domain name |
| | `--entrypoint <path>` | Override image ENTRYPOINT |
| `-e` | `--env KEY=VALUE` | Environment variable (repeatable) |
| | `--env-file <path>` | Env file of KEY=VALUE lines |
| | `--gpus all` | Add GPU devices (`all` = all GPUs; CDI:`microsoft.com/wslc=gpu`) |
| `-h` | `--hostname <name>` | Container hostname |
| `-i` | `--interactive` | Attach stdin, keep open |
| `-l` | `--label KEY=VALUE` | Metadata label |
| `-m` | `--memory <size>` | Memory limit (`512M`, `1G`) |
| | `--name <name>` | Container name |
| | `--network <name>` | Connect to named network |
| | `--network-alias <alias>` | Network-scoped alias |
| `-p` | `--publish [[ip:]host:]container[/proto]` | Publish port to host |
| `-P` | `--publish-all` | Publish all EXPOSEd ports to random host ports |
| | `--rm` | Auto-remove when container stops |
| | `--shm-size <size>` | `/dev/shm` size (`64M`, `1G`) |
| | `--stop-signal <sig>` | Signal used to stop container |
| | `--tmpfs <path>` | Mount tmpfs at path |
| `-t` | `--tty` | Allocate a TTY |
| | `--ulimit <name>=<soft>[:hard]` | Ulimit (`-1` = unlimited) |
| `-u` | `--user name\|uid\|uid:gid` | Run as user |
| `-v` | `--volume <src>:<dst>[:ro\|rw]` | Bind mount or named volume |
| `-w` | `--workdir <path>` | Working directory inside container |
| `-?` | `--help` | Help |

**Examples**
```powershell
wslc run --rm hello-world
wslc run --rm -it ubuntu:latest bash -c "echo hi from wslc"
wslc run -d --rm -p 8080:80 --name web nginx
wslc run -d --name app -v C:\Users\admin\src:/workspace -w /workspace -e APP_ENV=dev myimg:latest
wslc run -d --gpus all --name ml pytorch/pytorch:latest sleep infinity
```

**Port publish forms**
```text
-p 8080:80                 # host 127.0.0.1:8080 → container :80 (default bind from settings)
-p 0.0.0.0:8080:80         # all interfaces
-p 127.0.0.1:8443:443/tcp
-P                         # all EXPOSE’d ports → random host ports
```

**Volume forms**
```text
-v C:\data:/data
-v C:\data:/data:ro
-v myvol:/var/lib/app      # named volume
```

---

## wslc create
```text
wslc create [<options>] <image> [<command>] [<arguments>...]
```
Creates a container **without starting it**. Same option surface as `run` except no `-d/--detach` (attachment happens on later `start`).

Persistent engagement pattern:
```powershell
wslc create --name kali-pentest-002 -it `
  -v C:\Users\admin\pentest-workspace\engagement-002:/workspace `
  kalilinux/kali-rolling sleep infinity
wslc start kali-pentest-002
```

(Or one-shot: `wslc run -d --name … sleep infinity`.)

---

## wslc start
```text
wslc start [<options>] <container-id>
wslc container start …
```
| Flag | Long | Description |
|---|---|---|
| `-a` | `--attach` | Attach stdout/stderr |
| `-i` | `--interactive` | Attach stdin |
| `-?` | `--help` | Help |

---

## wslc stop
```text
wslc stop [<options>] [<container-id>]
wslc container stop …
```
| Flag | Long | Description |
|---|---|---|
| `-s` | `--signal` | Signal to send |
| `-t` | `--time <sec>` | Seconds to wait (default **5**) before hard kill path |
| `-?` | `--help` | Help |

---

## wslc kill
```text
wslc kill [<options>] <container-id>
wslc container kill …
```
| Flag | Long | Description |
|---|---|---|
| `-s` | `--signal` | Signal to send |
| `-?` | `--help` | Help |

---

## wslc remove / rm / delete
```text
wslc remove|rm|delete [<options>] <container-id>
wslc container remove …
```
| Flag | Long | Description |
|---|---|---|
| `-f` | `--force` | Delete even if running |
| `-?` | `--help` | Help |

---

## wslc attach
```text
wslc attach <container-id>
wslc container attach …
```
No extra flags beyond `-?`.

---

## wslc exec
```text
wslc exec [<options>] <container-id> <command> [<arguments>...]
wslc container exec …
```
| Flag | Long | Description |
|---|---|---|
| `-d` | `--detach` | Detached exec |
| `-e` | `--env KEY=VALUE` | Env override |
| | `--env-file <path>` | Env file |
| `-i` | `--interactive` | Keep stdin open |
| `-t` | `--tty` | Allocate TTY |
| `-u` | `--user name\|uid\|uid:gid` | User |
| `-w` | `--workdir <path>` | Working directory |
| `-?` | `--help` | Help |

**Patterns**
```powershell
wslc exec -it myctr bash
wslc exec myctr bash -lc 'apt-get update && apt-get install -y curl'
wslc exec -u 0 -w /workspace myctr sh -c 'id; pwd'
```

---

## wslc logs
```text
wslc logs [<options>] <container-id>
wslc container logs …
```
| Flag | Long | Description |
|---|---|---|
| `-f` | `--follow` | Stream / follow |
| `-n` | `--tail <n>` | Last *n* lines |
| `-t` | `--timestamps` | Include timestamps |
| | `--since <ts>` | Unix epoch seconds or RFC3339 (`2024-01-15T10:30:00Z`) |
| | `--until <ts>` | Upper bound timestamp |
| `-?` | `--help` | Help |

---

## wslc stats
```text
wslc stats [<options>] [<container-id>]
wslc container stats …
```
Snapshot of CPU, memory, network I/O, block I/O, PIDs.

| Flag | Long | Description |
|---|---|---|
| `-a` | `--all` | Include non-running |
| | `--format json\|table` | Output format (default `table`) |
| | `--no-trunc` | Do not truncate |
| `-?` | `--help` | Help |

---

## wslc list / ls / ps
```text
wslc list|ls|ps [<options>]
wslc container list|ls|ps …
```
Default: running only.

| Flag | Long | Description |
|---|---|---|
| `-a` | `--all` | All states |
| `-f` | `--filter …` | Filter expression |
| | `--format json\|table` | Output format |
| `-n` | `--last <n>` | Last *n* created (all states) |
| `-l` | `--latest` | Most recent (all states) |
| | `--no-trunc` | Do not truncate IDs/names |
| `-q` | `--quiet` | IDs only |
| `-?` | `--help` | Help |

Tutorial equivalents also accept `wslc container list --all`.

---

## wslc inspect
```text
wslc inspect [<options>] <object-id>
wslc container inspect <container-id>
wslc image inspect <image>
```
| Flag | Long | Description |
|---|---|---|
| `-t` | `--type <type>` | Restrict object type (top-level `inspect`) |
| `-?` | `--help` | Help |

---

## wslc export
```text
wslc export [<options>] <container-id>
wslc container export …
```
| Flag | Long | Description |
|---|---|---|
| `-o` | `--output <path>` | Write tar to file (else STDOUT) |
| `-?` | `--help` | Help |

---

## wslc container prune
```text
wslc container prune
```
Removes **all stopped** containers. No filters beyond `--help` in 2.9.3.0.

---

# IMAGE COMMANDS

## wslc build / wslc image build
```text
wslc build [<options>] <path>
wslc image build [<options>] <path>
```
`path` is the build context. Context file is `Dockerfile` or `Containerfile` (document both; samples use `Containerfile`).

| Flag | Long | Description |
|---|---|---|
| | `--build-arg KEY=VALUE` | Build-time ARG |
| | `--pull` | Always try to refresh base image |
| | `--target <stage>` | Multi-stage target |
| `-f` | `--file <path>` | Dockerfile path (`-` = stdin) |
| `-l` | `--label KEY=VALUE` | Image label |
| | `--no-cache` | Disable layer cache |
| `-t` | `--tag name[:tag]` | Tag built image |
| | `--verbose` | Verbose log |
| `-?` | `--help` | Help |

```powershell
wslc build -t helloworld-django .
wslc build -f Containerfile -t app:dev --build-arg ENV=ci --no-cache .
```

## wslc pull / wslc image pull
```text
wslc pull <image>
```
No extra flags in 2.9.3.0 beyond help. Reference fully qualified when needed:
```text
docker.io/library/alpine:latest
```

## wslc push / wslc image push
```text
wslc push <image>
```

## wslc tag / wslc image tag
```text
wslc tag <source> <target>
```
Forms: `image-name[:tag]`.

## wslc images / wslc image list / ls
```text
wslc images [<options>]
wslc image list|ls [<options>]
```
| Flag | Long | Description |
|---|---|---|
| `-f` | `--filter …` | Filter |
| | `--format json\|table` | Format |
| | `--no-trunc` | Full digests/IDs |
| `-q` | `--quiet` | IDs only |
| | `--verbose` | Verbose |
| `-?` | `--help` | Help |

## wslc rmi / wslc image remove / rm / delete
```text
wslc rmi [<options>] <image>
wslc image remove|rm|delete …
```
| Flag | Long | Description |
|---|---|---|
| `-f` | `--force` | Remove even if in use |
| | `--no-prune` | Do not delete untagged parents |
| `-?` | `--help` | Help |

## wslc image prune
```text
wslc image prune [<options>]
```
| Flag | Long | Description |
|---|---|---|
| `-a` | `--all` | All unused images, not just dangling |
| `-f` | `--filter …` | Filter |
| `-?` | `--help` | Help |

## wslc load / wslc image load
```text
wslc load -i <tar>
wslc image load -i <tar>
```
| Flag | Long | Description |
|---|---|---|
| `-i` | `--input <path>` | Tar archive path |
| `-?` | `--help` | Help |

## wslc save / wslc image save
```text
wslc save -o <path> <image>
```
| Flag | Long | Description |
|---|---|---|
| `-o` | `--output <path>` | Destination path |
| `-?` | `--help` | Help |

## wslc import / wslc image import
```text
wslc import [<options>] <file|-> [<image>]
```
Imports filesystem tarball into an image (optionally named).

| Flag | Long | Description |
|---|---|---|
| | `--no-trunc` | Do not truncate output |
| `-?` | `--help` | Help |

## wslc image inspect
```text
wslc image inspect <image>
```

---

# NETWORK COMMANDS

```text
wslc network create|remove|inspect|list|prune …
```

## network create
```text
wslc network create [<options>] <network-name>
```
| Flag | Long | Description |
|---|---|---|
| `-d` | `--driver <name>` | Driver (default `bridge`) |
| `-o` | `--opt KEY=VALUE` | Driver options |
| `-l` | `--label KEY=VALUE` | Metadata |
| `-?` | `--help` | Help |

## network remove / rm / delete
```text
wslc network remove [<options>] <network-name>
```
| Flag | Long | Description |
|---|---|---|
| `-f` | `--force` | No error if missing |

## network list / ls
| Flag | Long | Description |
|---|---|---|
| | `--format json\|table` | Format |
| `-q` | `--quiet` | Names only |

## network inspect
Detailed info for one+ networks.

## network prune
Removes unused networks (not referenced by any container).
| Flag | Long | Description |
|---|---|---|
| `-f` | `--filter …` | Filter |

Attach container to a network:
```powershell
wslc network create labnet
wslc run -d --name a --network labnet --network-alias api alpine sleep infinity
```

---

# VOLUME COMMANDS

```text
wslc volume create|remove|inspect|list|prune …
```

## volume create
```text
wslc volume create [<options>] [<volume-name>]
```
| Flag | Long | Description |
|---|---|---|
| `-d` | `--driver <name>` | `guest` (default) or `vhd` |
| `-o` | `--opt KEY=VALUE` | Driver options |
| `-l` | `--label KEY=VALUE` | Metadata |

```powershell
wslc volume create appdata
wslc volume create -d vhd bigcache
wslc run -d --name c -v appdata:/var/lib/app alpine sleep infinity
```

## volume remove / rm / delete
| Flag | Long | Description |
|---|---|---|
| `-f` | `--force` | No error if missing |

Cannot remove a volume that is in use.

## volume list / ls
| Flag | Long | Description |
|---|---|---|
| | `--format json\|table` | Format |
| `-q` | `--quiet` | Names only |

## volume inspect
Detailed volume metadata.

## volume prune
Removes unused **anonymous** local volumes; with `-a/--all` also unused named volumes.
| Flag | Long | Description |
|---|---|---|
| `-a` | `--all` | Include unused named volumes |
| `-f` | `--filter …` | Filter |

---

# REGISTRY / AUTH

```text
wslc login [<options>] [<server>]
wslc logout [<server>]
wslc registry login …
wslc registry logout …
```

### login
| Flag | Long | Description |
|---|---|---|
| `-u` | `--username` | Username |
| `-p` | `--password` | Password / PAT (prefer stdin) |
| | `--password-stdin` | Read secret from stdin |

```powershell
echo $PAT | wslc login -u myuser --password-stdin ghcr.io
wslc logout ghcr.io
```

Enterprise policy can block registries (`WSLC_E_REGISTRY_BLOCKED_BY_POLICY` / `WSLContainerRegistryAllowlist` GPO).

---

# SYSTEM / SESSION COMMANDS

```text
wslc system session list|run|shell|enter|terminate
```

| Subcommand | Purpose |
|---|---|
| `list [--verbose]` | Active sessions |
| `run <command> [args…]` | Run command in session **without TTY** (default = wslc default session) |
| `shell` | Interactive shell into session init namespace |
| `enter [--name <n>] <storage-path>` | Non-persistent session + shell; deleted on exit |
| `terminate` | Tear down session (default = default session) |

**Privileged / Docker-engine bridge (critical escape hatch):**
```powershell
# Talk to the session Moby engine directly
wslc system session run docker ps
wslc system session run docker run -d --name priv --privileged kalilinux/kali-rolling sleep infinity
wslc system session run docker exec -it priv bash
wslc system session run docker cp /tmp/staged priv:/root/staged
```

`system session run` often leaves stdout open → agents should not hang indefinitely on the process handle; capture needed output or kill after completion signal.

Debug shell:
```powershell
wslc system session shell
wslc system session list --verbose
wslc system session terminate
```

Ephemeral custom session:
```powershell
wslc system session enter --name tmp-lab C:\WslcTempLab
```

---

# FILE TRANSFER (NO `wslc cp`)

Preferred: bind-mount a host directory with `-v` and read/write under the mount.

PowerShell byte pipeline (binary-safe):
```powershell
# Host → container stdin
Get-Content -AsByteStream -Raw C:\path\file.bin |
  wslc exec -i myctr sh -c 'cat > /tmp/file.bin'

# Container → host (via stdout)
wslc exec myctr cat /etc/os-release > C:\tmp\os-release.txt
```

Session-stage when container is created outside default CLI list (privileged bridge):
```powershell
Get-Content -AsByteStream -Raw C:\path\file |
  wslc system session run /bin/sh -c 'cat > /tmp/staged'
wslc system session run docker cp /tmp/staged priv:/root/file
```

Tar import/export:
```powershell
wslc export -o C:\bak\ctr.tar myctr
wslc import C:\bak\fs.tar restored:latest
wslc save -o C:\bak\img.tar myimg:latest
wslc load -i C:\bak\img.tar
```

---

# QUICK MAN-PAGE CHEAT SHEET

```text
VERSION         wslc version
HELP            wslc --help | wslc <cmd> -?
SETTINGS        wslc settings | wslc settings reset

RUN/"DOCKER RUN"
  wslc run -d --rm -p 8080:80 -v C:\src:/src -e K=V --name n IMAGE [CMD]
  wslc run --gpus all …
  wslc run --cpus 2 -m 1G --shm-size 256M --tmpfs /tmp …

CREATE/START    wslc create --name n IMAGE sleep infinity ; wslc start n
EXEC            wslc exec -it n bash
LOGS            wslc logs -f -n 200 --timestamps n
STATS           wslc stats --format json
PS              wslc ps -a --format json -q
STOP/KILL/RM    wslc stop -t 10 n ; wslc kill -s SIGKILL n ; wslc rm -f n

BUILD/IMAGES    wslc build -t name:tag . ; wslc images ; wslc rmi -f id
PULL/PUSH/TAG   wslc pull alpine ; wslc tag a b ; wslc push b
PRUNE           wslc container prune ; wslc image prune -a
                wslc volume prune -a ; wslc network prune

NETWORK         wslc network create mynet ; wslc run --network mynet …
VOLUME          wslc volume create -d guest v ; wslc volume create -d vhd big
AUTH            wslc login -u u --password-stdin reg

SESSION/DEBUG   wslc system session list --verbose
                wslc system session shell
                wslc system session run docker …
                wslc system session terminate
```

---

# EXIT / TROUBLESHOOTING NOTES (CLI)

| Symptom | Likely cause / fix |
|---|---|
| `wslc` not found | Update WSL (`wsl --update`), restart shell, or invoke full path |
| Port not reachable on LAN | Default publish bind is `127.0.0.1` — set `defaultBindingAddress` or `-p 0.0.0.0:…` |
| Programmatic containers missing from `wslc ps` | Different **Session** name/storage than CLI default session |
| Need CAP_NET_ADMIN / privileged | Use SDK `Privileged=true` or `system session run docker run --privileged …` |
| Multi-line scripts via `exec` break | Write script into bind mount; `exec` the file path |
| `system session run` hangs agent | Command often finished; stdout still open — treat as fire-and-collect |
| GPU tools fail with OpenCL errors | GPU/CDI works for DirectX/`/dev/dxg` style; classic OpenCL (hashcat) still often fails — use CPU tools or host GPU path |

Verify version:
```powershell
wsl --version          # need container-capable build (2.9.3.0+ on this host)
wslc version
```
