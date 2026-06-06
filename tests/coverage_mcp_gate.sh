#!/usr/bin/env bash
# Coverage gate: fcov run with shared tests, assert 100% production colon-defs.
set -euo pipefail
cd "$(dirname "$0")/.."

: "${FMCP_HOME:=$PWD}"
: "${FMIX_HOME:=$HOME/fmix}"
: "${FLINT_HOME:=$HOME/flint}"
: "${FCOV_HOME:=$HOME/fcov}"
export FMCP_HOME FMIX_HOME FLINT_HOME FCOV_HOME
export PATH="$FMCP_HOME/bin:$FMIX_HOME/bin:$FLINT_HOME/bin:$FCOV_HOME/bin:$PATH"

echo "== fcov clean =="
fcov clean 2>/dev/null || rm -rf .fcov/calls

echo "== fcov run (shared) =="
timeout 1800 fcov run bin/fmcp test --shared

calls_mb=$(du -sm .fcov/calls 2>/dev/null | cut -f1 || echo 0)
calls_size=$(du -sh .fcov/calls 2>/dev/null | cut -f1 || echo "?")
echo "fcov calls dir: $calls_size (${calls_mb}MB)"
if [ "${calls_mb:-0}" -gt 100 ]; then
    echo "ERROR: .fcov/calls > 100MB — subprocess storm?" >&2
    exit 1
fi

echo "== fcov report =="
fcov report --format json > .fcov/gate-report.json
python3 tests/coverage_gate_check.py .fcov/gate-report.json
