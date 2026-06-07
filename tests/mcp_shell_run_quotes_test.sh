#!/usr/bin/env bash
# E2E: shell_run with single-quoted grep must finish quickly; mcp_ping in same session.
set -euo pipefail
FMCP_HOME="$(cd "$(dirname "$0")/.." && pwd)"
export FMCP_HOME PATH="$FMCP_HOME/bin:$PATH"
ROOT="$FMCP_HOME"

CMD='fcov clean 2>/dev/null; fcov run bin/fmcp test --shared tests/fmcp_emit_test.4th 2>&1 | grep -E '\''emit_test|ERROR|FAILED|passed'\'''

out=$(printf '%s\n' \
  '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-11-25","capabilities":{},"clientInfo":{"name":"e2e","version":"1"}}}' \
  '{"jsonrpc":"2.0","method":"notifications/initialized"}' \
  '{"jsonrpc":"2.0","id":2,"method":"tools/call","params":{"name":"shell_run","arguments":{"project_root":"'"$ROOT"'","command":"'"$CMD"'","timeout_seconds":60}}}' \
  '{"jsonrpc":"2.0","id":3,"method":"tools/call","params":{"name":"mcp_ping","arguments":{}}}' \
  | timeout 15 "$FMCP_HOME/bin/fmcp" serve 2>/dev/null)

echo "$out" | grep -q '"id":2'
echo "$out" | grep -q 'exit_code=0'
echo "$out" | grep -q 'fmcp_emit_test OK'
echo "$out" | grep -q '"id":3'
echo "$out" | grep -q 'fmcp ok version'
echo "$out" | grep -q 'exit_code=0'

elapsed=$(echo "$out" | grep -o 'elapsed_ms=[0-9]*' | head -1 | cut -d= -f2)
if [ -z "$elapsed" ] || [ "$elapsed" -gt 10000 ]; then
    echo "ERROR: shell_run with quotes took too long: elapsed_ms=${elapsed:-missing}" >&2
    exit 1
fi

echo "mcp_shell_run_quotes_test OK"
