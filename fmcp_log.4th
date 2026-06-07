\ fmcp_log.4th — diagnostics for MCP serve post-mortems.
\ Global log: $FMCP_LOG or $FMCP_HOME/.fmcp/serve.log
\ Per-repo log: $project_root/.fmcp/tool.log

require fmcp_utils.4th
require fmcp_version.4th
require fmcp_json.4th

2variable fmcp.log-project-root
2variable fmcp.log-tool-name
variable fmcp.log-seq
create fmcp.log-nlbuf 10 c,

: fmcp.log-enabled? ( -- f )
    s" FMCP_LOG" getenv 2dup nip IF
        2dup s" 0" compare 0= IF 2drop false EXIT THEN
        2dup s" off" compare 0= IF 2drop false EXIT THEN
        2drop true EXIT
    THEN
    2drop true ;

: fmcp.log-global-path ( -- a u )
    s" FMCP_LOG" getenv 2dup nip IF EXIT THEN
    2drop
    fmcp.home-path s" /.fmcp/serve.log" fmcp.str-concat ;

: fmcp.log-dirname { path-a path-u | i -- dir-a dir-u }
    path-u 0= IF nip s" ." EXIT THEN
    path-u TO i
    begin
        i 1- TO i
        i 0< IF s" ." EXIT THEN
        i 0> IF
            path-a i + c@ [char] / = IF
                path-a i fmcp.str-dup EXIT
            THEN
        THEN
    again ;

: fmcp.log-ensure-dir ( dir-a dir-u -- )
    dup IF
        s" mkdir -p '" 2swap fmcp.str-concat
        s" '" fmcp.str-concat
        fmcp.system-checked
    ELSE
        2drop
    THEN ;

: fmcp.log-append-path { path-a path-u line-a line-u -- }
    fmcp.log-enabled? 0= IF EXIT THEN
    path-a path-u fmcp.log-dirname fmcp.log-ensure-dir
    s" /tmp/fmcp-line-" getpid fmcp.u>dec fmcp.str-concat
    s" .txt" fmcp.str-concat
    2>r
    2r@ line-a line-u fmcp.write-text-file
    2r@ s" cat '" 2swap fmcp.str-concat
    s" ' >> '" fmcp.str-concat
    path-a path-u fmcp.str-concat
    s" '" fmcp.str-concat
    fmcp.system-checked
    2r> delete-file drop ;

: fmcp.log-write-line ( line-a line-u -- )
    fmcp.log-nlbuf 1 fmcp.str-concat
    fmcp.log-global-path 2swap fmcp.log-append-path ;

: fmcp.log-kv { pre-a pre-u key-a key-u val-a val-u -- a u }
    pre-a pre-u key-a key-u fmcp.str-concat
    s" =" fmcp.str-concat
    val-a val-u fmcp.str-concat
    fmcp.sp$ fmcp.str-concat ;

: fmcp.log-field { pre-a pre-u key-a key-u val-a val-u -- a u }
    val-a val-u nip IF
        pre-a pre-u key-a key-u val-a val-u fmcp.log-kv
    ELSE
        2drop pre-a pre-u
    THEN ;

: fmcp.log-prefix ( tag-a tag-u -- a u )
    2>r
    utime 1000000 um/mod nip fmcp.u>dec
    s"  pid=" fmcp.str-concat
    getpid fmcp.u>dec fmcp.str-concat
    s"  seq=" fmcp.str-concat
    fmcp.log-seq @ 1+ dup fmcp.log-seq ! fmcp.u>dec fmcp.str-concat
    s"  " fmcp.str-concat
    2r> fmcp.str-concat
    fmcp.sp$ fmcp.str-concat ;

: fmcp.log-trunc-field { a u max-u -- a u }
    u max-u <= IF a u fmcp.str-dup EXIT THEN
    a max-u fmcp.str-dup
    s" ..." fmcp.str-concat ;

: fmcp.log-project-path ( root-a root-u -- path-a path-u )
    s" /.fmcp/tool.log" fmcp.str-concat ;

: fmcp.log-project-append ( msg-a msg-u -- )
    fmcp.log-project-root 2@ nip 0= IF 2drop EXIT THEN
    fmcp.log-project-root 2@ fmcp.log-project-path fmcp.log-append-path ;

: fmcp.log-project-root-set ( root-a root-u -- )
    2dup nip IF
        fmcp.str-dup fmcp.log-project-root 2!
    ELSE
        2drop 0 0 fmcp.log-project-root 2!
    THEN ;

: fmcp.log-tool-root-field ( pre-a pre-u -- a u )
    2>r
    s" project_root" fmcp.arg-string fmcp.log-project-root-set
    s" project_root" fmcp.log-project-root 2@ fmcp.log-field
    2r> ;

: fmcp.log-session-start ( -- )
    fmcp.log-enabled? IF
        s" SESSION_START" fmcp.log-prefix
        s" version" fmcp-ver-data 2@ fmcp.log-field
        s" fmcp_home" fmcp.home-path fmcp.log-field
        s" cwd" fmcp.project-path fmcp.log-field
        fmcp.log-write-line
    THEN ;

