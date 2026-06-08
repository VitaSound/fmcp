\ tests/fmcp_readline_serve_test.4th — pipe serve (skipped under fcov).

require ../fmcp_utils.4th
require ../fmcp_exec.4th
fmcp.home-path s" forth-packages/ttester/1.2.1/ttester.4th" fmcp.fs-join required

0 #ERRORS !

fmcp.under-fcov? [IF]
    cr ." fmcp_readline_serve_test SKIP (under fcov)" cr
[ELSE]

fmcp.home-path 2constant serve-home

: fmcp.serve-inner ( cmd-a cmd-u -- inner-a inner-u )
    s" cd "
    serve-home fmcp.str-concat
    s"  && FMCP_HOME=" fmcp.str-concat
    serve-home fmcp.str-concat
    s"  PATH=$PATH:" fmcp.str-concat
    serve-home fmcp.str-concat
    s" /bin " fmcp.str-concat
    2swap fmcp.str-concat ;

: fmcp.serve-run ( cmd-a cmd-u -- f )
    fmcp.serve-inner
    serve-home 2swap fmcp.run-capture nip nip 0= ;

: fmcp.serve-ping-cmd ( -- a u )
    s" tests/run_serve_ping.sh" ;

: fmcp.serve-line-cmd ( -- a u )
    s" tests/run_serve_pipe.sh" ;

: fmcp.serve-one-cmd ( -- a u )
    s" tests/run_serve_one.sh" ;

: fmcp.serve-stress-cmd ( -- a u )
    s" tests/run_serve_stress.sh 200" ;

: fmcp.serve-contract-cmd ( -- a u )
    s" tests/mcp_tool_result_contract_test.sh" ;

T{ fmcp.serve-ping-cmd fmcp.serve-run -> -1 }T
T{ fmcp.serve-line-cmd fmcp.serve-run -> -1 }T
T{ fmcp.serve-one-cmd fmcp.serve-run -> -1 }T
T{ fmcp.serve-stress-cmd fmcp.serve-run -> -1 }T
T{ fmcp.serve-contract-cmd fmcp.serve-run -> -1 }T

[THEN]

#ERRORS @ 0= [IF] ." fmcp_readline_serve_test OK" cr [ELSE] ." fmcp_readline_serve_test FAILED" cr [THEN]
