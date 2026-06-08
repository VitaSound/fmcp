# Change Log

All notable changes to fmcp are documented here.

The format is based on [Keep a Changelog](http://keepachangelog.com/) and
this project adheres to [Semantic Versioning](http://semver.org/).

## [Unreleased]

## [0.1.15] - 2026-06-08

### Added
- `tests/fmcp_gaps_test.4th` — poll frags, log, cleanup paths; raises fcov
  baseline from ~65 % to ~71 % under `fcov run fmix test`.
- GitHub Actions CI (Gforth 0.7.9, fmix 0.7.2, `fmix test`).
- License, Ver and Cov badges in `README.md`.

## [0.1.14] - 2026-06-06

### Changed

- **Unified `tools/call` result contract** — every tool returns the same JSON shape in `structuredContent` and `content[0].text`: `tool`, `exit_code`, `elapsed_ms`, `truncated`, `output_bytes`, optional `project_root`, `artifacts[]`, `summary`, `output`. Replaces the old `[fmcp] elapsed_ms=…` text prefix. Module `fmcp_result.4th`; E2E `tests/mcp_tool_result_contract_test.sh`.

## [0.1.13] - 2026-06-08

### Fixed

- **MCP `serve` session drop (`Connection closed`)** — long feco batches (many `mcp_ping` / `fcov_run` in one session) no longer die around request ~23 with Gforth `Stack overflow`. Root cause: `EXIT` from `read-stdin-line`, `mcp-handle-core`, and `call-tool` corrupted the serve loop return stack; mitigated by rewriting those paths without `EXIT`, increasing default Gforth stacks (`GFORTH_DSTACK` / `GFORTH_RSTACK`, default 65536), and hardening tmp cleanup. Stress test: `tests/run_serve_stress.sh`.
- **MCP immediate `Error` on start** — `fmcp.cleanup-stale-tmp` used `system drop` but Gforth `system` leaves no stack value → `Stack underflow` before first request (stderr was hidden unless `FMCP_DEBUG`). Fixed: plain `system`; `bin/fmcp` resolves `GFORTH` to binary path and prints Gforth errors on failure.
- **Per-project tool log junk files** — `fmcp.log-project-append` passed `(line path)` to `log-append-path` instead of `(path line)`, so `cat … >>` created `TOOL_START` / `TOOL_END` files in the workspace root. Fixed with `2swap`; lines append to `project_root/.fmcp/tool.log`. E2E `tests/mcp_project_log_test.sh`.

## [0.1.12] - 2026-06-08

### Added

- **`fmcp_cleanup.4th`** — automatic `/tmp/fmcp-*` lifecycle: sweep stale files (>60 min) at session start, delete pid-scoped capture/eval/json/line temps after each tool and at `SESSION_END`. Disable with `FMCP_CLEANUP_TMP=0`. E2E `tests/mcp_cleanup_test.sh`.

### Changed

- **Serve logging off by default** — set `FMCP_LOG` to a path or `1` / `on` to enable; `bin/fmcp serve` no longer auto-writes `$FMCP_HOME/.fmcp/serve.log`. Shell `SESSION_END` trap runs only when logging is enabled.
- **Pid-scoped temp paths** — `fmcp-eval-<pid>.4th`, `fmcp-json-<pid>.out`; capture `.out`/`.pid`/`.ec`/`.cmd` removed after each run.

### Fixed

- **`fcov_run` default `test_command`** — when omitted, use `bin/fmcp test --shared` for fmcp repos (not bare `fcov run` → `fmix test`, which yields 0% coverage).

## [0.1.11] - 2026-06-08

### Added

- **`fetch_tags` MCP tool** — `project_root` + optional `timeout_seconds`; runs `scripts/fetch-tags.sh` when present (feco), else `git fetch --tags` and reports semver tags / `package.4th` version.

## [0.1.10] - 2026-06-08

### Fixed

- **`fmcp.log-field`** — empty optional values (`test_command` omitted on `fcov_run`) no longer stack-underflow (`val-u nip` + `2drop`).
- **`fmcp.log-tool-root-field`** — restore `pre` before `log-field` (SIGSEGV on `fcov_run` / `flint_lint` after `shell_run` in one serve session).

## [0.1.9] - 2026-06-08

### Fixed

- **`fmcp.line-parse`** — always heap-copy the request line before `fjson.parse` (stable pointers for logging); fix `allocate`/`linea!` stack leaks that broke parsing and tests.
- **`fmcp.log-tool-start`** — Gforth locals must be on the definition line (`log-field`, `log-kv`, …); fix `log-field` after `log-trunc-field` (`2>r` / `2r>`); use `fmcp.log-tool-name` instead of stack args.
- **Second `tools/call` with `FMCP_LOG`** — `shell_run` / `fcov_run` / … no longer SIGSEGV or stack-underflow after `mcp_ping` in the same serve session.

## [0.1.8] - 2026-06-08

### Fixed

- **`fmcp.log-tool-end`** — restore `text/u/ec` on stack for `tool-result-final` (was SIGSEGV / `Connection closed` on every `tools/call` including `mcp_ping`).
- **`TOOL_END out_bytes` field** — drop stray `text-a` before `fmcp.u>dec` (stack corruption / OOM when `FMCP_LOG` enabled).

## [0.1.7] - 2026-06-07

### Fixed

- **`fmcp.mcp-id-str`** — stray literal `1` after `s" 0"` corrupted the stack when logging requests without `id` (e.g. `notifications/initialized`); `fmcp serve` died after `initialize` and Cursor showed **No tools**.

## [0.1.6] - 2026-06-07

### Added

- **Serve diagnostics logging** (`fmcp_log.4th`) — structured lines for `SESSION_START`/`END`, `REQ`/`REQ_DONE`, `TOOL_START`/`TOOL_END`, `PARSE_ERROR`.
  - Global log: `$FMCP_LOG` or `$FMCP_HOME/.fmcp/serve.log` (default for `fmcp serve`; disabled for `fmcp test` unless `FMCP_LOG` is set).
  - Per-repo log: `$project_root/.fmcp/tool.log` (short `TOOL_START`/`TOOL_END` lines when `project_root` is known).
  - `TOOL_START` without matching `TOOL_END` marks the last tool before a crash or `Connection closed`.
- E2E `tests/mcp_serve_log_test.sh`; unit smoke `tests/fmcp_log_test.4th`.

### Changed

- **MCP session crash after many `flint_lint` calls** — cap reads use `fmcp.read-capture-out` (slurp + truncate at `FMCP_MAX_OUTPUT`) so huge lint output no longer grows unbounded; avoid batching many large `flint_lint` results in one serve without restart.

## [0.1.5] - 2026-06-07

### Fixed

- **`fcov_run` / `fmix_test` command build** — Gforth `s" "` is length 0, not a space; use `fmcp.sp$` between `run` and `test_command` (was `runfmix test`).
- **MCP session drop on long `fcov_run` / `fmix_test` / `flint_lint`** — these tools now use background capture + polling (like `gforth_eval` / `shell_run`) with `timeout_seconds` (defaults: fcov 300s, fmix 120s, flint 60s, packages 30s); serve returns JSON on timeout instead of blocking until the client kills the process.

### Added

- Regression test `tests/fmcp_fcov_cmd_test.4th`; E2E `tests/mcp_fcov_session_test.sh` (fcov_run timeout + mcp_ping in one session).

## [0.1.4] - 2026-06-07

### Fixed

- **`shell_run` quoting** — user `command` is written to `/tmp/fmcp-cap-*.cmd` and run via `sh CMDPATH`; arbitrary `'`, `|`, `;` no longer break the capture wrapper.
- **`poll-wait` fail-fast** — dead PID with empty `.ec` returns exit 125 after `read-ec` retry (~1s), not the full `timeout_seconds` wait; fixes MCP stdio blocking on malformed shell commands.
- **`pid-alive?`** — use `kill -0 PID` (not process-group `-PID`) so background capture PIDs are detected correctly.

### Added

- **`mcp_ping` MCP tool** — health check with version and serve pid.
- **`shell_run` MCP tool** — arbitrary shell command in `project_root` (default timeout 10s, max 300s).
- **Background subprocess capture** — `fmcp_poll.4th`, `fmcp.run-capture-bg` (PID poll, adaptive interval, kill → exit 124).
- **Tool observability** — `[fmcp] elapsed_ms=` / `exit_code=` metadata; `FMCP_MAX_OUTPUT` truncation.
- **E2E session tests** — `tests/mcp_session_timeout_test.sh`, `tests/mcp_shell_run_timeout_test.sh`.
- Unit tests: `fmcp_shell_run_test.4th`, `fmcp_shell_run_quotes_test.4th`, `fmcp_poll_test.4th`; `mcp_ping` / `shell_run` in smoke and call_tool tests.
- E2E: `tests/mcp_shell_run_quotes_test.sh` — single-quoted `grep` in one `serve` session.
- **Coverage gate** — `tests/coverage_mcp_gate.sh` + `tests/coverage_gate_check.py` (100% production colon-defs with denylist).
- **fcov guards** — `fmcp.under-fcov?` in `fmcp_utils.4th`; subprocess tests skip under instrumentation.
- **In-process coverage** — `tests/fmcp_coverage_direct_test.4th`, `run_serve_one.sh`, `run_handle_env.sh` (real gforth via `FCOV_REAL_GFORTH`).
- **Subprocess tests** (outside fcov only) — `fmcp_cli_test.4th`, `fmcp_readline_serve_test.4th`, `fmcp_call_tool_test.4th`.

### Changed

- **`gforth_eval`** — uses background capture instead of shell `timeout`; exit 124 on server-side timeout.
- **Tool schemas** — per-tool `inputSchema` (`test_file`, `test_command`, `shell_run` params).
- **`fmcp.slurp-file`** — fix empty-file stack underflow.
- **`fmcp_cli.4th`** — CLI words extracted from `fmcp.4th` for testability.
- **`fmcp_line.4th`** — library-only (no auto-run on `require`).
- **`fmcp_test.4th`** — `FMIX_TEST_ISOLATED` fallback when `FMCP_TEST_ISOLATED` unset (`fmix test --shared` / `fcov run`).
- **`package.4th`** — `key-list fcov-exclude tests/`.

## [0.1.3] - 2026-06-06

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
