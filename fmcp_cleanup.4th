\ fmcp_cleanup.4th — lifecycle for /tmp/fmcp-* artifacts.
\ Stale sweep at session start; pid-scoped cleanup at session end and after captures.
\ Disable with FMCP_CLEANUP_TMP=0 or off.

require fmcp_utils.4th

: fmcp.cleanup-enabled? ( -- f )
    s" FMCP_CLEANUP_TMP" getenv 2dup nip IF
        2dup s" 0" compare 0= IF 2drop false EXIT THEN
        2dup s" off" compare 0= IF 2drop false EXIT THEN
        2drop true EXIT
    THEN
    2drop true ;

: fmcp.cleanup-stale-tmp ( -- )
    fmcp.cleanup-enabled? 0= IF EXIT THEN
    s" find /tmp -maxdepth 1 -name 'fmcp-*' -mmin +60 -delete 2>/dev/null"
    fmcp.system-checked ;

: fmcp.cleanup-own-tmp ( -- )
    fmcp.cleanup-enabled? 0= IF EXIT THEN
    s" rm -f /tmp/fmcp-cap-"
    getpid fmcp.u>dec fmcp.str-concat
    s" -* /tmp/fmcp-line-" fmcp.str-concat
    getpid fmcp.u>dec fmcp.str-concat
    s" .txt /tmp/fmcp-eval-" fmcp.str-concat
    getpid fmcp.u>dec fmcp.str-concat
    s" .4th /tmp/fmcp-json-" fmcp.str-concat
    getpid fmcp.u>dec fmcp.str-concat
    s" .out 2>/dev/null" fmcp.str-concat
    fmcp.system-checked ;
