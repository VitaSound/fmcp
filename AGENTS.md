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

## MCP

Prefer `fmcp serve` tools over inventing shell commands. Typical order: `fmix_packages_get` → `flint_lint` → `fmix_test` → optional `fcov_*`.
