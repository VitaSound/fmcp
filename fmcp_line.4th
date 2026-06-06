\ fmcp_line.4th — handle one MCP request from FMCP_LINE env.

require fmcp_mcp.4th

: fmcp.handle-env-line ( -- )
    s" FMCP_LINE" getenv 2dup nip 0= IF
        cr s" [ERROR] FMCP_LINE not set" type cr
        1 (bye)
    THEN
    fmcp.set-line fmcp.mcp-handle-core ;
