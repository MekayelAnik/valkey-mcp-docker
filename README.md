<p align="center"><img src="https://valkey.io/img/valkey-horizontal.svg" alt="Valkey Logo" width="200"></p>

# Valkey MCP Server

<p align="center">
  <a href="https://hub.docker.com/r/mekayelanik/valkey-mcp-server"><img alt="Docker Pulls" src="https://img.shields.io/docker/pulls/mekayelanik/valkey-mcp-server?style=flat-square&logo=docker"></a>
  <a href="https://hub.docker.com/r/mekayelanik/valkey-mcp-server"><img alt="Docker Stars" src="https://img.shields.io/docker/stars/mekayelanik/valkey-mcp-server?style=flat-square&logo=docker"></a>
  <a href="https://github.com/MekayelAnik/valkey-mcp-docker/pkgs/container/valkey-mcp-server"><img alt="GHCR" src="https://img.shields.io/badge/GHCR-ghcr.io%2Fmekayelanik%2Fvalkey--mcp--server-blue?style=flat-square&logo=github"></a>
  <a href="https://github.com/MekayelAnik/valkey-mcp-docker/blob/main/LICENSE"><img alt="License: GPL-3.0" src="https://img.shields.io/badge/License-GPL--3.0-blue?style=flat-square"></a>
  <a href="https://hub.docker.com/r/mekayelanik/valkey-mcp-server"><img alt="Platforms" src="https://img.shields.io/badge/Platforms-amd64%20%7C%20arm64-lightgrey?style=flat-square"></a>
  <a href="https://github.com/MekayelAnik/valkey-mcp-docker/stargazers"><img alt="GitHub Stars" src="https://img.shields.io/github/stars/MekayelAnik/valkey-mcp-docker?style=flat-square"></a>
  <a href="https://github.com/MekayelAnik/valkey-mcp-docker/forks"><img alt="GitHub Forks" src="https://img.shields.io/github/forks/MekayelAnik/valkey-mcp-docker?style=flat-square"></a>
  <a href="https://github.com/MekayelAnik/valkey-mcp-docker/issues"><img alt="GitHub Issues" src="https://img.shields.io/github/issues/MekayelAnik/valkey-mcp-docker?style=flat-square"></a>
  <a href="https://github.com/MekayelAnik/valkey-mcp-docker/commits/main"><img alt="Last Commit" src="https://img.shields.io/github/last-commit/MekayelAnik/valkey-mcp-docker?style=flat-square"></a>
</p>

### Multi-Architecture Docker Image for Valkey Data Management

---

## 😎 Buy Me a Coffee ☕︎
**Your support encourages me to keep creating/supporting my open-source projects.** If you found value in this project, you can buy me a coffee to keep me inspired.

<p align="center">
<a href="https://07mekayel07.gumroad.com/coffee" target="_blank">
<img src="https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png" alt="Buy Me A Coffee" width="217" height="60">
</a>
</p>

## Table of Contents

