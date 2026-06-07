#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
LOG="$ROOT/.fmcp/serve-log-test-$$.log"
export FMCP_HOME="$ROOT"
export FMCP_LOG="$LOG"
export PATH="$ROOT/bin:$PATH"
cd "$ROOT"
printf '%s\n' '{"jsonrpc":"2.0","id":1,"method":"ping"}' | "$ROOT/bin/fmcp" serve >/dev/null
grep -q 'SESSION_START' "$LOG"
grep -q 'REQ' "$LOG"
grep -q 'method=ping' "$LOG"
grep -q 'REQ_DONE' "$LOG"
rm -f "$LOG"
echo "mcp_serve_log_test OK"
