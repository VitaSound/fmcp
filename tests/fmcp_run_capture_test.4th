\ tests/fmcp_run_capture_test.4th — gforth-eval and timed capture.

require ../fmcp_utils.4th
require ../fmcp_exec.4th
fmcp.home-path s" forth-packages/ttester/1.2.1/ttester.4th" fmcp.fs-join required

0 #ERRORS !

fmcp.project-path 2constant fmcp-test-root

fmcp.under-fcov? [IF]
    cr ." fmcp_run_capture_test SKIP (under fcov)" cr
[ELSE]

T{ fmcp-test-root s" 42 . cr" 10 fmcp.gforth-eval nip nip 0= -> -1 }T
T{ fmcp-test-root s" 10000 ms" 1 fmcp.gforth-eval nip nip 124 = -> -1 }T
T{ fmcp-test-root s" sleep 5" 1 fmcp.fcov-run nip nip 124 = -> -1 }T

[THEN]

#ERRORS @ 0= [IF] ." fmcp_run_capture_test OK" cr [ELSE] ." fmcp_run_capture_test FAILED" cr [THEN]
