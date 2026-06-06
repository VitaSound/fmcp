\ fmcp_poll.4th — background subprocess poll, kill by PID.

require fmcp_utils.4th
require fmcp_shellfrags.4th

variable fmcp.poll-timeout-ms
variable fmcp.poll-pid
variable fmcp.poll-read-u
variable fmcp.poll-result
2variable fmcp.poll-start-ut
2variable fmcp.poll-ec-path

: fmcp.ms@ ( -- u )
    utime d>s 1000 * ;

: fmcp.poll-start! ( -- )
    utime fmcp.poll-start-ut 2! ;

: fmcp.poll-elapsed-ms ( -- u )
    utime fmcp.poll-start-ut 2@ d- d>s 1000 / ;

: fmcp.file-u> ( path-a path-u -- u | 0 )
    fmcp.slurp-file dup 0= IF 2drop 0 EXIT THEN
    0 0 2swap >number 2drop drop ;

: fmcp.read-pid ( path-a path-u -- pid )
    0 fmcp.poll-read-u !
    begin
        2dup fmcp.file-u> dup IF fmcp.poll-read-u ! THEN
        fmcp.poll-read-u @ IF 2drop fmcp.poll-read-u @ EXIT THEN
        25 ms
    again ;

: fmcp.read-ec ( -- ec )
    -1 fmcp.poll-read-u !
    40 0 do
        fmcp.poll-ec-path 2@ fmcp.slurp-file dup IF
            0 0 2swap >number 2drop drop fmcp.poll-read-u ! leave
        THEN
        2drop 25 ms
    loop
    fmcp.poll-read-u @ dup 0< IF drop 1 THEN ;

: fmcp.pid-alive? ( pid -- f )
    dup 0= IF drop false EXIT THEN
    negate >r s" kill -0 " r> fmcp.u>dec fmcp.prepend-text
    fmcp.frag-null% fmcp.str-concat
    system fmcp.exit-status 0= ;

: fmcp.pid-kill ( pid -- )
    dup 0= IF drop EXIT THEN
    fmcp.poll-pid !
    fmcp.poll-pid @ negate >r s" kill -TERM " r> fmcp.u>dec fmcp.prepend-text
    fmcp.frag-null% fmcp.str-concat
    system
    fmcp.poll-pid @ >r s" pkill -TERM -P " r> fmcp.u>dec fmcp.prepend-text
    fmcp.frag-null% fmcp.str-concat
    system
    10 0 do
        fmcp.poll-pid @ fmcp.pid-alive? 0= IF
            unloop EXIT
        THEN
        100 ms
    loop
    fmcp.poll-pid @ negate >r s" kill -KILL " r> fmcp.u>dec fmcp.prepend-text
    fmcp.frag-null% fmcp.str-concat
    system
    fmcp.poll-pid @ >r s" pkill -KILL -P " r> fmcp.u>dec fmcp.prepend-text
    fmcp.frag-null% fmcp.str-concat
    system ;

: fmcp.poll-interval-ms ( elapsed-ms remaining-ms -- interval-ms )
    swap >r
    dup 1001 < IF drop r> drop 100 EXIT THEN
    drop
    r@ 500 < IF r> drop 50 EXIT THEN
    r@ 2000 < IF r> drop 200 EXIT THEN
    r@ 10000 < IF r> drop 500 EXIT THEN
    r@ 60000 < IF r> drop 1000 EXIT THEN
    r> dup 5000 > IF drop 5000 THEN
    4 / ;

: fmcp.poll-wait ( pid timeout-u ec-path-a ec-path-u -- ec )
    fmcp.poll-ec-path 2!
    swap fmcp.poll-pid !
    1000 * fmcp.poll-timeout-ms !
    fmcp.poll-start!
    -1 fmcp.poll-result !
    begin
        fmcp.poll-elapsed-ms fmcp.poll-timeout-ms @ >= IF
            fmcp.poll-pid @ fmcp.pid-kill fmcp.restore-terminal
            124 fmcp.poll-result !
        THEN
        fmcp.poll-result @ -1 = IF
            fmcp.poll-pid @ fmcp.pid-alive? 0= IF
                fmcp.poll-ec-path 2@ fmcp.slurp-file dup 0= IF
                    2drop
                ELSE
                    0 0 2swap >number 2drop drop fmcp.poll-result !
                THEN
            THEN
        THEN
        fmcp.poll-result @ -1 = IF
            fmcp.poll-elapsed-ms dup fmcp.poll-timeout-ms @ swap -
            fmcp.poll-interval-ms ms
        THEN
        fmcp.poll-result @ -1 <>
    until
    fmcp.poll-result @ ;
