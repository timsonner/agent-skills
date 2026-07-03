---
name: usage/zen
description: Using OpenCode Zen - curated list of tested and verified LLM models
license: MIT
compatibility: opencode
metadata:
  audience: developers
  workflow: usage
  language: markdown
---

# Using OpenCode Zen

OpenCode Zen is a curated list of language models that have been tested and verified by the OpenCode team for optimal performance and reliability.

## What is OpenCode Zen?

OpenCode Zen provides:
- A selection of LLM models known to work well with OpenCode
- Models tested for coding assistance capabilities
- Verified performance and reliability benchmarks
- Recommended configurations for different use cases

## Benefits of Using OpenCode Zen

1. **Reliability**: Models have been tested to work consistently with OpenCode
2. **Performance**: Optimized for coding tasks and code generation
3. **Compatibility**: Known to work well with OpenCode's features and workflows
4. **Reduced Setup Time**: No need to experiment with multiple models
5. **Community Validation**: Based on feedback from the OpenCode community

## How to Access OpenCode Zen

When configuring your LLM provider in OpenCode:
1. Run the `/connect` command in the TUI
2. Look for the OpenCode Zen option in the provider list
3. Select it to use the curated Zen models
4. Follow the authentication process if required

## Using Zen Models Effectively

### For Code Generation
Zen models are particularly strong at:
- Writing clean, functional code
- Following best practices and conventions
- Understanding complex programming concepts
- Generating boilerplate and repetitive code patterns

### For Code Explanation
Zen models excel at:
- Explaining complex code sections
- Breaking down algorithms and data structures
- Providing context for unfamiliar codebases
- Documenting code functionality

### For Refactoring
Zen models can help with:
- Suggesting improvements to code structure
- Identifying code smells and anti-patterns
- Recommending more efficient implementations
- Maintaining functionality while improving readability

## Zen Model Characteristics

The models in OpenCode Zen typically feature:
- Strong coding capabilities
- Good understanding of multiple programming languages
- Ability to follow detailed instructions
- Consistency in output quality
- Reasonable response times for coding tasks

## When to Consider Alternatives

While OpenCode Zen is recommended for most users, you might consider other providers if you need:
- Specific model capabilities not in Zen
- Different pricing or performance characteristics
- Enterprise-specific features or compliance requirements
- Access to the very latest model releases

## Getting Started with Zen

To begin using OpenCode Zen:
1. Ensure you have OpenCode installed
2. Run `/connect` to configure your provider
3. Select OpenCode Zen from the available options
4. Complete any required authentication
5. Start using OpenCode with the verified Zen models

## Example Prompts for Zen Models

```
Explain how this sorting algorithm works and suggest any improvements @src/utils/sort.js
```

```
Create a React hook for managing form validation with error handling.
```

```
Refactor this Python class to use dependency injection for better testability.
```

```
Write unit tests for this Go function covering all edge cases.
```