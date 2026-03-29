---
name: usage/tui
description: Using OpenCode's Terminal User Interface (TUI) - navigation, modes, and productivity tips
license: MIT
compatibility: opencode
metadata:
  audience: developers
  workflow: usage
  language: markdown
---

# Using OpenCode's Terminal User Interface (TUI)

OpenCode's Terminal User Interface (TUI) provides an interactive way to work with the AI coding agent. This guide covers how to navigate and use the TUI effectively.

## TUI Overview

When you launch OpenCode with `opencode`, you'll see the TUI which includes:

- Input area for prompts
- Display area for responses
- Status bar showing current mode and context
- Keyboard shortcuts for common actions

## Key TUI Features

### 1. Plan Mode vs Build Mode

Toggle between modes using the **Tab** key:

- **Plan Mode**: OpenCode suggests how it will implement changes without making them
- **Build Mode**: OpenCode executes the changes you've approved

The current mode is displayed in the status bar.

### 2. Fuzzy File Search

Use the `@` symbol to reference files in your prompts:

```
How is authentication handled in @src/auth/service.js
```

OpenCode will fuzzy search for the file and include its context in the prompt.

### 3. Image Support

Drag and drop images into the TUI to include them in your prompts. OpenCode can analyze and reference these images.

### 4. Undo/Redo

- `/undo`: Revert the last changes made by OpenCode
- `/redo`: Reapply changes that were undone

These commands can be used multiple times to step through your history.

### 5. Sharing Conversations

Use `/share` to create a shareable link to your current conversation and copy it to your clipboard.

## Productivity Tips

### Efficient Prompting

1. **Be Specific**: Provide clear, detailed descriptions of what you want
2. **Use Context**: Reference specific files, functions, or code sections
3. **Iterate**: Use Plan mode to review complex changes before implementing
4. **Leverage Examples**: Provide code examples or references when asking for similar implementations

### Working with Large Codebases

1. Use `@` to quickly jump to relevant files
2. Ask OpenCode to explain specific components before modifying them
3. Break large changes into smaller, manageable pieces

### Customizing the TUI

While the TUI itself has limited customization options, you can:

1. Adjust your terminal font and size for readability
2. Use keyboard shortcuts efficiently
3. Customize OpenCode's behavior through configuration files

## Common TUI Workflows

### Exploring a Codebase

1. Ask OpenCode to explain the project structure
2. Use `@` to examine specific files or directories
3. Ask about relationships between components

### Implementing a Feature

1. Describe the feature in detail
2. Switch to Plan mode (Tab) to review the approach
3. Provide feedback or request adjustments
4. Switch to Build mode (Tab) to implement
5. Review the changes and request refinements if needed

### Debugging Issues

1. Describe the problem and expected behavior
2. Ask OpenCode to examine relevant code sections
3. Request potential fixes or debugging strategies
4. Implement suggested changes and test

## TUI Keyboard Shortcuts

- **Tab**: Toggle Plan/Build mode
- **Enter**: Submit prompt
- **Escape**: Cancel input or clear selection
- **Up/Down**: Navigate command history
- **Ctrl+C**: Interrupt current operation
- **Ctrl+D**: Exit OpenCode
- **@**: Trigger fuzzy file search
- **:`**: Open command palette (if available)

## Troubleshooting TUI Issues

If you encounter issues with the TUI:

1. Ensure your terminal supports the required features
2. Check for compatibility with your terminal emulator
3. Try updating to the latest version of OpenCode
4. Report persistent issues to the OpenCode team