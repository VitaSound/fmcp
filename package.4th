\ Follows theforth.net publishing guidelines:
\   https://theforth.net/guidelines
forth-package
    key-value name fmcp
    key-value version 0.1.13
    key-value description MCP stdio bridge for VitaSound Forth tools (fmix, flint, fcov)
    key-value license COPL
    key-value main fmcp.4th
    key-value fmix ~> 0.7
    key-value flint ~> 0.2
    key-value fcov ~> 0.3
    key-list fcov-exclude tests/
    key-list tags mcp
    key-list tags gforth
    key-list tags cursor
    key-list dependencies fsemver git https://github.com/VitaSound/fsemver tag 0.1.0
    key-list dependencies fenum git https://github.com/VitaSound/fenum tag 0.1.1
    key-list dependencies fjson git https://github.com/VitaSound/fjson tag 0.2.4
    key-list dependencies ttester git https://github.com/VitaSound/ttester tag 1.2.1
    key-list dependencies f git https://github.com/VitaSound/f tag 0.2.4
end-forth-package
