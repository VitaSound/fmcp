\ fmcp_exec.4th — run fmix/flint/fcov in a project directory, capture output.

require fmcp_utils.4th
require fmcp_version.4th
require fmcp_shellfrags.4th
require fmcp_poll.4th

variable fmcp.eval-ec
2variable fmcp.eval-source
2variable fmcp.cap-root
2variable fmcp.cap-inner
2variable fmcp.eval-root
2variable fmcp.eval-source-in
variable fmcp.eval-timeout
variable fmcp.cap-seq
2variable fmcp.cap-out-path
2variable fmcp.cap-pid-path
2variable fmcp.cap-ec-path

: fmcp.max-timeout-u ( -- u )
    s" FMCP_MAX_TIMEOUT" getenv 2dup nip IF
        0 0 2swap >number 2drop drop dup IF
            1 max 300 min EXIT
        THEN
        2drop
    THEN
    2drop 300 ;

: fmcp.clamp-timeout ( timeout-u -- timeout-u )
    1 fmcp.max-timeout-u fmcp.clamp-u
    dup fmcp.max-timeout-u > IF
        drop fmcp.max-timeout-u EXIT
    THEN ;

: fmcp.capture-path! ( -- )
    s" /tmp/fmcp-cap-"
    getpid fmcp.u>dec fmcp.str-concat
    s" -" fmcp.str-concat
    fmcp.cap-seq @ 1+ dup fmcp.cap-seq !
    fmcp.u>dec fmcp.str-concat
    2dup s" .out" fmcp.str-concat fmcp.cap-out-path 2!
    2dup s" .pid" fmcp.str-concat fmcp.cap-pid-path 2!
    s" .ec" fmcp.str-concat fmcp.cap-ec-path 2! ;

: fmcp.touch-empty ( path-a path-u -- )
    w/o create-file throw close-file throw ;

: fmcp.run-capture ( root-a root-u inner-a inner-u -- out-a out-u ec )
    fmcp.cap-inner 2!
    fmcp.cap-root 2!
    fmcp.capture-path!
    fmcp.cap-root 2@ fmcp.validate-path 2drop
    s" cd " fmcp.cap-root 2@ fmcp.str-concat
    s"  && " fmcp.str-concat
    fmcp.cap-inner 2@ fmcp.str-concat
    fmcp.frag-out% fmcp.str-concat
    fmcp.cap-out-path 2@ fmcp.str-concat
    fmcp.frag-redir2% fmcp.str-concat
    system
    fmcp.exit-status >r
    fmcp.restore-terminal
    fmcp.cap-out-path 2@ fmcp.slurp-file
    r> ;

: fmcp.run-capture-bg-start ( -- pid )
    fmcp.cap-root 2@ fmcp.validate-path 2drop
    s" cd " fmcp.cap-root 2@ fmcp.str-concat
    fmcp.frag-sh-c% fmcp.str-concat
    fmcp.frag-squote% fmcp.str-concat
    fmcp.cap-inner 2@ fmcp.str-concat
    fmcp.frag-out% fmcp.str-concat
    fmcp.cap-out-path 2@ fmcp.str-concat
    fmcp.frag-redir2% fmcp.str-concat
    fmcp.frag-ec-echo% fmcp.str-concat
    fmcp.cap-ec-path 2@ fmcp.str-concat
    fmcp.frag-squote% fmcp.str-concat
    fmcp.frag-pid-echo% fmcp.str-concat
    fmcp.cap-pid-path 2@ fmcp.str-concat
    system fmcp.restore-terminal
    fmcp.cap-pid-path 2@ fmcp.read-pid ;

: fmcp.run-capture-bg ( root-a root-u inner-a inner-u timeout-u -- out-a out-u ec )
    fmcp.eval-timeout !
    fmcp.cap-inner 2!
    fmcp.cap-root 2!
    fmcp.eval-timeout @ fmcp.clamp-timeout fmcp.eval-timeout !
    fmcp.eval-timeout @ 0= IF
        fmcp.cap-root 2@ fmcp.cap-inner 2@ fmcp.run-capture EXIT
    THEN
    fmcp.capture-path!
    fmcp.cap-out-path 2@ fmcp.touch-empty
    fmcp.cap-pid-path 2@ fmcp.touch-empty
    fmcp.cap-ec-path 2@ fmcp.touch-empty
    fmcp.run-capture-bg-start fmcp.eval-timeout @
    fmcp.cap-ec-path 2@ fmcp.poll-wait fmcp.eval-ec !
    fmcp.cap-out-path 2@ fmcp.slurp-file
    dup IF
    ELSE 2drop s" " THEN
    fmcp.eval-ec @ ;

: fmcp.gforth-eval-cmd ( -- cmd-a cmd-u )
    s" gforth /tmp/fmcp-eval.4th < /dev/null" ;

