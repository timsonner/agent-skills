---
name: configure/mcp
description: Configuration for OpenCode MCP servers - adding local and remote Model Context Protocol tools
license: MIT
compatibility: opencode
metadata:
  audience: developers
  workflow: configuration
  language: markdown
---

# OpenCode MCP Servers Configuration

Add local and remote MCP (Model Context Protocol) tools to OpenCode.

## Overview

You can add external tools to OpenCode using the Model Context Protocol (MCP). OpenCode supports both local and remote MCP servers. Once added, MCP tools are automatically available to the LLM alongside built-in tools.

⚠️ **Caveats**: When you use an MCP server, it adds to the context. This can quickly add up if you have a lot of tools. Be careful with which MCP servers you enable, as certain servers (like the GitHub MCP server) can add many tokens and easily exceed the context limit.

## Enabling MCP Servers

You can define MCP servers in your OpenCode config (`opencode.json`) under the `mcp` key. Add each MCP with a unique name. You can refer to that MCP by name when prompting the LLM.

```jsonc
{
  "$schema": "https://opencode.ai/config.json",
  "mcp": {
    "name-of-mcp-server": {
      // ... configuration ...
      "enabled": true
    },
    "name-of-other-mcp-server": {
      // ... configuration ...
    }
  }
}
```

You can also disable a server by setting `enabled` to `false` (useful for temporarily disabling without removing from config).

### Overriding Remote Defaults

Organizations can provide default MCP servers via their `.well-known/opencode` endpoint. These servers may be disabled by default, allowing users to opt-in.

To enable a specific server from your organization's remote config, add it to your local config with `enabled: true`:

```json
{
  "$schema": "https://opencode.ai/config.json",
  "mcp": {
    "jira": {
      "type": "remote",
      "url": "https://jira.example.com/mcp",
      "enabled": true
    }
  }
}
```

Your local config values override remote defaults.

## Local MCP Servers

Add local MCP servers using `type: "local"` within the MCP object.

```jsonc
{
  "$schema": "https://opencode.ai/config.json",
  "mcp": {
    "my-local-mcp-server": {
      "type": "local",
      // Or ["bun", "x", "my-mcp-command"]
      "command": ["npx", "-y", "my-mcp-command"],
      "enabled": true,
      "environment": {
        "MY_ENV_VAR": "my_env_var_value"
      }
    }
  }
}
```

The `command` is how the local MCP server is started. You can also pass environment variables.

Example: Adding the `@modelcontextprotocol/server-everything` MCP server:

```jsonc
{
  "$schema": "https://opencode.ai/config.json",
  "mcp": {
    "mcp_everything": {
      "type": "local",
      "command": ["npx", "-y", "@modelcontextprotocol/server-everything"]
    }
  }
}
```

To use it: "use the mcp_everything tool to add the number 3 and 4"

### Local MCP Server Options

| Option | Type | Required | Description |
|--------|------|----------|-------------|
| `type` | String | Y | Must be `"local"` |
| `command` | Array | Y | Command and arguments to run the MCP server |
| `environment` | Object | N | Environment variables to set when running the server |
| `enabled` | Boolean | N | Enable/disable the MCP server on startup (defaults to true) |
| `timeout` | Number | N | Timeout in ms for fetching tools (defaults to 5000) |

## Remote MCP Servers

Add remote MCP servers by setting `type` to `"remote"`.

```json
{
  "$schema": "https://opencode.ai/config.json",
  "mcp": {
    "my-remote-mcp": {
      "type": "remote",
      "url": "https://my-mcp-server.com",
      "enabled": true,
      "headers": {
        "Authorization": "Bearer MY_API_KEY"
      }
    }
  }
}
```

The `url` is the URL of the remote MCP server. With the `headers` option, you can pass in a list of headers.

### Remote MCP Server Options

