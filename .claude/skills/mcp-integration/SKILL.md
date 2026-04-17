---
name: MCP-Integration
description: This skill should be used when the user asks about "adding an MCP server", "integrating MCP", "configuring MCP in a plugin", "using .mcp.json", "setting up Model Context Protocol", "connecting an external service", mentions "${CLAUDE_PLUGIN_ROOT} with MCP", or discusses MCP server types (SSE, stdio, HTTP, WebSocket). Provides comprehensive guidance on integrating Model Context Protocol servers into Claude Code plugins for external tool and service integration.
version: 0.1.0
---

# MCP Integration for Claude Code Plugins

## Overview

The Model Context Protocol (MCP) enables Claude Code plugins to integrate with external services and APIs by providing structured tool access. Use MCP integration to make external service capabilities available as tools within Claude Code.

**Core Capabilities:**
- Connect to external services (databases, APIs, file systems)
- Expose 10+ cohesive tools from a single service
- Handle OAuth and complex authentication flows
- Bundle MCP servers with plugins for automatic setup

## MCP Server Configuration Methods

Plugins can bundle MCP servers in two ways:

### Method 1: Dedicated .mcp.json (Recommended)

Create `.mcp.json` in the plugin root:

```json
{
  "database-tools": {
    "command": "${CLAUDE_PLUGIN_ROOT}/servers/db-server",
    "args": ["--config", "${CLAUDE_PLUGIN_ROOT}/config.json"],
    "env": {
      "DB_URL": "${DB_URL}"
    }
  }
}
```

**Advantages:**
- Clear separation of concerns
- Easier to maintain
- Better for multiple servers

### Method 2: Inline in plugin.json

Add an `mcpServers` field to plugin.json:

```json
{
  "name": "my-plugin",
  "version": "1.0.0",
  "mcpServers": {
    "plugin-api": {
      "command": "${CLAUDE_PLUGIN_ROOT}/servers/api-server",
      "args": ["--port", "8080"]
    }
  }
}
```

**Advantages:**
- Single configuration file
- Good for simple single-server plugins

## MCP Server Types

### stdio (Local Process)

Run local MCP servers as child processes. Best for local tools and custom servers.

**Configuration:**
```json
{
  "filesystem": {
    "command": "npx",
    "args": ["-y", "@modelcontextprotocol/server-filesystem", "/allowed/path"],
    "env": {
      "LOG_LEVEL": "debug"
    }
  }
}
```

**Use Cases:**
- File system access
- Local database connections
- Custom MCP servers
- NPM-packaged MCP servers

**Process Management:**
- Claude Code starts and manages the process
- Communication via stdin/stdout
- Terminated when Claude Code exits

### SSE (Server-Sent Events)

Connect to hosted MCP servers with OAuth support. Best for cloud services.

**Configuration:**
```json
{
  "asana": {
    "type": "sse",
    "url": "https://mcp.asana.com/sse"
  }
}
```

**Use Cases:**
- Official hosted MCP servers (Asana, GitHub, etc.)
- Cloud services with MCP endpoints
- OAuth-based authentication
- No local installation needed

**Authentication:**
- OAuth flows are handled automatically
- User is prompted on first use
- Token management by Claude Code

### HTTP (REST API)

Connect to RESTful MCP servers with token authentication.

**Configuration:**
```json
{
  "api-service": {
    "type": "http",
    "url": "https://api.example.com/mcp",
    "headers": {
      "Authorization": "Bearer ${API_TOKEN}",
      "X-Custom-Header": "value"
    }
  }
}
```

**Use Cases:**
- REST API-based MCP servers
- Token-based authentication
- Custom API backends
- Stateless interactions

### WebSocket (Real-Time)

Connect to WebSocket MCP servers for real-time bidirectional communication.

**Configuration:**
```json
{
  "realtime-service": {
    "type": "ws",
    "url": "wss://mcp.example.com/ws",
    "headers": {
      "Authorization": "Bearer ${TOKEN}"
    }
  }
}
```

**Use Cases:**
- Real-time data streaming
- Persistent connections
- Push notifications from the server
- Low latency requirements

## Environment Variable Expansion

All MCP configurations support environment variable substitution:

**${CLAUDE_PLUGIN_ROOT}** - Plugin directory (always use for portability):
```json
{
  "command": "${CLAUDE_PLUGIN_ROOT}/servers/my-server"
}
```

