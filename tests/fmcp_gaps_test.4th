\ tests/fmcp_gaps_test.4th — in-process coverage for poll, frags, log, tools, cleanup.

require ../fmcp_utils.4th
require ../fmcp_shellfrags.4th
require ../fmcp_poll.4th
require ../fmcp_cleanup.4th
require ../fmcp_result.4th
require ../fmcp_log.4th
fmcp.home-path s" forth-packages/ttester/1.2.1/ttester.4th" fmcp.fs-join required

0 #ERRORS !

: fmcp.gap-test-frags
    fmcp.frag-out% 2drop
    fmcp.frag-redir2% 2drop
    fmcp.frag-null% 2drop
    fmcp.frag-ec-echo% 2drop
    fmcp.frag-sh-c% 2drop
    fmcp.frag-squote% 2drop
    fmcp.frag-pid-echo% 2drop ;

T{ fmcp.gap-test-frags depth 0= -> -1 }T

T{ 500 1000 fmcp.poll-interval-ms 100 = -> -1 }T

T{ s" /tmp/fmcp-gap.pid" s" 4242" fmcp.write-text-file
    s" /tmp/fmcp-gap.pid" fmcp.file-u> 4242 = -> -1 }T

: fmcp.gap-test-log
    s" /tmp/fmcp-gap-serve.log" s" FMCP_LOG" 2swap 1 setenv throw
    fmcp.log-session-start
    s" test-end" fmcp.log-session-end ;

T{ fmcp.gap-test-log depth 0= -> -1 }T

T{ fmcp.cleanup-own-tmp depth 0= -> -1 }T

T{ s" /tmp/fmcp-gap-proj" fmcp.log-project-root-set
    s" line" fmcp.log-project-append depth 0= -> -1 }T

: report
    s" /tmp/fmcp-gap.pid" delete-file drop
    s" /tmp/fmcp-gap-serve.log" delete-file drop
    #ERRORS @ 0= IF
        ." fmcp_gaps_test OK" cr
    ELSE
        ." fmcp_gaps_test FAILED" cr
    THEN ;
report
bye
