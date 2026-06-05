\ tests/fmcp_build_list_test.4th — tools/list response tree.




require ../fmcp_utils.4th
require ../fmcp_build.4th
fmcp.home-path s" forth-packages/ttester/1.2.1/ttester.4th" fmcp.fs-join required

0 #ERRORS !

T{ 1 fjson.node-num fmcp.b-id-node ! fmcp.tools-list-node dup 0<> swap drop -> -1 }T

#ERRORS @ 0= [IF] ." fmcp_build_list_test OK" cr [ELSE] ." fmcp_build_list_test FAILED" cr [THEN]
