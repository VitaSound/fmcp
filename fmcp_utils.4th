\ fmcp_utils.4th — string helpers and safe shell fragments.

[IFUNDEF] fmcp.str-dup

: fmcp.str-dup { a u -- a-new u }
    u allocate throw { mem }
    a mem u move
    mem u ;

: fmcp.str-concat { a1 u1 a2 u2 -- a3 u3 }
    u1 u2 + allocate throw { mem }
    a1 mem u1 move
    a2 mem u1 + u2 move
    mem u1 u2 + ;

: fmcp.str-free ( a u -- )
    nip dup IF free throw ELSE drop THEN ;

: fmcp.fs-join { path-a path-u name-a name-u -- full-a full-u }
    path-u 1 + name-u + allocate throw { mem }
    path-a mem path-u move
    s" /" drop mem path-u + 1 move
    name-a mem path-u + 1 + name-u move
    mem path-u 1 + name-u + ;

: fmcp.path-char-ok? { c -- f }
    c [char] _ = IF true EXIT THEN
    c [char] - = IF true EXIT THEN
    c [char] . = IF true EXIT THEN
    c [char] / = IF true EXIT THEN
    c bl = IF false EXIT THEN
    c 127 u> IF false EXIT THEN
    c '0 '9 1+ within IF true EXIT THEN
    c 'a 'z 1+ within IF true EXIT THEN
    c 'A 'Z 1+ within ;

: fmcp.path-ok? { addr u -- f }
    dup 0= IF 2drop false EXIT THEN
    addr u 2dup s" .." search >r 2drop 2drop r> IF false EXIT THEN
    true u 0 ?do
        addr i + c@ fmcp.path-char-ok? 0= IF false unloop THEN
    loop ;

: fmcp.validate-path ( addr u -- addr u )
    2dup fmcp.path-ok? 0= IF
        cr s" [ERROR] Invalid path: " type type cr
        1 (bye)
    THEN ;

: fmcp.exit-status ( -- ec )
    $? 8 rshift ;

: fmcp.system-checked ( addr u -- )
    system
    fmcp.exit-status 0<> IF
        cr s" [ERROR] Command failed" type cr
        1 (bye)
    THEN ;

: fmcp.u>dec ( u -- a u )
    base @ >r decimal
    0 <# #s #> r> base ! ;

: fmcp.clamp-u { val lo hi -- u }
    val lo < IF lo EXIT THEN
    val hi > IF hi EXIT THEN
    val ;

: fmcp.prepend-text { pre-a pre-u text-a text-u -- a u }
    pre-a pre-u text-a text-u fmcp.str-concat ;

[THEN]

2variable fmcp.write-text
variable fmcp.write-fid

: fmcp.write-text-file ( path-a path-u text-a text-u -- )
    fmcp.write-text 2!
    w/o create-file throw fmcp.write-fid !
    fmcp.write-text 2@ fmcp.write-fid @ write-file throw
    fmcp.write-fid @ close-file throw ;

: fmcp.tool-home { env-a env-u def-a def-u -- a u }
    env-a env-u getenv 2dup nip IF
        EXIT
    THEN
    2drop
    def-a def-u fmcp.str-dup ;

: fmcp.home-path ( -- addr u )
    s" FMCP_HOME" getenv 2dup nip IF EXIT THEN
    2drop s" HOME" getenv s" /fmcp" fmcp.str-concat ;

: fmcp.project-path ( -- addr u )
    pad 4096 get-dir fmcp.str-dup ;

: fmcp.restore-terminal ( -- )
    s" stty sane 2>/dev/null" system ;

: fmcp.exit ( -- )
    fmcp.restore-terminal
    1 (bye) ;

2variable fmcp.cmd-arg
2variable fmcp.param-arg

: fmcp.read_args
    s" FMCP_CMD" getenv 2dup nip IF
        fmcp.str-dup fmcp.cmd-arg 2!
    ELSE
        2drop s" help" fmcp.cmd-arg 2!
    THEN
    s" FMCP_ARG" getenv 2dup nip IF
        fmcp.str-dup fmcp.param-arg 2!
    ELSE
        2drop s" " fmcp.param-arg 2!
    THEN ;

[IFUNDEF] fmcp.slurp-file
    require fmcp_json.4th
[THEN]
