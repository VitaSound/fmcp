\ fmcp_version.4th — read version from package.4th

require fmcp_utils.4th

2variable fmcp-ver-data
s" unknown" fmcp-ver-data 2!

MARKER fmcp.discard-ver-parser

: forth-package ;
: end-forth-package ;
: key-list 0 parse 2drop ;
: key-value
    parse-name s" version" compare 0= IF
        parse-name fmcp.str-dup fmcp-ver-data 2!
    ELSE
        0 parse 2drop
    THEN ;

: fmcp.read-self-version
    fmcp.home-path s" package.4th" fmcp.fs-join { buf bu }
    buf bu 2dup file-status nip 0= IF
        included
    ELSE
        2drop
    THEN
    buf free throw ;

fmcp.read-self-version
fmcp.discard-ver-parser
