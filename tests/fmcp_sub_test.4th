\ tests/fmcp_sub_test.4th — fmcp.set-line, fmcp.sub?, fmcp.json-get-digits.





require ../fmcp_utils.4th
require ../fmcp_json.4th
fmcp.home-path s" forth-packages/ttester/1.2.1/ttester.4th" fmcp.fs-join required

0 #ERRORS !

T{ s\" {\"method\":\"tools/list\"}" fmcp.set-line
    s\" tools/list" fmcp.sub? -> -1 }T

T{ s\" {\"method\":\"initialize\"}" fmcp.set-line
    s\" tools/list" fmcp.sub? -> 0 }T

T{ s\" {\"jsonrpc\":\"2.0\",\"id\":7,\"method\":\"x\"}" 2dup fmcp.set-line
    s\" \"id\":" fmcp.json-get-digits
    s\" 7" compare -> 0 }T

#ERRORS @ 0= [IF] ." fmcp_sub_test OK" cr [ELSE] ." fmcp_sub_test FAILED" cr [THEN]
