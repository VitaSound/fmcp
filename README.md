# fmcp

MCP stdio bridge for the [VitaSound Forth tooling](https://github.com/VitaSound) family:
**fmix**, **flint**, **fcov**.

Console-only utility (Gforth). `fmcp serve` runs one long-lived Gforth process that
reads newline-delimited JSON-RPC on stdin and writes NDJSON responses on stdout.

## Install

```bash
git clone git@github.com:VitaSound/fmcp.git
cd fmcp && fmix packages.get
```

## Shell setup

Add to `~/.bashrc` (or `~/.zshrc`) — **two lines for this tool only** (do not merge PATH with fmix/flint/fcov):

```bash
export FMCP_HOME="<install-dir>/fmcp"
export PATH="$FMCP_HOME/bin:$PATH"
```

`<install-dir>` is the parent of your clones. fmcp also needs fmix, flint, and fcov on `PATH` — each with its **own** two-line block. Bulk install: [VitaSound/feco](https://github.com/VitaSound/feco) — `./scripts/clone-ecosystem.sh`. Canonical rules: [feco shell setup](https://github.com/VitaSound/feco/blob/main/docs/shell-setup.md).

Then `source ~/.bashrc` and run `fmcp version`.

## Commands

```bash
fmcp help
fmcp version
fmcp serve    # MCP server (for Cursor)
```

## Cursor `mcp.json`

```json
{
  "mcpServers": {
    "vitasound-forth": {
      "command": "fmcp",
      "args": ["serve"],
      "env": {
        "FMIX_HOME": "/home/you/fmix",
        "FLINT_HOME": "/home/you/flint",
        "FCOV_HOME": "/home/you/fcov"
      }
    }
  }
}
```

## Forth style

Follow [frules](https://github.com/VitaSound/frules) (Gforth dialect). See `AGENTS.md`.

## Status

- [x] `initialize`, `tools/list`, `tools/call` over stdio (via [fjson](https://github.com/VitaSound/fjson) read-lite)
- [x] `fmcp_exec.4th` — `fmix_test`, `fmix_packages_get`, `flint_lint`, `fcov_run`, `fcov_report`
- [ ] Cursor skill / full E2E with real `FMIX_HOME` paths in `mcp.json`

## Documentation

- [doc/API.md](doc/API.md) — architecture, MCP methods/tools, module map, smoke E2E explained.
- [CHANGELOG.md](CHANGELOG.md) — release history.
- [AGENTS.md](AGENTS.md) — notes for AI agents working on this repo.

## Testing

```bash
fmcp test
bash tests/smoke_test.sh   # smoke E2E (stdio protocol, no Cursor)
```

**Smoke E2E** pipes NDJSON lines into `fmcp serve` and checks grep patterns —
see doc/API.md for details.
