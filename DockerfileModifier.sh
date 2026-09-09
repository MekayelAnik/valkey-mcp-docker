#!/bin/bash
set -euxo pipefail
# Set variables first
REPO_NAME='valkey-mcp-server'
BASE_IMAGE=$(cat ./build_data/base-image 2>/dev/null || echo "python:3.13-slim")
HAPROXY_IMAGE=$(cat ./build_data/haproxy-image 2>/dev/null || echo "haproxy:lts")
VALKEY_MCP_VERSION=$(cat ./build_data/version 2>/dev/null || exit 1)
VALKEY_MCP_PKG="awslabs.valkey-mcp-server==${VALKEY_MCP_VERSION}"
# mcp-proxy: stdio<->StreamableHTTP/SSE bridge. Replaces supergateway.
# Stateful by default (one stdio child shared across all sessions, multiplexed
# by JSON-RPC ids) — avoids the spawn-per-request memory leak that affected
# supergateway in stateless mode (supercorp-ai/supergateway#108).
MCP_PROXY_PKG=$(cat ./build_data/mcp_proxy_version 2>/dev/null || echo "mcp-proxy")
# FastMCP powers the alternative bridge selected with MCP_BRIDGE=fastmcp
# (resources/bridge.py). It tracks the mcp 2.x SDK, so it is installed into the
# server's venv rather than beside mcp-proxy.
FASTMCP_PKG=$(cat ./build_data/fastmcp_version 2>/dev/null || echo "fastmcp")
DOCKERFILE_NAME="Dockerfile.$REPO_NAME"

# Create a temporary file safely
TEMP_FILE=$(mktemp "${DOCKERFILE_NAME}.XXXXXX") || {
    echo "Error creating temporary file" >&2
    exit 1
}

# Check if this is a publication build
if [ -e ./build_data/publication ]; then
    # For publication builds, create a minimal Dockerfile that just tags the existing image
    {
        echo "ARG BASE_IMAGE=$BASE_IMAGE"
        echo "ARG VALKEY_MCP_VERSION=$VALKEY_MCP_VERSION"
        echo "FROM $BASE_IMAGE"
    } > "$TEMP_FILE"
else
    # Write the Dockerfile content to the temporary file first
    {
        echo "ARG BASE_IMAGE=$BASE_IMAGE"
        echo "ARG VALKEY_MCP_VERSION=$VALKEY_MCP_VERSION"
        cat << EOF
FROM $HAPROXY_IMAGE AS haproxy-src
FROM $BASE_IMAGE AS build

# Author info:
LABEL org.opencontainers.image.authors="MOHAMMAD MEKAYEL ANIK <mekayel.anik@gmail.com>"
LABEL org.opencontainers.image.description="Valkey MCP Server — Model Context Protocol server for Valkey/Redis databases, with mcp-proxy (stdio<->StreamableHTTP/SSE bridge)"
LABEL org.opencontainers.image.source="https://github.com/mekayelanik/valkey-mcp-docker"

# Copy the entrypoint script into the container and make it executable
COPY ./resources/ /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh /usr/local/bin/banner.sh \\
    && if [ -f /usr/local/bin/build-timestamp.txt ]; then chmod +r /usr/local/bin/build-timestamp.txt; fi \\
    && mkdir -p /etc/haproxy \\
    && mv -vf /usr/local/bin/haproxy.cfg.template /etc/haproxy/haproxy.cfg.template \\
    && ls -la /etc/haproxy/haproxy.cfg.template

# Install required Debian packages. Base is python slim (glibc) because
# valkey-glide only publishes manylinux wheels — no musllinux, so alpine would
# need a full Rust toolchain to build it from source. gosu replaces su-exec;
# the passwd package provides useradd/usermod/groupadd/groupmod.
RUN apt-get update && \\
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \\
    bash passwd gosu tzdata haproxy netcat-openbsd openssl ca-certificates util-linux && \\
    rm -rf /var/lib/apt/lists/*

# HAProxy with native QUIC/H3 support from official image
COPY --from=haproxy-src /usr/local/sbin/haproxy /usr/sbin/haproxy
RUN mkdir -p /usr/local/sbin && ln -sf /usr/sbin/haproxy /usr/local/sbin/haproxy

# Install mcp-proxy and valkey-mcp-server into SEPARATE environments.
# mcp-proxy replaces supergateway as the stdio<->HTTP bridge (pure Python, no Node).
# They cannot share one site-packages: mcp-proxy 0.12.x imports
# mcp.server.lowlevel.server.request_ctx, which mcp 2.0.0 removed, so the proxy
# is pinned to mcp<2 — but awslabs.valkey-mcp-server >=1.1.0 requires mcp>=2.0.0.
# pip resolves that to ResolutionImpossible. mcp-proxy only ever spawns the
# server as a stdio subprocess, so an isolated venv is enough — the child needs
# its console script on PATH, nothing more.
# FastMCP goes into that same venv: it tracks mcp 2.x, and it powers the
# alternative bridge (resources/bridge.py, MCP_BRIDGE=fastmcp) for the day
# mcp-proxy — unmaintained since 2026-05 — stops being viable.
RUN --mount=type=cache,target=/root/.cache/pip \\
    echo "Installing bridge: ${MCP_PROXY_PKG}" && \\
    pip install --no-cache-dir --break-system-packages ${MCP_PROXY_PKG} && \\
    mcp-proxy --version && \\
    echo "Installing server into isolated venv: ${VALKEY_MCP_PKG} + ${FASTMCP_PKG}" && \\
    python -m venv /opt/valkey-mcp && \\
    /opt/valkey-mcp/bin/pip install --no-cache-dir ${VALKEY_MCP_PKG} ${FASTMCP_PKG} && \\
    ln -sf /opt/valkey-mcp/bin/awslabs.valkey-mcp-server /usr/local/bin/awslabs.valkey-mcp-server && \\
    /opt/valkey-mcp/bin/python -c "import awslabs.valkey_mcp_server.main" && \\
    /opt/valkey-mcp/bin/python /usr/local/bin/bridge.py --help > /dev/null && \\
    echo "Packages installed successfully"

# Use an ARG for the default port
ARG PORT=8040

# Add ARG for API key
ARG API_KEY=""

# Set an ENV variable from the ARG for runtime
ENV PORT=\${PORT}
ENV API_KEY=\${API_KEY}

# L7 health check: auto-detects HTTP/HTTPS via ENABLE_HTTPS env var.
# /healthz is answered by HAProxy locally (mcp-proxy lacks a configurable
# health endpoint) so the check itself returns in well under a second.
# start-period=60s tolerates the cold-start period so orchestrators do not
# flap the container before the backend is ready.
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \\
    CMD sh -c 'wget -q --spider --no-check-certificate \$([ "\$ENABLE_HTTPS" = "true" ] && echo https || echo http)://127.0.0.1:\${PORT:-8040}/healthz'

# Set the entrypoint
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

EOF
    } > "$TEMP_FILE"
fi

# Atomically replace the target file with the temporary file
if mv -f "$TEMP_FILE" "$DOCKERFILE_NAME"; then
    echo "Dockerfile for $REPO_NAME created successfully."
else
    echo "Error: Failed to create Dockerfile for $REPO_NAME" >&2
    rm -f "$TEMP_FILE"
    exit 1
fi
