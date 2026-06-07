\ tests/fmcp_shell_run_quotes_test.4th — shell_run with single quotes in command.

require ../fmcp_utils.4th
require ../fmcp_exec.4th
fmcp.home-path s" forth-packages/ttester/1.2.1/ttester.4th" fmcp.fs-join required

0 #ERRORS !

fmcp.project-path 2constant fmcp-test-root

fmcp.under-fcov? [IF]
    cr ." fmcp_shell_run_quotes_test SKIP (under fcov)" cr
[ELSE]

: fmcp.shell-quote-cmd ( -- a u )
    s" echo " s" 'hello'" fmcp.str-concat ;

T{ fmcp-test-root fmcp.shell-quote-cmd 10 fmcp.shell-run nip nip 0= -> -1 }T

[THEN]

#ERRORS @ 0= [IF] ." fmcp_shell_run_quotes_test OK" cr [ELSE] ." fmcp_shell_run_quotes_test FAILED" cr [THEN]
