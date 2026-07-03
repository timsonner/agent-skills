---
name: wsl-containers
description: Commands, references, and APIs for building, running, and managing Linux containers using the wslc CLI or the Microsoft.WSL.Containers SDK in Windows Subsystem for Linux (WSL).
---

# WSL Containers Skill Guide

This skill equips the agent with capabilities to manage, run, build, and interact with Linux containers on Windows using the WSL Container feature (`wslc.exe` and the `Microsoft.WSL.Containers` API).

---

## 1. Prerequisites and Installation

To use WSL Containers, the system must run WSL version `2.9.3.0` or higher (from the pre-release channel).

### Verification
Check the WSL and `wslc` versions:
```powershell
wsl --version
# Output should show version 2.9.3.0 or higher
```

### Installation / Upgrade
If WSL is not on the latest version or `wslc` is not available:
1. Run a terminal (PowerShell or CMD) as an Administrator.
2. Run the update command to switch to the pre-release channel:
   ```powershell
   wsl --update --pre-release
   ```
3. Restart WSL to apply the changes:
   ```powershell
   wsl --shutdown
   ```
4. Verify `wslc` is installed:
   ```powershell
   wslc version
   ```

---

## 2. WSL Container CLI (`wslc.exe`)

`wslc.exe` provides a Docker-like command-line interface for managing container lifecycles.

### Pathing Note
Once installed via the pre-release channel, `wslc` is added to the system `PATH` (a shell restart may be required). If it is not found, you can run it using its absolute path: `& "C:\Program Files\WSL\wslc.exe"`.

### Common Commands
*   **Run a basic container (interactive / ephemeral):**
    ```powershell
    wslc run --rm -it ubuntu:latest bash -c "echo Hello world from WSL container!"
    ```
*   **Run a container in the background (detached) with port publishing:**
    ```powershell
    wslc run -it --rm -d -p 8080:80 --name web nginx
    ```
*   **List images:**
    ```powershell
    wslc image ls
    # or
    wslc images
    ```
*   **List containers (running & stopped):**
    ```powershell
    wslc container ps
    # or
    wslc list
    # List all including stopped
    wslc container ps -a
    ```
*   **Stop a running container:**
    ```powershell
    wslc container stop <container-name-or-id>
    ```
*   **Remove a container:**
    ```powershell
    wslc remove <container-name-or-id>
    ```
*   **Check container resource utilization statistics:**
    ```powershell
    wslc stats
    ```
*   **View container logs:**
    ```powershell
    wslc logs <container-name-or-id>
    ```
*   **Execute a command inside a running container:**
    ```powershell
    wslc exec -it <container-name-or-id> bash
    ```
*   **Build an image from a Dockerfile:**
    ```powershell
    wslc build -t my-custom-image:latest .
    ```

### Persistent / Permanent Containers
By default, using the `--rm` flag deletes the container upon exit. To create a persistent container that survives stops/restarts and retains installed packages or files:

1. **Create the container** (without `--rm`) with stdin/TTY allocations:
   ```powershell
   wslc create --name my-kali -it kalilinux/kali-rolling bash
   ```
2. **Start it**:
   ```powershell
   wslc start my-kali
   ```
3. **Execute commands inside the running container**:
   ```powershell
   wslc exec my-kali apt-get update
   wslc exec my-kali apt-get install -y curl
   ```
4. **Manage its lifecycle**:
   * Stop the container: `wslc stop my-kali`
   * Restart the container: `wslc start my-kali`
   * Remove the container permanently: `wslc remove my-kali`

5. **Volume Mounts (Host Directory Persistence)**:
   Use the `-v` or `--volume` flag to bind-mount a Windows directory directly inside the container (highly recommended for developer source code and logs):
   ```powershell
   wslc run -d --name my-web -v C:\Users\<username>\www:/usr/share/nginx/html nginx:latest
   ```

6. **File Transfers (Copying files to a container)**:
   Since `wslc cp` is not supported in the CLI, you can copy files cleanly from Windows to a container using PowerShell's native byte-stream pipeline (which preserves exact binary files and line endings):
   ```powershell
   Get-Content -AsByteStream -Raw "C:\path\to\local\file" | wslc exec -i <container-name> sh -c "cat > /path/inside/container"
   ```

---

## 3. WSL Container Developer API (`Microsoft.WSL.Containers`)

The developer API allows Windows applications to programmatically control Linux containers (similar to Docker SDKs) through a clean C# or C++ architecture.

### API Architecture Hierarchy
1.  **Session:** The root host environment that runs a WSL-backed engine instance. Controls service checks, image pulling, and resource limits (CPUs, RAM).
2.  **Container:** An isolated container instance created within a `Session` from an image.
3.  **Process:** A specific Linux process executing within a `Container`. Controls I/O streams (`stdin`, `stdout`, `stderr`), exit codes, and process termination.

### NuGet Package Installation
Add the NuGet package to your .NET project:
```powershell
dotnet add package Microsoft.WSL.Containers
```

