\ tests/fmcp_fcov_cmd_test.4th — fcov_run command must contain "run fmix", not "runfmix".

require ../fmcp_utils.4th
require ../fmcp_version.4th
require ../fmcp_exec.4th
fmcp.home-path s" forth-packages/ttester/1.2.1/ttester.4th" fmcp.fs-join required

0 #ERRORS !

fmcp.under-fcov? [IF]
    cr ." fmcp_fcov_cmd_test SKIP (under fcov)" cr
[ELSE]

: fmcp.fcov-run-cmd ( -- a u )
    fmcp.fcov-home s" fcov" s" " fmcp.bin-cmd
    s" run" fmcp.str-concat
    fmcp.sp$ fmcp.str-concat
    s" fmix test" fmcp.str-concat ;

: fmcp.fcov-cmd-has? ( pat-a pat-u -- f )
    fmcp.fcov-run-cmd 2swap search nip nip 0<> ;

T{ s" run fmix" fmcp.fcov-cmd-has? -> -1 }T
T{ s" runfmix" fmcp.fcov-cmd-has? -> 0 }T

[THEN]

#ERRORS @ 0= [IF] ." fmcp_fcov_cmd_test OK" cr [ELSE] ." fmcp_fcov_cmd_test FAILED" cr [THEN]
