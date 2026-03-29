---
name: configure/lsp
description: Configuration for OpenCode LSP servers - setting up and customizing Language Server Protocol integration
license: MIT
compatibility: opencode
metadata:
  audience: developers
  workflow: configuration
  language: markdown
---

# OpenCode LSP Servers Configuration

Configure and customize Language Server Protocol (LSP) servers in OpenCode to enhance code intelligence features.

## Overview

OpenCode integrates with your LSP servers to help the LLM interact with your codebase. It uses diagnostics to provide feedback to the LLM.

## Built-in LSP Servers

OpenCode comes with several built-in LSP servers for popular languages:

| LSP Server | Extensions | Requirements |
|------------|------------|--------------|
| astro | .astro | Auto-installs for Astro projects |
| bash | .sh, .bash, .zsh, .ksh | Auto-installs bash-language-server |
| clangd | .c, .cpp, .cc, .cxx, .c++, .h, .hpp, .hh, .hxx, .h++ | Auto-installs for C/C++ projects |
| csharp | .cs | `.NET SDK` installed |
| clojure-lsp | .clj, .cljs, .cljc, .edn | `clojure-lsp` command available |
| dart | .dart | `dart` command available |
| deno | .ts, .tsx, .js, .jsx, .mjs | `deno` command available (auto-detects deno.json/deno.jsonc) |
| elixir-ls | .ex, .exs | `elixir` command available |
| eslint | .ts, .tsx, .js, .jsx, .mjs, .cjs, .mts, .cts, .vue | `eslint` dependency in project |
| fsharp | .fs, .fsi, .fsx, .fsscript | `.NET SDK` installed |
| gleam | .gleam | `gleam` command available |
| gopls | .go | `go` command available |
| hls | .hs, .lhs | `haskell-language-server-wrapper` command available |
| jdtls | .java | `Java SDK (version 21+)` installed |
| julials | .jl | `julia` and `LanguageServer.jl` installed |
| kotlin-ls | .kt, .kts | Auto-installs for Kotlin projects |
| lua-ls | .lua | Auto-installs for Lua projects |
| nixd | .nix | `nixd` command available |
| ocaml-lsp | .ml, .mli | `ocamllsp` command available |
| oxlint | .ts, .tsx, .js, .jsx, .mjs, .cjs, .mts, .cts, .vue, .astro, .svelte | `oxlint` dependency in project |
| php intelephense | .php | Auto-installs for PHP projects |
| prisma | .prisma | `prisma` command available |
| pyright | .py, .pyi | `pyright` dependency installed |
| ruby-lsp (rubocop) | .rb, .rake, .gemspec, .ru | `ruby` and `gem` commands available |
| rust | .rs | `rust-analyzer` command available |
| sourcekit-lsp | .swift, .objc, .objcpp | `swift` installed (`xcode` on macOS) |
| svelte | .svelte | Auto-installs for Svelte projects |
| terraform | .tf, .tfvars | Auto-installs from GitHub releases |
| tinymist | .typ, .typc | Auto-installs from GitHub releases |
| typescript | .ts, .tsx, .js, .jsx, .mjs, .cjs, .mts, .cts | `typescript` dependency in project |
| vue | .vue | Auto-installs for Vue projects |
| yaml-ls | .yaml, .yml | Auto-installs Red Hat yaml-language-server |
| zls | .zig, .zon | `zig` command available |

LSP servers are automatically enabled when one of the above file extensions are detected and the requirements are met.

Note: You can disable automatic LSP server downloads by setting the `OPENCODE_DISABLE_LSP_DOWNLOAD` environment variable to `true`.

## How It Works

When opencode opens a file, it:
1. Checks the file extension against all enabled LSP servers.
2. Starts the appropriate LSP server if not already running.

## Configuration

You can customize LSP servers through the `lsp` section in your opencode config (`opencode.json`):

```json
{
  "$schema": "https://opencode.ai/config.json",
  "lsp": {}
}
```

Each LSP server supports the following properties:

| Property | Type | Description |
|----------|------|-------------|
| `disabled` | boolean | Set to `true` to disable the LSP server |
| `command` | string[] | The command to start the LSP server |
| `extensions` | string[] | File extensions this LSP server should handle |
| `env` | object | Environment variables to set when starting server |
| `initialization` | object | Initialization options to send to the LSP server |

### Environment Variables

Use the `env` property to set environment variables when starting the LSP server:

```json
{
  "$schema": "https://opencode.ai/config.json",
  "lsp": {
    "rust": {
      "env": {
        "RUST_LOG": "debug"
      }
    }
  }
}
```

### Initialization Options

Use the `initialization` property to pass initialization options to the LSP server. These are server-specific settings sent during the LSP `initialize` request:

```json
{
  "$schema": "https://opencode.ai/config.json",
  "lsp": {
    "typescript": {
      "initialization": {
        "preferences": {
          "importModuleSpecifierPreference": "relative"
        }
      }
    }
  }
}
```

Note: Initialization options vary by LSP server. Check your LSP server's documentation for available options.

### Disabling LSP Servers

To disable all LSP servers globally, set `lsp` to `false`:

```json
{
  "$schema": "https://opencode.ai/config.json",
  "lsp": false
}
```

To disable a specific LSP server, set `disabled` to `true`:

```json
{
  "$schema": "https://opencode.ai/config.json",
  "lsp": {
    "typescript": {
      "disabled": true
    }
  }
}
```

### Custom LSP Servers

You can add custom LSP servers by specifying the command and file extensions:

```json
{
  "$schema": "https://opencode.ai/config.json",
  "lsp": {
    "custom-lsp": {
      "command": ["custom-lsp-server", "--stdio"],
      "extensions": [".custom"]
    }
  }
}
```

## Additional Information

### PHP Intelephense

PHP Intelephense offers premium features through a license key. You can provide a license key by placing (only) the key in a text file at:

- On macOS/Linux: `$HOME/intelephense/license.txt`
- On Windows: `%USERPROFILE%/intelephense/license.txt`

The file should contain only the license key with no additional content.

## Best Practices

1. **Match Your Project**: Ensure LSP servers match the languages and frameworks used in your project
2. **Performance**: Consider resource usage of LSP servers, especially for large projects
3. **Reliability**: Choose LSP servers that are actively maintained and stable
4. **Configuration**: Take advantage of initialization options to tailor LSP behavior to your preferences
5. **Environment Variables**: Use environment variables for settings like log levels or API keys when needed
6. **Custom Servers**: Only add custom LSP servers when built-in options don't meet your needs

By configuring LSP servers appropriately, you enhance OpenCode's ability to understand and interact with your codebase, leading to more accurate and helpful AI assistance.