### C# Usage Example
```csharp
using Microsoft.WSL.Containers;
using System;
using System.Threading.Tasks;

class Program
{
    static async Task<int> Main()
    {
        // 1. Configure and initialize the WSL Session host
        var sessionSettings = new SessionSettings("MyAppSession", @"C:\WslcData") 
        { 
            CpuCount = 4, 
            MemorySizeInMB = 4096 
        };
        using var session = new Session(sessionSettings);
        session.Start();

        // 2. Pull a Linux image asynchronously
        Console.WriteLine("Pulling Alpine image...");
        var pullOp = session.PullImageAsync(new PullImageOptions("docker.io/library/alpine:latest"));
        await pullOp;

        // 3. Configure the container's initial command/process
        var initProcSettings = new ProcessSettings 
        { 
            CommandLine = new[] { "/bin/echo", "Hello from Microsoft.WSL.Containers API!" },
            OutputMode = ProcessOutputMode.Event 
        };

        // 4. Set up container options and build it inside the session
        var containerSettings = new ContainerSettings("alpine:latest") 
        { 
            Name = "my-test-container", 
            InitProcess = initProcSettings 
        };
        
        using var container = session.CreateContainer(containerSettings);
        
        // Start the container execution
        container.Start();
        Console.WriteLine("Container started successfully!");

        // 5. Cleanup the environment
        container.Delete(DeleteContainerOption.None);
        session.Terminate();
        
        return 0;
    }
}
```

---

## 4. WSL Container Architecture

The WSL Container system operates in a layered, virtualized structure:

1. **Windows Host (Your PC):** Runs the lightweight `wslc.exe` CLI wrapper client. It does not run the containers or the daemon itself; it just forwards API calls.
2. **WSL Session Utility VM:** A dedicated, lightweight Hyper-V Linux VM managed by the WSL Service. **This VM runs the actual Docker daemon (`dockerd`).**
3. **Container (e.g. Kali):** An isolated process namespace managed by the Session VM's Docker daemon. It does not run Docker inside itself.

Because `wslc` containers run on standard Docker under the hood, you can run privileged containers by executing standard Docker commands directly inside the Session VM using `wslc system session run docker ...`.


## 5. Troubleshooting & Best Practices

*   **Command Not Found (`wslc`):** If running `wslc` fails with a command not recognized error, confirm WSL is updated to the latest pre-release. Use the full path: `& "C:\Program Files\WSL\wslc.exe"`.
*   **Interactive Sessions & Isolation:** Programmatic sessions created via `Session` are separate from the system-wide default namespace. Containers started programmatically will not display in the default `wslc container list` unless they share the same session context.
*   **Networking Port Mapping:** Verify that ports mapped via `-p` (e.g. `8080:80`) do not conflict with active Windows services or existing WSL distributions.
*   **Privileged Containers & CAP_NET_ADMIN Workaround:** Since the preview `wslc.exe` CLI lacks the `--privileged` or `--cap-add` flags, you cannot run network-administrative tasks (like VPN tunnels / `ioctl TUNSETIFF` calls) directly via the standard CLI.
    *   **Architecture & Rationale:** Under the hood, `wslc` is a front-end Windows client wrapper that communicates with a standard Linux Docker daemon (`dockerd`) running inside a background Hyper-V Session VM. While the preview CLI client restricts capabilities for simplicity and security, the underlying Docker engine supports them fully. You can bypass client-side wrapper restrictions by executing commands directly against the internal daemon via the `wslc system session run` bridge.
    *   **Workaround Steps:**
        ```powershell
        # 1. Run a privileged container in the VM's docker daemon
        wslc system session run docker run -d --name privileged-kali --privileged kalilinux/kali-rolling sleep infinity
        
        # 2. Transfer files into the container via VM staging
        Get-Content -AsByteStream -Raw C:\path\to\host\file | wslc system session run /bin/sh -c "cat > /tmp/staged-file"
        wslc system session run docker cp /tmp/staged-file privileged-kali:/root/staged-file
        
        # 3. Exec commands inside the privileged container
        wslc system session run docker exec -it privileged-kali <command>
        ```
*   **Stuck Background / Session Tasks (Timeout check-in workflow):**
    Some WSL container or session commands (e.g. `wslc system session run`) do not close their stdout descriptors automatically, causing background tasks to remain in a `RUNNING` state indefinitely.
    *   **Agent Execution Workflow:**
        1. **Propose the command** as a background task using `run_command` with a standard wait time.
        2. **Schedule a check-in timer** immediately using the `schedule` tool:
           * `DurationSeconds`: Set to 5–10 seconds.
           * `TimerCondition`: Reference the task ID of the command (e.g. `task-123`).
           * `Prompt`: "Check on status of task-123"
        3. **End turn** by calling no tools and waiting for the timer to fire or the task to finish.
        4. **Check status:** When notified, call `manage_task` with action `status` on the task ID.
        5. **Kill if completed:** If the log output contains the expected results (showing the command completed successfully in the background), call `manage_task` with action `kill` to terminate the hanging shell connection and free system resources.
