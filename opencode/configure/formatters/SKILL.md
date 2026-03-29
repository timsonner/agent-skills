---
name: configure/formatters
description: Configuration for OpenCode formatters - setting up and customizing code formatters for different languages
license: MIT
compatibility: opencode
metadata:
  audience: developers
  workflow: configuration
  language: markdown
---

# OpenCode Formatters Configuration

Configure and customize code formatters in OpenCode to maintain consistent code styles.

## Overview

OpenCode uses language-specific formatters to automatically format files after they are written or edited. This ensures that generated code follows your project's code styles.

## How Formatters Work

When OpenCode writes or edits a file, it:
1. Checks the file extension against all enabled formatters
2. Runs the appropriate formatter command on the file
3. Applies the formatting changes automatically

This process happens in the background, ensuring your code styles are maintained without manual steps.

## Built-in Formatters

OpenCode comes with several built-in formatters for popular languages and frameworks:

| Formatter | Extensions | Requirements |
|-----------|------------|--------------|
| air | .R | `air` command available |
| biome | .js, .jsx, .ts, .tsx, .html, .css, .md, .json, .yaml, and more | `biome.json(c)` config file |
| cargofmt | .rs | `cargo fmt` command available |
| clang-format | .c, .cpp, .h, .hpp, .ino, and more | `.clang-format` config file |
| cljfmt | .clj, .cljs, .cljc, .edn | `cljfmt` command available |
| dart | .dart | `dart` command available |
| dfmt | .d | `dfmt` command available |
| gleam | .gleam | `gleam` command available |
| gofmt | .go | `gofmt` command available |
| htmlbeautifier | .erb, .html.erb | `htmlbeautifier` command available |
| ktlint | .kt, .kts | `ktlint` command available |
| mix | .ex, .exs, .eex, .heex, .leex, .neex, .sface | `mix` command available |
| nixfmt | .nix | `nixfmt` command available |
| ocamlformat | .ml, .mli | `ocamlformat` command available and `.ocamlformat` config file |
| ormolu | .hs | `ormolu` command available |
| oxfmt (Experimental) | .js, .jsx, .ts, .tsx | `oxfmt` dependency in `package.json` and experimental env variable flag |
| pint | .php | `laravel/pint` dependency in `composer.json` |
| prettier | .js, .jsx, .ts, .tsx, .html, .css, .md, .json, .yaml, and more | `prettier` dependency in `package.json` |
| rubocop | .rb, .rake, .gemspec, .ru | `rubocop` command available |
| ruff | .py, .pyi | `ruff` command available with config |
| rustfmt | .rs | `rustfmt` command available |
| shfmt | .sh, .bash | `shfmt` command available |
| standardrb | .rb, .rake, .gemspec, .ru | `standardrb` command available |
| terraform | .tf, .tfvars | `terraform` command available |
| uv | .py, .pyi | `uv` command available |
| zig | .zig, .zon | `zig` command available |

If your project has `prettier` in your `package.json`, OpenCode will automatically use it for supported file types.

## Configuring Formatters

Customize formatters through the `formatter` section in your OpenCode config (`opencode.json`):

```json
{
  "$schema": "https://opencode.ai/config.json",
  "formatter": {}
}
```

Each formatter configuration supports:

| Property | Type | Description |
|----------|------|-------------|
| `disabled` | boolean | Set to `true` to disable the formatter |
| `command` | string[] | The command to run for formatting |
| `environment` | object | Environment variables to set when running the formatter |
| `extensions` | string[] | File extensions this formatter should handle |

### Disabling Formatters

To disable all formatters globally:
```json
{
  "$schema": "https://opencode.ai/config.json",
  "formatter": false
}
```

To disable a specific formatter:
```json
{
  "$schema": "https://opencode.ai/config.json",
  "formatter": {
    "prettier": {
      "disabled": true
    }
  }
}
```

### Custom Formatters

Override built-in formatters or add new ones:

```json
{
  "$schema": "https://opencode.ai/config.json",
  "formatter": {
    "prettier": {
      "command": ["npx", "prettier", "--write", "$FILE"],
      "environment": {
        "NODE_ENV": "development"
      },
      "extensions": [".js", ".ts", ".jsx", ".tsx"]
    },
    "custom-markdown-formatter": {
      "command": ["deno", "fmt", "$FILE"],
      "extensions": [".md"]
    }
  }
}
```

The `$FILE` placeholder in the command will be replaced with the path to the file being formatted.

## Best Practices

1. **Match Your Project**: Ensure formatters match the tools already used in your project
2. **Team Consistency**: Configure formatters to match your team's agreed-upon standards
3. **Performance**: Consider formatter speed, especially for large files
4. **Reliability**: Choose formatters that are actively maintained
5. **Documentation**: Document formatter choices in your project's contribution guidelines

## Example Configurations

### JavaScript/TypeScript with Prettier
```json
{
  "$schema": "https://opencode.ai/config.json",
  "formatter": {
    "prettier": {
      "command": ["npx", "prettier", "--write", "$FILE"],
      "extensions": [".js", ".ts", ".jsx", ".tsx", ".vue", ".svelte"]
    }
  }
}
```

### Rust with Rustfmt
```json
{
  "$schema": "https://opencode.ai/config.json",
  "formatter": {
    "rustfmt": {
      "command": ["rustfmt"],
      "extensions": [".rs"]
    }
  }
}
```

### Python with Ruff
```json
{
  "$schema": "https://opencode.ai/config.json",
  "formatter": {
    "ruff": {
      "command": ["ruff", "check", "--fix", "$FILE"],
      "environment": {},
      "extensions": [".py", ".pyi"]
    }
  }
}
```

By configuring formatters appropriately, you ensure that OpenCode-generated code maintains consistency with your existing codebase and team standards.