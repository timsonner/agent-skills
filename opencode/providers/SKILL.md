---
name: providers
description: LLM provider configuration for OpenCode - how to set up and use different language model providers
license: MIT
compatibility: opencode
metadata:
  audience: developers
  workflow: configuration
  language: markdown
---

# OpenCode LLM Providers

OpenCode supports various LLM providers, allowing you to choose the best model for your needs. This guide covers how to configure and use different providers.

## Recommended: OpenCode Zen

If you are new to using LLM providers, we recommend using [OpenCode Zen](/docs/zen). It’s a curated list of models that have been tested and verified by the OpenCode team.

## Connecting to Providers

To configure an LLM provider:

1.  Run the `/connect` command in the TUI
    
    ```
    /connect
    ```
    
2.  Select your preferred provider from the list
    
3.  Follow the authentication process to obtain your API key
    
4.  Paste your API key when prompted
    
    ```
    ┌ API key││└ enter
    ```
    

## Available Providers

OpenCode supports integration with various LLM providers. For a complete list and specific configuration instructions for each provider, refer to the [Providers](/docs/providers#directory) documentation.

## Provider Configuration Tips

- Ensure you have valid API keys with sufficient quota
- Some providers may require specific model selections
- Check provider-specific rate limits and pricing
- Test your connection before starting complex tasks

## Switching Between Providers

You can switch between different providers at any time by running the `/connect` command again and selecting a different provider.

## Provider-Specific Features

Different providers may offer:
- Different model capabilities
- Varying response speeds
- Different cost structures
- Specialized features (reasoning, code generation, etc.)

Choose the provider that best matches your project requirements and budget.