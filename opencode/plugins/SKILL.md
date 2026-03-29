---
name: plugins
description: OpenCode Plugins - how to find, install, and use plugins to extend OpenCode functionality
license: MIT
compatibility: opencode
metadata:
  audience: developers
  workflow: extensibility
  language: markdown
---

# OpenCode Plugins

OpenCode supports a plugin system that allows you to extend its functionality with additional features, tools, and integrations.

## What are OpenCode Plugins?

OpenCode plugins are extensions that add new capabilities to the OpenCode agent, such as:
- New tools for specific tasks
- Additional skills for specialized domains
- Integrations with external services
- Enhanced UI components or features
- Custom commands and workflows

## Finding Plugins

You can discover OpenCode plugins through:

### Official Plugin Marketplace
The OpenCode Plugin Marketplace hosts verified plugins that have been tested for compatibility and safety.

### Community Repositories
Developers share plugins on platforms like GitHub, npm, and other code repositories.

### Internal Distribution
Organizations may distribute custom plugins internally for team-specific needs.

## Installing Plugins

Plugin installation methods vary depending on the plugin type:

### 1. Marketplace Installation
```
opencode plugin install <plugin-name>
```

### 2. Direct Installation from URL
```
opencode plugin install https://github.com/user/plugin-repo
```

### 3. Local Installation
```
opencode plugin install ./path/to/plugin
```

### 4. Package Managers
Some plugins can be installed via npm, pip, or other package managers:
```
npm install @opencode/plugin-example
```

## Using Plugins

Once installed, plugins can be used in various ways:

### Automatic Activation
Some plugins activate automatically upon installation and provide immediate functionality.

### Skill Registration
Plugins often add new skills that become available to agents:
```
/skills
```

### Tool Availability
Plugins may add new tools that agents can use:
```
/tools
```

### Command Extensions
Some plugins add new slash commands or modify existing ones.

### Configuration Changes
Plugins may add new configuration options or modify default behaviors.

## Developing Plugins

To create your own OpenCode plugin:

1.  Review the [Plugin Development Guide](/docs/plugins/development)
2.  Set up your development environment
3.  Implement the plugin interface
4.  Test your plugin thoroughly
5.  Publish to the marketplace or distribute internally

## Plugin Types

OpenCode supports several types of plugins:

### 1. Skill Plugins
Add new skills that teach agents specific capabilities.

### 2. Tool Plugins
Provide new tools that agents can use to perform actions.

### 3. UI Plugins
Modify or enhance the OpenCode user interface.

### 4. Integration Plugins
Connect OpenCode to external services and platforms.

### 5. Command Plugins
Add new slash commands or modify existing command behavior.

## Plugin Management

### Listing Installed Plugins
```
opencode plugin list
```

### Updating Plugins
```
opencode plugin update <plugin-name>
```

### Removing Plugins
```
opencode plugin uninstall <plugin-name>
```

### Plugin Information
```
opencode plugin info <plugin-name>
```

## Best Practices for Using Plugins

1. **Verify Sources**: Only install plugins from trusted sources
2. **Check Compatibility**: Ensure plugins are compatible with your OpenCode version
3. **Review Permissions**: Understand what access plugins require
4. **Keep Updated**: Regularly update plugins for security and feature improvements
5. **Isolate Testing**: Test new plugins in a separate environment before team-wide deployment
6. **Monitor Performance**: Watch for performance impacts from plugin usage

## Example Plugins

- **Language-Specific Plugins**: Enhanced support for Rust, Go, Python, etc.
- **Framework Plugins**: Specialized assistance for React, Django, Spring, etc.
- **Utility Plugins**: Code formatters, linters, or refactoring tools
- **Integration Plugins**: Jira, Slack, Docker, Kubernetes integrations
- **Productivity Plugins**: Task management, code review assistants, documentation generators

## Security Considerations

When using plugins:
- Review plugin code or trust the publisher
- Understand what system resources plugins can access
- Be cautious with plugins that require network access
- Consider sandboxing or isolation for untrusted plugins
- Keep plugins updated to patch security vulnerabilities

## Getting Help with Plugins

If you need assistance with plugins:
- Check the plugin documentation
- Visit the [Plugins documentation](/docs/plugins/)
- Ask questions in the OpenCode Discord community
- Check issue trackers for specific plugins
- Contact plugin developers directly for support