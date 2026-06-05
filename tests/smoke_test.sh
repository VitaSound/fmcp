#!/usr/bin/env bash
set -euo pipefail
FMCP_HOME="$(cd "$(dirname "$0")/.." && pwd)"
export FMCP_HOME PATH="$FMCP_HOME/bin:$PATH"

"$FMCP_HOME/bin/fmcp" version | grep -q '(fmcp)'

init_out=$(printf '%s\n' '{"jsonrpc":"2.0","id":1,"method":"initialize"}' \
  | timeout 15 "$FMCP_HOME/bin/fmcp" serve)
echo "$init_out" | grep -q protocolVersion
echo "$init_out" | grep -q '"id":1'
echo "$init_out" | grep -vq '"id":"1"'

printf '%s\n' '{"jsonrpc":"2.0","id":2,"method":"tools/list"}' \
  | timeout 15 "$FMCP_HOME/bin/fmcp" serve | grep -q fmix_test

printf '%s\n' '{"jsonrpc":"2.0","id":3,"method":"tools/call","params":{"name":"nope","arguments":{}}}' \
  | timeout 15 "$FMCP_HOME/bin/fmcp" serve | grep -q unknown

ping_out=$(printf '%s\n' '{"jsonrpc":"2.0","id":4,"method":"ping"}' \
  | timeout 15 "$FMCP_HOME/bin/fmcp" serve)
echo "$ping_out" | grep -q '"id":4'
echo "$ping_out" | grep -q '"result"'

handshake_out=$(printf '%s\n' \
  '{"jsonrpc":"2.0","id":1,"method":"initialize"}' \
  '{"jsonrpc":"2.0","method":"notifications/initialized"}' \
  '{"jsonrpc":"2.0","id":2,"method":"ping"}' \
  '{"jsonrpc":"2.0","id":3,"method":"tools/list"}' \
  | timeout 15 "$FMCP_HOME/bin/fmcp" serve)
echo "$handshake_out" | grep -q '"id":2'
echo "$handshake_out" | grep -q fmix_test

cursor_init='{"method":"initialize","params":{"protocolVersion":"2025-11-25","capabilities":{"roots":{"listChanged":false}},"clientInfo":{"name":"cursor-vscode","version":"1.0.0"}},"jsonrpc":"2.0","id":0}'
cursor_out=$(printf '%s\n' \
  "$cursor_init" \
  '{"method":"notifications/initialized","jsonrpc":"2.0"}' \
  '{"method":"resources/list","jsonrpc":"2.0","id":1}' \
  '{"method":"tools/list","jsonrpc":"2.0","id":2}' \
  '{"method":"prompts/list","jsonrpc":"2.0","id":4}' \
  | timeout 15 "$FMCP_HOME/bin/fmcp" serve)
cursor_lines=$(printf '%s\n' "$cursor_out" | grep -c . || true)
[ "$cursor_lines" -ge 4 ]
first_line=$(printf '%s\n' "$cursor_out" | head -1)
echo "$first_line" | grep -q protocolVersion
echo "$first_line" | grep -q '"id":0'
echo "$first_line" | grep -vq '"id":"0"'
echo "$cursor_out" | grep -vq '\\r\\n'

echo "smoke_test OK"
