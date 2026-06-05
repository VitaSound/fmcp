\ fmcp_exec.4th — run fmix/flint/fcov in a project directory, capture output.

require fmcp_utils.4th


: fmcp.run-capture { root-a root-u inner-a inner-u -- out-a out-u exit-code }
    root-a root-u fmcp.validate-path
    s" /tmp/fmcp-capture.out" { out-path-a out-path-u }
    s" cd " root-a root-u fmcp.str-concat
    s"  && " fmcp.str-concat
    inner-a inner-u fmcp.str-concat
    s"  > " fmcp.str-concat
    out-path-a out-path-u fmcp.str-concat
    s"  2>&1" fmcp.str-concat
    fmcp.system-checked
    out-path-a out-path-u fmcp.slurp-file
    $? ;


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

: fmcp.fmix-test { root-a root-u test-file-a test-file-u -- out-a out-u exit-code }
    fmcp.fmix-home s" fmix" s" " fmcp.bin-cmd
    s" test" fmcp.str-concat
    test-file-a test-file-u nip IF
        s" " fmcp.str-concat test-file-a test-file-u fmcp.str-concat
    THEN
    root-a root-u 2swap fmcp.run-capture ;

: fmcp.fmix-packages-get { root-a root-u -- out-a out-u exit-code }
    fmcp.fmix-home s" fmix" s" " fmcp.bin-cmd
    s" packages.get" fmcp.str-concat
    root-a root-u 2swap fmcp.run-capture ;

: fmcp.flint-lint { root-a root-u -- out-a out-u exit-code }
    fmcp.flint-home s" flint" s" " fmcp.bin-cmd
    s" lint ." fmcp.str-concat
    root-a root-u 2swap fmcp.run-capture ;

: fmcp.fcov-run { root-a root-u test-cmd-a test-cmd-u -- out-a out-u exit-code }
    fmcp.fcov-home s" fcov" s" " fmcp.bin-cmd
    s" run" fmcp.str-concat
    test-cmd-a test-cmd-u nip IF
        s" " fmcp.str-concat test-cmd-a test-cmd-u fmcp.str-concat
    THEN
    root-a root-u 2swap fmcp.run-capture ;

: fmcp.fcov-report-json { root-a root-u -- out-a out-u exit-code }
    fmcp.fcov-home s" fcov" s" " fmcp.bin-cmd
    s" report --format json" fmcp.str-concat
    root-a root-u 2swap fmcp.run-capture ;

