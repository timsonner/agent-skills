---
name: tui
description: Terminal User Interface (TUI) instructions for OpenCode - how to navigate and use the OpenCode TUI
license: MIT
compatibility: opencode
metadata:
  audience: developers
  workflow: interface
  language: markdown
---

# OpenCode Terminal User Interface (TUI)

OpenCode provides a rich Terminal User Interface (TUI) for interacting with the AI coding agent. This guide covers the basics of navigating and using the OpenCode TUI.

## Getting Started with the TUI

After installing OpenCode and configuring your LLM provider, you can start the TUI by running:

```
opencode
```

This will launch the OpenCode TUI in your terminal.

## Basic Navigation

The OpenCode TUI uses keyboard shortcuts for navigation and commands:

- **Tab**: Toggle between Plan mode and Build mode
- **Enter**: Submit a prompt or command
- **Escape**: Cancel or go back
- **Up/Down Arrows**: Navigate through history
- **Ctrl+C**: Interrupt current operation
- **Ctrl+D**: Exit OpenCode

## Plan Mode vs Build Mode

OpenCode operates in two distinct modes:

### Plan Mode (Tab key)
- Disables OpenCode's ability to make direct changes
- Focuses on suggesting *how* it will implement features
- Allows you to review and iterate on plans before execution
- Indicated by a visual cue in the lower right corner

### Build Mode (Tab key)
- Enables OpenCode to make actual changes to your codebase
- Executes the plans you've reviewed and approved
- Returns to this mode when you're ready to implement

## Special Features

### Fuzzy File Search
Use the `@` key to fuzzy search for files in your project:
```
How is authentication handled in @packages/functions/src/api/index.ts
```

### Image Support
You can drag and drop images into the terminal to include them in your prompts. OpenCode can analyze and reference these images.

### Undo/Redo Commands
- `/undo`: Revert the last changes made by OpenCode
- `/redo`: Reapply changes that were undone

### Sharing Conversations
- `/share`: Create a shareable link to your current conversation

## Common TUI Interactions

### Asking Questions
Simply type your question and press Enter. OpenCode will analyze your codebase and provide explanations.

### Requesting Changes
Describe what you want to change, and OpenCode will either:
1. Suggest a plan (in Plan mode) for you to review
2. Directly implement changes (in Build mode)

### Providing Feedback
After OpenCode gives a plan or makes changes, you can:
- Ask for revisions
- Provide additional context
- Request different approaches

## Tips for Effective TUI Use

1. **Be Specific**: Provide clear, detailed prompts
2. **Use Context**: Reference specific files with `@` notation
3. **Iterate**: Use Plan mode to review before implementing
4. **Leverage Undo**: Don't hesitate to experiment - you can always undo
5. **Share Learning**: Use `/share` to share useful conversations with teammates