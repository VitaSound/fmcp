\ tests/fmcp_build_init_test.4th — initialize result tree.





require ../fmcp_utils.4th
require ../fmcp_build.4th
fmcp.home-path s" forth-packages/ttester/1.2.1/ttester.4th" fmcp.fs-join required

0 #ERRORS !

T{ fmcp.build-initialize-result dup >r 0<> r> fjson.node-free -> -1 }T

#ERRORS @ 0= [IF] ." fmcp_build_init_test OK" cr [ELSE] ." fmcp_build_init_test FAILED" cr [THEN]
