\ fmcp_tools.4th — MCP tool dispatch.

require fmcp_build.4th
require fmcp_exec.4th
require fmcp_log.4th
require fmcp_result.4th

2variable fmcp.tool-t0-ut

: fmcp.tool-begin ( -- )
    utime fmcp.tool-t0-ut 2!
    fmcp.result-reset ;

: fmcp.tool-elapsed-ms ( -- u )
    utime fmcp.tool-t0-ut 2@ d- d>s 1000 / ;

: fmcp.tool-result-final ( text-a text-u ec -- node )
    fmcp.result-project-root-capture
    fmcp.log-tool-name 2@ fmcp.result-tool-set
    fmcp.tool-elapsed-ms fmcp.res-elapsed-ms !
    >r fmcp.tool-elapsed-ms fmcp.capture-truncated @ r> fmcp.log-tool-end
    fmcp.result-pack-node fmcp.tool-result-node ;

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
        s" unknown tool" fmcp.result-error-node fmcp.tool-result-node
    THEN THEN THEN THEN THEN THEN THEN THEN THEN ;

: fmcp.call-tool ( -- node )
    fmcp.tool-begin
    fmcp.param-name 2dup fmcp.log-tool-name 2! 2drop
    fmcp.log-tool-name 2@ nip 0= IF
        s" missing tool name" fmcp.result-error-node fmcp.tool-result-node
    ELSE
        fmcp.log-tool-start
        fmcp.call-tool-dispatch
    THEN ;
