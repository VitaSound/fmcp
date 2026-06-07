#!/usr/bin/env bash
# E2E: one fmcp serve session — fcov_run timeout then mcp_ping (no restart).
set -euo pipefail
FMCP_HOME="$(cd "$(dirname "$0")/.." && pwd)"
export FMCP_HOME PATH="$FMCP_HOME/bin:$PATH"
ROOT="$FMCP_HOME"

out=$(printf '%s\n' \
  '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-11-25","capabilities":{},"clientInfo":{"name":"e2e","version":"1"}}}' \
  '{"jsonrpc":"2.0","method":"notifications/initialized"}' \
  '{"jsonrpc":"2.0","id":2,"method":"tools/call","params":{"name":"fcov_run","arguments":{"project_root":"'"$ROOT"'","test_command":"sleep 5","timeout_seconds":1}}}' \
  '{"jsonrpc":"2.0","id":3,"method":"tools/call","params":{"name":"mcp_ping","arguments":{}}}' \
  | timeout 30 "$FMCP_HOME/bin/fmcp" serve 2>/dev/null)

echo "$out" | grep -q '"id":2'
echo "$out" | grep -q 'exit_code=124'
echo "$out" | grep -q 'elapsed_ms='
echo "$out" | grep -q '"isError":true'
echo "$out" | grep -q '"id":3'
echo "$out" | grep -q 'fmcp ok version'
echo "$out" | grep -q 'exit_code=0'

echo "mcp_fcov_session_test OK"
