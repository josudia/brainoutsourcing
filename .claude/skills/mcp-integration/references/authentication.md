# MCP Authentication Patterns

Complete guide to authentication methods for MCP servers in Claude Code plugins.

## Overview

MCP servers support multiple authentication methods depending on the server type and service requirements. Choose the method that best fits your use case and security requirements.

## OAuth (Automatic)

### How It Works

Claude Code handles the full OAuth 2.0 flow for SSE and HTTP servers automatically:

1. User attempts to use an MCP tool
2. Claude Code detects that authentication is needed
3. Opens browser for OAuth consent
4. User authorizes in the browser
5. Tokens are stored securely by Claude Code
6. Automatic token renewal

### Configuration

```json
{
  "service": {
    "type": "sse",
    "url": "https://mcp.example.com/sse"
  }
}
```

No additional auth configuration needed! Claude Code handles everything.

### Supported Services

**Known OAuth-capable MCP servers:**
- Asana: `https://mcp.asana.com/sse`
- GitHub (if available)
- Google services (if available)
- Custom OAuth servers

### OAuth Scopes

OAuth scopes are determined by the MCP server. Users see the required scopes during the consent flow.

**Document required scopes in your README:**
```markdown
## Authentication

This plugin requires the following Asana permissions:
- Read tasks and projects
- Create and update tasks
- Access workspace data
```

### Token Storage

Tokens are stored securely by Claude Code:
- Not accessible to plugins
- Encrypted at rest
- Automatic renewal
- Deleted on logout

### OAuth Troubleshooting

**Authentication loop:**
- Clear cached tokens (log out and back in)
- Check OAuth redirect URLs
- Check server OAuth configuration

**Scope issues:**
- User may need to re-authorize for new scopes
- Check server documentation for required scopes

**Token expiration:**
- Claude Code renews automatically
- If renewal fails, re-authentication is requested

## Token-Based Authentication

### Bearer Tokens

Most common for HTTP and WebSocket servers.

**Configuration:**
```json
{
  "api": {
    "type": "http",
    "url": "https://api.example.com/mcp",
    "headers": {
      "Authorization": "Bearer ${API_TOKEN}"
    }
  }
}
```

**Environment variable:**
```bash
export API_TOKEN="your-secret-token-here"
```

### API Keys

Alternative to bearer tokens, often in custom headers.

**Configuration:**
```json
{
  "api": {
    "type": "http",
    "url": "https://api.example.com/mcp",
    "headers": {
      "X-API-Key": "${API_KEY}",
      "X-API-Secret": "${API_SECRET}"
    }
  }
}
```

### Custom Headers

Services may use custom authentication headers.

**Configuration:**
```json
{
  "service": {
    "type": "sse",
    "url": "https://mcp.example.com/sse",
    "headers": {
      "X-Auth-Token": "${AUTH_TOKEN}",
      "X-User-ID": "${USER_ID}",
      "X-Tenant-ID": "${TENANT_ID}"
    }
  }
}
```

### Documenting Token Requirements

Always document in your README:

```markdown
## Setup

### Required Environment Variables

Set these environment variables before using the plugin:

\`\`\`bash
export API_TOKEN="your-token-here"
export API_SECRET="your-secret-here"
\`\`\`

### Obtaining Tokens

1. Visit https://api.example.com/tokens
2. Create a new API token
3. Copy token and secret
4. Set environment variables as shown above

### Token Permissions

The API token requires the following permissions:
- Read access to resources
- Write access to create items
- Delete access (optional, for cleanup operations)
\`\`\`
```

## Environment Variable Authentication (stdio)

### Passing Credentials to Servers

For stdio servers, pass credentials via environment variables:

```json
{
  "database": {
    "command": "python",
    "args": ["-m", "mcp_server_db"],
    "env": {
      "DATABASE_URL": "${DATABASE_URL}",
      "DB_USER": "${DB_USER}",
      "DB_PASSWORD": "${DB_PASSWORD}"
    }
  }
}
```

### User Environment Variables

```bash
# User sets these in their shell
export DATABASE_URL="postgresql://localhost/mydb"
export DB_USER="myuser"
export DB_PASSWORD="mypassword"
```

### Documentation Template

```markdown
## Database Configuration

Set these environment variables:

\`\`\`bash
export DATABASE_URL="postgresql://host:port/database"
export DB_USER="username"
export DB_PASSWORD="password"
\`\`\`

Or create a `.env` file (add to `.gitignore`):

\`\`\`
DATABASE_URL=postgresql://localhost:5432/mydb
DB_USER=myuser
DB_PASSWORD=mypassword
\`\`\`

Load with: \`source .env\` or \`export $(cat .env | xargs)\`
\`\`\`
```

## Dynamic Headers

### Header Helper Script

For tokens that change or expire, use a helper script:

```json
{
  "api": {
    "type": "sse",
    "url": "https://api.example.com",
    "headersHelper": "${CLAUDE_PLUGIN_ROOT}/scripts/get-headers.sh"
  }
}
```

**Script (get-headers.sh):**
```bash
#!/bin/bash
# Generate dynamic authentication headers

# Fetch a fresh token
TOKEN=$(get-fresh-token-from-somewhere)

# Output JSON headers
cat <<EOF
{
  "Authorization": "Bearer $TOKEN",
  "X-Timestamp": "$(date -Iseconds)"
}
EOF
```

### Use Cases for Dynamic Headers

- Short-lived tokens that need renewal
- Tokens with HMAC signatures
- Time-based authentication
- Dynamic tenant/workspace selection

## Security Best Practices

### DO

