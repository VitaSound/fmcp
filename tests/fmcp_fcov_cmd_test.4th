\ tests/fmcp_fcov_cmd_test.4th — fcov_run command spacing and default test_command.

require ../fmcp_utils.4th
require ../fmcp_version.4th
require ../fmcp_exec.4th
fmcp.home-path s" forth-packages/ttester/1.2.1/ttester.4th" fmcp.fs-join required

0 #ERRORS !

fmcp.project-path 2constant fmcp-fcov-test-root

: fmcp.fcov-run-cmd-empty ( -- a u )
    fmcp.fcov-home s" fcov" s" " fmcp.bin-cmd
    s" run" fmcp.str-concat
    fmcp.sp$ fmcp.str-concat
    fmcp-fcov-test-root fmcp.fcov-default-cmd
    fmcp.str-concat ;

: fmcp.fcov-run-cmd-fmix ( -- a u )
    fmcp.fcov-home s" fcov" s" " fmcp.bin-cmd
    s" run" fmcp.str-concat
    fmcp.sp$ fmcp.str-concat
    s" fmix test" fmcp.str-concat ;

: fmcp.fcov-cmd-has? ( pat-a pat-u cmd-a cmd-u -- f )
    search nip nip 0<> ;

T{ fmcp.fcov-run-cmd-fmix s" run fmix" fmcp.fcov-cmd-has? -> -1 }T
T{ fmcp.fcov-run-cmd-fmix s" runfmix" fmcp.fcov-cmd-has? -> 0 }T
T{ fmcp.fcov-run-cmd-empty s" bin/fmcp test --shared" fmcp.fcov-cmd-has? -> -1 }T
T{ fmcp-fcov-test-root fmcp.fcov-default-cmd
    s" bin/fmcp test --shared" compare 0= -> -1 }T

#ERRORS @ 0= [IF] ." fmcp_fcov_cmd_test OK" cr [ELSE] ." fmcp_fcov_cmd_test FAILED" cr [THEN]
