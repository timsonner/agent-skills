---
name: configure/custom-tools
description: Configuration for OpenCode custom tools - creating and managing tools that the LLM can call during conversations
author: Tim Sonner
license: MIT
compatibility: opencode
metadata:
  audience: developers
  workflow: configuration
  language: markdown
---

# OpenCode Custom Tools Configuration

Create tools that the LLM can call in OpenCode.

## Overview

Custom tools are functions you create that the LLM can call during conversations. They work alongside OpenCode’s built-in tools like `read`, `write`, and `bash`.

## Creating Custom Tools

### Location
Custom tools can be defined:
- Locally by placing them in the `.opencode/tools/` directory of your project.
- Globally, by placing them in `~/.config/opencode/tools/`.

### Structure
The easiest way to create tools is using the `tool()` helper which provides type-safety and validation.

Example (`.opencode/tools/database.ts`):
```typescript
import { tool } from "@opencode-ai/plugin"
export default tool({
  description: "Query the project database",
  args: {
    query: tool.schema.string().describe("SQL query to execute"),
  },
  async execute(args) {
    // Your database logic here
    return `Executed query: ${args.query}`
  },
})
```

The filename becomes the tool name. The above creates a `database` tool.

#### Multiple Tools per File
You can export multiple tools from a single file. Each export becomes a separate tool with the name `<filename>_<exportname>`:

Example (`.opencode/tools/math.ts`):
```typescript
import { tool } from "@opencode-ai/plugin"
export const add = tool({
  description: "Add two numbers",
  args: {
    a: tool.schema.number().describe("First number"),
    b: tool.schema.number().describe("Second number"),
  },
  async execute(args) {
    return args.a + args.b
  },
})
export const multiply = tool({
  description: "Multiply two numbers",
  args: {
    a: tool.schema.number().describe("First number"),
    b: tool.schema.number().describe("Second number"),
  },
  async execute(args) {
    return args.a * args.b
  },
})
```

This creates two tools: `math_add` and `math_multiply`.

#### Name Collisions with Built-in Tools
Custom tools are keyed by tool name. If a custom tool uses the same name as a built-in tool, the custom tool takes precedence.

Example (replacing built-in `bash` tool):
```typescript
import { tool } from "@opencode-ai/plugin"
export default tool({
  description: "Restricted bash wrapper",
  args: {
    command: tool.schema.string(),
  },
  async execute(args) {
    return `blocked: ${args.command}`
  },
})
```

Note: Prefer unique names unless you intentionally want to replace a built-in tool. If you want to disable a built-in tool but not override it, use [permissions](/docs/permissions).

### Arguments
You can use `tool.schema` (which is just [Zod](https://zod.dev)) to define argument types:

```typescript
args: {
  query: tool.schema.string().describe("SQL query to execute")
}
```

You can also import Zod directly and return a plain object:

```typescript
import { z } from "zod"
export default {
  description: "Tool description",
  args: {
    param: z.string().describe("Parameter description"),
  },
  async execute(args, context) {
    // Tool implementation
    return "result"
  },
}
```

### Context
Tools receive context about the current session:

Example (`.opencode/tools/project.ts`):
```typescript
import { tool } from "@opencode-ai/plugin"
export default tool({
  description: "Get project information",
  args: {},
  async execute(args, context) {
    // Access context information
    const { agent, sessionID, messageID, directory, worktree } = context
    return `Agent: ${agent}, Session: ${sessionID}, Message: ${messageID}, Directory: ${directory}, Worktree: ${worktree}`
  },
})
```

Use `context.directory` for the session working directory. Use `context.worktree` for the git worktree root.

## Examples

### Writing a Tool in Python
You can write your tools in any language you want. Here's an example that adds two numbers using Python.

First, create the tool as a Python script (`.opencode/tools/add.py`):
```python
import sys
a = int(sys.argv[1])
b = int(sys.argv[2])
print(a + b)
```

Then create the tool definition that invokes it (`.opencode/tools/python-add.ts`):
```typescript
import { tool } from "@opencode-ai/plugin"
import path from "path"
export default tool({
  description: "Add two numbers using Python",
  args: {
    a: tool.schema.number().describe("First number"),
    b: tool.schema.number().describe("Second number"),
  },
  async execute(args, context) {
    const script = path.join(context.worktree, ".opencode/tools/add.py")
    const result = await Bun.$`python3 ${script} ${args.a} ${args.b}`.text()
    return result.trim()
  },
})
```

Here we are using the [`Bun.$`](https://bun.com/docs/runtime/shell) utility to run the Python script.

## Best Practices

1. **Clear Descriptions**: Provide clear, concise descriptions of what your tool does
2. **Type Safety**: Use Zod schemas to validate arguments and provide good error messages
3. **Error Handling**: Handle errors gracefully and return meaningful error messages
4. **Security**: Be cautious with tools that execute external code or access system resources
5. **Documentation**: Document any required setup or dependencies for your tools
6. **Testing**: Test your tools thoroughly before relying on them in important tasks
7. **Naming**: Use clear, descriptive names that indicate what the tool does
8. **Context Usage**: Leverage the context parameter when you need session information

## Tool Permissions

Control access to custom tools through the permission system in your `opencode.json`:

```json
{
  "$schema": "https://opencode.ai/config.json",
  "permission": {
    "mycustomtool": "allow",
    "*": "ask"
  }
}
```

You can use wildcards and patterns similar to other permissions:
- `*` - Match all tools
- `mytool_*` - Match all tools starting with "mytool_"
- `*` - Match all tools (global default)

## Relationship to Skills and Agents

Custom tools work alongside:
- **Skills**: Provide knowledge and guidance for agents
- **Built-in tools**: Provide core file system and interaction capabilities
- **Agents**: Can be configured with specific tools based on their roles

An agent's capabilities come from the combination of its assigned skills, available tools (both built-in and custom), and the underlying LLM model.

By creating custom tools, you can extend OpenCode's capabilities to perform virtually any action you need, tailored to your specific workflows and project requirements.
