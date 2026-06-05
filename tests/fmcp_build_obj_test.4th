\ tests/fmcp_build_obj_test.4th — empty object/array nodes.





require ../fmcp_utils.4th
require ../fmcp_build.4th
fmcp.home-path s" forth-packages/ttester/1.2.1/ttester.4th" fmcp.fs-join required

0 #ERRORS !

T{ ulist-new fmcp.build-obj dup fjson.node-type FJSON_J-OBJ = swap drop -> -1 }T

T{ ulist-new fmcp.build-arr dup fjson.node-type FJSON_J-ARR = swap drop -> -1 }T

#ERRORS @ 0= [IF] ." fmcp_build_obj_test OK" cr [ELSE] ." fmcp_build_obj_test FAILED" cr [THEN]
