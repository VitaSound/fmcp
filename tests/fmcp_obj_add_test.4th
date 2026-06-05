\ tests/fmcp_obj_add_test.4th — fmcp.obj-add via variable slots.





require ../fmcp_utils.4th
require ../fmcp_build.4th
fmcp.home-path s" forth-packages/ttester/1.2.1/ttester.4th" fmcp.fs-join required

0 #ERRORS !

T{ ulist-new fmcp.b-entry !
    s" k" fmcp.obj-key 2!
    s" v" fjson.node-str fmcp.obj-val !
    fmcp.b-entry @ fmcp.obj-lst !
    fmcp.obj-add
    fmcp.b-entry @ ulist-len 1 = -> -1 }T

T{ ulist-new fmcp.b-entry !
    s" a" fmcp.obj-key 2!
    s" b" fjson.node-str fmcp.obj-val !
    fmcp.b-entry @ fmcp.obj-lst !
    fmcp.obj-add
    s" c" fmcp.obj-key 2!
    s" d" fjson.node-str fmcp.obj-val !
    fmcp.b-entry @ fmcp.obj-lst !
    fmcp.obj-add
    fmcp.b-entry @ ulist-len 2 = -> -1 }T

T{ ulist-new fmcp.b-wrap !
    s" x" fmcp.obj-key 2!
    s" y" fjson.node-str fmcp.obj-val !
    fmcp.b-wrap @ fmcp.obj-lst !
    fmcp.obj-add
    fmcp.b-wrap @ ulist-len 1 = -> -1 }T

#ERRORS @ 0= [IF] ." fmcp_obj_add_test OK" cr [ELSE] ." fmcp_obj_add_test FAILED" cr [THEN]
