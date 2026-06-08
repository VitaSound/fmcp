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
2variable fmcp.cap-cmd-path
2variable fmcp.eval-file-path
variable fmcp.capture-truncated

: fmcp.read-capture-out ( path-a path-u -- out-a out-u )
    0 fmcp.capture-truncated !
    fmcp.slurp-file dup 0= IF 2drop s" " EXIT THEN
    fmcp.max-output-u fmcp.truncate-text
    IF 1 fmcp.capture-truncated ! THEN ;

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
    2dup s" .ec" fmcp.str-concat fmcp.cap-ec-path 2!
    s" .cmd" fmcp.str-concat fmcp.cap-cmd-path 2! ;

: fmcp.cap-script-body ( -- a u )
    s\" #!/bin/sh\n"
    s" cd '" fmcp.str-concat
    fmcp.cap-root 2@ fmcp.str-concat
    s\" ' || exit 1\n" fmcp.str-concat
    s\" export TERM=dumb\n" fmcp.str-concat
    fmcp.cap-inner 2@ fmcp.str-concat ;

: fmcp.write-cap-script ( -- )
    fmcp.cap-script-body fmcp.cap-cmd-path 2@ 2swap fmcp.write-text-file ;

: fmcp.cap-unlink ( path-a path-u -- )
    delete-file drop ;

: fmcp.cap-cleanup-artifacts ( -- )
    fmcp.cap-out-path 2@ nip IF fmcp.cap-out-path 2@ fmcp.cap-unlink THEN
    fmcp.cap-pid-path 2@ nip IF fmcp.cap-pid-path 2@ fmcp.cap-unlink THEN
    fmcp.cap-ec-path 2@ nip IF fmcp.cap-ec-path 2@ fmcp.cap-unlink THEN
    fmcp.cap-cmd-path 2@ nip IF fmcp.cap-cmd-path 2@ fmcp.cap-unlink THEN ;

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
    fmcp.cap-out-path 2@ fmcp.read-capture-out
    r> fmcp.cap-cleanup-artifacts ;

: fmcp.run-capture-bg-start ( -- pid )
    s" TERM=dumb setsid sh -c "
    fmcp.frag-squote% fmcp.str-concat
    s" sh " fmcp.str-concat
    fmcp.cap-cmd-path 2@ fmcp.str-concat
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
    fmcp.write-cap-script
    fmcp.run-capture-bg-start fmcp.eval-timeout @
    fmcp.cap-ec-path 2@ fmcp.poll-wait fmcp.eval-ec !
    fmcp.cap-out-path 2@ fmcp.read-capture-out
    fmcp.eval-ec @ fmcp.cap-cleanup-artifacts ;

: fmcp.eval-file-path! ( -- )
    s" /tmp/fmcp-eval-"
    getpid fmcp.u>dec fmcp.str-concat
    s" .4th" fmcp.str-concat
    fmcp.eval-file-path 2! ;

: fmcp.gforth-eval-cmd ( -- cmd-a cmd-u )
    s" gforth " fmcp.eval-file-path 2@ fmcp.str-concat
    s"  < /dev/null" fmcp.str-concat ;

: fmcp.timeout-prefix ( timeout-u -- pre-a pre-u )
    fmcp.u>dec
    s" fmcp timed out after "
    2swap fmcp.prepend-text
    s"  seconds" fmcp.str-concat ;

: fmcp.no-ec-prefix ( -- a u )
    s" fmcp subprocess exited without exit code" ;

: fmcp.apply-capture-prefix ( out-a out-u ec -- out-a out-u ec )
    { out-a out-u ec }
    ec 124 = ec 125 = or IF
        ec 124 = IF
            fmcp.eval-timeout @ fmcp.timeout-prefix
        ELSE
            fmcp.no-ec-prefix
        THEN
        out-a out-u fmcp.prepend-text
        ec
    ELSE
        out-a out-u ec
    THEN ;

: fmcp.gforth-eval ( root-a root-u source-a source-u timeout-u -- out-a out-u ec )
    fmcp.eval-timeout !
    fmcp.eval-source-in 2!
    fmcp.eval-root 2!
    fmcp.eval-timeout @ fmcp.clamp-timeout fmcp.eval-timeout !
    fmcp.eval-source-in 2@ s"  bye" fmcp.str-concat fmcp.eval-source 2!
    fmcp.eval-file-path!
    fmcp.eval-file-path 2@ fmcp.eval-source 2@ fmcp.write-text-file
    fmcp.eval-root 2@ fmcp.gforth-eval-cmd fmcp.eval-timeout @
    fmcp.run-capture-bg fmcp.eval-ec !
    fmcp.eval-file-path 2@ fmcp.cap-unlink
    fmcp.eval-ec @ fmcp.apply-capture-prefix ;

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
    fmcp.eval-ec @ fmcp.apply-capture-prefix ;

: fmcp.fetch-tags-script? { root-a root-u -- f }
    root-a root-u s" scripts/fetch-tags.sh" fmcp.fs-join
    file-status nip 0= ;

: fmcp.fetch-tags-git-inner ( -- a u )
    s\" git fetch --tags --quiet origin 2>/dev/null || true
