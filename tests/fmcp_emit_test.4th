\ tests/fmcp_emit_test.4th — emit-node-line stack balance.





require ../fmcp_utils.4th
require ../fmcp_build.4th
fmcp.home-path s" forth-packages/ttester/1.2.1/ttester.4th" fmcp.fs-join required

0 #ERRORS !

T{ 1 fjson.node-num fmcp.b-id-node ! s" x" 0 fmcp.tool-result-node fmcp.emit-node-line depth 0= -> -1 }T

#ERRORS @ 0= [IF] ." fmcp_emit_test OK" cr [ELSE] ." fmcp_emit_test FAILED" cr [THEN]
