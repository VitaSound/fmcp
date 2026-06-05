\ fmcp_tools.4th — MCP tool dispatch.

require fmcp_build.4th
require fmcp_exec.4th

: fmcp.call-tool ( -- node )
    fmcp.param-name 2dup nip 0= IF
        2drop s" missing tool name" fmcp.tool-error-node EXIT
    THEN
    2dup s" fmix_test" compare 0= IF
        2drop
        s" project_root" fmcp.arg-string
        s" test_file" fmcp.arg-string
        fmcp.fmix-test fmcp.tool-result-node EXIT
    THEN
    2dup s" fmix_packages_get" compare 0= IF
        2drop
        s" project_root" fmcp.arg-string
        fmcp.fmix-packages-get fmcp.tool-result-node EXIT
    THEN
    2dup s" flint_lint" compare 0= IF
        2drop
        s" project_root" fmcp.arg-string
        fmcp.flint-lint fmcp.tool-result-node EXIT
    THEN
    2dup s" fcov_run" compare 0= IF
        2drop
        s" project_root" fmcp.arg-string
        s" test_command" fmcp.arg-string
        fmcp.fcov-run fmcp.tool-result-node EXIT
    THEN
    2dup s" fcov_report" compare 0= IF
        2drop
        s" project_root" fmcp.arg-string
        fmcp.fcov-report-json fmcp.tool-result-node EXIT
    THEN
    2drop s" unknown tool" fmcp.tool-error-node ;
