\ tests/fmcp_coverage_direct_test.4th — in-process fcov targets (no subprocess storm).

require unix/libc.fs
require ../fmcp_utils.4th
require ../fmcp_mcp.4th
require ../fmcp_cli.4th
require ../fmcp_readline.4th
require ../fmcp_serve_line.4th
require ../fmcp_line.4th
require ../fmcp_exec.4th
require ../fmcp_test.4th
fmcp.home-path s" forth-packages/ttester/1.2.1/ttester.4th" fmcp.fs-join required

0 #ERRORS !

fmcp.project-path 2constant cov-root

: fmcp.cov-nope-line ( -- a u )
    s\" {\"jsonrpc\":\"2.0\",\"id\":5,\"method\":\"nope\"}" ;

: fmcp.cov-tool-nope-line ( -- a u )
    s\" {\"jsonrpc\":\"2.0\",\"id\":6,\"method\":\"tools/call\",\"params\":{\"name\":\"nope\",\"arguments\":{}}}" ;

T{ s\" {\\\"jsonrpc\\\":\\\"2.0\\\",\\\"id\\\":1,\\\"method\\\":\\\"ping\\\"}"
    fmcp.set-line fmcp.mcp-handle-core depth 0= -> -1 }T

T{ s\" {\\\"jsonrpc\\\":\\\"2.0\\\",\\\"id\\\":2,\\\"method\\\":\\\"ping\\\"}"
    s" FMCP_LINE" 2swap 1 setenv throw fmcp.serve-one-line depth 0= -> -1 }T

T{ s\" {\\\"jsonrpc\\\":\\\"2.0\\\",\\\"id\\\":4,\\\"method\\\":\\\"ping\\\"}"
    s" FMCP_LINE" 2swap 1 setenv throw fmcp.handle-env-line depth 0= -> -1 }T

T{ s" version" s" FMCP_CMD" 2swap 1 setenv throw
    s" " s" FMCP_ARG" 2swap 1 setenv throw
    fmcp.read_args fmcp.version depth 0= -> -1 }T

T{ s" help" s" FMCP_CMD" 2swap 1 setenv throw
    s" " s" FMCP_ARG" 2swap 1 setenv throw
    fmcp.read_args fmcp.help depth 0= -> -1 }T

T{ s" serve" s" FMCP_CMD" 2swap 1 setenv throw
    s" " s" FMCP_ARG" 2swap 1 setenv throw
    fmcp-dispatch depth 0= -> -1 }T

T{ fmcp.help fmcp.version true -> -1 }T

T{ fmcp.cov-nope-line fmcp.mcp-handle-line depth 0= -> -1 }T

T{ fmcp.cov-tool-nope-line fmcp.mcp-handle-line depth 0= -> -1 }T

T{ fmcp.schema-node@ drop
    fmcp.build-method-not-found drop
    s" bad" fmcp.result-error-node fmcp.tool-result-node drop depth 0= -> -1 }T

T{ s\" {\\\"jsonrpc\\\":\\\"2.0\\\",\\\"method\\\":\\\"notifications/initialized\\\"}"
    fmcp.mcp-handle-line depth 0= -> -1 }T

T{ fmcp.restore-terminal depth 0= -> -1 }T

T{ fmcp.fmix-home nip 0>
    fmcp.flint-home nip 0> and
    fmcp.fcov-home nip 0> and -> -1 }T

T{ fmcp.fmix-home s" fmix" s" test" fmcp.bin-cmd nip 0> -> -1 }T

T{ cov-root s" tests/some_test.4th" fmcp.fs-join fmcp.build-isolated-cmd nip 0> -> -1 }T

fmcp.under-fcov? [IF]
    cov-root s" tests/run_serve_one.sh" fmcp.system-checked
    cov-root s" tests/run_handle_env.sh" fmcp.system-checked
[THEN]

#ERRORS @ 0= [IF] ." fmcp_coverage_direct_test OK" cr [ELSE] ." fmcp_coverage_direct_test FAILED" cr [THEN]
