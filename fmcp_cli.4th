\ fmcp_cli.4th — CLI help, version, and dispatch (no auto-run).

require fmcp_utils.4th
require fmcp_version.4th
require fmcp_test.4th

: fmcp.help
    cr s" fmcp v" type fmcp-ver-data 2@ type
    s"  — MCP stdio bridge for fmix, flint, fcov" type cr
    s" Usage: fmcp <command>" type cr
    s" Commands:" type cr
    s"    serve          - MCP server on stdin/stdout (for Cursor mcp.json)" type cr
    s"    test [--isolated|--shared] [<test_file>]  - Run *_test.4th in ./tests" type cr
    s"    version        - Show version" type cr
    s"    help           - Show this help" type cr cr
    s" Configure Cursor: command fmcp, args serve, PATH to fmix/flint/fcov bins." type cr
    s" Set FMIX_HOME FLINT_HOME FCOV_HOME as needed." type cr cr ;

: fmcp.version
    cr s" ** (fmcp) v" type fmcp-ver-data 2@ type cr cr ;

\ bin/fmcp serve loads fmcp_serve.4th directly; this path is for
\ FMCP_CMD=serve via fmcp.4th (same message as before).
: fmcp.serve-cli
    fmcp.help cr s" Use: fmcp serve (stdio loop)." type cr ;

\ Look up sd in wid; if found, drop sd, execute the word, return true.
\ Otherwise leave any1+sd and return false.
: obey-wordlist? ( any1 sd wid -- any2 true | any1 sd false )
    >r 2dup r> search-wordlist IF
        nip nip execute true EXIT
    THEN false
;

wordlist constant fmcp.commands
get-current fmcp.commands set-current
    synonym serve   fmcp.serve-cli
    synonym test    fmcp.test
    synonym version fmcp.version
    synonym help    fmcp.help
set-current

: fmcp.dispatch-command ( sd.command -- )
    dup 0= IF 2drop fmcp.help EXIT THEN
    fmcp.commands obey-wordlist? IF EXIT THEN
    cr s" Unknown command: " type type cr
    fmcp.help
    1 (bye)
;

: fmcp-dispatch
    fmcp.read_args
    fmcp.cmd-arg 2@ fmcp.dispatch-command ;
