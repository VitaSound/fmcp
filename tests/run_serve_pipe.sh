#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
export FMCP_HOME="$ROOT"
export PATH="$ROOT/bin:$PATH"
cd "$ROOT"
printf '%s\n' '{"jsonrpc":"2.0","id":2,"method":"ping"}' | "$ROOT/bin/fmcp" serve
