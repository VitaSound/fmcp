#!/usr/bin/env bash
set -euo pipefail
TESTS_DIR="$(cd "$(dirname "$0")" && pwd)"
RUN="$TESTS_DIR/test_mcp_run.sh"

out=$(printf '%s\n' \
  '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2024-11-05","capabilities":{},"clientInfo":{"name":"smoke","version":"1.0"}}}' \
  '{"jsonrpc":"2.0","method":"notifications/initialized"}' \
  '{"jsonrpc":"2.0","id":3,"method":"tools/list"}' \
  | timeout 30 "$RUN" 2>/dev/null)

echo "$out" | grep -q protocolVersion
echo "$out" | grep -q '"id":1'
echo "$out" | grep -q '"id":3'
echo "$out" | grep -q echo

echo "test_mcp_smoke OK"
