\ tests/fmcp_call_tool_test.4th — tools/call dispatch (MCP tool paths).

require ../fmcp_utils.4th
require ../fmcp_mcp.4th
fmcp.home-path s" forth-packages/ttester/1.2.1/ttester.4th" fmcp.fs-join required

0 #ERRORS !

fmcp.project-path 2constant tool-root
2variable fmcp.tcl-name
2variable fmcp.tcl-args

: fmcp.tools-call-line ( name-a name-u args-a args-u -- line-a line-u )
    fmcp.tcl-args 2!
    fmcp.tcl-name 2!
    s\" {\\\"jsonrpc\\\":\\\"2.0\\\",\\\"id\\\":99,\\\"method\\\":\\\"tools/call\\\",\\\"params\\\":{\\\"name\\\":\\\""
    fmcp.tcl-name 2@ fmcp.str-concat
    s\" \\\",\\\"arguments\\\":"
    fmcp.str-concat
    fmcp.tcl-args 2@ fmcp.str-concat
    s\" }}"
    fmcp.str-concat
    s\" }"
    fmcp.str-concat ;

: fmcp.root-args ( -- a u )
    s\" {\\\"project_root\\\":\\\""
    tool-root fmcp.str-concat
    s\" \\\"}"
    fmcp.str-concat ;

: fmcp.args-empty ( -- a u )
    s\" {}"
    ;

: fmcp.args-gforth-eval ( -- a u )
    s\" {\\\"project_root\\\":\\\""
    tool-root fmcp.str-concat
    s\" \\\",\\\"source\\\":\\\"42 . cr\\\"}"
    fmcp.str-concat ;

: fmcp.args-fmix-test ( -- a u )
    s\" {\\\"project_root\\\":\\\""
    tool-root fmcp.str-concat
    s\" \\\",\\\"test_file\\\":\\\"tests/some_test.4th\\\"}"
    fmcp.str-concat ;

: fmcp.args-fcov-run ( -- a u )
    s\" {\\\"project_root\\\":\\\""
    tool-root fmcp.str-concat
    s\" \\\",\\\"test_command\\\":\\\"fmix test\\\"}"
    fmcp.str-concat ;

fmcp.under-fcov? [IF]
    cr ." fmcp_call_tool_test SKIP (under fcov)" cr
[ELSE]

T{ s" gforth_eval" fmcp.args-gforth-eval fmcp.tools-call-line
    fmcp.set-line fmcp.mcp-handle-core depth 0= -> -1 }T

T{ s" fmix_test" fmcp.args-fmix-test fmcp.tools-call-line
    fmcp.set-line fmcp.mcp-handle-core depth 0= -> -1 }T

T{ s" fmix_packages_get" fmcp.root-args fmcp.tools-call-line
    fmcp.set-line fmcp.mcp-handle-core depth 0= -> -1 }T

T{ s" flint_lint" fmcp.root-args fmcp.tools-call-line
    fmcp.set-line fmcp.mcp-handle-core depth 0= -> -1 }T

T{ s" fcov_report" fmcp.root-args fmcp.tools-call-line
    fmcp.set-line fmcp.mcp-handle-core depth 0= -> -1 }T

T{ s" fcov_run" fmcp.args-fcov-run fmcp.tools-call-line
    fmcp.set-line fmcp.mcp-handle-core depth 0= -> -1 }T

T{ s" nope" fmcp.args-empty fmcp.tools-call-line
    fmcp.set-line fmcp.mcp-handle-core depth 0= -> -1 }T

[THEN]

#ERRORS @ 0= [IF] ." fmcp_call_tool_test OK" cr [ELSE] ." fmcp_call_tool_test FAILED" cr [THEN]