- **Use environment variables:**
```json
{
  "headers": {
    "Authorization": "Bearer ${API_TOKEN}"
  }
}
```

- **Document required variables in the README**

- **Always use HTTPS/WSS**

- **Implement token rotation**

- **Store tokens securely (env vars, not files)**

- **Let OAuth handle authentication when available**

### DO NOT

- **Hard-code tokens:**
```json
{
  "headers": {
    "Authorization": "Bearer sk-abc123..."  // NEVER!
  }
}
```

- **Commit tokens to Git**

- **Share tokens in documentation**

- **Use HTTP instead of HTTPS**

- **Store tokens in plugin files**

- **Log tokens or sensitive headers**

## Multi-Tenancy Patterns

### Workspace/Tenant Selection

**Via environment variable:**
```json
{
  "api": {
    "type": "http",
    "url": "https://api.example.com/mcp",
    "headers": {
      "Authorization": "Bearer ${API_TOKEN}",
      "X-Workspace-ID": "${WORKSPACE_ID}"
    }
  }
}
```

**Via URL:**
```json
{
  "api": {
    "type": "http",
    "url": "https://${TENANT_ID}.api.example.com/mcp"
  }
}
```

### User-Specific Configuration

Users set their own workspace:

```bash
export WORKSPACE_ID="my-workspace-123"
export TENANT_ID="my-company"
```

## Authentication Troubleshooting

### Common Issues

**401 Unauthorized:**
- Check if token is set correctly
- Check if token has expired
- Check if token has required permissions
- Check header format

**403 Forbidden:**
- Token is valid but missing permissions
- Check scope/permissions
- Check workspace/tenant ID
- Admin approval may be required

**Token not found:**
```bash
# Check if environment variable is set
echo $API_TOKEN

# If empty, set it
export API_TOKEN="your-token"
```

**Token in wrong format:**
```json
// Correct
"Authorization": "Bearer sk-abc123"

// Wrong
"Authorization": "sk-abc123"
```

### Debugging Authentication

**Enable debug mode:**
```bash
claude --debug
```

Look for:
- Authentication header values (sanitized)
- OAuth flow progress
- Token renewal attempts
- Authentication errors

**Test authentication separately:**
```bash
# Test HTTP endpoint
curl -H "Authorization: Bearer $API_TOKEN" \
     https://api.example.com/mcp/health

# Should return 200 OK
```

## Migration Patterns

### From Hard-Coded to Environment Variables

**Before:**
```json
{
  "headers": {
    "Authorization": "Bearer sk-hard-coded-token"
  }
}
```

**After:**
```json
{
  "headers": {
    "Authorization": "Bearer ${API_TOKEN}"
  }
}
```

**Migration steps:**
1. Add environment variable to plugin README
2. Update configuration to use ${VAR}
3. Test with the variable set
4. Remove hard-coded value
5. Commit changes

### From Basic Auth to OAuth

**Before:**
```json
{
  "headers": {
    "Authorization": "Basic ${BASE64_CREDENTIALS}"
  }
}
```

**After:**
```json
{
  "type": "sse",
  "url": "https://mcp.example.com/sse"
}
```

**Benefits:**
- Better security
- No credential management
- Automatic token renewal
- Scoped permissions

## Advanced Authentication

### Mutual TLS (mTLS)

Some enterprise services require client certificates.

**Not directly supported in MCP configuration.**

**Workaround:** Wrap in a stdio server that handles mTLS:

```json
{
  "secure-api": {
    "command": "${CLAUDE_PLUGIN_ROOT}/servers/mtls-wrapper",
    "args": ["--cert", "${CLIENT_CERT}", "--key", "${CLIENT_KEY}"],
    "env": {
      "API_URL": "https://secure.example.com"
    }
  }
}
```

### JWT Tokens

Generate JWT tokens dynamically with a header helper script:

```bash
#!/bin/bash
# generate-jwt.sh

# Generate JWT (using a library or API call)
JWT=$(generate-jwt-token)

echo "{\"Authorization\": \"Bearer $JWT\"}"
```

```json
{
  "headersHelper": "${CLAUDE_PLUGIN_ROOT}/scripts/generate-jwt.sh"
}
```

### HMAC Signatures

For APIs that require request signing:

```bash
#!/bin/bash
# generate-hmac.sh

TIMESTAMP=$(date -Iseconds)
SIGNATURE=$(echo -n "$TIMESTAMP" | openssl dgst -sha256 -hmac "$SECRET_KEY" | cut -d' ' -f2)

cat <<EOF
{
  "X-Timestamp": "$TIMESTAMP",
  "X-Signature": "$SIGNATURE",
  "X-API-Key": "$API_KEY"
}
EOF
```

## Best Practices Summary

### For Plugin Developers

1. **Prefer OAuth** when the service supports it
2. **Use environment variables** for tokens
3. **Document all required variables** in the README
4. **Provide setup instructions** with examples
5. **Never commit credentials**
6. **Use only HTTPS/WSS**
7. **Test authentication thoroughly**

### For Plugin Users

1. **Set environment variables** before using the plugin
2. **Keep tokens secure** and private
3. **Rotate tokens regularly**
4. **Use different tokens** for dev/prod
5. **Do not commit .env files** to Git
6. **Check OAuth scopes** before authorizing

## Conclusion

Choose the authentication method that matches your MCP server's requirements:
- **OAuth** for cloud services (easiest for users)
- **Bearer tokens** for API services
- **Environment variables** for stdio servers
- **Dynamic headers** for complex auth flows

Always prioritize security and provide clear setup documentation for users.
