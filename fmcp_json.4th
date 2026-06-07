\ fmcp_json.4th — fjson 0.2.4 tree parse, build helpers, emit.

[IFUNDEF] fmcp-fjson-loaded
    require forth-packages/fenum/0.1.1/fenum.4th
    require forth-packages/fjson/0.2.4/fjson.4th
    2drop
    true constant fmcp-fjson-loaded
[THEN]

variable fmcp.linea
variable fmcp.lineu
variable fmcp.line-heap
variable fmcp.parse-sa
variable fmcp.parse-su
variable fmcp.parsed-root
variable fmcp.b-id-node
2variable fmcp.m-method
2variable fmcp.arg-key

: fmcp.line-free ( -- )
    fmcp.parsed-root @ ?dup IF fjson.node-free THEN
    0 fmcp.parsed-root !
    fmcp.line-heap @ ?dup IF free throw THEN
    0 fmcp.line-heap !
    0 fmcp.lineu ! 0 fmcp.linea ! ;

: fmcp.line-parse ( linea lineu -- ok )
    fmcp.parse-su !
    fmcp.parse-sa !
    fmcp.line-free
    fmcp.parse-su @ allocate throw fmcp.line-heap !
    fmcp.parse-sa @ fmcp.line-heap @ fmcp.parse-su @ move
    fmcp.line-heap @ fmcp.linea !
    fmcp.parse-su @ fmcp.lineu !
    fmcp.linea @ fmcp.lineu @ fjson.parse fmcp.parsed-root !
    fmcp.parsed-root @ 0= 0= ;

: fmcp.parsed-root@ ( -- node )
    fmcp.parsed-root @ ;

: fmcp.req-get ( key-a key-u -- val-node|0 )
    fmcp.parsed-root@ fjson.object-get ;

: fmcp.req-str ( key-a key-u -- vala valu | 0 0 )
    fmcp.req-get dup 0= IF drop 0 0 EXIT THEN
    fjson.node-str@ ;

: fmcp.json-get-string ( linea lineu keya keyu -- vala valu | 0 0 )
    fjson.key-string ;

: fmcp.json-get-digits ( linea lineu keya keyu -- diga digu | 0 0 )
    fjson.key-digits ;

: fmcp.set-line ( la lu -- )
    fmcp.lineu ! fmcp.linea ! ;

: fmcp.parse-json ( linea lineu -- ok )
    fmcp.set-line
    fmcp.linea @ fmcp.lineu @ fmcp.line-parse ;

: fmcp.sub? ( sa su -- f )
    fmcp.linea @ fmcp.lineu @ 2swap search nip nip 0<> ;

: fmcp.object-get-str ( keya keyu obj -- vala valu | 0 0 )
    fjson.object-get dup 0= IF drop 0 0 EXIT THEN
    fjson.node-str@ ;

: fmcp.mcp-id-node ( -- node )
    s" id" fmcp.req-get ?dup IF
        dup fjson.node-type FJSON_J-NUM = IF
            fjson.node-num@ fjson.node-num
        ELSE
            fjson.node-str@ nip fjson.node-str
        THEN
    ELSE
        drop 0 fjson.node-num
    THEN ;

: fmcp.stash-id ( -- )
    fmcp.mcp-id-node fmcp.b-id-node ! ;

: fmcp.mcp-id-str ( -- ida idu )
    s" id" fmcp.req-get dup 0= IF
        drop s" 0" EXIT
    THEN
    dup fjson.node-type FJSON_J-NUM = IF
        fjson.node-num@ fjson.u>str
    ELSE
        fjson.node-str@
    THEN ;

: fmcp.param-name ( -- na nu | 0 0 )
    s" params" fmcp.req-get dup 0= IF
        drop 0 0 EXIT
    THEN
    s" name" rot fmcp.object-get-str ;

