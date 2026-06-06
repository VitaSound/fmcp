#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
GFORTH="${FCOV_REAL_GFORTH:-$(command -v gforth)}"
export FMCP_HOME="$ROOT"
export PATH="$ROOT/bin:$PATH"
cd "$ROOT"
printf '%s\n' '{"jsonrpc":"2.0","id":1,"method":"ping"}' | "$ROOT/bin/fmcp" serve
