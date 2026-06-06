\ tests/fmcp_cli_test.4th — CLI subprocess (skipped under fcov).

require ../fmcp_utils.4th
require ../fmcp_exec.4th
fmcp.home-path s" forth-packages/ttester/1.2.1/ttester.4th" fmcp.fs-join required

0 #ERRORS !

fmcp.under-fcov? [IF]
    cr ." fmcp_cli_test SKIP (under fcov)" cr
[ELSE]

fmcp.home-path 2constant cli-home

: fmcp.cli-inner ( cmd-a cmd-u -- inner-a inner-u )
    s" cd "
    cli-home fmcp.str-concat
    s"  && FMCP_HOME=" fmcp.str-concat
    cli-home fmcp.str-concat
    s"  PATH=$PATH:" fmcp.str-concat
    cli-home fmcp.str-concat
    s" /bin " fmcp.str-concat
    2swap fmcp.str-concat ;

: fmcp.cli-run ( cmd-a cmd-u -- ec )
    fmcp.cli-inner
    cli-home 2swap fmcp.run-capture nip nip ;

: fmcp.cli-version-cmd ( -- a u )
    s" fmcp version" ;

: fmcp.cli-help-cmd ( -- a u )
    s" fmcp help" ;

: fmcp.cli-test-one-cmd ( -- a u )
    s" fmcp test tests/some_test.4th" ;

: fmcp.cli-test-shared-cmd ( -- a u )
    s" fmcp test --shared tests/some_test.4th" ;

: fmcp.cli-unknown-cmd ( -- a u )
    s" fmcp nope" ;

T{ fmcp.cli-version-cmd fmcp.cli-run 0= -> -1 }T
T{ fmcp.cli-help-cmd fmcp.cli-run 0= -> -1 }T
T{ fmcp.cli-test-one-cmd fmcp.cli-run 0= -> -1 }T
T{ fmcp.cli-test-shared-cmd fmcp.cli-run 0= -> -1 }T
T{ fmcp.cli-unknown-cmd fmcp.cli-run 0<> -> -1 }T

[THEN]

#ERRORS @ 0= [IF] ." fmcp_cli_test OK" cr [ELSE] ." fmcp_cli_test FAILED" cr [THEN]
