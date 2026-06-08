\ fmcp_mcp.4th — MCP request handler (one NDJSON line via FMCP_LINE).
\ No EXIT in handle-core — EXIT from nested words corrupts serve-stdio loop return stack.

require fmcp_json.4th
require fmcp_tools.4th

: fmcp.mcp-method? ( ma mu targeta targetu -- f )
    2swap compare 0= ;

: fmcp.has-id? ( -- f )
    s" id" fmcp.req-get 0<> ;

: fmcp.mcp-reply-empty ( -- )
    fmcp.stash-id
    fmcp.build-empty-result-rpc fmcp.emit-node-line ;

: fmcp.mcp-reply-empty-list ( key-a key-u -- )
    fmcp.stash-id
    fmcp.build-named-empty-list-rpc fmcp.emit-node-line ;

: fmcp.mcp-reply-method-not-found ( -- )
    fmcp.stash-id
    fmcp.build-method-not-found fmcp.emit-node-line ;

: fmcp.mcp-dispatch-method ( -- )
    fmcp.m-method 2@ s" initialize" fmcp.mcp-method? IF
        fmcp.stash-id
        fmcp.build-initialize-result fmcp.b-result !
        fmcp.build-rpc fmcp.emit-node-line
        s" initialize" fmcp.log-request-done
    ELSE fmcp.m-method 2@ s" notifications/initialized" fmcp.mcp-method? IF
    ELSE fmcp.m-method 2@ s" ping" fmcp.mcp-method? IF
        fmcp.mcp-reply-empty
        s" ping" fmcp.log-request-done
    ELSE fmcp.m-method 2@ s" resources/list" fmcp.mcp-method? IF
        s" resources" fmcp.mcp-reply-empty-list
        s" resources/list" fmcp.log-request-done
    ELSE fmcp.m-method 2@ s" prompts/list" fmcp.mcp-method? IF
        s" prompts" fmcp.mcp-reply-empty-list
        s" prompts/list" fmcp.log-request-done
    ELSE fmcp.m-method 2@ s" tools/list" fmcp.mcp-method? IF
        fmcp.stash-id
        fmcp.tools-list-node fmcp.emit-node-line
        s" tools/list" fmcp.log-request-done
    ELSE fmcp.m-method 2@ s" tools/call" fmcp.mcp-method? IF
        fmcp.stash-id
        fmcp.call-tool fmcp.emit-node-line
        s" tools/call" fmcp.log-request-done
    ELSE fmcp.has-id? IF
        fmcp.mcp-reply-method-not-found
        fmcp.m-method 2@ fmcp.log-request-done
    THEN THEN THEN THEN THEN THEN THEN THEN ;

: fmcp.mcp-handle-core ( -- )
    fmcp.linea @ fmcp.lineu @ fmcp.line-parse 0= IF
        fmcp.log-parse-error
    ELSE
        s" method" fmcp.req-get dup IF
            fjson.node-str@ fmcp.m-method 2!
            fmcp.m-method 2@ fmcp.log-request
            fmcp.mcp-dispatch-method
        ELSE
            drop
        THEN
    THEN
    fmcp.line-free ;

: fmcp.mcp-handle-line ( linea lineu -- )
    fmcp.set-line fmcp.mcp-handle-core ;
