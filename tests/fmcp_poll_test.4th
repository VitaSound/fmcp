\ tests/fmcp_poll_test.4th — read-pid and poll helpers.

require ../fmcp_utils.4th
require ../fmcp_poll.4th
fmcp.home-path s" forth-packages/ttester/1.2.1/ttester.4th" fmcp.fs-join required

0 #ERRORS !

fmcp.under-fcov? [IF]
    cr ." fmcp_poll_test SKIP (under fcov)" cr
[ELSE]

: fmcp.poll-test-pid-path ( -- a u )
    s" /tmp/fmcp-poll-test.pid" ;

T{ fmcp.poll-test-pid-path s" 4242" fmcp.write-text-file
    fmcp.poll-test-pid-path fmcp.read-pid 4242 = -> -1 }T

: fmcp.poll-test-dead-ec-path ( -- a u )
    s" /tmp/fmcp-poll-test-dead.ec" ;

T{ fmcp.poll-test-dead-ec-path s" " fmcp.write-text-file
    0 2 fmcp.poll-test-dead-ec-path fmcp.poll-wait 125 = -> -1 }T

[THEN]

#ERRORS @ 0= [IF] ." fmcp_poll_test OK" cr [ELSE] ." fmcp_poll_test FAILED" cr [THEN]
