---
name: configure/rules
description: Configuration for OpenCode rules - defining custom instructions and behaviors for the AI agent
license: MIT
compatibility: opencode
metadata:
  audience: developers
  workflow: configuration
  language: markdown
---

# OpenCode Rules Configuration

Define custom instructions and behaviors for the OpenCode AI agent using rules.

## Overview

Rules allow you to customize how OpenCode behaves in your project by defining specific instructions that the AI agent should follow. These can include coding conventions, project-specific guidelines, or behavioral constraints.

## Creating Rules

Rules are typically defined in your project's configuration files or through special command interfaces. They help tailor OpenCode's behavior to your specific project needs and team practices.

## Types of Rules

OpenCode supports various types of rules that can influence:

### Coding Standards
- Language-specific formatting guidelines
- Naming conventions
- Code organization preferences
- Commenting standards

### Behavioral Guidelines
- How the agent should approach problem-solving
- Preferences for certain implementation patterns
- Constraints on what the agent can or cannot do
- Interaction preferences with users

### Project-Specific Instructions
- Framework-specific guidelines
- Architecture preferences
- Dependency management rules
- Testing strategies

## Applying Rules

Rules can be applied through:
- Configuration files in your project
- Special command interfaces in OpenCode
- Agent-specific instructions
- Skill definitions that encode rules

## Best Practices

When defining rules for OpenCode:
1. Be specific and clear about what you want
2. Focus on behaviors that will improve consistency
3. Consider your team's existing practices
4. Start with a few key rules and iterate
5. Review and update rules as your project evolves

## Example Rule Applications

While the specific syntax for defining rules may vary based on how you configure OpenCode, common applications include:

- Enforcing specific code formatting styles
- Requiring certain types of comments or documentation
- Specifying preferred architectural patterns
- Setting constraints on file modifications
- Defining how the agent should ask clarifying questions

## Relationship to Other Configuration

Rules work alongside other OpenCode configuration elements:
- Tool permissions control what actions the agent can take
- Agent definitions specify capabilities and behaviors
- Skills provide domain-specific knowledge
- Models determine the underlying LLM capabilities

By defining clear rules, you can help ensure that OpenCode behaves in ways that align with your project's standards and your team's preferences.