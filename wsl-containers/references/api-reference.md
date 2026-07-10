# Microsoft.WSL.Containers API Reference (C# projection)

**Status:** Preview API — pin package versions. Microsoft docs note subject-to-change until GA (targeted fall 2026 in public docs).

**Authoritative docs**
- Overview: https://learn.microsoft.com/en-us/windows/wsl/wsl-container
- Full multi-language surface: https://wsl.dev/api-reference/
- C# index: https://wsl.dev/api-reference/csharp/
- Samples (C / C++/WinRT / C#): https://aka.ms/wslc-samples → microsoft/WSL `doc/samples/`
- NuGet: `Microsoft.WSL.Containers` (samples pin `2.9.3`)

**Related CLI man-page:** `references/cli-reference.md`

---

## Object model

```text
WslcService  (static install/version checks)
    └── Session  (one Hyper-V utility VM + image/volume store)
            └── Container  (one OCI container)
                    └── Process  (init process + secondary exec processes)
```

Typical flow:
1. `WslcService.GetMissingComponents()` / `GetVersion()`
2. `new Session(SessionSettings)` → `Start()`
3. `PullImageAsync` / `LoadImage` / `ImportImage`
4. `CreateContainer(ContainerSettings)` → subscribe process events → `Start()`
5. optional `CreateProcess` for exec
6. `Stop` + `Delete` + `Session.Terminate()` + `Dispose()`

---

## Install

### C#
```powershell
dotnet add package Microsoft.WSL.Containers
```
```csharp
using Microsoft.WSL.Containers;
```

Project notes from official samples:
```xml
<TargetFramework>net8.0-windows10.0.19041.0</TargetFramework>
<!-- native wslcsdk.dll is arch-specific -->
<PlatformTarget Condition="'$(PlatformTarget)' == ''">x64</PlatformTarget>
<PackageReference Include="Microsoft.WSL.Containers" Version="2.9.3" />
```

### C++/WinRT (preview, breaking changes possible)
```cpp
#include <winrt/Microsoft.WSL.Containers.h>
using namespace winrt::Microsoft::WSL::Containers;
```

### C
Header/lib: `wslcsdk.h` / `wslcsdk.lib` / `wslcsdk.dll` — see https://wsl.dev/api-reference/c/

---

## WslcService (static)

```csharp
public static class WslcService
{
    public static IReadOnlyList<Component> GetMissingComponents();
    public static ServiceVersion GetVersion();
    public static void InstallWithDependencies();
    public static IAsyncActionWithProgress<InstallProgress> InstallWithDependenciesAsync();
}
```

```csharp
var missing = WslcService.GetMissingComponents();
if (missing.Count > 0)
{
    Console.WriteLine($"Missing: {string.Join(", ", missing)}");
    // also: WslcService.InstallWithDependencies();  or  wsl --install / wsl --update
    return;
}

var ver = WslcService.GetVersion();
Console.WriteLine($"{ver.Major}.{ver.Minor}.{ver.Revision}");
```

> Learn docs sometimes show `ComponentFlags`; live wsl.dev C# projection uses `IReadOnlyList<Component>`. Prefer wsl.dev + package IntelliSense when they disagree.

---

## SessionSettings

```csharp
public sealed class SessionSettings
{
    public SessionSettings(string name, string storagePath);

    public string Name { get; set; }
    public string StoragePath { get; set; }
    public uint? CpuCount { get; set; }
    public uint? MemorySizeInMB { get; set; }
    public TimeSpan? Timeout { get; set; }
    public VhdOptions VhdRequirements { get; set; }
    public bool EnableGpu { get; set; }
}
```

| Property | Notes |
|---|---|
| `Name` | Machine-wide unique session key. Colliding name → `ERROR_ALREADY_EXISTS`. Visible to other users (name + creator SID + PID). **Do not put secrets in the name.** |
| `StoragePath` | Directory for session VHD/data; created if missing |
| `CpuCount` | Optional; default session-side around 2 vCPU when unset (runtime defaults documented ~2 CPU / 2000 MB / 32 GB dynamic VHDX / 5 min boot timeout) |
| `MemorySizeInMB` | Optional RAM |
| `Timeout` | Positive; must fit uint32 milliseconds |
| `EnableGpu` | Session-level GPU plumbing (CDI `/dev/dxg`) |
| `VhdRequirements` | Optional base VHD constraints |

```csharp
var sessionSettings = new SessionSettings("MyApp", @"C:\WslcData")
{
    CpuCount = 4,
    MemorySizeInMB = 4096,
    Timeout = TimeSpan.FromMinutes(5),
    EnableGpu = true
};
```

> Some overview snippets use `MemoryMB`; the settings class property on wsl.dev is **`MemorySizeInMB`**.

---

## Session

```csharp
public sealed class Session : IDisposable
{
    public Session(SessionSettings settings);

    public event SessionTerminationHandler Terminated;
    public event ProcessCrashHandler ProcessCrashed;

    public void Start();
    public void Terminate();
    public Container CreateContainer(ContainerSettings containerSettings);

    public void PullImage(PullImageOptions options);
    public IAsyncActionWithProgress<ImageProgress> PullImageAsync(PullImageOptions options);

    public void ImportImage(string path, string imageName);
    public IAsyncActionWithProgress<ImageProgress> ImportImageAsync(string path, string imageName);

    public void LoadImage(string path);
    public IAsyncActionWithProgress<ImageProgress> LoadImageAsync(string path);

    public void PushImage(PushImageOptions options);
    public IAsyncActionWithProgress<ImageProgress> PushImageAsync(PushImageOptions options);

    public void DeleteImage(string nameOrId);
    public void TagImage(TagImageOptions options);

    public void CreateVhdVolume(VhdOptions options);
    public void DeleteVhdVolume(string name);

    public string Authenticate(Uri serverAddress, string username, string password);
    public IReadOnlyList<ImageInfo> GetImages();

    public void Dispose();
}
```

### Image managers
```csharp
session.Start();

var pull = session.PullImageAsync(new PullImageOptions("docker.io/library/alpine:latest"));
pull.Progress = (op, p) =>
    Console.WriteLine($"{p.Status} {p.Id} {p.CurrentBytes}/{p.TotalBytes}");
await pull;

session.TagImage(new TagImageOptions("alpine:latest", "registry.example.com/alpine", "v1"));
session.DeleteImage("demo:old");

session.ImportImage(@"C:\images\demo.tar", "demo:imported");
session.LoadImage(@"C:\images\docker-save.tar");

string token = session.Authenticate(
    new Uri("https://registry.example.com"),
    "user1",
    "p@ssw0rd");
await session.PushImageAsync(new PushImageOptions("registry.example.com/demo:latest", token));

foreach (var img in session.GetImages())
    Console.WriteLine(img.Name);
```

### VHD volumes
```csharp
var vhd = new VhdOptions("cache", 2UL * 1024 * 1024 * 1024, VhdType.Dynamic)
{
    Owner = new VhdOwner { Uid = 1000, Gid = 1000 }
};
session.CreateVhdVolume(vhd);
// … use as named volume "cache"
session.DeleteVhdVolume("cache");
```

### Events
```csharp
session.Terminated += reason => Console.WriteLine($"terminated: {reason}");
session.ProcessCrashed += info =>
    Console.WriteLine($"crash: {info.ProcessName} pid={info.Pid}");
```

---

## ProcessSettings

```csharp
public sealed class ProcessSettings
{
    public string WorkingDirectory { get; set; }
    public IList<string> CommandLine { get; set; }   // required non-empty before Process.Start for secondaries
    public IDictionary<string, string> EnvironmentVariables { get; set; }
    public ProcessOutputMode OutputMode { get; set; }
}
```

| ProcessOutputMode | Behavior |
|---|---|
| `Discard = 0` | Drop streams discarded |
| `Stream = 1` | Use `GetOutputStream` / `GetInputStream` |
| `Event = 2` | Raise `OutputReceived` / `ErrorReceived` |

> Overview snippets sometimes use `CmdLine`; typed surface is **`CommandLine`**.

---

## ContainerSettings

```csharp
public sealed class ContainerSettings
{
    public ContainerSettings(string imageName);

    public string ImageName { get; set; }
    public string Name { get; set; }
    public ProcessSettings InitProcess { get; set; }
    public ContainerNetworkingMode? NetworkingMode { get; set; }
    public string HostName { get; set; }
    public string DomainName { get; set; }
    public bool EnableAutoRemove { get; set; }
    public bool EnableGpu { get; set; }
    public bool Privileged { get; set; }          // ← privileged works here (CLI omits --privileged)
    public IList<ContainerPortMapping> PortMappings { get; set; }
    public IList<ContainerVolume> Volumes { get; set; }
    public IList<ContainerNamedVolume> NamedVolumes { get; set; }
}
```

```csharp
public enum ContainerNetworkingMode
{
    None = 0,
    Bridged = 1
}
```

```csharp
// Port mapping
public sealed class ContainerPortMapping
{
    public ContainerPortMapping(ushort windowsPort, ushort containerPort, PortProtocol protocol);
    public ushort WindowsPort { get; set; }
    public ushort ContainerPort { get; set; }
    public PortProtocol Protocol { get; set; }
    public HostName WindowsAddress { get; set; } // IPv4/IPv6 HostName only; null = default bind
}
```

Full container create example:
```csharp
var init = new ProcessSettings
{
    CommandLine = new List<string> { "/bin/sh", "-c", "echo hello" },
    OutputMode = ProcessOutputMode.Event
};

var settings = new ContainerSettings("docker.io/library/alpine:latest")
{
    Name = "demo-container",
    InitProcess = init,
    NetworkingMode = ContainerNetworkingMode.Bridged,
    EnableAutoRemove = true,
    EnableGpu = false,
    Privileged = false,
    PortMappings = new List<ContainerPortMapping>
    {
        new(8080, 80, PortProtocol.TCP)
        {
            WindowsAddress = new Windows.Networking.HostName("127.0.0.1")
        }
    },
    Volumes = new List<ContainerVolume>
    {
        new(@"C:\data", "/workspace/data", /*readOnly*/ false)
    },
    NamedVolumes = new List<ContainerNamedVolume>
    {
        new("cache", "/var/cache/app", false)
    }
};

var container = session.CreateContainer(settings);
```

---

## Container

```csharp
public sealed class Container : IDisposable
{
    public string Id { get; }
    public Process InitProcess { get; }   // only if InitProcess configured in settings
    public ContainerState State { get; }

    public void Start();   // no flags; auto-attaches init if OutputMode Event/Stream
    public void Stop(Signal signal, TimeSpan timeout);
    public void Delete(DeleteContainerOption option);
    public Process CreateProcess(ProcessSettings newProcessSettings);
    public string Inspect();
    public void Dispose();
}
```

```csharp
public enum ContainerState
{
    Invalid = 0,
    Created = 1,
    Running = 2,
    Exited = 3,
    Deleted = 4
}

[Flags]
public enum DeleteContainerOption
{
    None = 0,
    Force = 1
}

public enum Signal
{
    None = 0,
    SIGHUP = 1,
    SIGINT = 2,
    SIGQUIT = 3,
    SIGKILL = 9,
    SIGTERM = 15
}
```

```csharp
container.Start();
// …
if (container.State == ContainerState.Running)
    container.Stop(Signal.SIGTERM, TimeSpan.FromSeconds(10));
container.Delete(DeleteContainerOption.Force);
```

> Learn snippets may say `DeleteContainerFlags`; projection enum is **`DeleteContainerOption`**.

Secondary process (docker-exec analogue):
```csharp
var exec = container.CreateProcess(new ProcessSettings
{
    CommandLine = new List<string> { "/bin/sh", "-c", "echo secondary" },
    OutputMode = ProcessOutputMode.Event,
    WorkingDirectory = "/workspace"
});
exec.OutputReceived += data => Console.Write(Encoding.UTF8.GetString(data));
exec.Start();   // only for secondary processes — init is started by Container.Start()
```

---

## Process

```csharp
public sealed class Process
{
    public uint Pid { get; }
    public ProcessState State { get; }
    public int ExitCode { get; }

    public event ProcessOutputHandler OutputReceived; // needs OutputMode.Event
    public event ProcessOutputHandler ErrorReceived;  // needs OutputMode.Event
    public event ProcessExitHandler Exited;           // all modes

    public void Start();                 // secondary only
    public void Signal(Signal signal);
    public IInputStream GetOutputStream(ProcessOutputHandle outputHandle); // Stream mode
    public IOutputStream GetInputStream();                                 // stdin
}
```

Event I/O:
```csharp
container.InitProcess.OutputReceived += data =>
    Console.Write(Encoding.UTF8.GetString(data));
container.InitProcess.Exited += code =>
    Console.WriteLine($"exit {code}");
```

Stream I/O:
```csharp
using IInputStream stdout = process.GetOutputStream(ProcessOutputHandle.StandardOutput);
using var reader = new DataReader(stdout);
await reader.LoadAsync(4096);
string text = reader.ReadString(reader.UnconsumedBufferLength);

using IOutputStream stdin = process.GetInputStream();
using var writer = new DataWriter(stdin);
writer.WriteString("hello\n");
await writer.StoreAsync();
await writer.FlushAsync();
```

---

## End-to-end C# (from wsl.dev, slightly hardened)

```csharp
using Microsoft.WSL.Containers;
using System;
using System.Text;
using System.Threading.Tasks;

class Program
{
    static async Task<int> Main()
    {
        var missing = WslcService.GetMissingComponents();
        if (missing.Count > 0)
        {
            Console.WriteLine("WSL components missing. Run: wsl --install / wsl --update");
            return 1;
        }

        var ver = WslcService.GetVersion();
        Console.WriteLine($"WSL container service: {ver.Major}.{ver.Minor}.{ver.Revision}");

        using var session = new Session(new SessionSettings("MyApp", @"C:\WslcData")
        {
            CpuCount = 4,
            MemorySizeInMB = 4096
        });
        session.Start();

        var pull = session.PullImageAsync(new PullImageOptions("docker.io/library/alpine:latest"));
        pull.Progress = (_, p) =>
            Console.WriteLine($"Pull: {p.Status} {p.CurrentBytes}/{p.TotalBytes}");
        await pull;

        var init = new ProcessSettings
        {
            CommandLine = new[] { "/bin/echo", "Hello from WSL Container!" },
            OutputMode = ProcessOutputMode.Event
        };

        using var container = session.CreateContainer(new ContainerSettings("alpine:latest")
        {
            Name = "hello-container",
            InitProcess = init
        });

        var exited = new TaskCompletionSource<int>(TaskCreationOptions.RunContinuationsAsynchronously);
        container.InitProcess.OutputReceived += data =>
            Console.Write(Encoding.UTF8.GetString(data));
        container.InitProcess.Exited += code => exited.TrySetResult(code);

        container.Start();

        var done = await Task.WhenAny(exited.Task, Task.Delay(TimeSpan.FromSeconds(30)));
        int code = done == exited.Task ? exited.Task.Result : -1;
        Console.WriteLine($"exit={code}");

        if (container.State == ContainerState.Running)
            container.Stop(Signal.SIGTERM, TimeSpan.FromSeconds(10));
        container.Delete(DeleteContainerOption.None);
        session.Terminate();
        return code;
    }
}
```

---

## C++/WinRT sketch (from Learn)

```cpp
#include <winrt/Microsoft.WSL.Containers.h>
using namespace winrt::Microsoft::WSL::Containers;

auto missing = WslcService::GetMissingComponents();
// …

SessionSettings sessionSettings{ L"MyApp", L"C:\\WslcData" };
sessionSettings.CpuCount(4);
sessionSettings.MemoryMB(4096); // C++ projection naming may differ; check headers

Session session{ sessionSettings };
session.Start();

PullImageOptions pullOptions{ L"docker.io/library/alpine:latest" };
co_await session.PullImageAsync(pullOptions);

// ProcessSettings + ContainerSettings + container.Start() …
container.Stop(Signal::SIGTERM, std::chrono::seconds(10));
container.Delete(DeleteContainerFlags::None);
session.Terminate();
```

> C++ property names in Learn (`MemoryMB`, `DeleteContainerFlags`) can lag; **always check the installed headers / NuGet projection**.

---

## Official samples (https://aka.ms/wslc-samples)

| Sample | Language | What it shows |
|---|---|---|
| WSLC-HelloWorld | C | Minimal alpine `echo` |
| WSLC-Neofetch | C++/WinRT | Run `neofetch` from native EXE |
| WSLC-NextCloud | C# | Long-running server + bind data dir + port 8080 |
| WSLC-CustomContainer | C# | Custom `Containerfile` auto-built from MSBuild + exec Python QR tool |

Nextcloud sample storage pattern (relative to EXE):
- `WslcNextcloudStorage\` → ephemeral session VHD
- `WslcNextcloudData\` → bind-mounted `/var/www/html/data`

---

## Architecture notes useful to API authors

From product design write-ups + Microsoft samples:

1. **Per-app utility VM** — each `Session` is a dedicated Hyper-V guest, **not** your Ubuntu distro.
2. **IPC** — Windows host uses HV sockets (`WSLC_FORK`, `WSLC_MOUNT`, `WSLC_UNIX_CONNECT`, …). Docker Engine REST is proxied to guest `/var/run/docker.sock`.
3. **Bind mounts** — Windows path → HCS share → 9p or virtiofs into guest, then into container.
4. **GPU** — CDI v0.6.0, kind `microsoft.com/wslc`, device `microsoft.com/wslc=gpu`, node `/dev/dxg`, same DirectX user-mode stack as WSLg.
5. **Plugin DLL API** (advanced) — lifecycle hooks `OnSessionCreated`, `ContainerStarted`, `ImageCreated`, … plus `WSLCMountFolder`, `WSLCCreateProcess`, Win32 HANDLEs for stdio. See microsoft/WSL PR history around plugin extensions.
6. **Enterprise** — registry allowlist GPO `WSLContainerRegistryAllowlist`; blocked pull → `WSLC_E_REGISTRY_BLOCKED_BY_POLICY`.

---

## Session isolation vs CLI

Containers created in a named programmatic session are **not** listed by the default CLI namespace (`wslc ps`) unless they share that session. Design app sessions with deliberate `Name` + `StoragePath`, and never assume CLI visibility.

Default CLI session store example:
```text
%LOCALAPPDATA%\wslc\sessions\wslc-cli-<user>\
```

---

## Known API documentation drift checklist

When code fails to compile against snippets:

| Snippet name | Prefer projection name |
|---|---|
| `MemoryMB` (C# snippets) | `MemorySizeInMB` |
| `CmdLine` | `CommandLine` |
| `DeleteContainerFlags` | `DeleteContainerOption` |
| `ComponentFlags` bitmask | `IReadOnlyList<Component>` / `GetMissingComponents()` count |
| `ProcessSettings.OutputMode` with no enum | `ProcessOutputMode.Event|Stream|Discard` |

Always: build against the installed NuGet + https://wsl.dev/api-reference/csharp/ as the living reference.
