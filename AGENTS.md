# fmcp (AI context)

**Gforth** MCP bridge for VitaSound tools. Coding rules: sibling [frules](../frules) (`rules/forth-dialect-gforth.mdc`, stack effects, factoring).

## Related tools

| Tool | Role |
|------|------|
| fmix | packages.get, test |
| flint | duplicate-def lint (exit 0; grep `[WARN]`) |
| fcov | coverage run/report |
| fsemver | semver pins in package.4th |
| fenum | container helpers |

See also [fmix/AGENTS.md](../fmix/AGENTS.md) for ecosystem workflow.

## Architecture

- `bin/fmcp` — launcher; `serve` runs one long-lived Gforth process (`require fmcp_serve.4th`, `fmcp.serve-stdio`)
- `fmcp_json.4th` — fjson **0.2.4** tree in/out (`line-parse`, `emit-node-line`)
- `fmcp_build.4th` — builders via `fmcp.b-*` / `fmcp.obj-*` slots (no `{ }` / `>r` on hot path)
- `fmcp_mcp.4th` — JSON-RPC dispatch (`mcp-handle-core`)
- `fmcp_exec.4th` — subprocess wrappers for `tools/call`

Legacy/alternate entry points (not used by `bin/fmcp serve`): `fmcp_serve_line.4th` (`FMCP_LINE` env), `fmcp_line.4th`.

## MCP (for AI agents)

Cursor server name in `mcp.json`: **`vitasound-forth`**. The agent sees **tool names** below (not `fmcp` / not shell).

### When to use MCP

Use MCP tools from **vitasound-forth** when working on any VitaSound Forth checkout (fmix, flint, fcov, fmcp, fjson, …). **Do not** invent equivalent shell commands (`fmix test`, `flint lint`, …) if the MCP tool exists.

`project_root` is always the **absolute path** to the package being worked on (e.g. `/home/sea/fmix`), not `FMCP_HOME`.

### Tools

| MCP tool | When | Arguments |
|----------|------|-----------|
| `fmix_packages_get` | After clone, or when `package.4th` / deps changed | `project_root` |
| `flint_lint` | Before commit; after editing `.4th` | `project_root` |
| `fmix_test` | Run unit tests | `project_root`, optional `test_file` |
| `fcov_run` | Coverage collection (when asked) | `project_root`, optional `test_command` |
| `fcov_report` | Coverage JSON report | `project_root` |
| `gforth_eval` | Ad-hoc Gforth snippet in `project_root` | `project_root`, `source`, optional `timeout_seconds` (default 10, max 300) |
| `mcp_ping` | Health check (version, serve pid) | _(none)_ |
| `shell_run` | Shell command in `project_root` | `project_root`, `command`, optional `timeout_seconds` (default 10, max 300) |

### Typical workflow

```text
fmix_packages_get → flint_lint → fmix_test → (optional) fcov_run → fcov_report
```

Use **`gforth_eval`** for quick stack checks instead of shell `gforth`; server enforces timeout (exit 124 → `isError`).

1. **`fmix_packages_get`** — vendored `forth-packages/` must exist before test/lint.
2. **`flint_lint`** — exit 0; grep output for `[WARN]` if reviewing duplicates.
3. **`fmix_test`** — default full suite; pass `test_file` only for a single test.
4. **`fcov_*`** — only when the user asks for coverage.

### Working on fmcp itself

For changes in **this** repo (`fmcp`), `project_root` = `$FMCP_HOME` (fmcp checkout). Still use MCP for consistency, or `fmcp test` / `bash tests/smoke_test.sh` from shell when debugging the bridge.

### If tools are missing

Server not connected: Cursor **Settings → MCP** → `vitasound-forth` must be green → **Refresh**. See [README.md](README.md) for `mcp.json` paths (`FMCP_HOME`, `FMIX_HOME`, `PATH` in `env`).

Optional diagnostics in `tests/`: `test_mcp_smoke.sh`, `mcp_probe_run.sh` (protocol log → `/tmp/mcp-probe.log`).
