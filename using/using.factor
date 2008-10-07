! Copyright (C) 2008 okomok
! See http://factorcode.org/license.txt for BSD license.

USING: kernel lexer sequences qualified ;

IN: ainan.using

QUALIFIED: sequences
QUALIFIED: lexer

<PRIVATE

! See: qualified
: define-words ( vocab-name -- )
    dup define-qualified
; inline

PRIVATE>

: AINAN-USING:
    #! Syntax: AINAN-USING: vocabularies... ;
    ";" lexer:parse-tokens [ define-words ] sequences:each
; parsing
