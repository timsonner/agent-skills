---
name: configure/acp
description: Configuration for OpenCode ACP Support - setting up OpenCode to work with ACP-compatible editors
author: Tim Sonner
license: MIT
compatibility: opencode
metadata:
  audience: developers
  workflow: configuration
  language: markdown
---

# OpenCode ACP Support Configuration

Configure OpenCode to work with ACP (Agent Client Protocol)-compatible editors and IDEs.

## Overview

OpenCode supports the [Agent Client Protocol](https://agentclientprotocol.com) (ACP), allowing you to use it directly in compatible editors and IDEs. ACP is an open protocol that standardizes communication between code editors and AI coding agents.

## How ACP Works

When configured for ACP, OpenCode runs as a subprocess that communicates with your editor over JSON-RPC via stdio. This allows you to access OpenCode's AI coding capabilities directly within your editor's interface.

## Configuration Examples

### Zed Editor

Add to your Zed configuration (`~/.config/zed/settings.json`):

```json
{
  "agent_servers": {
    "OpenCode": {
      "command": "opencode",
      "args": ["acp"]
    }
  }
```

To open it, use the `agent: new thread` action in the Command Palette.

You can also bind a keyboard shortcut by editing your `keymap.json`:

```json
[
  {
    "bindings": {
      "cmd-alt-o": [
        "agent::NewExternalAgentThread",
        {
          "agent": {
            "custom": {
              "name": "OpenCode",
              "command": {
                "command": "opencode",
                "args": ["acp"]
              }
            }
          }
        }
      ]
    }
  }
]
```

### JetBrains IDEs

Add to your JetBrains IDE `acp.json` according to the [documentation](https://www.jetbrains.com/help/ai-assistant/acp.html):

```json
{
  "agent_servers": {
    "OpenCode": {
      "command": "/absolute/path/bin/opencode",
      "args": ["acp"]
    }
  }
}
```

To open it, use the new 'OpenCode' agent in the AI Chat agent selector.

### Avante.nvim

Add to your Avante.nvim configuration:

```lua
{
  acp_providers = {
    ["opencode"] = {
      command = "opencode",
      args = { "acp" }
    }
  }
}
```

If you need to pass environment variables:

```lua
{
  acp_providers = {
    ["opencode"] = {
      command = "opencode",
      args = { "acp" },
      env = {
        OPENCODE_API_KEY = os.getenv("OPENCODE_API_KEY")
      }
    }
  }
}
```

### CodeCompanion.nvim

To use OpenCode as an ACP agent in CodeCompanion.nvim, add the following to your Neovim config:

```lua
require("codecompanion").setup({
  interactions = {
    chat = {
      adapter = {
        name = "opencode",
        model = "claude-sonnet-4",
      },
    },
  },
})
```

This config sets up CodeCompanion to use OpenCode as the ACP agent for chat.

If you need to pass environment variables (like `OPENCODE_API_KEY`), refer to the CodeCompanion.nvim documentation for full details.

## Supported Features via ACP

OpenCode works the same via ACP as it does in the terminal. All features are supported:

- Built-in tools (file operations, terminal commands, etc.)
- Custom tools and slash commands
- MCP servers configured in your OpenCode config
- Project-specific rules from `AGENTS.md`
- Custom formatters and linters
- Agents and permissions system

## Limitations

Note: Some built-in slash commands like `/undo` and `/redo` are currently unsupported when using ACP.

## Best Practices

1. **Use Absolute Paths**: When specifying the OpenCode command in editor configurations, use absolute paths to ensure reliability
2. **Environment Variables**: Pass necessary environment variables (like API keys) through your editor's configuration when required
3. **Editor Documentation**: Consult your specific editor's ACP documentation for the most accurate and up-to-date configuration instructions
4. **Testing**: Test your ACP configuration to ensure OpenCode connects and responds correctly within your editor
5. **Keep Updated**: Monitor both OpenCode and your editor's ACP implementation for updates that may affect compatibility

By configuring ACP support, you can seamlessly integrate OpenCode's AI coding assistance into your preferred editing environment, maintaining workflow efficiency while leveraging powerful AI capabilities.
