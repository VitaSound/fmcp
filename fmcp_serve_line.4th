\ fmcp_serve_line.4th — one NDJSON line from FMCP_LINE env (fmcp serve).

require fmcp_mcp.4th

: fmcp.serve-one-line ( -- )
    s" FMCP_LINE" getenv 2dup nip 0= IF
        2drop 1 (bye)
    THEN
    fmcp.set-line fmcp.mcp-handle-core ;
