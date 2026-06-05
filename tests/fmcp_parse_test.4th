\ tests/fmcp_parse_test.4th — inbound tree parse helpers.




require ../fmcp_utils.4th
require ../fmcp_json.4th
fmcp.home-path s" forth-packages/ttester/1.2.1/ttester.4th" fmcp.fs-join required

0 #ERRORS !

T{ s" {}" fmcp.parse-json 0<> -> -1 fmcp.line-free }T

T{ s\" {\"jsonrpc\":\"2.0\",\"method\":\"initialize\"}"
    fmcp.parse-json drop
    s" method" fmcp.req-str s" initialize" compare 0= -> -1
    fmcp.line-free }T

T{ s\" {\"jsonrpc\":\"2.0\",\"id\":42,\"method\":\"x\"}"
    fmcp.parse-json drop
    fmcp.mcp-id-str s" 42" compare 0= -> -1
    fmcp.line-free }T

T{ s\" {\"jsonrpc\":\"2.0\",\"id\":42,\"method\":\"x\"}"
    fmcp.parse-json drop
    fmcp.mcp-id-node fjson.node-type FJSON_J-NUM = -> -1
    fmcp.line-free }T

T{ s\" {\"jsonrpc\":\"2.0\",\"id\":\"7\",\"method\":\"x\"}"
    fmcp.parse-json drop
    fmcp.mcp-id-str s" 7" compare 0= -> -1
    fmcp.line-free }T

T{ s\" {\"jsonrpc\":\"2.0\",\"method\":\"tools/call\",\"params\":{\"name\":\"fmix_test\",\"arguments\":{\"project_root\":\"/tmp\"}}}"
    fmcp.parse-json 0<> -> -1 fmcp.line-free }T

#ERRORS @ 0= [IF] ." fmcp_parse_test OK" cr [ELSE] ." fmcp_parse_test FAILED" cr [THEN]