**User Environment Variables** - From the user's shell:
```json
{
  "env": {
    "API_KEY": "${MY_API_KEY}",
    "DATABASE_URL": "${DB_URL}"
  }
}
```

**Best Practice:** Document all required environment variables in the plugin README.

## MCP Tool Naming

When MCP servers provide tools, they are automatically prefixed:

**Format:** `mcp__plugin_<plugin-name>_<server-name>__<tool-name>`

**Example:**
- Plugin: `asana`
- Server: `asana`
- Tool: `create_task`
- **Full Name:** `mcp__plugin_asana_asana__asana_create_task`

### Using MCP Tools in Commands

Pre-allow specific MCP tools in command frontmatter:

```markdown
---
allowed-tools: [
  "mcp__plugin_asana_asana__asana_create_task",
  "mcp__plugin_asana_asana__asana_search_tasks"
]
---
```

**Wildcard (use sparingly):**
```markdown
---
allowed-tools: ["mcp__plugin_asana_asana__*"]
---
```

**Best Practice:** Pre-allow specific tools, not wildcards, for better security.

## Lifecycle Management

**Automatic Startup:**
- MCP servers start when the plugin is activated
- Connection is established before first tool use
- Restart required after configuration changes

**Lifecycle:**
1. Plugin is loaded
2. MCP configuration is parsed
3. Server process started (stdio) or connection established (SSE/HTTP/WS)
4. Tools are discovered and registered
5. Tools are available as `mcp__plugin_...__...`

**View Servers:**
Use the `/mcp` command to see all servers, including plugin-provided ones.

## Authentication Patterns

### OAuth (SSE/HTTP)

OAuth is handled automatically by Claude Code:

```json
{
  "type": "sse",
  "url": "https://mcp.example.com/sse"
}
```

The user authenticates in the browser on first use. No additional configuration needed.

### Token-Based (Headers)

Static or environment variable tokens:

```json
{
  "type": "http",
  "url": "https://api.example.com",
  "headers": {
    "Authorization": "Bearer ${API_TOKEN}"
  }
}
```

Document required environment variables in the README.

### Environment Variables (stdio)

Pass configuration to MCP servers:

```json
{
  "command": "python",
  "args": ["-m", "my_mcp_server"],
  "env": {
    "DATABASE_URL": "${DB_URL}",
    "API_KEY": "${API_KEY}",
    "LOG_LEVEL": "info"
  }
}
```

## Integration Patterns

### Pattern 1: Simple Tool Wrapper

Commands use MCP tools with user interaction:

```markdown
# Command: create-item.md
---
allowed-tools: ["mcp__plugin_name_server__create_item"]
---

Steps:
1. Collect item details from the user
2. Use mcp__plugin_name_server__create_item
3. Confirm creation
```

**Use for:** Adding validation or preprocessing before MCP calls.

### Pattern 2: Autonomous Agent

Agents use MCP tools autonomously:

```markdown
# Agent: data-analyzer.md

Analysis process:
1. Query data via mcp__plugin_db_server__query
2. Process and analyze results
3. Generate insights report
```

**Use for:** Multi-step MCP workflows without user interaction.

### Pattern 3: Multi-Server Plugin

Integrate multiple MCP servers:

```json
{
  "github": {
    "type": "sse",
    "url": "https://mcp.github.com/sse"
  },
  "jira": {
    "type": "sse",
    "url": "https://mcp.jira.com/sse"
  }
}
```

**Use for:** Workflows spanning multiple services.

## Security Best Practices

### Use HTTPS/WSS

Always use secure connections:

```json
"url": "https://mcp.example.com/sse"
"url": "http://mcp.example.com/sse"
```

### Token Management

**DO:**
- Use environment variables for tokens
- Document required env vars in the README
- Let the OAuth flow handle authentication

**DO NOT:**
- Hard-code tokens in configuration
- Commit tokens to Git
- Share tokens in documentation

### Permission Scoping

Only pre-allow necessary MCP tools:

```markdown
allowed-tools: [
  "mcp__plugin_api_server__read_data",
  "mcp__plugin_api_server__create_item"
]

allowed-tools: ["mcp__plugin_api_server__*"]
```

## Error Handling

### Connection Errors

Handling MCP server unavailability:
- Provide fallback behavior in commands
- Inform the user about connection issues
- Check server URL and configuration

### Tool Invocation Errors

Handling failed MCP operations:
- Validate inputs before MCP tool calls
- Provide clear error messages
- Check rate limiting and quotas

