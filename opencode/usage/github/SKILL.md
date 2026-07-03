---
name: usage/github
description: Using OpenCode with GitHub - repository management, pull requests, and collaboration features
license: MIT
compatibility: opencode
metadata:
  audience: developers
  workflow: usage
  language: markdown
---

# Using OpenCode with GitHub

OpenCode provides excellent integration with GitHub, helping you manage repositories, create pull requests, and collaborate effectively.

## GitHub Integration Features

OpenCode can assist with various GitHub-related tasks:

### 1. Repository Management
- Understanding repository structure and conventions
- Helping with repository setup and initialization
- Assisting with README files and documentation
- Supporting .gitignore configurations

### 2. Pull Request Assistance
- Creating pull request descriptions
- Suggesting improvements based on review comments
- Helping address feedback from code reviews
- Generating summaries of changes for PRs

### 3. Issue Management
- Helping create detailed issue reports
- Suggesting fixes based on issue descriptions
- Assisting with reproducing and understanding bugs
- Creating reproduction steps for reported issues

### 4. Collaboration Features
- Understanding team coding conventions
- Helping maintain consistency across contributions
- Assisting with code review processes
- Supporting documentation updates alongside code changes

## Common GitHub Tasks with OpenCode

### Creating a Pull Request
```
I've implemented a new feature for user authentication. Help me create a pull request summary that explains:
- What the feature does
- How it works
- Any breaking changes
- Testing instructions
```

### Addressing Review Comments
```
Based on these review comments:
1. Need to add error handling to the API calls
2. Should extract this logic into a helper function
3. Missing unit tests for edge cases

Please update the code in @src/services/auth.js accordingly.
```

### Working with Issues
```
Looking at issue #123: "Users unable to reset password when email contains special characters"
Help me understand the problem and suggest a fix.
```

### Understanding Repository Structure
```
Explain how this GitHub repository is organized:
- Where is the main application code?
- How are tests structured?
- What build tools are used?
- How are dependencies managed?
```

## GitHub Best Practices with OpenCode

When using OpenCode with GitHub:

1. **Leverage Context**: Use @ to reference specific files or sections when asking for help
2. **Be Specific**: Clearly describe what you need help with regarding GitHub workflows
3. **Follow Conventions**: Ask OpenCode to follow your team's GitHub practices
4. **Review Thoroughly**: Always review OpenCode's suggestions before creating PRs or commits
5. **Combine with Git**: Use OpenCode for coding assistance, but manage Git operations yourself or with Git-specific tools

## Example Prompts

```
How should I structure this new feature branch based on GitHub flow? @docs/CONTRIBUTING.md
```

```
Create a README.md file for this project that includes installation, usage, and API documentation.
```

```
Help me write a contribution guide for this open source project.
```

```
Explain how to set up GitHub Actions for CI/CD in this Node.js project.
```