: fmcp.arg-string ( keya keyu -- va vu | 0 0 )
    fmcp.arg-key 2!
    s" params" fmcp.req-get dup 0= IF
        drop 0 0 EXIT
    THEN
    s" arguments" rot fjson.object-get dup 0= IF
        drop 0 0 EXIT
    THEN
    fmcp.arg-key 2@ rot fmcp.object-get-str ;

: fmcp.arg-node ( keya keyu -- node|0 )
    fmcp.arg-key 2!
    s" params" fmcp.req-get dup 0= IF
        drop 0 EXIT
    THEN
    s" arguments" rot fjson.object-get dup 0= IF
        drop 0 EXIT
    THEN
    fmcp.arg-key 2@ rot fjson.object-get ;

: fmcp.arg-number ( keya keyu -- n | 0 )
    fmcp.arg-node dup 0= IF
        drop 0 EXIT
    THEN
    dup fjson.node-type FJSON_J-NUM = IF
        fjson.node-num@ EXIT
    THEN
    fjson.node-str@ dup 0= IF
        2drop 0 EXIT
    THEN
    >number 2drop drop ;

: fmcp.arg-number-default ( keya keyu default -- n )
    >r fmcp.arg-number dup IF
        r> drop EXIT
    THEN
    drop r> ;

[IFUNDEF] fmcp.slurp-file

variable fmcp.slurp-fid
variable fmcp.slurp-u
variable fmcp.slurp-read-u
variable fmcp.slurp-buf

: fmcp.slurp-file ( patha pathu -- bufa bufu | 0 0 )
    r/o open-file throw
    fmcp.slurp-fid !
    fmcp.slurp-fid @ file-size throw d>s dup 0= IF
        drop fmcp.slurp-fid @ close-file throw 0 0 EXIT
    THEN
    fmcp.slurp-u !
    fmcp.slurp-u @ allocate throw fmcp.slurp-buf !
    fmcp.slurp-buf @ fmcp.slurp-u @ fmcp.slurp-fid @ read-file throw drop
    fmcp.slurp-fid @ close-file throw
    fmcp.slurp-buf @ fmcp.slurp-u @ ;

: fmcp.slurp-file-limit ( patha pathu maxu -- bufa bufu limited? )
    { patha pathu maxu }
    patha pathu r/o open-file throw fmcp.slurp-fid !
    fmcp.slurp-fid @ file-size throw d>s
    dup 0= IF
        drop fmcp.slurp-fid @ close-file throw 0 0 false EXIT
    THEN
    dup fmcp.slurp-u !
    maxu swap umin dup fmcp.slurp-read-u !
    fmcp.slurp-read-u @ allocate throw fmcp.slurp-buf !
    fmcp.slurp-buf @ fmcp.slurp-read-u @ fmcp.slurp-fid @ read-file throw drop
    fmcp.slurp-fid @ close-file throw
    fmcp.slurp-u @ fmcp.slurp-read-u @ >
    fmcp.slurp-buf @ fmcp.slurp-read-u @ swap ;

[THEN]

require fmcp_utils.4th

variable fmcp.emit-node
2variable fmcp.json-out-path

: fmcp.json-out-path! ( -- )
    s" /tmp/fmcp-json-"
    getpid fmcp.u>dec fmcp.str-concat
    s" .out" fmcp.str-concat
    fmcp.json-out-path 2! ;

: fmcp.node-to-str ( node -- jsona jsonu )
    fmcp.emit-node !
    fmcp.json-out-path!
    fjson.fid @ >r
    fmcp.json-out-path 2@ w/o create-file throw fjson.fid !
    fmcp.emit-node @ fjson.emit-node
    fmcp.emit-node @ fjson.node-free
    fjson.fid @ close-file throw
    r> fjson.fid !
    fmcp.json-out-path 2@ fmcp.slurp-file dup 0= IF
        s" {}" 2 EXIT
    THEN
    fmcp.json-out-path 2@ delete-file drop ;

: fmcp.emit-node-line ( node -- )
    fjson.emit-to-stdout
    dup fjson.emit-node cr
    stdout flush-file drop
    fjson.node-free ;
