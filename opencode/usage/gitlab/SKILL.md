---
name: usage/gitlab
description: Using OpenCode with GitLab - repository management, merge requests, and CI/CD features
author: Tim Sonner
license: MIT
compatibility: opencode
metadata:
  audience: developers
  workflow: usage
  language: markdown
---

# Using OpenCode with GitLab

OpenCode provides excellent integration with GitLab, helping you manage repositories, create merge requests, and work with GitLab's CI/CD features.

## GitLab Integration Features

OpenCode can assist with various GitLab-related tasks:

### 1. Repository Management
- Understanding repository structure and conventions
- Helping with repository setup and initialization
- Assisting with README files and documentation
- Supporting .gitignore configurations

### 2. Merge Request Assistance
- Creating merge request descriptions
- Suggesting improvements based on review comments
- Helping address feedback from code reviews
- Generating summaries of changes for merge requests

### 3. Issue Management
- Helping create detailed issue reports
- Suggesting fixes based on issue descriptions
- Assisting with reproducing and understanding bugs
- Creating reproduction steps for reported issues

### 4. CI/CD Pipeline Support
- Understanding .gitlab-ci.yml configurations
- Helping create and optimize CI/CD pipelines
- Assisting with debugging pipeline failures
- Suggesting improvements to build and test stages

### 5. Collaboration Features
- Understanding team coding conventions
- Helping maintain consistency across contributions
- Assisting with code review processes
- Supporting documentation updates alongside code changes

## Common GitLab Tasks with OpenCode

### Creating a Merge Request
```
I've implemented a new feature for user authentication. Help me create a merge request summary that explains:
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

Please update the code in @src/services/auth</think>Based on these review comments:
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

### Working with CI/CD Pipelines
```
This GitLab CI pipeline is failing in the test stage:
- Error: "Cannot find module 'jest'"
- The pipeline runs npm test but jest isn't installed in the test job

Help me fix the .gitlab-ci.yml to properly install dependencies before running tests.
```

### Understanding Repository Structure
```
Explain how this GitLab repository is organized:
- Where is the main application code?
- How are tests structured?
- What CI/CD pipelines are configured?
- How are dependencies managed?
```

## GitLab Best Practices with OpenCode

When using OpenCode with GitLab:

1. **Leverage Context**: Use @ to reference specific files or sections when asking for help
2. **Be Specific**: Clearly describe what you need help with regarding GitLab workflows
3. **Follow Conventions**: Ask OpenCode to follow your team's GitLab practices
4. **Review Thoroughly**: Always review OpenCode's suggestions before creating merge requests or commits
5. **Combine with Git**: Use OpenCode for coding assistance, but manage Git operations yourself or with Git-specific tools
6. **CI/CD Awareness**: Consider pipeline implications when making changes

## Example Prompts

```
How should I structure this new feature branch based on GitLab flow? @docs/CONTRIBUTING.md
```

```
Create a README.md file for this project that includes installation, usage, and API documentation.
```

```
Help me write a contribution guide for this open source project.
```

```
Explain how to set up GitLab CI/CD for automated testing in this Node.js project.
```

```
Review this .gitlab-ci.yml file and suggest improvements for better performance and reliability.
```
