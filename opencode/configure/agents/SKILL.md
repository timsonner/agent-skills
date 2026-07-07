---
name: configure/agents
description: Configuration for OpenCode agents - defining and customizing AI agent behaviors and capabilities
author: Tim Sonner
license: MIT
compatibility: opencode
metadata:
  audience: developers
  workflow: configuration
  language: markdown
---

# OpenCode Agents Configuration

Configure and customize OpenCode agents to define their behaviors, capabilities, and roles in your development workflow.

## Overview

Agents in OpenCode are specialized AI assistants that can be configured with specific skills, tools, and behaviors to handle different types of tasks. You can define custom agents or modify existing ones to better suit your project needs.

## Agent Configuration

Agents are typically configured through:
- Configuration files that define agent properties
- Skill assignments that determine what the agent knows
- Tool permissions that control what actions the agent can take
- Behavioral instructions that guide how the agent operates

## Types of Agents

OpenCode supports various types of agents that can be configured for different purposes:

### General Purpose Agents
- Handle a wide range of development tasks
- Equipped with diverse skills and tools
- Suitable for general coding assistance

### Specialized Agents
- Focused on specific domains (e.g., web development, data science)
- Equipped with domain-specific skills and knowledge
- Optimized for particular types of tasks

### Collaborative Agents
- Designed to work in teams with other agents or humans
- May have communication and coordination capabilities
- Useful for complex, multi-step workflows

## Configuring Agent Properties

When configuring agents, you can typically specify:

### Name and Description
- Human-readable identifier for the agent
- Explanation of the agent's purpose and capabilities

### Assigned Skills
- List of skills that provide the agent with knowledge and capabilities
- Determines what the agent knows how to do

### Tool Permissions
- Controls which tools the agent can use
- Determines what actions the agent can perform in your codebase

### Behavioral Instructions
- Guidelines for how the agent should approach tasks
- May include preferences for certain methodologies or constraints

### Model Assignment
- Which LLM model powers the agent
- Affects the agent's capabilities and performance

## Agent Skills

Skills are a key part of agent configuration, providing:
- Domain-specific knowledge
- Procedural guidance for specific tasks
- Examples and best practices
- Context for understanding project types

An agent's capabilities are largely determined by the skills assigned to it.

## Agent Tools

Tools determine what actions an agent can take:
- File system operations (read, write, edit, etc.)
- Code search and navigation (grep, glob, list)
- External interactions (webfetch, question)
- System operations (bash, etc.)
- Custom tools and MCP server integrations

## Best Practices for Agent Configuration

1. **Start Clear**: Define a clear purpose for each agent
2. **Match Skills to Tasks**: Assign skills that align with the agent's intended use
3. **Principle of Least Privilege**: Give agents only the tools they need
4. **Test and Iterate**: Try agent configurations and refine based on performance
5. **Document Intent**: Keep notes on why agents are configured the way they are

## Example Agent Configurations

While the exact syntax for defining agents may vary, common configuration patterns include:

### Coding Assistant Agent
```
Name: General Coding Assistant
Skills: intro, usage, usage/ask-questions, usage/make-changes
Tools: read, write, edit, grep, glob, list, question
Model: [appropriate LLM model]
```

### Web Development Specialist
```
Name: Web Development Agent
Skills: usage/web, usage/tui, intro, usage/add-features
Tools: read, write, edit, grep, glob, list, webfetch, question
Model: [appropriate LLM model]
```

### Code Review Agent
```
Name: Code Review Agent
Skills: usage/ask-questions, intro
Tools: read, grep, glob, list, question
Permissions: edit=deny (read-only review)
Model: [appropriate LLM model]
```

## Relationship to Skills

Agents and skills work together:
- Skills provide knowledge and capabilities
- Agents are configured with specific skills to create specialized assistants
- The same skill can be used by multiple agents
- Agents can be reconfigured with different skills for different tasks

By configuring agents thoughtfully, you can create specialized AI assistants that are optimally suited for different aspects of your development workflow.
