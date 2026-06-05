\ fmcp_readline.4th — read one line from stdin (MCP NDJSON).
\ Uses stdin read-file (not key) for reliable pipe I/O from Cursor/Electron.
\ Handles CRLF: \r and \n are line ends (not stored); lone \n after \r is skipped.

create fmcp.linebuf 8192 allot
create fmcp.read-byte-buf 1 allot
variable fmcp.linelen

: fmcp.read-byte ( -- c|-1 )
    fmcp.read-byte-buf 1 stdin read-file throw
    dup 0= IF drop -1 EXIT THEN
    fmcp.read-byte-buf c@ ;

: fmcp.strip-cr ( -- )
    begin
        fmcp.linelen @ 0= IF EXIT THEN
        fmcp.linelen @ 1- fmcp.linebuf + c@ 13 = WHILE
        fmcp.linelen @ 1- fmcp.linelen !
    repeat ;

: fmcp.read-stdin-line ( -- a u | 0 0 )
    0 fmcp.linelen !
    begin
        fmcp.read-byte dup -1 = IF
            fmcp.linelen @ dup IF
                nip fmcp.strip-cr fmcp.linebuf swap EXIT
            ELSE 2drop 0 0 EXIT THEN
        THEN
        dup 13 = over 10 = or IF
            2drop fmcp.linelen @ dup IF
                nip fmcp.strip-cr fmcp.linebuf swap EXIT
            THEN
        ELSE
            fmcp.linelen @ 8191 > IF 2drop fmcp.linebuf 8191 EXIT THEN
            dup fmcp.linelen @ fmcp.linebuf + c!
            fmcp.linelen @ 1+ fmcp.linelen !
        THEN
    again ;
