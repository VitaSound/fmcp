\ fmcp_shellfrags.4th — shell snippet bytes (avoid > and ; in source lines).

create fmcp.frag-out
bl c, char > c, bl c,
here fmcp.frag-out - constant fmcp.frag-out-len

create fmcp.frag-redir2
bl c, char 2 c, char > c, char & c, char 1 c,
here fmcp.frag-redir2 - constant fmcp.frag-redir2-len

create fmcp.frag-null
bl c, char 2 c, char > c, char / c, char d c, char e c, char v c,
char / c, char n c, char u c, char l c, char l c,
here fmcp.frag-null - constant fmcp.frag-null-len

create fmcp.frag-ec-echo
bl c, char ; c, bl c,
char e c, char c c, char h c, char o c, bl c,
char $ c, char ? c, bl c, char > c, bl c,
here fmcp.frag-ec-echo - constant fmcp.frag-ec-echo-len

create fmcp.frag-sh-c
bl c, char & c, char & c, bl c,
char T c, char E c, char R c, char M c, char = c,
char d c, char u c, char m c, char b c, bl c,
char s c, char e c, char t c, char s c, char i c, char d c, bl c,
char s c, char h c, bl c, char - c, char c c, bl c,
here fmcp.frag-sh-c - constant fmcp.frag-sh-c-len

create fmcp.frag-squote
char ' c,
here fmcp.frag-squote - constant fmcp.frag-squote-len

create fmcp.frag-pid-echo
bl c, char & c, bl c,
char e c, char c c, char h c, char o c, bl c,
char $ c, char ! c, bl c, char > c, bl c,
here fmcp.frag-pid-echo - constant fmcp.frag-pid-echo-len

: fmcp.frag-out% ( -- a u ) fmcp.frag-out fmcp.frag-out-len ;
: fmcp.frag-redir2% ( -- a u ) fmcp.frag-redir2 fmcp.frag-redir2-len ;
: fmcp.frag-null% ( -- a u ) fmcp.frag-null fmcp.frag-null-len ;
: fmcp.frag-ec-echo% ( -- a u ) fmcp.frag-ec-echo fmcp.frag-ec-echo-len ;
: fmcp.frag-sh-c% ( -- a u ) fmcp.frag-sh-c fmcp.frag-sh-c-len ;
: fmcp.frag-squote% ( -- a u ) fmcp.frag-squote fmcp.frag-squote-len ;
: fmcp.frag-pid-echo% ( -- a u ) fmcp.frag-pid-echo fmcp.frag-pid-echo-len ;