| Option | Type | Required | Description |
|--------|------|----------|-------------|
| `type` | String | Y | Must be `"remote"` |
| `url` | String | Y | URL of the remote MCP server |
| `enabled` | Boolean | N | Enable/disable the MCP server on startup (defaults to true) |
| `headers` | Object | N | Headers to send with the request |
| `oauth` | Object | N | OAuth authentication configuration |
| `timeout` | Number | N | Timeout in ms for fetching tools (defaults to 5000) |

## OAuth Authentication

OpenCode automatically handles OAuth authentication for remote MCP servers. When a server requires authentication, OpenCode will:

1. Detect the 401 response and initiate the OAuth flow
2. Use Dynamic Client Registration (RFC 7591) if supported by the server
3. Store tokens securely for future requests

### Automatic (Recommended)

For most OAuth-enabled MCP servers, no special configuration is needed. Just configure the remote server:

```json
{
  "$schema": "https://opencode.ai/config.json",
  "mcp": {
    "my-oauth-server": {
      "type": "remote",
      "url": "https://mcp.example.com/mcp"
    }
  }
}
```

If the server requires authentication, OpenCode will prompt you to authenticate when you first try to use it. You can also manually trigger the flow with `opencode mcp auth <server-name>`.

### Pre-registered

If you have client credentials from the MCP server provider, you can configure them:

```json
{
  "$schema": "https://opencode.ai/config.json",
  "mcp": {
    "my-oauth-server": {
      "type": "remote",
      "url": "https://mcp.example.com/mcp",
      "oauth": {
        "clientId": "{env:MY_MCP_CLIENT_ID}",
        "clientSecret": "{env:MY_MCP_CLIENT_SECRET}",
        "scope": "tools:read tools:execute"
      }
    }
  }
}
```

### Authenticating & Managing Credentials

- Authenticate with a specific MCP server: `opencode mcp auth my-oauth-server`
- List all MCP servers and their auth status: `opencode mcp list`
- Remove stored credentials: `opencode mcp logout my-oauth-server`

The `mcp auth` command opens your browser for authorization. After authorization, OpenCode stores tokens securely in `~/.local/share/opencode/mcp-auth.json`.

### Disabling OAuth

If you want to disable automatic OAuth for a server (e.g., for servers that use API keys instead), set `oauth` to `false`:

```json
{
  "$schema": "https://opencode.ai/config.json",
  "mcp": {
    "my-api-key-server": {
      "type": "remote",
      "url": "https://mcp.example.com/mcp",
      "oauth": false,
      "headers": {
        "Authorization": "Bearer {env:MY_API_KEY}"
      }
    }
  }
}
```

### OAuth Options

| Option | Type | Description |
|--------|------|-------------|
| `oauth` | Object \| false | OAuth config object, or `false` to disable OAuth auto-detection |
| `clientId` | String | OAuth client ID (if not provided, dynamic client registration attempted) |
| `clientSecret` | String | OAuth client secret, if required by the authorization server |
| `scope` | String | OAuth scopes to request during authorization |

## Managing MCP Servers

Your MCPs are available as tools in OpenCode, alongside built-in tools. You can manage them through the OpenCode config like any other tool.

### Global Management

Enable/disable them globally:

```json
{
  "$schema": "https://opencode.ai/config.json",
  "mcp": {
    "my-mcp-foo": {
      "type": "local",
      "command": ["bun", "x", "my-mcp-command-foo"]
    },
    "my-mcp-bar": {
      "type": "local",
      "command": ["bun", "x", "my-mcp-command-bar"]
    }
  },
  "tools": {
    "my-mcp-foo": false
  }
}
```

Use glob patterns to disable multiple MCPs:

```json
{
  "$schema": "https://opencode.ai/config.json",
  "mcp": {
    "my-mcp-foo": {
      "type": "local",
      "command": ["bun", "x", "my-mcp-command-foo"]
    },
    "my-mcp-bar": {
      "type": "local",
      "command": ["bun", "x", "my-mcp-command-bar"]
    }
  },
  "tools": {
    "my-mcp*": false
  }
}
```

