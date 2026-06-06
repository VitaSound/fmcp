\ fmcp_tools.4th — MCP tool dispatch.

require fmcp_build.4th
require fmcp_exec.4th

2variable fmcp.tool-t0-ut

: fmcp.tool-begin ( -- )
    utime fmcp.tool-t0-ut 2! ;

: fmcp.tool-elapsed-ms ( -- u )
    utime fmcp.tool-t0-ut 2@ d- d>s 1000 * ;

: fmcp.tool-meta-line ( ec -- a u )
    base @ >r decimal
    swap >r
    fmcp.tool-elapsed-ms fmcp.u>dec
    s" fmcp elapsed_ms=" fmcp.str-concat
    s" exit_code=" fmcp.str-concat
    r> fmcp.u>dec fmcp.str-concat
    r> base ! ;

: fmcp.tool-format-result ( text-a text-u ec -- text-a text-u ec )
    >r
    fmcp.max-output-u fmcp.truncate-text { trunc? }
    trunc? IF
        s\" \nfmcp output truncated" fmcp.str-concat THEN
    r@ fmcp.tool-meta-line
    fmcp.prepend-text
    r> ;

: fmcp.tool-result-final ( text-a text-u ec -- node )
    fmcp.tool-format-result fmcp.tool-result-node ;

: fmcp.call-tool ( -- node )
    fmcp.tool-begin
    fmcp.param-name 2dup nip 0= IF
        2drop s" missing tool name" fmcp.tool-error-node EXIT
    THEN
    2dup s" mcp_ping" compare 0= IF
        2drop fmcp.mcp-ping-text 0 fmcp.tool-result-final EXIT
    THEN
    2dup s" shell_run" compare 0= IF
        2drop
        s" project_root" fmcp.arg-string
        s" command" fmcp.arg-string
        s" timeout_seconds" 10 fmcp.arg-number-default
        fmcp.shell-run fmcp.tool-result-final EXIT
    THEN
    2dup s" fmix_test" compare 0= IF
        2drop
        s" project_root" fmcp.arg-string
        s" test_file" fmcp.arg-string
        fmcp.fmix-test fmcp.tool-result-final EXIT
    THEN
    2dup s" fmix_packages_get" compare 0= IF
        2drop
        s" project_root" fmcp.arg-string
        fmcp.fmix-packages-get fmcp.tool-result-final EXIT
    THEN
    2dup s" flint_lint" compare 0= IF
        2drop
        s" project_root" fmcp.arg-string
        fmcp.flint-lint fmcp.tool-result-final EXIT
    THEN
    2dup s" fcov_run" compare 0= IF
        2drop
        s" project_root" fmcp.arg-string
        s" test_command" fmcp.arg-string
        fmcp.fcov-run fmcp.tool-result-final EXIT
    THEN
    2dup s" fcov_report" compare 0= IF
        2drop
        s" project_root" fmcp.arg-string
        fmcp.fcov-report-json fmcp.tool-result-final EXIT
    THEN
    2dup s" gforth_eval" compare 0= IF
        2drop
        s" project_root" fmcp.arg-string
        s" source" fmcp.arg-string
        s" timeout_seconds" 10 fmcp.arg-number-default
        fmcp.gforth-eval fmcp.tool-result-final EXIT
    THEN
    2drop s" unknown tool" fmcp.tool-error-node ;
