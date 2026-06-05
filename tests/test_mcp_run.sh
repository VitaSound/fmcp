#!/usr/bin/env bash
# Cursor MCP launcher for Python test server (WSL).
set -euo pipefail
TESTS_DIR="$(cd "$(dirname "$0")" && pwd)"
VENV="$TESTS_DIR/.venv-test-mcp"

if [ ! -x "$VENV/bin/python" ]; then
    python3 -m venv "$VENV"
    "$VENV/bin/pip" install -q -r "$TESTS_DIR/test_mcp_requirements.txt"
fi

exec "$VENV/bin/python" "$TESTS_DIR/test_mcp_server.py"
