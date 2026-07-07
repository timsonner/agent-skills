---
name: windows
description: Windows-specific instructions for OpenCode - installation and usage on Windows systems
author: Tim Sonner
license: MIT
compatibility: opencode
metadata:
  audience: developers
  workflow: windows
  language: markdown
---

# OpenCode on Windows

## Recommended: Use WSL

For the best experience on Windows, we recommend using [Windows Subsystem for Linux (WSL)](/docs/windows-wsl). It provides better performance and full compatibility with OpenCode’s features.

## Installation Methods on Windows

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

## Windows-Specific Considerations

While OpenCode can run on Windows, using WSL is recommended for:
- Better performance
- Full compatibility with all features
- Consistent Linux-like environment
- Access to Unix-based tools and utilities

If you choose to run OpenCode natively on Windows, be aware that some features may have limited functionality or require additional configuration.
