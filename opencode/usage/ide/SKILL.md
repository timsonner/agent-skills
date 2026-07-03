---
name: usage/ide
description: Using OpenCode with IDE extensions - VS Code, JetBrains, and other editor integrations
license: MIT
compatibility: opencode
metadata:
  audience: developers
  workflow: usage
  language: markdown
---

# Using OpenCode with IDE Extensions

OpenCode provides IDE extensions that bring its AI coding capabilities directly into your favorite editors like VS Code and JetBrains IDEs.

## Available IDE Extensions

OpenCode offers extensions for:

- **Visual Studio Code**: Rich integration with VS Code's editor
- **JetBrains IDEs**: Support for IntelliJ, PyCharm, WebStorm, etc.
- **Other editors**: Additional integrations may be available

## VS Code Extension Features

The OpenCode VS Code extension provides:

### 1. Inline Chat
- Chat with OpenCode directly in the editor sidebar
- Reference code from your workspace using @ mentions
- Get explanations and suggestions without leaving your editor

### 2. Code Actions
- Generate code from natural language descriptions
- Refactor existing code with AI assistance
- Create tests, documentation, and comments

### 3. Context Awareness
- Understand your project structure and dependencies
- Reference open files and selections in prompts
- Maintain awareness of coding conventions in your workspace

### 4. Seamless Integration
- Keyboard shortcuts for common actions
- Integration with VS Code's command palette
- Status bar indicators for OpenCode state

## JetBrains Extension Features

The OpenCode JetBrains extension provides similar capabilities:

### 1. AI Assistant Tool Window
- Dedicated panel for interacting with OpenCode
- Chat interface with code context awareness
- History of interactions

### 2. Code Generation and Refactoring
- Generate code snippets, functions, classes
- Refactor code with AI-powered suggestions
- Create unit tests and documentation

### 3. Contextual Understanding
- Project structure awareness
- Language-specific intelligence
- Framework and library recognition

## Using IDE Extensions Effectively

### Getting Started

1. Install the OpenCode extension from your IDE's marketplace
2. Sign in with your OpenCode account
3. Configure any necessary settings (API keys if required)

### Basic Usage

1. Open the OpenCode panel/chat in your IDE
2. Describe what you want to accomplish
3. Use @ to reference specific files or code sections
4. Review suggestions and apply changes

### Advanced Features

- **File Reference**: Use @filename.js to include file context
- **Selection Awareness**: OpenCode understands selected text in editors
- **Multi-file Operations**: Request changes across multiple files
- **Language-Specific Help**: Get framework-specific assistance

## IDE-Specific Commands and Shortcuts

### VS Code
- `Ctrl+Shift+P` → "OpenCode: Open Chat"
- `Ctrl+Alt+O` → Focus OpenCode chat
- Customizable keybindings for common actions

### JetBrains
- Access via "Tools" → "OpenCode" menu
- Dedicated tool window accessible from sidebar
- Configurable shortcuts in IDE settings

## Best Practices for IDE Usage

1. **Context is Key**: Use file references (@) to give OpenCode specific context
2. **Iterative Refinement**: Start with broad requests, then refine based on results
3. **Leverage Editor Features**: Combine OpenCode suggestions with editor refactoring tools
4. **Stay in Flow**: Use IDE integrations to minimize context switching
5. **Code Review**: Always review AI-generated code before accepting

## Troubleshooting IDE Extensions

If you encounter issues with the IDE extensions:

1. Ensure you're using the latest version of the extension
2. Check that you're signed in to your OpenCode account
3. Verify network connectivity if using cloud features
4. Try reinstalling the extension
5. Check IDE logs for specific error messages
6. Contact support if issues persist

## Example Workflows

### In VS Code
1. Open a file you want to modify
2. Open OpenCode sidebar (`Ctrl+Shift+P` → "OpenCode: Open Chat")
3. Ask: "Add error handling to this function" @currentFile.js
4. Review the suggested changes
5. Apply changes with a click or command

### In JetBrains
1. Select a code block you want to refactor
2. Open OpenCode tool window
3. Ask: "Extract this block into a reusable function" @selection
4. Review and apply the suggested refactoring