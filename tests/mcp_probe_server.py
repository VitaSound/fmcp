#!/usr/bin/env python3
"""MCP probe server for Cursor diagnostics.

Writes a full stdio transcript to /tmp/mcp-probe.log (override with MCP_PROBE_LOG).
Enable in ~/.cursor/mcp.json as server "mcp-probe", refresh MCP in Cursor, then inspect the log.

One process: outer wrapper logs every NDJSON line both ways; inner worker is a normal MCP server.
"""

from __future__ import annotations

import datetime
import json
import os
import subprocess
import sys
import threading

LOG_PATH = os.environ.get("MCP_PROBE_LOG", "/tmp/mcp-probe.log")
WORKER_ENV = "MCP_PROBE_WORKER"


def probe_log(kind: str, payload: str) -> None:
    stamp = datetime.datetime.now().isoformat(timespec="milliseconds")
    with open(LOG_PATH, "a", encoding="utf-8") as handle:
        handle.write(f"{stamp} [{kind}] {payload}\n")


def summarize_line(direction: str, line: str) -> None:
    probe_log(direction, line)
    try:
        msg = json.loads(line)
    except json.JSONDecodeError as exc:
        probe_log("PARSE-ERR", f"{direction}: {exc}: {line[:200]}")
        return

    method = msg.get("method")
    msg_id = msg.get("id", "-")
    if method:
        probe_log("METHOD", f"{direction} id={msg_id} method={method}")
    elif "result" in msg:
        result = msg["result"]
        if isinstance(result, dict):
            keys = ",".join(sorted(result.keys())[:8])
            probe_log("RESULT", f"{direction} id={msg_id} keys={keys}")
        else:
            probe_log("RESULT", f"{direction} id={msg_id} type={type(result).__name__}")
    elif "error" in msg:
        err = msg["error"]
        probe_log("ERROR", f"{direction} id={msg_id} code={err.get('code')} msg={err.get('message')}")


def session_start() -> None:
    if os.environ.get("MCP_PROBE_CLEAR") == "1":
        open(LOG_PATH, "w", encoding="utf-8").close()
    probe_log("SESSION", f"start pid={os.getpid()} log={LOG_PATH}")
    probe_log(
        "ENV",
        json.dumps(
            {
                "HOME": os.environ.get("HOME"),
                "USER": os.environ.get("USER"),
                "SHELL": os.environ.get("SHELL"),
                "PATH_head": (os.environ.get("PATH") or "")[:240],
            },
            ensure_ascii=False,
        ),
    )


def run_worker() -> int:
    from mcp.server.fastmcp import FastMCP

    mcp = FastMCP("mcp-probe")

    @mcp.tool()
    def probe_echo(message: str = "ok") -> str:
        """Echo probe — verifies tools/call from Cursor."""
        probe_log("TOOL", f"probe_echo({message!r})")
        return message

    mcp.run(transport="stdio")
    return 0


def pump(label: str, src, dst) -> None:
    try:
        for line in src:
            if line.strip():
                summarize_line(label, line.rstrip("\n"))
            dst.write(line)
            dst.flush()
    finally:
        try:
            dst.close()
        except OSError:
            pass


def run_proxy() -> int:
    session_start()
    env = os.environ.copy()
    env[WORKER_ENV] = "1"
    proc = subprocess.Popen(
        [sys.executable, __file__],
        stdin=subprocess.PIPE,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        env=env,
        text=True,
        bufsize=1,
    )
    assert proc.stdin is not None
    assert proc.stdout is not None
    assert proc.stderr is not None

    def drain_stderr() -> None:
        for line in proc.stderr:
            text = line.rstrip("\n")
            if text:
                probe_log("STDERR", text)

    threading.Thread(target=drain_stderr, daemon=True).start()
    threading.Thread(target=pump, args=("C->S", sys.stdin, proc.stdin), daemon=True).start()
    pump("S->C", proc.stdout, sys.stdout)
    code = proc.wait()
    probe_log("SESSION", f"end exit={code}")
    return code


def main() -> int:
    if os.environ.get(WORKER_ENV) == "1":
        return run_worker()
    return run_proxy()


if __name__ == "__main__":
    raise SystemExit(main())
