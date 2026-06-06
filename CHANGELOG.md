# Change Log

All notable changes to fmcp are documented here.

The format is based on [Keep a Changelog](http://keepachangelog.com/) and
this project adheres to [Semantic Versioning](http://semver.org/).

## [Unreleased]

### Fixed

- **`fmcp.run-capture`** — capture temp paths include process id (`/tmp/fmcp-cap-<pid>-<n>.out`);
  nested `gforth_eval` during `fmix_test` no longer truncates the parent capture file
  (was `Terminated.` / null bytes / truncated test listing in MCP output).

## [0.1.2] - 2026-06-06

### Added

- **`gforth_eval` MCP tool** — evaluate a Gforth snippet in `project_root` with server-side
  `timeout` (default 10s, max 300s); exit 124 → `[fmcp] timed out after Ns` and `isError: true`.
- **`fmcp.exit-status`** — normalize Gforth `$?` after `system` (wait status >> 8).
- Unit tests: `fmcp_run_capture_test.4th`, `fmcp_json_args_test.4th`; smoke covers `gforth_eval`.

### Changed

- **`fmcp.run-capture`** — use plain `system` (non-zero exit preserved); avoid Gforth output
  locals that leaked stack cells to callers.

## [0.1.1] - 2026-06-06

### Fixed

- **Cursor MCP connect** — upgrade **fjson 0.2.4** so `initialize` with JSON booleans
  (`listChanged: false`) parses; previously dropped silently with 0-byte reply.
- **`initialize` protocolVersion** — respond with `2025-11-25` (Cursor expectation).
- **`fmcp.emit-node-line`** — restore NDJSON (`cr` + flush); broken Content-Length framing
  emitted literal `\r\n` text and broke stdio clients.
- **`bin/fmcp serve`** — skip `reset_tty` on serve (stdin is a pipe, not a TTY).

### Added

- **`bin/fmcp-cursor-serve`** — wrapper with `FMCP_HOME`, sibling tool homes, and `PATH`.
- **README** — Cursor `mcp.json` examples (Remote WSL, Windows+WSL, native Linux).
- **Smoke E2E** — Cursor-exact handshake (`id: 0`, `false` in capabilities).
- **Diagnostic Python MCP** in `tests/`: `test_mcp_*`, `mcp_probe_*` (optional Cursor compare).

### Changed

- **fjson** dependency pin `0.2.3` → `0.2.4` in `package.4th`.

## [0.1.0] - 2026-06-04

Initial public release. MCP stdio bridge exposing VitaSound Forth tools
(fmix, flint, fcov) to Cursor and other MCP clients.

### Added

- **`fmcp serve`** — newline-delimited JSON-RPC on stdin; each line handled
  in Gforth via `FMCP_LINE` (bash loop in `bin/fmcp` is I/O only).
- **MCP methods**: `initialize`, `notifications/initialized`, `tools/list`,
  `tools/call` (`fmcp/mcp.4th`).
- **Tools** (`fmcp/exec.4th`, `fmcp/tools.4th`):
  `fmix_test`, `fmix_packages_get`, `flint_lint`, `fcov_run`, `fcov_report`.
- **JSON** via vendored [fjson](https://github.com/VitaSound/fjson) read-lite
  (`fmcp/json.4th`); removed inline json-lite parser.
- Smoke E2E: `tests/smoke_test.sh` (initialize, tools/list, unknown tool).
- Unit tests: `fmcp_json_test.4th`, `fmcp_sub_test.4th`, `fmcp_tools_test.4th`.
- `AGENTS.md` for agent/Cursor contributors.
- ttester **1.2.1** in `package.4th`.

### Known limitations

- `fmcp.json-escape-text` does not yet escape `"` in tool result text
  (uses `fjson.str-dup` only).
- Full Cursor E2E with real `FMIX_HOME` tool execution not automated in CI.
