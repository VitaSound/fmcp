#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
export FMCP_HOME="$ROOT"
export PATH="$ROOT/bin:$PATH"
cd "$ROOT"

gforth -e "s\" $ROOT\" fpath also-path" \
    -e "s\" $ROOT/tests/fmcp_cleanup_e2e.4th\" included" \
    -e "bye" </dev/null

echo "mcp_cleanup_test OK"
