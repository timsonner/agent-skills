---
name: server
description: OpenCode Server - how to run and manage the OpenCode server for API access and integrations
author: Tim Sonner
license: MIT
compatibility: opencode
metadata:
  audience: developers
  workflow: server-management
  language: markdown
---

# OpenCode Server

The OpenCode Server provides API access to OpenCode's capabilities, enabling integrations with other tools, services, and custom frontends.

## What is the OpenCode Server?

The OpenCode Server is a backend service that exposes OpenCode's AI coding agent functionality through APIs, allowing you to:

- Access OpenCode programmatically via REST or GraphQL APIs
- Build custom interfaces and integrations
- Embed OpenCode capabilities in other applications
- Scale OpenCode usage across teams or organizations
- Run OpenCode in headless or automated environments

## Server Features

### 1. API Access
- RESTful endpoints for core OpenCode functionality
- GraphQL API for flexible data querying
- WebSocket support for real-time interactions
- Authentication and authorization mechanisms

### 2. Agent Management
- Create and manage AI agent instances
- Configure agent behaviors and capabilities
- Monitor agent performance and usage
- Scale agents based on demand

### 3. Integration Capabilities
- Connect to version control systems (GitHub, GitLab, etc.)
- Integrate with issue trackers and project management tools
- Link with CI/CD pipelines and development tools
- Connect to internal developer portals and dashboards

### 4. Customization and Extension
- Deploy custom skills and tools
- Configure provider settings and API keys
- Modify agent behaviors through configuration
- Extend functionality with plugins and middleware

## Running the OpenCode Server

To run the OpenCode Server:

1.  Ensure you have the server package installed
2.  Configure necessary environment variables (API keys, ports, etc.)
3.  Start the server using the provided command
4.  Access the API documentation at the configured endpoint

### Basic Server Startup

```
opencode-server start
```

### Configuration Options

The server can be configured through:
- Environment variables
- Configuration files
- Command-line arguments
- Runtime administration APIs

## Server API Endpoints

The OpenCode Server typically provides endpoints for:

### Agent Operations
- `POST /agents` - Create a new agent instance
- `GET /agents/{id}` - Get agent details
- `PUT /agents/{id}` - Update agent configuration
- `DELETE /agents/{id}` - Delete an agent instance
- `POST /agents/{id}/prompt` - Send a prompt to an agent

### File and Project Management
- `GET /projects/{id}/files` - List project files
- `PUT /projects/{id}/files/{path}` - Update file contents
- `GET /projects/{id}/files/{path}` - Retrieve file contents
- `POST /projects/{id}/files/{path}` - Create new file

### Skills and Tools
- `GET /skills` - List available skills
- `POST /skills` - Add new skills
- `GET /tools` - List available tools
- `POST /tools` - Register custom tools

### Configuration
- `GET /config` - Get server configuration
- `PUT /config` - Update server configuration
- `POST /config/providers` - Configure LLM providers

## Authentication and Security

The OpenCode Server supports various authentication methods:
- API keys for service-to-service authentication
- OAuth 2.0 for user authentication
- JWT tokens for stateless authentication
- Integration with enterprise identity providers

Security features include:
- Rate limiting and abuse prevention
- Input validation and sanitization
- Audit logging for all operations
- Data encryption in transit and at rest

## Server Deployment Options

### 1. Local Development
- Run server locally for testing and development
- Use Docker containers for consistent environments
- Configure hot-reloading for rapid iteration

### 2. Production Deployment
- Kubernetes deployments for scalable orchestration
- Docker Swarm or ECS for container orchestration
- Traditional VM or bare-metal installations
- Managed service offerings (if available)

### 3. Cloud Deployment
- AWS ECS/EKS, Azure Container Instances, or GCP Cloud Run
- Serverless configurations for variable workloads
- Managed databases for persistence
- CDN integration for global accessibility

## Server Management and Monitoring

### Administration
- Dashboard for monitoring server health and usage
- Logs and metrics collection
- Backup and recovery procedures
- Update and patch management processes

### Performance Optimization
- Resource allocation and scaling strategies
- Caching configurations for improved response times
- Database optimization for concurrent users
- Load balancing for high availability

## Using the Server with Clients

Once the server is running, you can interact with it using:

### Official Clients
- OpenCode TUI (terminal interface)
- OpenCode Desktop application
- OpenCode IDE extensions (VS Code, JetBrains, etc.)
- Custom web or mobile clients

### Programmatic Access
- REST API clients in any language
- GraphQL clients (Apollo, Relay, etc.)
- WebSocket connections for real-time features
- SDKs and language-specific wrappers

## Example API Usage

### Creating an Agent and Sending a Prompt
```bash
# Create a new agent
curl -X POST http://localhost:3000/agents \
  -H "Content-Type: application/json" \
  -d '{"name": "coding-assistant", "skills": ["intro", "usage"]}'

# Send a prompt to the agent
curl -X POST http://localhost:3000/agents/abc123/prompt \
  -H "Content-Type: application/json" \
  -d '{"prompt": "Explain how to create a REST API in Node.js"}'
```

### Retrieving Project Files
```bash
# List files in a project
curl -X GET http://localhost:3000/projects/def456/files

# Get contents of a specific file
curl -X GET http://localhost:3000/projects/def456/files/src/main.js
```

## Best Practices for Server Usage

1. **Secure Your Server**: Always use authentication and HTTPS in production
2. **Monitor Resource Usage**: Track CPU, memory, and API usage
3. **Keep Dependencies Updated**: Regularly update server packages
4. **Backup Configuration**: Regularly backup server configurations and data
5. **Test Changes**: Validate configuration changes in staging before production
6. **Document Integrations**: Keep documentation of how your systems interact with the server
7. **Plan for Scale**: Consider horizontal scaling strategies for increased load

## Troubleshooting

Common server issues and solutions:

- **Connection Problems**: Check network settings, firewall rules, and server status
- **Authentication Failures**: Verify API keys, tokens, and authentication configurations
- **Performance Issues**: Monitor resource usage and consider scaling or optimization
- **Error Responses**: Check API documentation for correct request formats and parameters
- **Agent Timeouts**: Review complex prompts or consider increasing timeout values

## Getting Help

For assistance with the OpenCode Server:
- Refer to the [Server documentation](/docs/server/)
- Check server logs for detailed error information
- Ask questions in the OpenCode Discord community
- Review open issues and feature requests on GitHub
- Contact support for enterprise deployment assistance
