# Change Log

All notable changes to fmcp are documented here.

The format is based on [Keep a Changelog](http://keepachangelog.com/) and
this project adheres to [Semantic Versioning](http://semver.org/).

## [Unreleased]

### Changed

- **Layout (fmix-compatible)**: modules moved from `fmcp/` subdir to root (`fmcp_*.4th`);
  `bin/fmcp` sets `$FMCP_HOME` on fpath; `fmcp test` runner (`fmcp_test.4th`).
- **fjson 0.2.3** (`require fjson.4th`): tree parse/emit; `parse-string` uses `str-dup`.
- **`fmcp_build.4th`**: slot-based `fmcp.obj-add-key`; no `>r` / Gforth locals on hot path;
  `fmcp.tool-error-node` stores `b-text` before `b-id`.
- **`fmcp_mcp.4th`**: `fmcp.m-method` (`2variable`); `mcp-handle-core` reads line from
  `fmcp.linea` / `fmcp.lineu`.
- Removed low-level manual JSON concat from response path.

### Fixed

- `initialize` response advertises `capabilities.tools` (required for Cursor MCP tool discovery).
- `bin/fmcp serve` — one long-lived Gforth process (`fmcp_serve.4th`, `fmcp.serve-stdio` + `read-stdin-line`) instead of spawning Gforth per line.
- `fmcp_readline.4th` — fix `c!` store in `read-stdin-line`.
- `bin/fmcp serve` — silence Gforth stderr (`redefined …`) so MCP clients do not treat it as protocol errors.
- `fmcp.line-parse` — remove erroneous `2drop` after `fjson.parse` (parser consumes input).
- `fmcp.object-get-str` / `fmcp.req-str` — `drop` (not `2drop`) when lookup returns `0`.
- `tools/call` — stash request `id` in `fmcp.b-id` before `call-tool`; `tool-result-node` /
  `tool-error-node` no longer take `id` from the stack (exec words leave `project_root` there).
- `fmcp.parse-json` — `set-line` consumes the line; no extra `2drop`.
- `fmcp.param-name` / `fmcp.arg-string` — `rot` before `object-get` (not `swap`).
- `fmcp.serve-one-line` — `set-line` consumes `getenv` result (no `2dup`/`2drop`).
- `fjson.pair-new` without `>r` before `str-dup` (fjson 0.2.3).

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