echo '--- package.4th version ---'
grep -E 'key-value version' package.4th 2>/dev/null | head -1 || echo '(none)'
echo '--- latest semver tag ---'
git tag -l 2>/dev/null | sed 's/^v//' | grep -E '^[0-9]' | sort -V | tail -1 || echo '(none)'
echo '--- git describe ---'
git describe --tags --abbrev=0 2>/dev/null || echo '(none)'
echo '--- all semver tags ---'
git tag -l 2>/dev/null | sed 's/^v//' | grep -E '^[0-9]' | sort -V
" ;

: fmcp.fetch-tags-inner { root-a root-u -- inner-a inner-u }
    root-a root-u fmcp.fetch-tags-script? IF
        s" ./scripts/fetch-tags.sh"
    ELSE
        fmcp.fetch-tags-git-inner
    THEN ;

: fmcp.fetch-tags { root-a root-u timeout-u -- out-a out-u ec }
    timeout-u fmcp.eval-timeout !
    root-a root-u fmcp.cap-root 2!
    root-a root-u fmcp.fetch-tags-inner fmcp.cap-inner 2!
    fmcp.eval-timeout @ fmcp.clamp-timeout fmcp.eval-timeout !
    fmcp.cap-root 2@ fmcp.cap-inner 2@ fmcp.eval-timeout @ fmcp.run-capture-bg
    fmcp.eval-ec !
    fmcp.eval-ec @ fmcp.apply-capture-prefix ;

: fmcp.mcp-ping-text ( -- a u )
    s" fmcp ok version "
    fmcp-ver-data 2@ fmcp.str-concat
    s"  serve_pid "
    fmcp.str-concat
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

: fmcp.fmix-test { root-a root-u test-file-a test-file-u timeout-u -- }
    fmcp.fmix-home s" fmix" s" " fmcp.bin-cmd
    s" test" fmcp.str-concat
    test-file-a test-file-u nip IF
        fmcp.sp$ fmcp.str-concat test-file-a test-file-u fmcp.str-concat
    THEN
    root-a root-u 2swap timeout-u fmcp.run-capture-bg
    fmcp.apply-capture-prefix ;

: fmcp.fmix-packages-get { root-a root-u timeout-u -- }
    fmcp.fmix-home s" fmix" s" " fmcp.bin-cmd
    s" packages.get" fmcp.str-concat
    root-a root-u 2swap timeout-u fmcp.run-capture-bg
    fmcp.apply-capture-prefix ;

: fmcp.int-to-str ( n -- a u )
    dup abs 0 <# #s #> 2dup nip IF EXIT THEN drop s" 0" ;

: fmcp.arg-truthy? ( key-a key-u -- f )
    fmcp.arg-string nip 0= IF false EXIT THEN
    s" true" compare 0= ;

: fmcp.flint-lint { root-a root-u timeout-u -- }
    fmcp.flint-home s" flint" s" " fmcp.bin-cmd
    s" lint ." fmcp.str-concat
    s" strict" fmcp.arg-truthy? IF s" --strict" fmcp.str-concat THEN
    s" project_only" fmcp.arg-truthy? IF s" --project-only" fmcp.str-concat THEN
    root-a root-u 2swap timeout-u fmcp.run-capture-bg
    fmcp.apply-capture-prefix ;

: fmcp.fmix-check { root-a root-u timeout-u -- }
    s" stage" fmcp.arg-string nip IF
        s" stage" fmcp.arg-string
    ELSE
        s" pre-commit"
    THEN { st-a st-u }
    fmcp.fmix-home s" /bin/fmix check --stage " fmcp.str-concat
    st-a st-u fmcp.str-concat
    s" no_flint" fmcp.arg-truthy? IF s" --no-flint" fmcp.str-concat THEN
    s" no_fcov" fmcp.arg-truthy? IF s" --no-fcov" fmcp.str-concat THEN
    s" fail_under" fmcp.arg-number dup IF
        s" --fail-under " fmcp.str-concat swap fmcp.int-to-str fmcp.str-concat
    ELSE drop THEN
    root-a root-u 2swap timeout-u fmcp.run-capture-bg
    fmcp.apply-capture-prefix
    st-a st-u drop free throw ;

: fmcp.bin-exists? { root-a root-u tool-a tool-u -- f }
    root-a root-u s" bin" fmcp.fs-join
    tool-a tool-u fmcp.fs-join
    file-status nip 0= ;

: fmcp.fcov-default-cmd { root-a root-u -- cmd-a cmd-u }
    root-a root-u s" fmcp" fmcp.bin-exists? IF
        s" bin/fmcp test --shared" EXIT
    THEN
    root-a root-u s" fmix" fmcp.bin-exists? IF
        s" fmix test" EXIT
    THEN
    s" fmix test" ;

: fmcp.fcov-run { root-a root-u test-cmd-a test-cmd-u timeout-u -- }
    fmcp.fcov-home s" fcov" s" " fmcp.bin-cmd
    s" run" fmcp.str-concat
    test-cmd-a test-cmd-u nip IF
        fmcp.sp$ fmcp.str-concat test-cmd-a test-cmd-u fmcp.str-concat
    ELSE
        fmcp.sp$ fmcp.str-concat
        root-a root-u fmcp.fcov-default-cmd fmcp.str-concat
    THEN
    root-a root-u 2swap timeout-u fmcp.run-capture-bg
    fmcp.apply-capture-prefix ;

: fmcp.fcov-report-json { root-a root-u -- }
    fmcp.fcov-home s" fcov" s" " fmcp.bin-cmd
    s\" report --format json" fmcp.str-concat
    root-a root-u 2swap fmcp.run-capture ;
