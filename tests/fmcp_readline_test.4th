\ tests/fmcp_readline_test.4th — CRLF stdin lines.




require ../fmcp_utils.4th
require ../fmcp_mcp.4th
fmcp.home-path s" forth-packages/ttester/1.2.1/ttester.4th" fmcp.fs-join required

0 #ERRORS !

\ Cannot easily inject stdin in ttester; verify parse accepts line without trailing CR.
T{ s\" {\"jsonrpc\":\"2.0\",\"id\":1,\"method\":\"initialize\"}"
    fmcp.parse-json 0<> -> -1 fmcp.line-free }T

#ERRORS @ 0= [IF] ." fmcp_readline_test OK" cr [ELSE] ." fmcp_readline_test FAILED" cr [THEN]
