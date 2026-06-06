\ tests/fmcp_json_args_test.4th — arg-number-default.

require ../fmcp_utils.4th
require ../fmcp_json.4th
fmcp.home-path s" forth-packages/ttester/1.2.1/ttester.4th" fmcp.fs-join required

0 #ERRORS !

s\" {\"jsonrpc\":\"2.0\",\"id\":1,\"method\":\"tools/call\",\"params\":{\"name\":\"gforth_eval\",\"arguments\":{\"timeout_seconds\":25}}}"
fmcp.line-parse drop

T{ s" timeout_seconds" 10 fmcp.arg-number-default 25 = -> -1 }T

s\" {\"jsonrpc\":\"2.0\",\"id\":1,\"method\":\"tools/call\",\"params\":{\"name\":\"gforth_eval\",\"arguments\":{}}}"
fmcp.line-parse drop

T{ s" timeout_seconds" 10 fmcp.arg-number-default 10 = -> -1 }T

s\" {\"jsonrpc\":\"2.0\",\"id\":1,\"method\":\"tools/call\",\"params\":{\"name\":\"gforth_eval\",\"arguments\":{\"project_root\":\"/tmp\",\"source\":\"1\"}}}"
fmcp.line-parse drop

T{ s" project_root" fmcp.arg-string nip 0> -> -1 }T
T{ s" missing_key" fmcp.arg-string nip 0= -> -1 }T

#ERRORS @ 0= [IF] ." fmcp_json_args_test OK" cr [ELSE] ." fmcp_json_args_test FAILED" cr [THEN]