: fmcp.timeout-prefix ( timeout-u -- pre-a pre-u )
    fmcp.u>dec s" fmcp timed out after " fmcp.str-concat
    s" seconds" fmcp.str-concat ;

: fmcp.gforth-eval ( root-a root-u source-a source-u timeout-u -- out-a out-u ec )
    fmcp.eval-timeout !
    fmcp.eval-source-in 2!
    fmcp.eval-root 2!
    fmcp.eval-timeout @ fmcp.clamp-timeout fmcp.eval-timeout !
    fmcp.eval-source-in 2@ s"  bye" fmcp.str-concat fmcp.eval-source 2!
    s" /tmp/fmcp-eval.4th" fmcp.eval-source 2@ fmcp.write-text-file
    fmcp.eval-root 2@ fmcp.gforth-eval-cmd fmcp.eval-timeout @
    fmcp.run-capture-bg
    fmcp.eval-ec !
    fmcp.eval-ec @ 124 = IF
        fmcp.eval-timeout @ fmcp.timeout-prefix
        2swap fmcp.prepend-text
    THEN
    fmcp.eval-ec @ ;

: fmcp.shell-run ( root-a root-u cmd-a cmd-u timeout-u -- out-a out-u ec )
    { root-a root-u cmd-a cmd-u timeout-u }
    timeout-u fmcp.eval-timeout !
    root-a root-u fmcp.cap-root 2!
    cmd-u 4096 > IF
        s" fmcp command too long, max 4096 bytes" 1 EXIT
    THEN
    cmd-a cmd-u fmcp.cap-inner 2!
    fmcp.eval-timeout @ fmcp.clamp-timeout fmcp.eval-timeout !
    fmcp.cap-root 2@ fmcp.cap-inner 2@ fmcp.eval-timeout @ fmcp.run-capture-bg
    fmcp.eval-ec !
    fmcp.eval-ec @ 124 = IF
        fmcp.eval-timeout @ fmcp.timeout-prefix
        2swap fmcp.prepend-text
    THEN
    fmcp.eval-ec @ ;

: fmcp.mcp-ping-text ( -- a u )
    s" fmcp ok version " fmcp.str-concat
    fmcp-ver-data 2@ fmcp.str-concat
    s" serve_pid " fmcp.str-concat
    getpid fmcp.u>dec fmcp.str-concat ;

: fmcp.fmix-home ( -- a u )
    s" HOME" getenv s" /fmix" fmcp.str-concat
    s" FMIX_HOME" 2swap fmcp.tool-home ;

: fmcp.flint-home ( -- a u )
    s" HOME" getenv s" /flint" fmcp.str-concat
    s" FLINT_HOME" 2swap fmcp.tool-home ;

: fmcp.fcov-home ( -- a u )
    s" HOME" getenv s" /fcov" fmcp.str-concat
    s" FCOV_HOME" 2swap fmcp.tool-home ;

: fmcp.bin-cmd { home-a home-u tool-a tool-u sub-a sub-u -- cmd-a cmd-u }
    home-a home-u s" /bin/" fmcp.str-concat tool-a tool-u fmcp.str-concat
    s"  " fmcp.str-concat sub-a sub-u fmcp.str-concat ;

: fmcp.fmix-test { root-a root-u test-file-a test-file-u -- }
    fmcp.fmix-home s" fmix" s" " fmcp.bin-cmd
    s" test" fmcp.str-concat
    test-file-a test-file-u nip IF
        s" " fmcp.str-concat test-file-a test-file-u fmcp.str-concat
    THEN
    root-a root-u 2swap fmcp.run-capture ;

: fmcp.fmix-packages-get { root-a root-u -- }
    fmcp.fmix-home s" fmix" s" " fmcp.bin-cmd
    s" packages.get" fmcp.str-concat
    root-a root-u 2swap fmcp.run-capture ;

: fmcp.flint-lint { root-a root-u -- }
    fmcp.flint-home s" flint" s" " fmcp.bin-cmd
    s" lint ." fmcp.str-concat
    root-a root-u 2swap fmcp.run-capture ;

: fmcp.fcov-run { root-a root-u test-cmd-a test-cmd-u -- }
    fmcp.fcov-home s" fcov" s" " fmcp.bin-cmd
    s" run" fmcp.str-concat
    test-cmd-a test-cmd-u nip IF
        s" " fmcp.str-concat test-cmd-a test-cmd-u fmcp.str-concat
    THEN
    root-a root-u 2swap fmcp.run-capture ;

: fmcp.fcov-report-json { root-a root-u -- }
    fmcp.fcov-home s" fcov" s" " fmcp.bin-cmd
    s\" report --format json" fmcp.str-concat
    root-a root-u 2swap fmcp.run-capture ;
