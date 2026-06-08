\ tests/fmcp_build_result_test.4th — tool-result-node + structuredContent.

require ../fmcp_utils.4th
require ../fmcp_result.4th
fmcp.home-path s" forth-packages/ttester/1.2.1/ttester.4th" fmcp.fs-join required

0 #ERRORS !

T{ fmcp.result-reset
    s" ping" fmcp.result-tool-set
    1 fjson.node-num fmcp.b-id-node !
    s" ok" 0 fmcp.result-pack-node
    fmcp.tool-result-node dup >r 0<> r> fjson.node-free -> -1 }T

#ERRORS @ 0= [IF] ." fmcp_build_result_test OK" cr [ELSE] ." fmcp_build_result_test FAILED" cr [THEN]
