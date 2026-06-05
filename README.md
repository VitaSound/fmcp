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

**Which file to edit?** In the UI, Cursor opens the config for your session:

| How you work | File Cursor edits |
|--------------|-------------------|
| **Remote WSL** (workspace under `/home/...`) | `~/.cursor/mcp.json` **inside Linux** — use Linux paths below |
| **Windows app**, code lives in WSL | `%USERPROFILE%\.cursor\mcp.json` on **Windows** — use `wsl.exe` below |

Do not mix them: editing only the Linux file does nothing if Cursor runs MCP on Windows, and vice versa.

### Remote WSL (Cursor opens `/home/you/.cursor/mcp.json`)

```json
{
  "mcpServers": {
    "vitasound-forth": {
      "command": "/home/sea/fmcp/bin/fmcp",
      "args": ["serve"],
      "env": {
        "FMCP_HOME": "/home/sea/fmcp",
        "FMIX_HOME": "/home/sea/fmix",
        "FLINT_HOME": "/home/sea/flint",
        "FCOV_HOME": "/home/sea/fcov",
        "PATH": "/home/sea/fmcp/bin:/home/sea/fmix/bin:/home/sea/flint/bin:/home/sea/fcov/bin:/usr/local/bin:/usr/bin:/bin"
      }
    }
  }
}
```

Adjust `/home/sea/...` if your clones live elsewhere. `"command": "fmcp"` without `PATH` in `env` fails — Cursor does not load `~/.bashrc`.

Optional wrapper (same env baked in): `"command": "/home/sea/fmcp/bin/fmcp-cursor-serve"`, `"args": []`.

### Cursor on Windows + repo in WSL (not Remote)

Cursor runs MCP on **Windows** and cannot use `/home/...` paths directly. Use `wsl.exe` and the wrapper script:

```json
{
  "mcpServers": {
    "vitasound-forth": {
      "command": "C:\\Windows\\System32\\wsl.exe",
      "args": [
        "-d",
        "Ubuntu-22.04",
        "-e",
        "/home/sea/fmcp/bin/fmcp-cursor-serve"
      ]
    }
  }
}
```

Edit `-d` to match `wsl -l -v` (distro name). Adjust the path if your clone is not under `/home/sea/fmcp`.

Config file on Windows: `%USERPROFILE%\.cursor\mcp.json` (e.g. `C:\Users\You\.cursor\mcp.json`).

`bin/fmcp-cursor-serve` exports `FMCP_HOME`, sibling tool homes, `PATH`, then `exec fmcp serve`.

### Cursor connected to WSL (Remote / workspace in Linux)

Same JSON as **Remote WSL** above (`~/.cursor/mcp.json` with Linux paths).

### Linux / explicit env (native Linux, no WSL bridge)

```json
{
  "mcpServers": {
    "vitasound-forth": {
      "command": "/absolute/path/to/fmcp/bin/fmcp",
      "args": ["serve"],
      "env": {
        "FMCP_HOME": "/absolute/path/to/fmcp",
        "FMIX_HOME": "/absolute/path/to/fmix",
        "FLINT_HOME": "/absolute/path/to/flint",
        "FCOV_HOME": "/absolute/path/to/fcov",
        "PATH": "/absolute/path/to/fmcp/bin:/absolute/path/to/fmix/bin:/absolute/path/to/flint/bin:/absolute/path/to/fcov/bin:/usr/local/bin:/usr/bin:/bin"
      }
    }
  }
}
```

Use an **absolute** path for `command`. Cursor does not load your shell `~/.bashrc`, so `"command": "fmcp"` fails unless `fmcp` happens to be on the default PATH.

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
