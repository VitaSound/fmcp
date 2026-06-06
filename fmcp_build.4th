\ fmcp_build.4th — JSON-RPC response trees via fjson node layer.
\ Hot path: fmcp.b-* / fmcp.obj-* slots — no Gforth locals, no >r before pair-new.
\ Note: do not call ulist-reverse inside compiled words (breaks fjson.node-free defer).
\ obj-add-key call pattern: s" key" <val-a u or node> fjson.node-str? lst @ fmcp.obj-add-key

require fmcp_json.4th

2variable fmcp.b-name
2variable fmcp.b-desc
2variable fmcp.b-text
variable fmcp.b-ec
variable fmcp.b-result
variable fmcp.b-entry
variable fmcp.b-lst
variable fmcp.b-wrap
variable fmcp.b-inner
variable fmcp.b-val

2variable fmcp.obj-key
variable fmcp.obj-val
variable fmcp.obj-lst

variable fmcp.schema-node

: fmcp.schema-project-root-parse ( -- node )
    s\" {\"type\":\"object\",\"properties\":{\"project_root\":{\"type\":\"string\"}},\"required\":[\"project_root\"]}"
    fjson.parse ;

: fmcp.schema-gforth-eval-parse ( -- node )
    s\" {\"type\":\"object\",\"properties\":{\"project_root\":{\"type\":\"string\"},\"source\":{\"type\":\"string\"},\"timeout_seconds\":{\"type\":\"number\"}},\"required\":[\"project_root\",\"source\"]}"
    fjson.parse ;

: fmcp.init-schema ( -- )
    fmcp.schema-project-root-parse fmcp.schema-node ! ;

: fmcp.schema-node@ ( -- node )
    fmcp.schema-node @ 0= IF fmcp.init-schema THEN
    fmcp.schema-node @ ;

: fmcp.build-obj ( lst -- node )
    fjson.node-obj ;

: fmcp.build-arr ( lst -- node )
    fjson.node-arr ;

: fmcp.obj-add ( -- )
    fmcp.obj-key 2@ fmcp.obj-val @ fjson.pair-new
    fmcp.obj-lst @ ulist-add ;

: fmcp.obj-add-key ( key-a key-u val-node lst -- )
    fmcp.obj-lst !
    fmcp.obj-val !
    fmcp.obj-key 2!
    fmcp.obj-add ;

: fmcp.obj-add-val ( key-a key-u lst -- )
    fmcp.obj-lst !
    fmcp.b-val @ fmcp.obj-val !
    fmcp.obj-key 2!
    fmcp.obj-add ;

: fmcp.content-array ( item-lst -- node )
    fmcp.b-entry !
    ulist-new fmcp.b-inner !
    fmcp.b-entry @ fmcp.build-obj fmcp.b-inner @ ulist-add
    fmcp.b-inner @ fmcp.build-arr ;

: fmcp.build-tool-entry ( name-a name-u desc-a desc-u -- node )
    fmcp.b-desc 2!
    fmcp.b-name 2!
    ulist-new fmcp.b-entry !
    s" name" fmcp.b-name 2@ fjson.node-str fmcp.b-entry @ fmcp.obj-add-key
    s" description" fmcp.b-desc 2@ fjson.node-str fmcp.b-entry @ fmcp.obj-add-key
    s" inputSchema" fmcp.schema-project-root-parse fmcp.b-entry @ fmcp.obj-add-key
    fmcp.b-entry @ fmcp.build-obj ;

: fmcp.build-gforth-eval-entry ( -- node )
    ulist-new fmcp.b-entry !
    s" name" s" gforth_eval" fjson.node-str fmcp.b-entry @ fmcp.obj-add-key
    s" description" s" Evaluate Gforth snippet in project_root (timeout default 10s, max 300s)" fjson.node-str fmcp.b-entry @ fmcp.obj-add-key
    s" inputSchema" fmcp.schema-gforth-eval-parse fmcp.b-entry @ fmcp.obj-add-key
    fmcp.b-entry @ fmcp.build-obj ;

: fmcp.build-rpc ( -- node )
    ulist-new fmcp.b-lst !
    s" jsonrpc" s" 2.0" fjson.node-str fmcp.b-lst @ fmcp.obj-add-key
    s" id" fmcp.b-id-node @ fmcp.b-lst @ fmcp.obj-add-key
    s" result" fmcp.b-result @ fmcp.b-lst @ fmcp.obj-add-key
    fmcp.b-lst @ fmcp.build-obj ;

: fmcp.build-error-rpc ( -- node )
    ulist-new fmcp.b-lst !
    s" jsonrpc" s" 2.0" fjson.node-str fmcp.b-lst @ fmcp.obj-add-key
    s" id" fmcp.b-id-node @ fmcp.b-lst @ fmcp.obj-add-key
    s" error" fmcp.b-result @ fmcp.b-lst @ fmcp.obj-add-key
    fmcp.b-lst @ fmcp.build-obj ;

