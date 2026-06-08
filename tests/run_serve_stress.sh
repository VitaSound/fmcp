#!/usr/bin/env bash
# Stress fmcp serve: many mcp_ping in one session (feco batch pattern).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
export FMCP_HOME="$ROOT"
export FMCP_LOG=0
export PATH="$ROOT/bin:$PATH"
cd "$ROOT"
count="${1:-200}"
lines=0
while IFS= read -r _; do
  lines=$((lines + 1))
done < <(
  for n in $(seq 1 "$count"); do
    printf '%s\n' \
      "{\"jsonrpc\":\"2.0\",\"id\":$n,\"method\":\"tools/call\",\"params\":{\"name\":\"mcp_ping\",\"arguments\":{}}}"
  done | "$ROOT/bin/fmcp" serve
)
if [ "$lines" -ne "$count" ]; then
  echo "serve stress: expected $count responses, got $lines" >&2
  exit 1
fi
echo "serve stress OK ($count pings)"
