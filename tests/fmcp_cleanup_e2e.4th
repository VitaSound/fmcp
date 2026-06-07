\ tests/fmcp_cleanup_e2e.4th — e2e for fmcp.cleanup-own-tmp (via mcp_cleanup_test.sh).

require fmcp_cleanup.4th

2variable fmcp.cleanup-e2e-path

: fmcp.cleanup-e2e ( -- )
    s" /tmp/fmcp-line-" getpid fmcp.u>dec fmcp.str-concat
    s" .txt" fmcp.str-concat
    2dup fmcp.cleanup-e2e-path 2!
    s" cleanup-smoke" fmcp.write-text-file
    fmcp.cleanup-own-tmp
    fmcp.cleanup-e2e-path 2@ file-status nip 0= abort" cleanup-own-tmp left line file" ;

fmcp.cleanup-e2e
