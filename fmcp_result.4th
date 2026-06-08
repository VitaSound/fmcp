\ fmcp_result.4th — unified tools/call result contract (structuredContent + JSON text).
\ Schema: tool, exit_code, elapsed_ms, truncated, output_bytes, project_root?,
\         artifacts[], summary, output.

require fmcp_log.4th
require fmcp_build.4th
require fmcp_exec.4th

2variable fmcp.res-tool
2variable fmcp.res-project-root
2variable fmcp.res-output
2variable fmcp.res-summary
variable fmcp.res-elapsed-ms
variable fmcp.res-truncated
variable fmcp.res-out-bytes
variable fmcp.res-artifacts-lst

: fmcp.result-reset ( -- )
    0 0 fmcp.res-tool 2!
    0 0 fmcp.res-project-root 2!
    0 0 fmcp.res-output 2!
    0 0 fmcp.res-summary 2!
    0 fmcp.res-elapsed-ms !
    0 fmcp.res-truncated !
    0 fmcp.res-out-bytes !
    0 fmcp.res-artifacts-lst ! ;

: fmcp.result-tool-set ( name-a name-u -- )
    fmcp.res-tool 2! ;

: fmcp.result-project-root-capture ( -- )
    fmcp.log-project-root 2@ nip IF
        fmcp.log-project-root 2@ fmcp.res-project-root 2!
    ELSE
        s" project_root" fmcp.arg-string fmcp.res-project-root 2!
    THEN ;

: fmcp.result-summary-from { text-a text-u exit-code -- a u }
    text-a text-u dup IF
        200 fmcp.log-trunc-field
    ELSE
        2drop
        exit-code 0= IF
            s" ok"
        ELSE exit-code 124 = IF
            s" timed out"
        ELSE
            s" failed"
        THEN THEN
    THEN ;

: fmcp.result-tool-log-path ( root-a root-u -- path-a path-u )
    s" /.fmcp/tool.log" fmcp.str-concat ;

: fmcp.result-artifacts-node ( -- node )
    ulist-new fmcp.res-artifacts-lst !
    fmcp.log-enabled? IF
        fmcp.res-project-root 2@ nip IF
            fmcp.res-project-root 2@ fmcp.result-tool-log-path
            fjson.node-str fmcp.res-artifacts-lst @ ulist-add
        THEN
    THEN
    fmcp.res-artifacts-lst @ fmcp.build-arr ;

: fmcp.result-obj-add-num { key-a key-u n lst -- }
    lst fmcp.obj-lst !
    n fjson.node-num fmcp.obj-val !
    key-a key-u fmcp.obj-key 2!
    fmcp.obj-add ;

: fmcp.result-obj-add-bool { key-a key-u flag-val lst -- }
    lst fmcp.obj-lst !
    flag-val fjson.node-bool fmcp.obj-val !
    key-a key-u fmcp.obj-key 2!
    fmcp.obj-add ;

: fmcp.result-json-exit-code ( code -- code' )
    dup -1 = IF drop 1 THEN ;

: fmcp.result-structured-node { exit-code -- node }
    ulist-new fmcp.b-entry !
    s" tool" fmcp.res-tool 2@ fjson.node-str fmcp.b-entry @ fmcp.obj-add-key
    s" exit_code" exit-code fmcp.result-json-exit-code fmcp.b-entry @ fmcp.result-obj-add-num
    s" elapsed_ms" fmcp.res-elapsed-ms @ fmcp.b-entry @ fmcp.result-obj-add-num
    s" truncated" fmcp.res-truncated @ 0<> fmcp.b-entry @ fmcp.result-obj-add-bool
    s" output_bytes" fmcp.res-out-bytes @ fmcp.b-entry @ fmcp.result-obj-add-num
    fmcp.res-project-root 2@ nip IF
        s" project_root" fmcp.res-project-root 2@ fjson.node-str
        fmcp.b-entry @ fmcp.obj-add-key
    THEN
    fmcp.result-artifacts-node fmcp.b-val !
    s" artifacts" fmcp.b-entry @ fmcp.obj-add-val
    s" summary" fmcp.res-summary 2@ fjson.node-str fmcp.b-entry @ fmcp.obj-add-key
    s" output" fmcp.res-output 2@ fjson.node-str fmcp.b-entry @ fmcp.obj-add-key
    fmcp.b-entry @ fmcp.build-obj ;

: fmcp.result-pack-node { text-a text-u exit-code -- node }
    exit-code fmcp.b-ec !
    text-a text-u fmcp.max-output-u fmcp.truncate-text { trunc? }
    trunc? fmcp.res-truncated !
    fmcp.capture-truncated @ IF -1 fmcp.res-truncated ! THEN
    fmcp.res-output 2!
    fmcp.res-output 2@ nip fmcp.res-out-bytes !
    fmcp.res-output 2@ exit-code fmcp.result-summary-from fmcp.res-summary 2!
    exit-code fmcp.result-structured-node ;

: fmcp.result-error-node ( msg-a msg-u -- node )
    fmcp.log-tool-name 2@ fmcp.result-tool-set
    0 0 fmcp.res-output 2!
    0 fmcp.res-out-bytes !
    0 fmcp.res-truncated !
    0 fmcp.res-elapsed-ms !
    fmcp.res-summary 2!
    -1 fmcp.b-ec !
    -1 fmcp.result-structured-node ;
