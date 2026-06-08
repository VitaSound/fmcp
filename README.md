# fmcp
[![License](https://img.shields.io/badge/License-COPL-red.svg)](https://raw.githubusercontent.com/VitaSound/fmcp/refs/heads/main/LICENSE)
[![Ver](https://img.shields.io/badge/Ver-0.2.0-green.svg)](https://github.com/VitaSound/fmcp/releases/tag/0.2.0)
[![Cov](https://img.shields.io/badge/Cov-71%25-yellow.svg)](https://github.com/VitaSound/fmcp/actions/workflows/ci.yml)

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

Serve diagnostics logging is **off by default**. Enable with `FMCP_LOG` set to a file path, or `FMCP_LOG=1` / `on` for `$FMCP_HOME/.fmcp/serve.log`. Disable explicitly with `FMCP_LOG=0`, `off`, or `false`. Per-repo tool calls append to `$project_root/.fmcp/tool.log` only when logging is enabled. See [AGENTS.md](AGENTS.md) for post-mortem use after `Connection closed`.

Temporary files under `/tmp/fmcp-*` are removed after each capture and at session end; stale files older than 60 minutes are swept at session start (`FMCP_CLEANUP_TMP=0` to disable).

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

## Using MCP in the agent (Cursor)

After `mcp.json` is set up, enable the server and teach the agent to call it.

### 1. Enable the server

1. **Settings → MCP** — turn on **`vitasound-forth`**.
2. Status must be **connected** (green). If not: **Refresh**, then check paths in `mcp.json` and [doc/API.md](doc/API.md).
3. In chat you can ask: *«List MCP tools from vitasound-forth»* — expect `mcp_ping`, `shell_run`, `fmix_check`, `fmix_test`, `flint_lint`, `fmix_packages_get`, `fcov_run`, `fcov_report`, `gforth_eval`.

### 2. Tell the agent to use MCP (not shell)

Agents do not auto-prefer MCP. Add guidance in the **workspace you code in** (fmix, flint, fcov, …):

**Option A — `AGENTS.md` in that repo** (copy or link the MCP section from [AGENTS.md](AGENTS.md)):

```markdown
## VitaSound tooling

Use MCP server **vitasound-forth** for packages, lint, tests, coverage.
Do not run `fmix test` / `flint` / `fcov` via terminal when MCP tools exist.

Order: `fmix_packages_get` → `fmix_check` (or `fmix_test` + `flint_lint` + optional `fcov_*`).
`project_root` = absolute path to this repo (e.g. `/home/sea/fmix`).
```

**Option B — Cursor rule** (`.cursor/rules/vitasound-forth.mdc` in the target repo):

```markdown
---
description: VitaSound Forth — use fmcp MCP tools
alwaysApply: true
---

Prefer MCP **vitasound-forth**: `fmix_packages_get`, `flint_lint`, `fmix_test`, `fcov_run`, `fcov_report`.
Pass `project_root` as the absolute package path. No ad-hoc shell for the same operations.
```

**Option C — one-off in chat:**

> Use vitasound-forth MCP for tests and lint; `project_root` = `/home/sea/fmix`.

### 3. What the agent should run

| Task | MCP tool | Not this |
|------|----------|----------|
| Fetch deps | `fmix_packages_get` | `fmix packages.get` in shell |
| Lint | `flint_lint` | `flint lint` in shell |
| Tests | `fmix_test` | `fmix test` in shell |
| Coverage | `fcov_run`, `fcov_report` | manual `fcov` CLI |

Full tool params and agent workflow: [AGENTS.md](AGENTS.md).

### 4. Verify without Cursor

```bash
bash tests/smoke_test.sh                    # fmcp protocol
bash tests/mcp_serve_log_test.sh            # serve diagnostics log (SESSION_START, REQ, ping)
bash tests/mcp_cleanup_test.sh              # /tmp/fmcp-* temp cleanup
bash tests/mcp_session_timeout_test.sh    # timeout eval + ping in one session
bash tests/mcp_shell_run_timeout_test.sh  # shell_run sleep + ping in one session
bash tests/mcp_fcov_session_test.sh       # fcov_run timeout + ping in one session
bash tests/test_mcp_smoke.sh              # optional Python reference MCP
```

## Forth style

Follow [frules](https://github.com/VitaSound/frules) (Gforth dialect). See `AGENTS.md`.

## Status

- [x] `initialize`, `tools/list`, `tools/call` over stdio (via [fjson](https://github.com/VitaSound/fjson) read-lite)
- [x] `fmcp_exec.4th` — `fmix_test`, `fmix_packages_get`, `flint_lint`, `fcov_run`, `fcov_report`
- [x] Cursor agent guidance — [AGENTS.md](AGENTS.md), README «Using MCP in the agent»
- [ ] Full E2E with real `FMIX_HOME` tool execution in CI

## Documentation

- [doc/API.md](doc/API.md) — architecture, MCP methods/tools, module map, smoke E2E explained.
- [CHANGELOG.md](CHANGELOG.md) — release history.
- [AGENTS.md](AGENTS.md) — notes for AI agents working on this repo.

## Testing

Two contours — do not mix them in one `fcov run`:

| Contour | Command | Purpose |
|---------|---------|---------|
| **Correctness** | `fmix test` (isolated, default) | Full regression: subprocess CLI, pipe serve, MCP tools |
| **Coverage** | `./tests/coverage_mcp_gate.sh` | fcov instrumentation + shared in-process tests + guards |

```bash
fmcp test                    # or: fmix test  — isolated subprocess per *_test.4th
./tests/coverage_mcp_gate.sh # fcov clean → bin/fmcp test --shared → 100% gate
bash tests/smoke_test.sh     # smoke E2E (stdio protocol, no Cursor)
```

### fcov / coverage rules

- **Before every `fcov run`:** `fcov clean` (or `rm -rf .fcov/calls` if a run was killed). Check size: `du -sh .fcov/calls` — if **> ~100 MB**, subprocess storm; clean before aggregate.
- **Under fcov** (`FCOV_CALLS_LOG` set): subprocess tests skip via `fmcp.under-fcov?` — no nested `fmix test`, `fcov_run`, CLI/pipe serve, or `gforth_eval` storms.
- **Metric:** production colon-defs in `fmcp_*.4th` (not `tests/`); gate denylist excludes subprocess-only words (`fmcp.run-isolated`, `fmcp.serve-stdio`, exec wrappers, etc.) — see `tests/coverage_gate_check.py`.

**Smoke E2E** pipes NDJSON lines into `fmcp serve` and checks grep patterns —
see doc/API.md for details.