: fmcp.build-empty-obj ( -- node )
    ulist-new fmcp.build-obj ;

: fmcp.build-empty-result-rpc ( -- node )
    fmcp.build-empty-obj fmcp.b-result !
    fmcp.build-rpc ;

: fmcp.build-named-empty-list ( key-a key-u -- node )
    fmcp.obj-key 2!
    ulist-new fmcp.b-wrap !
    ulist-new fmcp.b-lst !
    fmcp.b-lst @ fmcp.build-arr fmcp.b-val !
    fmcp.obj-key 2@ fmcp.b-wrap @ fmcp.obj-add-val
    fmcp.b-wrap @ fmcp.build-obj ;

: fmcp.build-named-empty-list-rpc ( key-a key-u -- node )
    fmcp.build-named-empty-list fmcp.b-result !
    fmcp.build-rpc ;

: fmcp.build-method-not-found ( -- node )
    ulist-new fmcp.b-wrap !
    ulist-new fmcp.b-entry !
    s" code" 32601 fjson.node-num fmcp.b-entry @ fmcp.obj-add-key
    s" message" s" Method not found" fjson.node-str fmcp.b-entry @ fmcp.obj-add-key
    fmcp.b-entry @ fmcp.build-obj fmcp.b-result !
    fmcp.build-error-rpc ;

: fmcp.build-tool-result ( -- node )
    ulist-new fmcp.b-entry !
    s" type" s" text" fjson.node-str fmcp.b-entry @ fmcp.obj-add-key
    s" text" fmcp.b-text 2@ fjson.node-str fmcp.b-entry @ fmcp.obj-add-key
    ulist-new fmcp.b-wrap !
    fmcp.b-entry @ fmcp.content-array fmcp.b-val !
    s" content" fmcp.b-wrap @ fmcp.obj-add-val
    fmcp.b-ec @ fjson.node-bool fmcp.b-val !
    s" isError" fmcp.b-wrap @ fmcp.obj-add-val
    fmcp.b-wrap @ fmcp.build-obj ;

: fmcp.build-tools-cap ( -- node )
    ulist-new fmcp.b-entry !
    s" listChanged" 0 fjson.node-bool fmcp.b-entry @ fmcp.obj-add-key
    fmcp.b-entry @ fmcp.build-obj ;

: fmcp.build-initialize-result ( -- node )
    ulist-new fmcp.b-wrap !
    fmcp.build-tools-cap fmcp.b-val !
    ulist-new fmcp.b-entry !
    s" tools" fmcp.b-entry @ fmcp.obj-add-val
    fmcp.b-entry @ fmcp.build-obj fmcp.b-val !
    s" capabilities" fmcp.b-wrap @ fmcp.obj-add-val
    ulist-new fmcp.b-entry !
    s" name" s" fmcp" fjson.node-str fmcp.b-entry @ fmcp.obj-add-key
    s" version" s" 0.1.2" fjson.node-str fmcp.b-entry @ fmcp.obj-add-key
    fmcp.b-entry @ fmcp.build-obj fmcp.b-val !
    s" serverInfo" fmcp.b-wrap @ fmcp.obj-add-val
    s" protocolVersion" s" 2025-11-25" fjson.node-str fmcp.b-wrap @ fmcp.obj-add-key
    fmcp.b-wrap @ fmcp.build-obj ;

: fmcp.build-tools-list-result ( -- node )
    ulist-new fmcp.b-lst !
    s" fmix_test" s" Run fmix test" fmcp.build-tool-entry fmcp.b-lst @ ulist-add
    s" fmix_packages_get" s" Run fmix packages.get" fmcp.build-tool-entry fmcp.b-lst @ ulist-add
    s" flint_lint" s" Run flint lint" fmcp.build-tool-entry fmcp.b-lst @ ulist-add
    s" fcov_run" s" Run fcov run" fmcp.build-tool-entry fmcp.b-lst @ ulist-add
    s" fcov_report" s" fcov report json" fmcp.build-tool-entry fmcp.b-lst @ ulist-add
    fmcp.build-gforth-eval-entry fmcp.b-lst @ ulist-add
    ulist-new fmcp.b-wrap !
    fmcp.b-lst @ fmcp.build-arr fmcp.b-val !
    s" tools" fmcp.b-wrap @ fmcp.obj-add-val
    fmcp.b-wrap @ fmcp.build-obj ;

: fmcp.tools-list-node ( -- node )
    fmcp.build-tools-list-result fmcp.b-result !
    fmcp.build-rpc ;

: fmcp.tool-result-node ( text-a text-u ec -- node )
    fmcp.b-ec !
    fmcp.b-text 2!
    fmcp.build-tool-result fmcp.b-result !
    fmcp.build-rpc ;

: fmcp.tool-error-node ( msg-a msg-u -- node )
    fmcp.b-text 2!
    -1 fmcp.b-ec !
    fmcp.build-tool-result fmcp.b-result !
    fmcp.build-rpc ;

fmcp.init-schema
:noname depth 0> IF drop THEN ; execute
