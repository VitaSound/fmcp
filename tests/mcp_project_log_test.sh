#!/usr/bin/env bash
# Per-project tool lines go to project_root/.fmcp/tool.log, not repo-root junk files.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PROJ="$(mktemp -d /tmp/fmcp-projlog-XXXXXX)"
LOG="$ROOT/.fmcp/serve-projlog-$$.log"
export FMCP_HOME="$ROOT"
export FMCP_LOG="$LOG"
export PATH="$ROOT/bin:$PATH"
cleanup() {
  rm -rf "$PROJ" "$LOG"
}
trap cleanup EXIT
printf '%s\n' \
  '{"jsonrpc":"2.0","id":1,"method":"tools/call","params":{"name":"shell_run","arguments":{"project_root":"'"$PROJ"'","command":"echo ok"}}}' \
  | "$ROOT/bin/fmcp" serve >/dev/null
test -f "$PROJ/.fmcp/tool.log"
grep -q 'TOOL_START' "$PROJ/.fmcp/tool.log"
grep -q 'TOOL_END' "$PROJ/.fmcp/tool.log"
count="$(find "$PROJ" -maxdepth 1 -name 'TOOL_*' | wc -l)"
test "$count" -eq 0
echo "mcp_project_log_test OK"
