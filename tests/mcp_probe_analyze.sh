#!/usr/bin/env bash
# Summarize /tmp/mcp-probe.log after a Cursor MCP session.
LOG="${MCP_PROBE_LOG:-/tmp/mcp-probe.log}"
if [ ! -f "$LOG" ]; then
    echo "No log at $LOG"
    exit 1
fi
echo "=== $LOG ==="
echo "--- sessions ---"
grep '\[SESSION\]' "$LOG" || true
echo "--- methods (order) ---"
grep '\[METHOD\]' "$LOG" || true
echo "--- errors ---"
grep '\[ERROR\]\|\[PARSE-ERR\]\|\[STDERR\]' "$LOG" || true
echo "--- raw transcript (C->S / S->C) ---"
grep '\[C->S\]\|\[S->C\]' "$LOG" || true
