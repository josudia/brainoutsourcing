# MCP Server Types: Detailed Reference

Complete reference for all MCP server types supported in Claude Code plugins.

## stdio (Standard Input/Output)

### Overview

Run local MCP servers as child processes with communication via stdin/stdout. Best choice for local tools, custom servers, and NPM packages.

### Configuration

**Simple:**
```json
{
  "my-server": {
    "command": "npx",
    "args": ["-y", "my-mcp-server"]
  }
}
```

**With Environment:**
```json
{
  "my-server": {
    "command": "${CLAUDE_PLUGIN_ROOT}/servers/custom-server",
    "args": ["--config", "${CLAUDE_PLUGIN_ROOT}/config.json"],
    "env": {
      "API_KEY": "${MY_API_KEY}",
      "LOG_LEVEL": "debug",
      "DATABASE_URL": "${DB_URL}"
    }
  }
}
```

### Process Lifecycle

1. **Start**: Claude Code launches the process with `command` and `args`
2. **Communication**: JSON-RPC messages over stdin/stdout
3. **Lifetime**: Process runs for the entire Claude Code session
4. **Termination**: Process is terminated when Claude Code exits

### Use Cases

**NPM Packages:**
```json
{
  "filesystem": {
    "command": "npx",
    "args": ["-y", "@modelcontextprotocol/server-filesystem", "/path"]
  }
}
```

**Custom Scripts:**
```json
{
  "custom": {
    "command": "${CLAUDE_PLUGIN_ROOT}/servers/my-server.js",
    "args": ["--verbose"]
  }
}
```

**Python Servers:**
```json
{
  "python-server": {
    "command": "python",
    "args": ["-m", "my_mcp_server"],
    "env": {
      "PYTHONUNBUFFERED": "1"
    }
  }
}
```

### Best Practices

1. **Use absolute paths or ${CLAUDE_PLUGIN_ROOT}**
2. **Set PYTHONUNBUFFERED for Python servers**
3. **Pass configuration via args or env, not via stdin**
4. **Handle server crashes gracefully**
5. **Log to stderr, not stdout (stdout is for the MCP protocol)**

### Troubleshooting

**Server does not start:**
- Check if the command exists and is executable
- Check file paths
- Check permissions
- Check `claude --debug` logs

**Communication fails:**
- Ensure the server uses stdin/stdout correctly
- Check for accidental print/console.log output
- Check JSON-RPC format

## SSE (Server-Sent Events)

### Overview

Connect to hosted MCP servers over HTTP with Server-Sent Events for streaming. Best for cloud services and OAuth authentication.

### Configuration

**Simple:**
```json
{
  "hosted-service": {
    "type": "sse",
    "url": "https://mcp.example.com/sse"
  }
}
```

**With Headers:**
```json
{
  "service": {
    "type": "sse",
    "url": "https://mcp.example.com/sse",
    "headers": {
      "X-API-Version": "v1",
      "X-Client-ID": "${CLIENT_ID}"
    }
  }
}
```

### Connection Lifecycle

1. **Initialization**: HTTP connection established to the URL
2. **Handshake**: MCP protocol negotiation
3. **Streaming**: Server sends events via SSE
4. **Requests**: Client sends HTTP POST for tool calls
5. **Reconnection**: Automatic reconnection on disconnection

### Authentication

**OAuth (Automatic):**
```json
{
  "asana": {
    "type": "sse",
    "url": "https://mcp.asana.com/sse"
  }
}
```

Claude Code handles the OAuth flow:
1. User is prompted to authenticate on first use
2. Opens browser for OAuth flow
3. Tokens are stored securely
4. Automatic token renewal

**Custom Headers:**
```json
{
  "service": {
    "type": "sse",
    "url": "https://mcp.example.com/sse",
    "headers": {
      "Authorization": "Bearer ${API_TOKEN}"
    }
  }
}
```

