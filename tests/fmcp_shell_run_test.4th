\ tests/fmcp_shell_run_test.4th — shell_run capture and timeout.

require ../fmcp_utils.4th
require ../fmcp_exec.4th
fmcp.home-path s" forth-packages/ttester/1.2.1/ttester.4th" fmcp.fs-join required

0 #ERRORS !

fmcp.project-path 2constant fmcp-test-root

fmcp.under-fcov? [IF]
    cr ." fmcp_shell_run_test SKIP (under fcov)" cr
[ELSE]

T{ fmcp-test-root s" echo hello" 10 fmcp.shell-run nip nip 0= -> -1 }T
T{ fmcp-test-root s" sleep 30" 1 fmcp.shell-run nip nip 124 = -> -1 }T

[THEN]

#ERRORS @ 0= [IF] ." fmcp_shell_run_test OK" cr [ELSE] ." fmcp_shell_run_test FAILED" cr [THEN]
