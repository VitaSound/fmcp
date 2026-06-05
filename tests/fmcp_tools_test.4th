\ tests/fmcp_tools_test.4th — parse tools/list id.




require ../fmcp_utils.4th
require ../fmcp_mcp.4th
fmcp.home-path s" forth-packages/ttester/1.2.1/ttester.4th" fmcp.fs-join required

0 #ERRORS !

T{ s\" {\"jsonrpc\":\"2.0\",\"id\":42,\"method\":\"tools/list\"}"
    fmcp.parse-json drop
    fmcp.mcp-id-str s" 42" compare 0= -> -1
    fmcp.line-free }T

#ERRORS @ 0= [IF] ." fmcp_tools_test OK" cr [ELSE] ." fmcp_tools_test FAILED" cr [THEN]