### Use Cases

**Official Services:**
- Asana: `https://mcp.asana.com/sse`
- GitHub: `https://mcp.github.com/sse`
- Other hosted MCP servers

**Custom Hosted Servers:**
Deploy your own MCP server and expose it via HTTPS + SSE.

### Best Practices

1. **Always use HTTPS, never HTTP**
2. **Let OAuth handle authentication when available**
3. **Use environment variables for tokens**
4. **Handle connection errors gracefully**
5. **Document required OAuth scopes**

### Troubleshooting

**Connection refused:**
- Check URL
- Check HTTPS certificate
- Check network connection
- Check firewall settings

**OAuth fails:**
- Clear cached tokens
- Check OAuth scopes
- Check redirect URLs
- Re-authenticate

## HTTP (REST API)

### Overview

Connect to RESTful MCP servers via standard HTTP requests. Best for token-based auth and stateless interactions.

### Configuration

**Simple:**
```json
{
  "api": {
    "type": "http",
    "url": "https://api.example.com/mcp"
  }
}
```

**With Authentication:**
```json
{
  "api": {
    "type": "http",
    "url": "https://api.example.com/mcp",
    "headers": {
      "Authorization": "Bearer ${API_TOKEN}",
      "Content-Type": "application/json",
      "X-API-Version": "2024-01-01"
    }
  }
}
```

### Request/Response Flow

1. **Tool Discovery**: GET to discover available tools
2. **Tool Invocation**: POST with tool name and parameters
3. **Response**: JSON response with results or errors
4. **Stateless**: Each request is independent

### Authentication

**Token-Based:**
```json
{
  "headers": {
    "Authorization": "Bearer ${API_TOKEN}"
  }
}
```

**API Key:**
```json
{
  "headers": {
    "X-API-Key": "${API_KEY}"
  }
}
```

**Custom Auth:**
```json
{
  "headers": {
    "X-Auth-Token": "${AUTH_TOKEN}",
    "X-User-ID": "${USER_ID}"
  }
}
```

### Use Cases

- REST API backends
- Internal services
- Microservices
- Serverless Functions

### Best Practices

1. **Use HTTPS for all connections**
2. **Store tokens in environment variables**
3. **Implement retry logic for transient errors**
4. **Handle rate limiting**
5. **Set appropriate timeouts**

### Troubleshooting

**HTTP Errors:**
- 401: Check authentication headers
- 403: Check permissions
- 429: Implement rate limiting
- 500: Check server logs

**Timeout Issues:**
- Increase timeout if needed
- Check server performance
- Optimize tool implementations

## WebSocket (Real-Time)

### Overview

Connect to MCP servers via WebSocket for real-time bidirectional communication. Best for streaming and low-latency applications.

### Configuration

**Simple:**
```json
{
  "realtime": {
    "type": "ws",
    "url": "wss://mcp.example.com/ws"
  }
}
```

**With Authentication:**
```json
{
  "realtime": {
    "type": "ws",
    "url": "wss://mcp.example.com/ws",
    "headers": {
      "Authorization": "Bearer ${TOKEN}",
      "X-Client-ID": "${CLIENT_ID}"
    }
  }
}
```

### Connection Lifecycle

1. **Handshake**: WebSocket upgrade request
2. **Connection**: Persistent bidirectional channel
3. **Messages**: JSON-RPC over WebSocket
4. **Heartbeat**: Keep-alive messages
5. **Reconnection**: Automatic on disconnection

### Use Cases

- Real-time data streaming
- Live updates and notifications
- Collaborative editing
- Low-latency tool calls
- Push notifications from the server

### Best Practices

1. **Use WSS (secure WebSocket), never WS**
2. **Implement heartbeat/ping-pong**
3. **Implement reconnection logic**
4. **Buffer messages during disconnection**
5. **Set connection timeouts**

### Troubleshooting

