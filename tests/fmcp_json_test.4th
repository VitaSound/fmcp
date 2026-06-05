\ tests/fmcp_json_test.4th — fjson tree emit + read-lite legacy.




require ../fmcp_utils.4th
require ../fmcp_build.4th
fmcp.home-path s" forth-packages/ttester/1.2.1/ttester.4th" fmcp.fs-join required

0 #ERRORS !

T{ s\" {\"name\":\"fmcp\"}" s\" \"name\":" fmcp.json-get-string
    s" fmcp" compare 0= -> -1 }T

#ERRORS @ 0= [IF] ." fmcp_json_test OK" cr [ELSE] ." fmcp_json_test FAILED" cr [THEN]
