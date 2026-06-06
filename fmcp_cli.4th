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

: fmcp-dispatch
    fmcp.read_args
    fmcp.cmd-arg 2@ s" serve" compare 0= IF
        fmcp.help cr s" Use: fmcp serve (stdio loop)." type cr EXIT
    THEN
    fmcp.cmd-arg 2@ s" test" compare 0= IF fmcp.test EXIT THEN
    fmcp.cmd-arg 2@ s" version" compare 0= IF fmcp.version EXIT THEN
    fmcp.cmd-arg 2@ s" help" compare 0= IF fmcp.help EXIT THEN
    cr s" Unknown command: " type fmcp.cmd-arg 2@ type cr
    fmcp.help
    1 (bye) ;
