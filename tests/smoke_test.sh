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

echo "smoke_test OK"
