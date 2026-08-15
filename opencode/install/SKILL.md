---
name: install
description: Installation instructions for OpenCode - various methods including script, Node.js, Homebrew, Arch Linux, and Windows
author: Tim Sonner
license: MIT
compatibility: opencode
metadata:
  audience: developers
  workflow: setup
  language: markdown
---

# OpenCode Installation

The easiest way to install OpenCode is through the install script.

Terminal window

```
curl -fsSL https://opencode.ai/install | bash
```

You can also install it with the following commands:

## Using Node.js

-   [npm](#tab-panel-0)
-   [Bun](#tab-panel-1)
-   [pnpm](#tab-panel-2)
-   [Yarn](#tab-panel-3)

Terminal window

```
npm install -g opencode-ai
```

Terminal window

```
bun install -g opencode-ai
```

Terminal window

```
pnpm install -g opencode-ai
```

Terminal window

```
yarn global add opencode-ai
```

## Using Homebrew on macOS and Linux

Terminal window

```
brew install anomalyco/tap/opencode
```

> We recommend using the OpenCode tap for the most up to date releases. The official `brew install opencode` formula is maintained by the Homebrew team and is updated less frequently.

## Installing on Arch Linux

Terminal window

```
sudo pacman -S opencode           # Arch Linux (Stable)
paru -S opencode-bin              # Arch Linux (Latest from AUR)
```

### Windows

**Recommended (native CLI):**

```powershell
winget install --id SST.opencode --accept-source-agreements --accept-package-agreements
```

Then refresh PATH in the current shell (or open a new terminal):

```powershell
$env:Path = [System.Environment]::GetEnvironmentVariable('Path','Machine') + ';' +
            [System.Environment]::GetEnvironmentVariable('Path','User')
opencode --version
```

Package id **`SST.opencode`** is the CLI. **`SST.OpenCodeDesktop`** is the desktop app.

WSL is optional, not required for `opencode run`. Other Windows package managers:

-   **Using Chocolatey**
    
    Terminal window
    
    ```
    choco install opencode
    ```
    
-   **Using Scoop**
    
    Terminal window
    
    ```
    scoop install opencode
    ```
    
-   **Using NPM**
    
    Terminal window
    
    ```
    npm install -g opencode-ai
    ```
    
-   **Using Mise**
    
    Terminal window
    
    ```
    mise use -g github:anomalyco/opencode
    ```
    
-   **Using Docker**
    
    Terminal window
    
    ```
    docker run -it --rm ghcr.io/anomalyco/opencode
    ```
    
Support for installing OpenCode on Windows using Bun is currently in progress.

You can also grab the binary from the [Releases](https://github.com/anomalyco/opencode/releases).
