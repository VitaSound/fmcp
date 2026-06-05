\ tests/fmcp_dispatch_test.4th — mcp-handle-line (one request per process).





require ../fmcp_utils.4th
require ../fmcp_mcp.4th
fmcp.home-path s" forth-packages/ttester/1.2.1/ttester.4th" fmcp.fs-join required

0 #ERRORS !

T{ s\" {\"jsonrpc\":\"2.0\",\"id\":1,\"method\":\"initialize\"}"
    fmcp.set-line fmcp.mcp-handle-core depth 0= -> -1 }T

T{ s\" {\"jsonrpc\":\"2.0\",\"id\":2,\"method\":\"ping\"}"
    fmcp.set-line fmcp.mcp-handle-core depth 0= -> -1 }T

T{ s\" {\"jsonrpc\":\"2.0\",\"id\":3,\"method\":\"resources/list\"}"
    fmcp.set-line fmcp.mcp-handle-core depth 0= -> -1 }T

#ERRORS @ 0= [IF] ." fmcp_dispatch_test OK" cr [ELSE] ." fmcp_dispatch_test FAILED" cr [THEN]
