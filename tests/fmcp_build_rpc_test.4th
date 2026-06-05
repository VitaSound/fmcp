\ tests/fmcp_build_rpc_test.4th — JSON-RPC wrapper.




require ../fmcp_utils.4th
require ../fmcp_build.4th
fmcp.home-path s" forth-packages/ttester/1.2.1/ttester.4th" fmcp.fs-join required

0 #ERRORS !

T{ 0 fjson.node-num fmcp.b-id-node ! ulist-new fmcp.build-obj fmcp.b-result !
    fmcp.build-rpc dup >r 0<> r> fjson.node-free -> -1 }T

#ERRORS @ 0= [IF] ." fmcp_build_rpc_test OK" cr [ELSE] ." fmcp_build_rpc_test FAILED" cr [THEN]
