\ fmcp_tools.4th — MCP tool dispatch.

require fmcp_build.4th
require fmcp_exec.4th
require fmcp_log.4th

2variable fmcp.tool-t0-ut

: fmcp.tool-begin ( -- )
    utime fmcp.tool-t0-ut 2! ;

: fmcp.tool-elapsed-ms ( -- u )
    utime fmcp.tool-t0-ut 2@ d- d>s 1000 / ;

: fmcp.tool-meta-line ( ec -- a u )
    >r
    base @ >r decimal
    s" [fmcp] elapsed_ms="
    fmcp.tool-elapsed-ms fmcp.u>dec fmcp.str-concat
    s"  exit_code=" fmcp.str-concat
    r> base !
    r> fmcp.u>dec fmcp.str-concat
    s" \n" fmcp.str-concat ;

: fmcp.tool-format-result ( text-a text-u ec -- text-a text-u ec )
    >r
    fmcp.max-output-u fmcp.truncate-text { trunc? }
    trunc? IF
        s\" \nfmcp output truncated" fmcp.str-concat THEN
    fmcp.capture-truncated @ IF
        s\" \nfmcp output truncated" fmcp.str-concat THEN
    r@ fmcp.tool-meta-line
    2swap fmcp.prepend-text
    r> ;

: fmcp.tool-result-final ( text-a text-u ec -- node )
    >r fmcp.tool-elapsed-ms fmcp.capture-truncated @ r> fmcp.log-tool-end
    fmcp.tool-format-result fmcp.tool-result-node ;

: fmcp.call-tool-dispatch ( -- node )
    fmcp.log-tool-name 2@ s" mcp_ping" compare 0= IF
        fmcp.mcp-ping-text 0 fmcp.tool-result-final
    ELSE fmcp.log-tool-name 2@ s" shell_run" compare 0= IF
        s" project_root" fmcp.arg-string
        s" command" fmcp.arg-string
        s" timeout_seconds" 10 fmcp.arg-number-default
        fmcp.shell-run fmcp.tool-result-final
    ELSE fmcp.log-tool-name 2@ s" fetch_tags" compare 0= IF
        s" project_root" fmcp.arg-string
        s" timeout_seconds" 120 fmcp.arg-number-default
        fmcp.fetch-tags fmcp.tool-result-final
    ELSE fmcp.log-tool-name 2@ s" fmix_test" compare 0= IF
        s" project_root" fmcp.arg-string
        s" test_file" fmcp.arg-string
        s" timeout_seconds" 120 fmcp.arg-number-default
        fmcp.fmix-test fmcp.tool-result-final
    ELSE fmcp.log-tool-name 2@ s" fmix_packages_get" compare 0= IF
        s" project_root" fmcp.arg-string
        s" timeout_seconds" 30 fmcp.arg-number-default
        fmcp.fmix-packages-get fmcp.tool-result-final
    ELSE fmcp.log-tool-name 2@ s" flint_lint" compare 0= IF
        s" project_root" fmcp.arg-string
        s" timeout_seconds" 60 fmcp.arg-number-default
        fmcp.flint-lint fmcp.tool-result-final
    ELSE fmcp.log-tool-name 2@ s" fcov_run" compare 0= IF
        s" project_root" fmcp.arg-string
        s" test_command" fmcp.arg-string
        s" timeout_seconds" 300 fmcp.arg-number-default
        fmcp.fcov-run fmcp.tool-result-final
    ELSE fmcp.log-tool-name 2@ s" fcov_report" compare 0= IF
        s" project_root" fmcp.arg-string
        fmcp.fcov-report-json fmcp.tool-result-final
    ELSE fmcp.log-tool-name 2@ s" gforth_eval" compare 0= IF
        s" project_root" fmcp.arg-string
        s" source" fmcp.arg-string
        s" timeout_seconds" 10 fmcp.arg-number-default
        fmcp.gforth-eval fmcp.tool-result-final
    ELSE
        s" unknown tool" fmcp.tool-error-node
    THEN THEN THEN THEN THEN THEN THEN THEN THEN ;

: fmcp.call-tool ( -- node )
    fmcp.tool-begin
    fmcp.param-name 2dup fmcp.log-tool-name 2! 2drop
    fmcp.log-tool-name 2@ nip 0= IF
        s" missing tool name" fmcp.tool-error-node
    ELSE
        fmcp.log-tool-start
        fmcp.call-tool-dispatch
    THEN ;
