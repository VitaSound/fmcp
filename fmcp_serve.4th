\ fmcp_serve.4th — MCP stdio loop (one Gforth process for whole session).

require fmcp_mcp.4th
require fmcp_readline.4th
require fmcp_log.4th

: fmcp.serve-stdio ( -- )
    fmcp.log-session-start
    begin
        fmcp.read-stdin-line dup 0= IF
            2drop
            s" stdin_eof" fmcp.log-session-end
            0 (bye)
        THEN
        fmcp.set-line fmcp.mcp-handle-core
    again ;
