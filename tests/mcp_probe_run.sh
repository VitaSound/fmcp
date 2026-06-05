#!/usr/bin/env bash
set -euo pipefail
TESTS_DIR="$(cd "$(dirname "$0")" && pwd)"
VENV="$TESTS_DIR/.venv-test-mcp"

if [ ! -x "$VENV/bin/python" ]; then
    python3 -m venv "$VENV"
    "$VENV/bin/pip" install -q -r "$TESTS_DIR/test_mcp_requirements.txt"
fi

# Fresh log each Cursor connect unless you unset this in mcp.json env.
export MCP_PROBE_CLEAR="${MCP_PROBE_CLEAR:-1}"
export MCP_PROBE_LOG="${MCP_PROBE_LOG:-/tmp/mcp-probe.log}"

exec "$VENV/bin/python" "$TESTS_DIR/mcp_probe_server.py"
