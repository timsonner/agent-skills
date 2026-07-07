---
name: prerequisites
description: Prerequisites for using OpenCode - terminal emulator requirements and API key setup
author: Tim Sonner
license: MIT
compatibility: opencode
metadata:
  audience: developers
  workflow: setup
  language: markdown
---

# OpenCode Prerequisites

Before using OpenCode, you need to ensure you have the following prerequisites:

## Terminal Emulator Requirements

To use OpenCode in your terminal, you’ll need a modern terminal emulator like:

- [WezTerm](https://wezterm.org) - cross-platform
- [Alacritty](https://alacritty.org) - cross-platform
- [Ghostty](https://ghostty.org) - Linux and macOS
- [Kitty](https://sw.kovidgoyal.net/kitty/) - Linux and macOS

These terminals are recommended for optimal performance and compatibility with OpenCode’s features.

## API Keys for LLM Providers

You’ll need API keys for the LLM providers you want to use with OpenCode. OpenCode supports various LLM providers, and you can configure their API keys in the settings.

If you are new to using LLM providers, we recommend using [OpenCode Zen](/docs/zen). It’s a curated list of models that have been tested and verified by the OpenCode team.

To configure your API keys:
1. Run the `/connect` command in the TUI
2. Select your preferred provider
3. Follow the authentication process to obtain and enter your API key