: fmcp.log-session-end ( reason-a reason-u -- )
    2>r
    fmcp.log-enabled? IF
        s" SESSION_END" fmcp.log-prefix
        s" reason" 2r> fmcp.log-field
        fmcp.log-write-line
    ELSE
        2r> 2drop
    THEN ;

: fmcp.log-request ( method-a method-u -- )
    2>r
    fmcp.log-enabled? IF
        s" REQ" fmcp.log-prefix
        s" id" fmcp.mcp-id-str fmcp.log-field
        s" method" 2r> fmcp.log-field
        fmcp.log-write-line
    ELSE
        2r> 2drop
    THEN ;

: fmcp.log-request-done ( method-a method-u -- )
    2>r
    fmcp.log-enabled? IF
        s" REQ_DONE" fmcp.log-prefix
        s" id" fmcp.mcp-id-str fmcp.log-field
        s" method" 2r> fmcp.log-field
        fmcp.log-write-line
    ELSE
        2r> 2drop
    THEN ;

: fmcp.log-parse-error ( -- )
    fmcp.log-enabled? IF
        s" PARSE_ERROR" fmcp.log-prefix
        s" line" fmcp.linea @ fmcp.lineu @ 200 fmcp.log-trunc-field
        fmcp.log-field
        fmcp.log-write-line
    THEN ;

: fmcp.log-tool-start ( -- )
    fmcp.log-tool-name 2@ nip 0= IF EXIT THEN
    fmcp.log-enabled? 0= IF EXIT THEN
    0 0 fmcp.log-project-root 2!
    s" TOOL_START" fmcp.log-prefix
    s" id" fmcp.mcp-id-str fmcp.log-field
    s" tool" fmcp.log-tool-name 2@ fmcp.log-field
    fmcp.log-tool-name 2@ s" shell_run" compare 0= IF
        s" command" fmcp.arg-string 200 fmcp.log-trunc-field
        2>r s" command" 2r> fmcp.log-field
        s" project_root" fmcp.arg-string fmcp.log-project-root-set
        s" project_root" fmcp.log-project-root 2@ fmcp.log-field
    ELSE
        fmcp.log-tool-name 2@ s" gforth_eval" compare 0= IF
            s" source" fmcp.arg-string 80 fmcp.log-trunc-field
            2>r s" source" 2r> fmcp.log-field
            fmcp.log-tool-root-field
        ELSE
            fmcp.log-tool-name 2@ s" fcov_run" compare 0= IF
                s" test_command" fmcp.arg-string 120 fmcp.log-trunc-field
                2>r s" test_command" 2r> fmcp.log-field
                fmcp.log-tool-root-field
            ELSE
                fmcp.log-tool-name 2@ s" fmix_test" compare 0= IF
                    s" test_file" fmcp.arg-string
                    fmcp.log-field
                    fmcp.log-tool-root-field
                ELSE
                    fmcp.log-tool-name 2@ s" mcp_ping" compare 0<> IF
                        fmcp.log-tool-root-field
                    THEN
                THEN
            THEN
        THEN
    THEN
    s" timeout" s" timeout_seconds" 0 fmcp.arg-number-default fmcp.u>dec
    fmcp.log-field
    fmcp.log-write-line
    fmcp.log-project-root 2@ nip IF
        s" TOOL_START id=" fmcp.mcp-id-str fmcp.str-concat
        s" tool=" fmcp.str-concat fmcp.log-tool-name 2@ fmcp.str-concat
        s" project_root=" fmcp.str-concat
        fmcp.log-project-root 2@ fmcp.str-concat
        fmcp.log-project-append
    THEN ;

: fmcp.log-tool-end { text-a text-u elapsed-ms trunc-flag ec -- text-a text-u ec }
    fmcp.log-tool-name 2@ nip IF
    fmcp.log-enabled? IF
    s" TOOL_END" fmcp.log-prefix
    s" id" fmcp.mcp-id-str fmcp.log-field
    s" tool" fmcp.log-tool-name 2@ fmcp.log-field
    s" elapsed_ms" elapsed-ms fmcp.u>dec fmcp.log-field
    s" exit_code" ec fmcp.u>dec fmcp.log-field
    s" out_bytes" text-u fmcp.u>dec fmcp.log-field
    s" capture_truncated" trunc-flag fmcp.u>dec fmcp.log-field
    fmcp.log-write-line
    fmcp.log-project-root 2@ nip IF
        s" TOOL_END id=" fmcp.mcp-id-str fmcp.str-concat
        s" tool=" fmcp.str-concat fmcp.log-tool-name 2@ fmcp.str-concat
        ec fmcp.u>dec s" exit_code=" fmcp.str-concat fmcp.str-concat
        fmcp.log-project-append
    THEN
    THEN
    THEN
    text-a text-u ec ;
