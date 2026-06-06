\ fmcp_exec.4th — run fmix/flint/fcov in a project directory, capture output.

require fmcp_utils.4th

variable fmcp.eval-ec
2variable fmcp.eval-source
2variable fmcp.cap-root
2variable fmcp.cap-inner
2variable fmcp.eval-root
2variable fmcp.eval-source-in
variable fmcp.eval-timeout

: fmcp.run-capture ( root-a root-u inner-a inner-u -- out-a out-u ec )
    fmcp.cap-inner 2!
    fmcp.cap-root 2!
    fmcp.cap-root 2@ fmcp.validate-path 2drop
    s" cd " fmcp.cap-root 2@ fmcp.str-concat
    s"  && " fmcp.str-concat
    fmcp.cap-inner 2@ fmcp.str-concat
    s"  > /tmp/fmcp-capture.out 2>&1" fmcp.str-concat
    system
    s" /tmp/fmcp-capture.out" fmcp.slurp-file
    fmcp.exit-status ;

: fmcp.run-capture-timed ( root-a root-u inner-a inner-u timeout-u -- out-a out-u ec )
    fmcp.eval-timeout !
    fmcp.cap-inner 2!
    fmcp.cap-root 2!
    fmcp.eval-timeout @ 0= IF
        fmcp.cap-root 2@ fmcp.cap-inner 2@ fmcp.run-capture EXIT
    THEN
    s" timeout " fmcp.eval-timeout @ fmcp.u>dec fmcp.str-concat
    s"  " fmcp.str-concat
    fmcp.cap-inner 2@ fmcp.str-concat
    fmcp.cap-root 2@ 2swap fmcp.run-capture ;

: fmcp.gforth-eval-cmd ( -- cmd-a cmd-u )
    s" gforth --no-rc /tmp/fmcp-eval.4th" ;

: fmcp.timeout-prefix ( timeout-u -- pre-a pre-u )
    fmcp.u>dec s" [fmcp] timed out after " fmcp.str-concat
    s" s" fmcp.str-concat ;

: fmcp.gforth-eval ( root-a root-u source-a source-u timeout-u -- out-a out-u ec )
    fmcp.eval-timeout !
    fmcp.eval-source-in 2!
    fmcp.eval-root 2!
    fmcp.eval-timeout @ 1 300 fmcp.clamp-u fmcp.eval-timeout !
    fmcp.eval-source-in 2@ s"  bye" fmcp.str-concat fmcp.eval-source 2!
    s" /tmp/fmcp-eval.4th" fmcp.eval-source 2@ fmcp.write-text-file
    fmcp.eval-root 2@ fmcp.gforth-eval-cmd fmcp.eval-timeout @
    fmcp.run-capture-timed
    fmcp.eval-ec !
    fmcp.eval-ec @ 124 = IF
        fmcp.eval-timeout @ fmcp.timeout-prefix
        2swap fmcp.prepend-text
    THEN
    fmcp.eval-ec @ ;


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
    s" report --format json" fmcp.str-concat
    root-a root-u 2swap fmcp.run-capture ;

