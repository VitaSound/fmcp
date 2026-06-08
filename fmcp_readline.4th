\ fmcp_readline.4th — read one line from stdin (MCP NDJSON).
\ Uses stdin read-file (not key) for reliable pipe I/O from Cursor/Electron.
\ Handles CRLF: \r and \n are line ends (not stored); lone \n after \r is skipped.
\ No EXIT in the read loop — EXIT from nested BEGIN/AGAIN corrupts outer DO/BEGIN loops.

create fmcp.linebuf 8192 allot
create fmcp.read-byte-buf 1 allot
variable fmcp.linelen
variable fmcp.read-done
2variable fmcp.read-out

: fmcp.read-byte ( -- c|-1 )
    fmcp.read-byte-buf 1 stdin read-file throw
    dup 0= IF drop -1 ELSE fmcp.read-byte-buf c@ THEN ;

: fmcp.strip-cr ( -- )
    begin
        fmcp.linelen @ 0> IF
            fmcp.linelen @ 1- fmcp.linebuf + c@ 13 =
        ELSE
            false
        THEN
    while
        fmcp.linelen @ 1- fmcp.linelen !
    repeat ;

: fmcp.read-stdin-line ( -- a u | 0 0 )
    0 fmcp.linelen !
    0 fmcp.read-done !
    begin fmcp.read-done @ 0= while
        fmcp.read-byte
        dup -1 = IF
            drop
            fmcp.linelen @ IF
                fmcp.strip-cr
                fmcp.linebuf fmcp.linelen @ fmcp.read-out 2!
            ELSE
                0 0 fmcp.read-out 2!
            THEN
            -1 fmcp.read-done !
        ELSE
            dup 13 = over 10 = or IF
                2drop
                fmcp.linelen @ IF
                    fmcp.strip-cr
                    fmcp.linebuf fmcp.linelen @ fmcp.read-out 2!
                    -1 fmcp.read-done !
                THEN
            ELSE
                fmcp.linelen @ 8191 > IF
                    2drop
                    fmcp.linebuf 8191 fmcp.read-out 2!
                    -1 fmcp.read-done !
                ELSE
                    dup fmcp.linelen @ fmcp.linebuf + c!
                    fmcp.linelen @ 1+ fmcp.linelen !
                    drop
                THEN
            THEN
        THEN
    repeat
    fmcp.read-out 2@ ;
