---
name: network
description: Network configuration for OpenCode - proxy settings, network troubleshooting, and connectivity options
license: MIT
compatibility: opencode
metadata:
  audience: developers
  workflow: configuration
  language: markdown
---

# OpenCode Network Configuration

OpenCode provides options for configuring network settings, which can be useful when working behind proxies or in restricted network environments.

## Network Settings

You can configure network-related settings through OpenCode's configuration system. This includes:

- Proxy configuration
- Connection timeouts
- SSL/TLS settings
- Custom headers

## Proxy Configuration

If you're behind a proxy, you may need to configure OpenCode to work properly. This can typically be done through:

1. Environment variables (HTTP_PROXY, HTTPS_PROXY, NO_PROXY)
2. OpenCode-specific network settings
3. System-wide proxy configurations

## Network Troubleshooting

If you encounter network-related issues with OpenCode:

1. Check your internet connection
2. Verify proxy settings if applicable
3. Ensure firewall settings allow OpenCode to connect to required endpoints
4. Check SSL/TLS certificate validation if using HTTPS
5. Review any error messages for specific connection issues

## Connectivity Requirements

OpenCode requires connectivity to:
- LLM provider APIs (varies by provider)
- OpenCode backend services (for certain features)
- Package registries (if installing dependencies)
- Version control systems (for Git operations)

## Best Practices

- Use secure connections (HTTPS) whenever possible
- Keep proxy credentials secure
- Test network connectivity before starting important tasks
- Monitor network usage if on metered connections