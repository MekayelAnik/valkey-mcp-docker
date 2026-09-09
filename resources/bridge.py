#!/usr/bin/env python3
"""Bridge a stdio MCP server to Streamable HTTP (/mcp) and SSE (/sse).

Alternative to mcp-proxy for servers that require the mcp 2.x SDK. mcp-proxy
0.12.0 imports mcp.server.lowlevel.server.request_ctx, removed in mcp 2.0.0,
so it is pinned to mcp<2 and cannot share an environment with such a server.
This bridge is built on FastMCP, which tracks mcp 2.x, and therefore runs in
the same environment as the server itself.

Selected at runtime with MCP_BRIDGE=fastmcp; mcp-proxy remains the default.
The accepted flags mirror the mcp-proxy invocation in entrypoint.sh so the two
bridges stay interchangeable.
"""

import argparse
import contextlib
import os

import uvicorn
from fastmcp.client.transports import StdioTransport
from fastmcp.server import create_proxy
from starlette.applications import Starlette
from starlette.middleware import Middleware
from starlette.middleware.cors import CORSMiddleware

DEFAULT_EXPOSE_HEADERS = ["Mcp-Session-Id"]


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--host", default="127.0.0.1")
    parser.add_argument("--port", type=int, required=True)
    parser.add_argument("--stateless", action=argparse.BooleanOptionalAction, default=False)
    parser.add_argument("--allow-origin", action="append", default=[])
    parser.add_argument("--expose-header", action="append", default=[])
    parser.add_argument("--log-level", default=os.environ.get("BRIDGE_LOG_LEVEL", "info"))
    parser.add_argument("command", nargs=argparse.REMAINDER, help="-- stdio command and its args")
    args = parser.parse_args()

    argv = args.command
    if argv and argv[0] == "--":
        argv = argv[1:]
    if not argv:
        parser.error("no stdio command given (pass it after --)")
    args.command = argv
    return args


def build_app(args: argparse.Namespace) -> Starlette:
    # The mcp SDK spawns stdio children with a small allowlisted environment.
    # The server reads its configuration (VALKEY_HOST, VALKEY_PORT, ...) from
    # the container environment, so pass it through in full — this is what
    # mcp-proxy's --pass-environment does.
    transport = StdioTransport(
        command=args.command[0],
        args=args.command[1:],
        env=dict(os.environ),
    )
    # Without an explicit name the proxy reports itself as FastMCPProxy-<hash>;
    # mcp-proxy forwards the upstream server's identity, so match that.
    proxy = create_proxy(transport, name=os.path.basename(args.command[0]))

    # Each sub-app is built on its own absolute path and their routes are then
    # merged into one Starlette app. Mounting under a prefix instead would make
    # /mcp answer 307 to /mcp/, which mcp-proxy never did.
    http_app = proxy.http_app(path="/mcp", transport="http", stateless_http=args.stateless)
    sse_app = proxy.http_app(path="/sse", transport="sse", stateless_http=args.stateless)

    @contextlib.asynccontextmanager
    async def lifespan(app: Starlette):
        async with http_app.lifespan(app), sse_app.lifespan(app):
            yield

    middleware = []
    if args.allow_origin:
        middleware.append(
            Middleware(
                CORSMiddleware,
                allow_origins=args.allow_origin,
                allow_methods=["*"],
                allow_headers=["*"],
                expose_headers=args.expose_header or DEFAULT_EXPOSE_HEADERS,
            )
        )

    return Starlette(
        routes=[*http_app.routes, *sse_app.routes],
        middleware=middleware,
        lifespan=lifespan,
    )


def main() -> None:
    args = parse_args()
    print(f"fastmcp bridge: /mcp (StreamableHTTP) + /sse -> {' '.join(args.command)}", flush=True)
    uvicorn.run(build_app(args), host=args.host, port=args.port, log_level=args.log_level)


if __name__ == "__main__":
    main()
