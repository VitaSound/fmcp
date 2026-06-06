#!/usr/bin/env bash
# One-line serve via real gforth (not fcov PATH shim).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
GFORTH="${FCOV_REAL_GFORTH:-$(command -v gforth)}"
export FMCP_HOME="$ROOT"
export FMCP_LINE='{"jsonrpc":"2.0","id":2,"method":"ping"}'
cd "$ROOT"
"$GFORTH" --no-rc \
    -e "s\" $ROOT\" fpath also-path" \
    -e "require fmcp_serve_line.4th" \
    -e "fmcp.serve-one-line" \
    -e "bye"