### Per-Agent Management

If you have many MCP servers, you may want to enable them per agent and disable them globally:

1. Disable globally as a tool
2. In your agent config, enable the MCP server as a tool

```json
{
  "$schema": "https://opencode.ai/config.json",
  "mcp": {
    "my-mcp": {
      "type": "local",
      "command": ["bun", "x", "my-mcp-command"],
      "enabled": true
    }
  },
  "tools": {
    "my-mcp*": false
  },
  "agent": {
    "my-agent": {
      "tools": {
        "my-mcp*": true
      }
    }
  }
}
```

### Glob Patterns

The glob pattern uses simple regex globbing:
- `*` matches zero or more of any character (e.g., `"my-mcp*"` matches `my-mcp_search`, `my-mcp_list`, etc.)
- `?` matches exactly one character
- All other characters match literally

Note: MCP server tools are registered with server name as prefix, so to disable all tools for a server use: `"mymcpservername_*": false`

## Examples

### Sentry MCP Server

Add the [Sentry MCP server](https://mcp.sentry.dev) to interact with your Sentry projects and issues:

```json
{
  "$schema": "https://opencode.ai/config.json",
  "mcp": {
    "sentry": {
      "type": "remote",
      "url": "https://mcp.sentry.dev/mcp",
      "oauth": {}
    }
  }
}
```

After adding the configuration, authenticate with Sentry:
```
opencode mcp auth sentry
```

This opens a browser window to complete the OAuth flow and connect OpenCode to your Sentry account.

Once authenticated, use Sentry tools in your prompts:
```
Show me the latest unresolved issues in my project. use sentry
```

### Context7 MCP Server

Add the [Context7 MCP server](https://github.com/upstash/context7) to search through docs:

```json
{
  "$schema": "https://opencode.ai/config.json",
  "mcp": {
    "context7": {
      "type": "remote",
      "url": "https://mcp.context7.com/mcp"
    }
  }
}
```

If you have a free account, use your API key for higher rate-limits:
```json
{
  "$schema": "https://opencode.ai/config.json",
  "mcp": {
    "context7": {
      "type": "remote",
      "url": "https://mcp.context7.com/mcp",
      "headers": {
        "CONTEXT7_API_KEY": "{env:CONTEXT7_API_KEY}"
      }
    }
  }
}
```

Add `use context7` to your prompts:
```
Configure a Cloudflare Worker script to cache JSON API responses for five minutes. use context7
```

Alternatively, add to your AGENTS.md:
```
When you need to search docs, use `context7` tools.
```

### Grep by Vercel MCP Server

Add the [Grep by Vercel](https://grep.app) MCP server to search through code snippets on GitHub:

```json
{
  "$schema": "https://opencode.ai/config.json",
  "mcp": {
    "gh_grep": {
      "type": "remote",
      "url": "https://mcp.grep.app"
    }
  }
}
```

Since we named our MCP server `gh_grep`, add `use the gh_grep tool` to your prompts:
```
What's the right way to set a custom domain in an SST Astro component? use the gh_grep tool
```

Alternatively, add to your AGENTS.md:
```
If you are unsure how to do something, use `gh_grep` to search code examples from GitHub.
```

## Best Practices

1. **Context Awareness**: Be mindful that MCP servers add to your context limit - enable only what you need
2. **Security**: Only enable MCP servers from trusted sources
3. **Performance**: Some MCP servers may be slow - test responsiveness before relying on them
4. **Authentication**: Properly configure OAuth or API keys for remote servers that require authentication
5. **Environment Variables**: Use environment variables for sensitive data like API keys rather than hardcoding
6. **Documentation**: Document which MCP servers your project uses and why
7. **Updates**: Keep MCP server implementations updated for security and feature improvements

By configuring MCP servers appropriately, you can greatly extend OpenCode's capabilities with specialized tools for services like Sentry, documentation search, code search, and many other external systems.