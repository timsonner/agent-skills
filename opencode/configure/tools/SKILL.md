---
name: configure/tools
description: Configuration for OpenCode tools - managing tool permissions and built-in tools like bash, edit, write, read, etc.
license: MIT
compatibility: opencode
metadata:
  audience: developers
  workflow: configuration
  language: markdown
---

# OpenCode Tools Configuration

Manage the tools an LLM can use in OpenCode.

## Overview

Tools allow the LLM to perform actions in your codebase. OpenCode comes with a set of built-in tools, but you can extend it with [custom tools](/docs/custom-tools) or [MCP servers](/docs/mcp-servers).

By default, all tools are **enabled** and don't need permission to run. You can control tool behavior through [permissions](/docs/permissions).

## Configuring Tool Permissions

Use the `permission` field in your `opencode.json` file to control tool behavior. You can allow, deny, or require approval for each tool.

### Basic Permission Configuration

```json
{
  "$schema": "https://opencode.ai/config.json",
  "permission": {
    "edit": "deny",
    "bash": "ask",
    "webfetch": "allow"
  }
}
```

### Using Wildcards

You can use wildcards to control multiple tools at once. For example, to require approval for all tools from an MCP server:

```json
{
  "$schema": "https://opencode.ai/config.json",
  "permission": {
    "mymcp_*": "ask"
  }
}
```

[Learn more](/docs/permissions) about configuring permissions.

## Built-in Tools

Here are all the built-in tools available in OpenCode:

### bash
Execute shell commands in your project environment.

Configuration:
```json
{
  "$schema": "https://opencode.ai/config.json",
  "permission": {
    "bash": "allow"
  }
}
```

### edit
Modify existing files using exact string replacements.

Configuration:
```json
{
  "$schema": "https://opencode.ai/config.json",
  "permission": {
    "edit": "allow"
  }
}
```

### write
Create new files or overwrite existing ones.

Note: The `write` tool is controlled by the `edit` permission.

Configuration:
```json
{
  "$schema": "https://opencode.ai/config.json",
  "permission": {
    "edit": "allow"
  }
}
```

### read
Read file contents from your codebase.

Configuration:
```json
{
  "$schema": "https://opencode.ai/config.json",
  "permission": {
    "read": "allow"
  }
}
```

### grep
Search file contents using regular expressions.

Configuration:
```json
{
  "$schema": "https://opencode.ai/config.json",
  "permission": {
    "grep": "allow"
  }
}
```

### glob
Find files by pattern matching.

Configuration:
```json
{
  "$schema": "https://opencode.ai/config.json",
  "permission": {
    "glob": "allow"
  }
}
```

### list
List files and directories in a given path.

Configuration:
```json
{
  "$schema": "https://opencode.ai/config.json",
  "permission": {
    "list": "allow"
  }
}
```

### lsp (experimental)
Interact with your configured LSP servers to get code intelligence features.

Note: This tool is only available when `OPENCODE_EXPERIMENTAL_LSP_TOOL=true`.

Configuration:
```json
{
  "$schema": "https://opencode.ai/config.json",
  "permission": {
    "lsp": "allow"
  }
}
```

### patch
Apply patches to files.

Note: The `patch` tool is controlled by the `edit` permission.

Configuration:
```json
{
  "$schema": "https://opencode.ai/config.json",
  "permission": {
    "edit": "allow"
  }
}
```

### skill
Load a skill (a `SKILL.md` file) and return its content in the conversation.

Configuration:
```json
{
  "$schema": "https://opencode.ai/config.json",
  "permission": {
    "skill": "allow"
  }
}
```

### todowrite
Manage todo lists during coding sessions.

Configuration:
```json
{
  "$schema": "https://opencode.ai/config.json",
  "permission": {
    "todowrite": "allow"
  }
}
```

Note: This tool is disabled for subagents by default.

### webfetch
Fetch web content.

Configuration:
```json
{
  "$schema": "https://opencode.ai/config.json",
  "permission": {
    "webfetch": "allow"
  }
}
```

### websearch
Search the web for information.

Note: This tool is only available when using the OpenCode provider or when `OPENCODE_ENABLE_EXA` is set.

Configuration:
```json
{
  "$schema": "https://opencode.ai/config.json",
  "permission": {
    "websearch": "allow"
  }
}
```

### question
Ask the user questions during execution.

Configuration:
```json
{
  "$schema": "https://opencode.ai/config.json",
  "permission": {
    "question": "allow"
  }
}
```

## Custom Tools and MCP Servers

In addition to built-in tools, you can extend OpenCode with:

- [Custom tools](/docs/custom-tools): Define your own functions that the LLM can call
- [MCP servers](/docs/mcp-servers): Integrate external tools and services

## Internals

Internally, tools like `grep`, `glob`, and `list` use [ripgrep](https://github.com/BurntSushi/ripgrep) under the hood. By default, ripgrep respects `.gitignore` patterns.

### Ignore Patterns

To include files that would normally be ignored, create a `.ignore` file in your project root:

```
!node_modules/
!dist/
!build/
```

This allows ripgrep to search within those directories even if they're listed in `.gitignore`.