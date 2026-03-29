---
name: configure/commands
description: Configuration for OpenCode custom commands - creating and managing custom slash commands for repetitive tasks
license: MIT
compatibility: opencode
metadata:
  audience: developers
  workflow: configuration
  language: markdown
---

# OpenCode Commands Configuration

Create custom commands for repetitive tasks in OpenCode.

## Overview

Custom commands let you specify a prompt you want to run when that command is executed in the TUI. They are in addition to the built-in commands like `/init`, `/undo`, `/redo`, `/share`, `/help`.

## Creating Command Files

You can create custom commands by creating markdown files in the `commands/` directory.

### Per-project Commands
Create `.opencode/commands/test.md`:

```
---description: Run tests with coverageagent: buildmodel: anthropic/claude-3-5-sonnet-20241022---
Run the full test suite with coverage report and show any failures.
Focus on the failing tests and suggest fixes.
```

The frontmatter defines command properties. The content becomes the template.

Use the command by typing `/` followed by the command name:
```
/test
```

### Global Commands
You can also define commands globally:
- Global: `~/.config/opencode/commands/`
- Per-project: `.opencode/commands/`

## Command Configuration Options

### JSON Configuration
You can add custom commands through the OpenCode config:

```jsonc
{
  "$schema": "https://opencode.ai/config.json",
  "command": {
    "test": {
      "template": "Run the full test suite with coverage report and show any failures.\nFocus on the failing tests and suggest fixes.",
      "description": "Run tests with coverage",
      "agent": "build",
      "model": "anthropic/claude-3-5-sonnet-20241022"
    }
  }
}
```

Then run the command in the TUI:
```
/test
```

## Prompt Configuration

The prompts for custom commands support several special placeholders and syntax.

### Arguments
Pass arguments to commands using the `$ARGUMENTS` placeholder:

```
---description: Create a new component---
Create a new React component named $ARGUMENTS with TypeScript support.Include proper typing and basic structure.
```

Run with arguments:
```
/component Button
```

Access individual arguments:
- `$1` - First argument
- `$2` - Second argument
- `$3` - Third argument

Example:
```
---description: Create a new file with content---
Create a file named $1 in the directory $2 with the following content: $3
```

Run:
```
/create-file config.json src "{ \"key\": \"value\" }"
```

### Shell Output
Use ``!`command`* to inject bash command output:

```
---description: Analyze test coverage---
Here are the current test results:!`npm test`
Based on these results, suggest improvements to increase coverage.
```

Or:
```
---description: Review recent changes---
Recent git commits:!`git log --oneline -10`
Review these changes and suggest any improvements.
```

### File References
Include files using `@` followed by the filename:

```
---description: Review component---
Review the component in @src/components/Button.tsx.Check for performance issues and suggest improvements.
```

## Command Options

### Template (Required)
The `template` option defines the prompt sent to the LLM when the command executes.

### Description (Optional)
The `description` option provides a brief description shown in the TUI when typing the command.

### Agent (Optional)
The `agent` config specifies which agent should execute the command. If not specified, defaults to your current agent.

### Subtask (Optional)
The `subtask` boolean forces the command to trigger a subagent invocation. Useful to avoid polluting primary context.

### Model (Optional)
The `model` config overrides the default model for this command.

## Built-in Commands

OpenCode includes several built-in commands like `/init`, `/undo`, `/redo`, `/share`, `/help`. Custom commands can override built-in commands if they share the same name.

## Best Practices

1. **Be Specific**: Create commands for truly repetitive tasks
2. **Use Arguments**: Make commands flexible with argument placeholders
3. **Leverage Shell Output**: Incorporate command outputs for dynamic prompts
4. **Reference Files**: Use `@` to include relevant file content
5. **Document Clearly**: Provide helpful descriptions for team members
6. **Test Commands**: Verify commands work as expected before sharing
7. **Version Control**: Consider committing command files to share with team

## Example Commands

### Code Generation
```
---description: Create a React component---
Create a new React component named $ARGUMENTS with props $2.
Include proper TypeScript interfaces and default export.
```

### Debugging Assistance
```
---description: Debug error---
I'm getting this error: $ARGUMENTS
Here's the relevant code: @$1
Please help me identify and fix the issue.
```

### Project Analysis
```
---description: Analyze project structure---
Please analyze the structure of this project:
!`find . -type f -not -path "*/node_modules/*" -not -path "*/.git/*" | head -20`
Focus on identifying the main architectural patterns.
```

By creating custom commands, you can streamline your workflow and reduce repetitive typing when working with OpenCode.