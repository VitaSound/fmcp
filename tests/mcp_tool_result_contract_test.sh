#!/usr/bin/env bash
# tools/call returns structuredContent + JSON text with unified contract fields.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
export FMCP_HOME="$ROOT"
export FMCP_LOG=0
export PATH="$ROOT/bin:$PATH"
cd "$ROOT"
out=$(printf '%s\n' \
  '{"jsonrpc":"2.0","id":1,"method":"tools/call","params":{"name":"mcp_ping","arguments":{}}}' \
  | "$ROOT/bin/fmcp" serve)
echo "$out" | grep -q '"structuredContent"'
echo "$out" | grep -q '"exit_code"'
echo "$out" | grep -q '"elapsed_ms"'
echo "$out" | grep -q '"summary"'
echo "$out" | grep -q '"output"'
echo "$out" | grep -q '"tool"'
echo "mcp_tool_result_contract_test OK"
