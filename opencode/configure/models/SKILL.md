---
name: configure/models
description: Configuration for OpenCode models - selecting and configuring LLM providers and specific models
author: Tim Sonner
license: MIT
compatibility: opencode
metadata:
  audience: developers
  workflow: configuration
  language: markdown
---

# OpenCode Models Configuration

Configure and select the language models that power OpenCode's AI agents.

## Overview

OpenCode supports various LLM providers and models. You can configure which models to use for different agents or tasks, balancing capabilities, performance, and cost.

## Model Configuration

Models are typically configured through:
- Provider selection (which LLM service to use)
- Model selection (which specific model from that provider)
- Provider-specific settings (API keys, parameters, etc.)
- Agent assignments (which model powers which agent)

## Available Providers

OpenCode supports integration with various LLM providers. For a complete list, see the [Providers](/docs/providers/) documentation.

## Recommended: OpenCode Zen

If you are new to using LLM providers, we recommend using [OpenCode Zen](/docs/zen). It’s a curated list of models that have been tested and verified by the OpenCode team.

## Configuring Models

### Provider Configuration
To configure an LLM provider:
1. Run the `/connect` command in the TUI
2. Select your preferred provider from the list
3. Follow the authentication process to obtain your API key
4. Paste your API key when prompted

### Model Selection
Once a provider is configured, you can typically select from available models offered by that provider. Different models offer different balances of:
- Capabilities (reasoning, code generation, etc.)
- Speed and response time
- Cost per token
- Context window size

### Agent Model Assignment
Different agents can be assigned different models based on their tasks:
- Complex reasoning tasks might use more capable models
- Simple code generation might use faster, less expensive models
- Specialized domains might benefit from models trained on relevant data

## Model Parameters

When configuring models, you may be able to adjust parameters such as:
- Temperature (controls randomness vs. determinism)
- Max tokens (limits response length)
- Top-p (alternative to temperature for controlling randomness)
- Frequency and presence penalties (reduce repetition)

## Best Practices for Model Configuration

1. **Match Model to Task**: Use appropriate models for different types of work
2. **Consider Cost**: Balance capabilities with budget constraints
3. **Test Performance**: Try different models to see what works best for your use cases
4. **Stay Updated**: New models are released periodically - consider upgrading when beneficial
5. **Document Choices**: Keep notes on why specific models were chosen for specific agents

## Example Model Configurations

### For Complex Reasoning Tasks
- Provider: [Specific provider]
- Model: [Most capable model available]
- Use for: Architecture planning, complex debugging, strategic decisions

### For Code Generation
- Provider: [Specific provider]
- Model: [Model known for strong code generation]
- Use for: Writing new functions, creating files, implementing features

### For Quick Tasks
- Provider: [Specific provider]
- Model: [Faster, more efficient model]
- Use for: Simple questions, small edits, explanations

### For Specialized Domains
- Provider: [Provider with domain-specific models]
- Model: [Model trained on relevant data]
- Use for: Tasks in specific fields like data science, security, etc.

## Relationship to Agents and Skills

Models work together with agents and skills:
- Models provide the underlying AI capabilities
- Agents are configured with specific models to determine their intelligence
- Skills provide domain-specific knowledge that agents apply using their model capabilities
- The same skill can be used by agents with different models, potentially yielding different results

By configuring models thoughtfully, you can ensure that OpenCode's AI agents have the right capabilities for the tasks they're assigned to perform.
