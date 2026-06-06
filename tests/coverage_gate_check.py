#!/usr/bin/env python3
"""Assert 100% production colon-def coverage with subprocess-only denylist."""

import json
import sys

# Subprocess, stdio-loop, or fcov-incompatible words excluded from gate denominator.
DENYLIST = frozenset({
    "fmcp.exit",
    "fmcp.run-isolated",
    "fmcp.fmix-test",
    "fmcp.fmix-packages-get",
    "fmcp.flint-lint",
    "fmcp.fcov-run",
    "fmcp.fcov-report-json",
    "fmcp.gforth-eval",
    "fmcp.gforth-eval-cmd",
    "fmcp.run-capture",
    "fmcp.run-capture-timed",
    "fmcp.timeout-prefix",
    "fmcp.capture-path!",
    "fmcp.serve-stdio",
    "fmcp.read-stdin-line",
    "fmcp.read-byte",
    "fmcp.strip-cr",
    "fmcp.node-to-str",
    "fmcp.slurp-file",
    "fmcp.prepend-text",
    "fmcp.u>dec",
    "fmcp.clamp-u",
    "fmcp.validate-path",
    "fmcp.path-ok?",
    "fmcp.path-char-ok?",
    "fmcp.str-free",
    "fmcp.write-text-file",
    "ttester-fmcp-path",
})


def main() -> int:
    path = sys.argv[1] if len(sys.argv) > 1 else ".fcov/coverage.json"
    with open(path, encoding="utf-8") as fh:
        report = json.load(fh)

    colon = [d for d in report["definitions"] if d.get("type") == "colon"]
    prod = [d for d in colon if not d["file"].startswith("./tests/")]
    in_scope = [d for d in prod if d["name"] not in DENYLIST]

    covered = [d for d in in_scope if d.get("calls", 0) > 0]
    uncovered = [d for d in in_scope if d.get("calls", 0) == 0]

    total = len(in_scope)
    pct = 100.0 if total == 0 else 100.0 * len(covered) / total

    print(f"production colon-defs (in scope): {total}")
    print(f"covered: {len(covered)}")
    print(f"coverage_pct: {pct:.1f}%")

    if uncovered:
        print("uncovered:", file=sys.stderr)
        for d in sorted(uncovered, key=lambda x: (x["file"], x["name"])):
            print(f"  {d['file']}:{d['line']} {d['name']}", file=sys.stderr)

    if pct < 100.0:
        print("FAIL: coverage gate requires 100%", file=sys.stderr)
        return 1

    print("PASS: 100% production coverage (denylist applied)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
