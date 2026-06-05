\ fmcp_test.4th — test runner (fmix-compatible layout).

require fmcp_utils.4th

: ttester-project-path ( -- addr u )
    fmcp.project-path s" forth-packages/ttester/1.2.1/ttester.4th" fmcp.fs-join ;

: ttester-fmcp-path ( -- addr u )
    fmcp.home-path s" forth-packages/ttester/1.2.1/ttester.4th" fmcp.fs-join ;

: load-ttester ( -- )
    ttester-project-path
    2dup file-status nip 0= IF
        required
    ELSE
        2drop ttester-fmcp-path required
    THEN ;

load-ttester

2variable test-path
variable wdirid
create test-buff 255 allot
variable fmcp.ERRORS 0 fmcp.ERRORS !
variable fmcp.ERROR 0 fmcp.ERROR !

variable fmcp.test-isolated?
true fmcp.test-isolated? !

: fmcp.read-isolated-mode ( -- )
    s" FMCP_TEST_ISOLATED" getenv 2dup nip 0= IF
        2drop true fmcp.test-isolated? ! EXIT
    THEN
    s" 0" compare 0= IF
        false fmcp.test-isolated? !
    ELSE
        true fmcp.test-isolated? !
    THEN ;

fmcp.read-isolated-mode

: fail-fast-error ( addr u -- )
    s" ERROR" type cr type cr SOURCE TYPE CR
    1 fmcp.ERRORS +!
    1 fmcp.ERROR ! ;

' fail-fast-error ERROR-XT !

: get-test-path test-path 2@ ;

: fmcp.build-isolated-cmd ( file-a file-u -- cmd-a cmd-u )
    s\" TERM=dumb gforth -e 's\" "
    2swap fmcp.str-concat
    s\" \" included bye' </dev/null"
    fmcp.str-concat ;

: fmcp.run-isolated ( file-a file-u -- )
    fmcp.build-isolated-cmd
    2dup system
    drop free throw
    $? 0<> IF
        1 fmcp.ERRORS +!
        1 fmcp.ERROR !
    THEN ;

: test-file-operate
    get-test-path 2swap fmcp.fs-join
    2dup type s"  - " type
    0 fmcp.ERROR !
    fmcp.test-isolated? @ IF
        cr fmcp.run-isolated
    ELSE
        included
    THEN
    fmcp.ERROR @ 0= IF s" OK" type cr THEN ;

: test-file-filter
    2dup s" _test.4th" search
    IF
        2drop s" * Test file: " type test-file-operate
    ELSE
        2drop 2drop
    THEN ;

: test-read-dir
    get-test-path open-dir
    0= IF
        wdirid !
        BEGIN
            test-buff 255 wdirid @ read-dir throw
        WHILE
            test-buff swap test-file-filter
        REPEAT
        wdirid @ close-dir throw
    ELSE
        s" [ERROR] Cannot open ./tests directory" type cr
    THEN ;

: fmcp.test
    fmcp.param-arg 2@
    0= IF
        drop cr s" * Start Tests" type cr
        fmcp.project-path s" tests" fmcp.fs-join test-path 2!
        test-read-dir
    ELSE
        drop cr s" * Start Tests for one file: " type
        fmcp.project-path test-path 2!
        fmcp.param-arg 2@ test-file-operate
    THEN
    fmcp.ERRORS @ 0= IF
        cr s" * All tests passed successfully." type cr
    ELSE
        cr s" * Some tests failed. Total errors: " type
        fmcp.ERRORS @ . cr
        fmcp.exit
    THEN ;