**Connection Drops:**
- Implement reconnection logic
- Check network stability
- Check if server supports WebSocket
- Check firewall settings

**Message Delivery:**
- Implement message acknowledgment
- Handle out-of-order messages
- Buffer during disconnection

## Comparison Matrix

| Feature | stdio | SSE | HTTP | WebSocket |
|---------|-------|-----|------|-----------|
| **Transport** | Process | HTTP/SSE | HTTP | WebSocket |
| **Direction** | Bidirectional | Server→Client | Request/Response | Bidirectional |
| **State** | Stateful | Stateful | Stateless | Stateful |
| **Auth** | Env vars | OAuth/Headers | Headers | Headers |
| **Use Case** | Local tools | Cloud services | REST APIs | Real-time |
| **Latency** | Lowest | Medium | Medium | Low |
| **Setup** | Simple | Medium | Simple | Medium |
| **Reconnection** | Process restart | Automatic | N/A | Automatic |

## Choosing the Right Type

**Use stdio when:**
- Running local tools or custom servers
- Lowest latency is needed
- Working with file systems or local databases
- Shipping the server with the plugin

**Use SSE when:**
- Connecting to hosted services
- OAuth authentication is needed
- Using official MCP servers (Asana, GitHub)
- Automatic reconnection is desired

**Use HTTP when:**
- Integrating with REST APIs
- Stateless interactions are needed
- Token-based auth is used
- Simple request/response pattern

**Use WebSocket when:**
- Real-time updates are needed
- Building collaborative features
- Low latency is critical
- Bidirectional streaming is required

## Migrating Between Types

### From stdio to SSE

**Before (stdio):**
```json
{
  "local-server": {
    "command": "node",
    "args": ["server.js"]
  }
}
```

**After (SSE - deploy the server):**
```json
{
  "hosted-server": {
    "type": "sse",
    "url": "https://mcp.example.com/sse"
  }
}
```

### From HTTP to WebSocket

**Before (HTTP):**
```json
{
  "api": {
    "type": "http",
    "url": "https://api.example.com/mcp"
  }
}
```

**After (WebSocket):**
```json
{
  "realtime": {
    "type": "ws",
    "url": "wss://api.example.com/ws"
  }
}
```

Benefits: Real-time updates, lower latency, bidirectional communication.

## Advanced Configuration

### Multiple Servers

Combine different types:

```json
{
  "local-db": {
    "command": "npx",
    "args": ["-y", "mcp-server-sqlite", "./data.db"]
  },
  "cloud-api": {
    "type": "sse",
    "url": "https://mcp.example.com/sse"
  },
  "internal-service": {
    "type": "http",
    "url": "https://api.example.com/mcp",
    "headers": {
      "Authorization": "Bearer ${API_TOKEN}"
    }
  }
}
```

### Conditional Configuration

Use environment variables to switch servers:

```json
{
  "api": {
    "type": "http",
    "url": "${API_URL}",
    "headers": {
      "Authorization": "Bearer ${API_TOKEN}"
    }
  }
}
```

Set different values for dev/prod:
- Dev: `API_URL=http://localhost:8080/mcp`
- Prod: `API_URL=https://api.production.com/mcp`

## Security Considerations

### stdio Security

- Validate command paths
- Do not run user-provided commands
- Restrict environment variable access
- Limit file system access

### Network Security

- Always use HTTPS/WSS
- Validate SSL certificates
- Do not skip certificate verification
- Use secure token storage

### Token Management

- Never hard-code tokens
- Use environment variables
- Rotate tokens regularly
- Implement token renewal
- Document required scopes

## Conclusion

Choose the MCP server type based on your use case:
- **stdio** for local, custom, or NPM-packaged servers
- **SSE** for hosted services with OAuth
- **HTTP** for REST APIs with token auth
- **WebSocket** for real-time bidirectional communication

Test thoroughly and handle errors gracefully for robust MCP integration.
