#!/usr/bin/env python3
"""Minimal MCP stdio server for Cursor/fmcp diagnostics."""

from mcp.server.fastmcp import FastMCP

mcp = FastMCP("test-mcp")


@mcp.tool()
def echo(message: str = "pong") -> str:
    """Echo a message — proves tools/call works."""
    return message


if __name__ == "__main__":
    mcp.run(transport="stdio")
