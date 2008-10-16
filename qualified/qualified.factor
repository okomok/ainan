! Copyright (C) 2008 okomok
! See http://factorcode.org/license.txt for BSD license.

USING: kernel lexer sequences qualified ;

IN: ainan.qualified

: AINAN-QUALIFIED:
    ";" parse-tokens [ dup define-qualified ] each
; parsing