### Configuration Errors

Validate MCP configuration:
- Test server connectivity during development
- Validate JSON syntax
- Check required environment variables

## Performance Considerations

### Lazy Loading

MCP servers connect on demand:
- Not all servers connect at startup
- First tool use triggers the connection
- Connection pooling is managed automatically

### Batching

Bundle similar requests when possible:

```
# Good: Single query with filters
tasks = search_tasks(project="X", assignee="me", limit=50)

# Avoid: Many individual queries
for id in task_ids:
    task = get_task(id)
```

## Testing MCP Integration

### Local Testing

1. Configure the MCP server in `.mcp.json`
2. Install the plugin locally (`.claude-plugin/`)
3. Run `/mcp` to verify the server appears
4. Test tool calls in commands
5. Check `claude --debug` logs for connection issues

### Validation Checklist

- [ ] MCP configuration is valid JSON
- [ ] Server URL is correct and reachable
- [ ] Required environment variables documented
- [ ] Tools appear in `/mcp` output
- [ ] Authentication works (OAuth or token)
- [ ] Tool calls from commands succeed
- [ ] Error cases are handled gracefully

## Debugging

### Enable Debug Logging

```bash
claude --debug
```

Look for:
- MCP server connection attempts
- Tool discovery logs
- Authentication flows
- Tool invocation errors

### Common Issues

**Server does not connect:**
- Check URL
- Check if server is running (stdio)
- Check network connection
- Check authentication configuration

**Tools not available:**
- Check if server connected successfully
- Verify tool names exactly
- Run `/mcp` to see available tools
- Restart Claude Code after configuration changes

**Authentication fails:**
- Clear cached auth tokens
- Re-authenticate
- Check token scopes and permissions
- Check environment variables

## Quick Reference

### MCP Server Types

| Type  | Transport | Best For                | Auth           |
|-------|-----------|-------------------------|----------------|
| stdio | Process   | Local tools, custom servers | Env vars  |
| SSE   | HTTP      | Hosted services, cloud APIs | OAuth    |
| HTTP  | REST      | API backends, token auth | Token        |
| ws    | WebSocket | Real-time, streaming    | Token          |

### Configuration Checklist

- [ ] Server type specified (stdio/SSE/HTTP/ws)
- [ ] Type-specific fields complete (command or url)
- [ ] Authentication configured
- [ ] Environment variables documented
- [ ] HTTPS/WSS used (not HTTP/WS)
- [ ] ${CLAUDE_PLUGIN_ROOT} used for paths

### Best Practices

**DO:**
- Use ${CLAUDE_PLUGIN_ROOT} for portable paths
- Document required environment variables
- Use secure connections (HTTPS/WSS)
- Pre-allow specific MCP tools in commands
- Test MCP integration before publishing
- Handle connection and tool errors gracefully

**DO NOT:**
- Hard-code absolute paths
- Commit credentials to Git
- Use HTTP instead of HTTPS
- Pre-allow all tools with wildcards
- Skip error handling
- Forget setup documentation

## Additional Resources

### Reference Files

For detailed information, consult:

- **`references/server-types.md`** - Detailed description of each server type
- **`references/authentication.md`** - Authentication patterns and OAuth
- **`references/tool-usage.md`** - Using MCP tools in commands and agents

### Example Configurations

Working examples in `examples/`:

- **`stdio-server.json`** - Local stdio MCP server
- **`sse-server.json`** - Hosted SSE server with OAuth
- **`http-server.json`** - REST API with token auth

### External Resources

- **Official MCP Documentation**: https://modelcontextprotocol.io/
- **Claude Code MCP Documentation**: https://docs.claude.com/en/docs/claude-code/mcp
- **MCP SDK**: @modelcontextprotocol/sdk
- **Testing**: Use `claude --debug` and the `/mcp` command

## Implementation Workflow

To add MCP integration to a plugin:

1. Choose MCP server type (stdio, SSE, HTTP, ws)
2. Create `.mcp.json` in the plugin root with configuration
3. Use ${CLAUDE_PLUGIN_ROOT} for all file references
4. Document required environment variables in the README
5. Test locally with the `/mcp` command
6. Pre-allow MCP tools in relevant commands
7. Handle authentication (OAuth or token)
8. Test error cases (connection failures, auth errors)
9. Document MCP integration in the plugin README

Focus on stdio for custom/local servers, SSE for hosted services with OAuth.
