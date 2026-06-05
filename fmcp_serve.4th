\ fmcp_serve.4th — MCP stdio loop (one Gforth process for whole session).

require fmcp_mcp.4th
require fmcp_readline.4th

: fmcp.serve-stdio ( -- )
    begin
        fmcp.read-stdin-line dup 0= IF
            2drop 0 (bye)
        THEN
        fmcp.set-line fmcp.mcp-handle-core
    again ;
