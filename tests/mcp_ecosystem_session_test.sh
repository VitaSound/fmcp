#!/usr/bin/env bash
# E2E: flint_lint + fcov_run for all feco repos in one serve session (heavy; may OOM).
# Prefer mcp_ecosystem_fcov_test.sh for CI; restart MCP between repos if this flakes.
set -euo pipefail
FMCP_HOME="$(cd "$(dirname "$0")/.." && pwd)"
WS="${FECO_WORKSPACE:-$(dirname "$FMCP_HOME")}"
export FMCP_HOME PATH="$FMCP_HOME/bin:$PATH"

repos=(frules fsemver ttester fenum f fmix flint fcov fmcp fjson fhdlgen fhdl)
lines=(
  '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-11-25","capabilities":{},"clientInfo":{"name":"e2e","version":"1"}}}'
  '{"jsonrpc":"2.0","method":"notifications/initialized"}'
)
id=2
for r in "${repos[@]}"; do
  root="$WS/$r"
  [ -d "$root" ] || { echo "skip missing $root" >&2; continue; }
  lines+=("{\"jsonrpc\":\"2.0\",\"id\":$id,\"method\":\"tools/call\",\"params\":{\"name\":\"flint_lint\",\"arguments\":{\"project_root\":\"$root\",\"timeout_seconds\":60}}}")
  id=$((id + 1))
  lines+=("{\"jsonrpc\":\"2.0\",\"id\":$id,\"method\":\"tools/call\",\"params\":{\"name\":\"fcov_run\",\"arguments\":{\"project_root\":\"$root\",\"test_command\":\"fmix test\",\"timeout_seconds\":300}}}")
  id=$((id + 1))
done
lines+=("{\"jsonrpc\":\"2.0\",\"id\":$id,\"method\":\"tools/call\",\"params\":{\"name\":\"mcp_ping\",\"arguments\":{}}}")

out=$(printf '%s\n' "${lines[@]}" | timeout 120 "$FMCP_HOME/bin/fmcp" serve 2>/dev/null)
echo "$out" | grep -q '"id":1'
echo "$out" | grep -q "\"id\":$id"
echo "$out" | grep -q 'fmcp ok version'
echo "$out" | grep -q 'exit_code=0'

echo "mcp_ecosystem_session_test OK"