- [Overview](#overview)
- [Supported Architectures](#supported-architectures)
- [Available Tags](#available-tags)
- [Quick Start](#quick-start)
- [Configuration](#configuration)
- [MCP Client Configuration](#mcp-client-configuration)
- [Network Configuration](#network-configuration)
- [Updating](#updating)
- [Troubleshooting](#troubleshooting)
- [Additional Resources](#additional-resources)
- [Support & License](#support--license)

---

## Overview

Valkey MCP Server is a Model Context Protocol server that provides tools for managing and interacting with Valkey databases. Built on Alpine Linux for minimal footprint and maximum security, wrapped with Supergateway for HTTP/SSE/WebSocket transport. Valkey is an open-source, high-performance key/value datastore that is fully compatible with the Redis protocol.

### Key Features

- **Multi-Architecture Support** - Native support for x86-64 and ARM64
- **Multiple Transport Protocols** - HTTP, SSE, and WebSocket support
- **Secure by Design** - Alpine-based with minimal attack surface
- **High Performance** - ZSTD compression for faster deployments
- **Production Ready** - Stable releases with comprehensive testing
- **Easy Configuration** - Simple environment variable setup

---

## Supported Architectures

| Architecture | Tag Prefix | Status |
|:-------------|:-----------|:------:|
| **x86-64** | `amd64-<version>` | Stable |
| **ARM64** | `arm64v8-<version>` | Stable |

> Multi-arch images automatically select the correct architecture for your system.

---

## Available Tags

| Tag | Stability | Description | Use Case |
|:----|:---------:|:------------|:---------|
| `stable` | High | Most stable release | **Recommended for production** |
| `latest` | High | Latest stable release | Stay current with stable features |
| `1.0.16` | High | Specific version | Version pinning for consistency |
| `0.1.0-08042026` | High | Version + build date | Exact build reproducibility |
| `beta` | Low | Beta releases | **Testing only** |

### System Requirements

- **Docker Engine:** 23.0+
- **RAM:** Minimum 512MB
- **CPU:** Single core sufficient

> **CRITICAL:** Do NOT expose this container directly to the internet without proper security measures (reverse proxy, SSL/TLS, authentication, firewall rules).

---

## Quick Start

### Docker Compose (Recommended)

```yaml
services:
  valkey-mcp-server:
    image: mekayelanik/valkey-mcp-server:stable
    container_name: valkey-mcp-server
    restart: unless-stopped
    ports:
      - "8040:8040"
    environment:
      - PORT=8040
      - INTERNAL_PORT=38011
      - PUID=1000
      - PGID=1000
      - TZ=Asia/Dhaka
      - PROTOCOL=SHTTP
      - ENABLE_HTTPS=false
      - HTTP_VERSION_MODE=auto
      # Valkey connection settings
      # - VALKEY_URL=valkey://localhost:6379
      # - VALKEY_HOST=localhost
      # - VALKEY_PORT=6379
      # - VALKEY_USERNAME=
      # - VALKEY_PWD=
      # - VALKEY_USE_SSL=false
      # - VALKEY_SSL_CA_PATH=
      # - VALKEY_SSL_KEYFILE=
      # - VALKEY_SSL_CERTFILE=
      # - VALKEY_SSL_CERT_REQS=required
      # - VALKEY_SSL_CA_CERTS=
      # - VALKEY_CLUSTER_MODE=false
      # Optional: require Bearer token auth at HAProxy layer
      # - API_KEY=replace-with-strong-secret
    hostname: valkey-mcp-server
    domainname: local
```

**Deploy:**
```bash
docker compose up -d
docker compose logs -f valkey-mcp-server
```

### Docker CLI

```bash
docker run -d \
  --name=valkey-mcp-server \
  --restart=unless-stopped \
  -p 8040:8040 \
  -e PORT=8040 \
  -e INTERNAL_PORT=38011 \
  -e PUID=1000 \
  -e PGID=1000 \
  -e TZ=Asia/Dhaka \
  -e PROTOCOL=SHTTP \
  -e ENABLE_HTTPS=false \
  -e HTTP_VERSION_MODE=auto \
  mekayelanik/valkey-mcp-server:stable
```

### Access Endpoints

| Protocol | Endpoint | Use Case |
|:---------|:---------|:---------|
| **HTTP** | `http://host-ip:8040/mcp` | Best compatibility (recommended) |
| **SSE** | `http://host-ip:8040/sse` | Real-time streaming |
| **WebSocket** | `ws://host-ip:8040/message` | Bidirectional communication |

When HTTPS is enabled (`ENABLE_HTTPS=true`), use TLS endpoints:

| Protocol | Endpoint |
|:---------|:---------|
| **SHTTP** | `https://host-ip:8040/mcp` |
| **SSE** | `https://host-ip:8040/sse` |
| **WebSocket** | `wss://host-ip:8040/message` |

> **Security Warning:** The container now defaults to HTTP (`ENABLE_HTTPS=false`) for easier local setup. Use `ENABLE_HTTPS=true` for production, public networks, or any untrusted environment.
>
> **ARM Devices:** Allow 30-60 seconds for initialization before accessing endpoints.

---

## Configuration

### Environment Variables

| Variable | Default | Description |
|:---------|:-------:|:------------|
| `PORT` | `8040` | External server port |
| `INTERNAL_PORT` | `38011` | Internal MCP server port used by supergateway |
| `PUID` | `1000` | User ID for file permissions |
| `PGID` | `1000` | Group ID for file permissions |
| `TZ` | `UTC` | Container timezone ([TZ database](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones)) |
| `PROTOCOL` | `SHTTP` | Default transport protocol |
| `VALKEY_URL` | *(empty)* | Full Valkey connection URL (e.g. `valkey://user:pass@host:6379`) |
| `VALKEY_HOST` | `127.0.0.1` | Valkey server hostname |
| `VALKEY_PORT` | `6379` | Valkey server port |
| `VALKEY_USERNAME` | *(empty)* | Valkey authentication username |
| `VALKEY_PWD` | *(empty)* | Valkey authentication password |
| `VALKEY_USE_SSL` | `false` | Enable SSL for Valkey connection (`true`/`false`) |
| `VALKEY_SSL_CA_PATH` | *(empty)* | Path to SSL CA file |
| `VALKEY_SSL_KEYFILE` | *(empty)* | Path to SSL key file |
| `VALKEY_SSL_CERTFILE` | *(empty)* | Path to SSL certificate file |
| `VALKEY_SSL_CERT_REQS` | `required` | SSL certificate requirements |
| `VALKEY_SSL_CA_CERTS` | *(empty)* | Path to SSL CA certificates |
| `VALKEY_CLUSTER_MODE` | `false` | Enable Valkey Cluster mode (`true`/`false`) |
| `VALKEY_READONLY` | *(unset)* | `true` → `--readonly`, `false` → `--no-readonly`, unset → upstream default (read-write) |
| `API_KEY` | *(empty)* | Enables Bearer token auth (`Authorization: Bearer <API_KEY>`) |
| `CORS` | *(empty)* | Comma-separated CORS origins, supports `*` |
| `ENABLE_HTTPS` | `false` | Enables TLS termination in HAProxy |
| `TLS_CERT_PATH` | `/etc/haproxy/certs/server.crt` | TLS cert path |
| `TLS_KEY_PATH` | `/etc/haproxy/certs/server.key` | TLS private key path |
| `TLS_PEM_PATH` | `/etc/haproxy/certs/server.pem` | Combined PEM file used by HAProxy |
| `TLS_CN` | `localhost` | CN for auto-generated certificate |
| `TLS_SAN` | `DNS:<TLS_CN>` | SAN for auto-generated certificate |
| `TLS_DAYS` | `365` | Auto-generated cert validity period |
| `TLS_MIN_VERSION` | `TLSv1.3` | Minimum TLS protocol (`TLSv1.2` or `TLSv1.3`) |
| `HTTP_VERSION_MODE` | `auto` | `auto`, `all`, `h1`, `h2`, `h3`, `h1+h2` |
| `RATE_LIMIT` | `0` | Max requests per `RATE_LIMIT_PERIOD` per IP (`0` = disabled) |
| `RATE_LIMIT_PERIOD` | `10s` | Sliding window for rate limiting (e.g., `10s`, `1m`, `1h`) |
| `MAX_CONNECTIONS_PER_IP` | `0` | Max concurrent connections per IP (`0` = disabled) |
| `IP_ALLOWLIST` | *(empty)* | Comma-separated IPs/CIDRs to allow (all others blocked) |
| `IP_BLOCKLIST` | *(empty)* | Comma-separated IPs/CIDRs to block |

### HTTPS and HTTP Version Notes

- If `ENABLE_HTTPS=true` and cert files are missing, the container auto-generates a self-signed certificate.
- If `TLS_CERT_PATH` and `TLS_KEY_PATH` exist, they are merged into `TLS_PEM_PATH` and used directly.
- `HTTP_VERSION_MODE=h3` (or `auto`) enables HTTP/3 only when HAProxy build includes QUIC; otherwise it safely falls back.

### API Key Authentication Notes

- Set `API_KEY` to enforce authentication at reverse proxy level.
- Expected header format: `Authorization: Bearer <API_KEY>`.
- Localhost health checks remain accessible for liveness/readiness.

### Rate Limiting and IP Access Control

- **Rate limiting:** Set `RATE_LIMIT=100` to allow 100 requests per `RATE_LIMIT_PERIOD` (default `10s`) per IP. Exceeding the limit returns HTTP 429 with a `Retry-After` header.
- **Connection limiting:** Set `MAX_CONNECTIONS_PER_IP=50` to cap concurrent connections per IP. Exceeding returns HTTP 429.
- **IP blocklist:** Set `IP_BLOCKLIST=192.0.2.0/24,198.51.100.5` to block specific IPs/CIDRs. Blocked IPs receive HTTP 403.
- **IP allowlist:** Set `IP_ALLOWLIST=10.0.0.0/8,192.168.1.0/24` to allow only listed IPs/CIDRs. All others receive HTTP 403. Localhost is always allowed.
- All features default to disabled. Combine as needed — blocklist is checked before allowlist.

### User & Group IDs

Find your IDs and set them to avoid permission issues:

```bash
id username
# uid=1000(user) gid=1000(group)
```

### Timezone Examples

```yaml
- TZ=Asia/Dhaka        # Bangladesh
- TZ=America/New_York  # US Eastern
- TZ=Europe/London     # UK
- TZ=UTC               # Universal Time
```

---

## MCP Client Configuration

### Transport Support

| Client | HTTP | SSE | WebSocket | Recommended |
|:-------|:----:|:---:|:---------:|:------------|
| **VS Code (Cline/Roo-Cline)** | Yes | Yes | No | HTTP |
| **Claude Desktop** | Yes | Yes | Experimental | HTTP |
| **Claude CLI** | Yes | Yes | Experimental | HTTP |
| **Codex CLI** | Yes | Yes | Experimental | HTTP |
| **Codeium (Windsurf)** | Yes | Yes | Experimental | HTTP |
| **Cursor** | Yes | Yes | Experimental | HTTP |

---

### VS Code (Cline/Roo-Cline)

Configure in `.vscode/settings.json`:

```json
{
  "mcp.servers": {
    "valkey-mcp": {
      "url": "http://host-ip:8040/mcp",
      "transport": "http"
    }
  }
}
```

---

### Claude Desktop App/Claude Code

**With API_KEY:**
```
claude mcp add-json valkey-mcp '{"type":"http","url":"http://localhost:8040/mcp","headers":{"Authorization":"Bearer <YOUR_API_KEY>"}}'
```

**Without API_KEY:**
```
claude mcp add-json valkey-mcp '{"type":"http","url":"http://localhost:8040/mcp"}'
```

---

### Codex CLI

Configure in `~/.codex/config.json`:

```json
{
  "mcpServers": {
    "valkey-mcp": {
      "transport": "http",
      "url": "http://host-ip:8040/mcp"
    }
  }
}
```

---

### Codeium (Windsurf)

Configure in `.codeium/mcp_settings.json`:

```json
{
  "mcpServers": {
    "valkey-mcp": {
      "transport": "http",
      "url": "http://host-ip:8040/mcp"
    }
  }
}
```

---

### Cursor

Configure in `~/.cursor/mcp.json`:

```json
{
  "mcpServers": {
    "valkey-mcp": {
      "transport": "http",
      "url": "http://host-ip:8040/mcp"
    }
  }
}
```

---

### Testing Configuration

Verify with [MCP Inspector](https://github.com/modelcontextprotocol/inspector):

```bash
npm install -g @modelcontextprotocol/inspector
mcp-inspector http://host-ip:8040/mcp
```

---

## Network Configuration

### Comparison

| Network Mode | Complexity | Performance | Use Case |
|:-------------|:----------:|:-----------:|:---------|
| **Bridge** | Easy | Good | Default, isolated |
| **Host** | Moderate | Excellent | Direct host access |
| **MACVLAN** | Advanced | Excellent | Dedicated IP |

---

### Bridge Network (Default)

```yaml
services:
  valkey-mcp-server:
    image: mekayelanik/valkey-mcp-server:stable
    ports:
      - "8040:8040"
```

**Benefits:** Container isolation, easy setup, works everywhere
**Access:** `http://localhost:8040/mcp`

---

### Host Network (Linux Only)

```yaml
services:
  valkey-mcp-server:
    image: mekayelanik/valkey-mcp-server:stable
    network_mode: host
```

**Benefits:** Maximum performance, no NAT overhead, no port mapping needed
**Considerations:** Linux only, shares host network namespace
**Access:** `http://localhost:8040/mcp`

---

### MACVLAN Network (Advanced)

```yaml
services:
  valkey-mcp-server:
    image: mekayelanik/valkey-mcp-server:stable
    mac_address: "AB:BC:CD:DE:EF:01"
    networks:
      macvlan-net:
        ipv4_address: 192.168.1.100

networks:
  macvlan-net:
    driver: macvlan
    driver_opts:
      parent: eth0
    ipam:
      config:
        - subnet: 192.168.1.0/24
          gateway: 192.168.1.1
```

**Benefits:** Dedicated IP, direct LAN access
**Considerations:** Linux only, requires additional setup
**Access:** `http://192.168.1.100:8040/mcp`

---

## Updating

### Docker Compose

```bash
docker compose pull
docker compose up -d
docker image prune -f
```

### Docker CLI

```bash
docker pull mekayelanik/valkey-mcp-server:stable
docker stop valkey-mcp-server && docker rm valkey-mcp-server
# Run your original docker run command
docker image prune -f
```

### One-Time Update with Watchtower

```bash
docker run --rm \
  -v /var/run/docker.sock:/var/run/docker.sock \
  containrrr/watchtower \
  --run-once \
  valkey-mcp-server
```

---

## Troubleshooting

### Pre-Flight Checklist

- Docker Engine 23.0+
- Port 8040 available
- Sufficient startup time (ARM devices)
- Latest stable image
- Correct configuration

### Common Issues

#### Container Won't Start

```bash
# Check Docker version
docker --version

# Verify port availability
sudo netstat -tulpn | grep 8040

# Check logs
docker logs valkey-mcp-server
```

#### Permission Errors

```bash
# Get your IDs
id $USER

# Update configuration with correct PUID/PGID
# Fix volume permissions if needed
sudo chown -R 1000:1000 /path/to/volume
```

#### Client Cannot Connect

```bash
# Test connectivity
curl http://localhost:8040/mcp
curl http://host-ip:8040/mcp
curl -k https://localhost:8040/mcp
curl -k https://host-ip:8040/mcp

# Check firewall
sudo ufw status

# Verify container
docker inspect valkey-mcp-server | grep IPAddress
```

#### Slow ARM Performance

- Wait 30-60 seconds after start
- Monitor: `docker logs -f valkey-mcp-server`
- Check resources: `docker stats valkey-mcp-server`
- Use faster storage (SSD vs SD card)

### Debug Information

When reporting issues, include:

```bash
# System info
docker --version && uname -a

# Container logs
docker logs valkey-mcp-server --tail 200 > logs.txt

# Container config
docker inspect valkey-mcp-server > inspect.json
```

---

## Additional Resources

### Documentation
- [Valkey MCP Upstream](https://github.com/awslabs/mcp)
- [PyPI Package](https://pypi.org/project/awslabs.valkey-mcp-server/)
- [MCP Inspector](https://github.com/modelcontextprotocol/inspector)

### Docker Resources
- [Docker Compose Best Practices](https://docs.docker.com/compose/production/)
- [Docker Networking](https://docs.docker.com/network/)
- [Docker Security](https://docs.docker.com/engine/security/)

### Monitoring
- [Diun - Update Notifier](https://crazymax.dev/diun/)
- [Watchtower](https://containrrr.dev/watchtower/)

---

## 😎 Buy Me a Coffee ☕︎
**Your support encourages me to keep creating/supporting my open-source projects.** If you found value in this project, you can buy me a coffee to keep me inspired.

<p align="center">
  <a href="https://07mekayel07.gumroad.com/coffee" target="_blank">
    <img src="https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png" alt="Buy Me A Coffee" width="217" height="60">
  </a>
</p>

## Support & License

### Getting Help

**Docker Image Issues:**
- GitHub: [valkey-mcp-docker/issues](https://github.com/MekayelAnik/valkey-mcp-docker/issues)

**Valkey MCP Issues:**
- GitHub: [awslabs/mcp/issues](https://github.com/awslabs/mcp/issues)

### Contributing

We welcome contributions:
1. Report bugs via GitHub Issues
2. Suggest features
3. Improve documentation
4. Test beta releases

### License

GPL License. See [LICENSE](https://raw.githubusercontent.com/MekayelAnik/valkey-mcp-docker/refs/heads/main/LICENSE) for details.

Valkey MCP server has its own license - see [upstream repository](https://github.com/awslabs/mcp).

---

<div align="center">

[Back to Top](#valkey-mcp-server)

</div>
