! Copyright (C) 2008 okomok
! See http://factorcode.org/license.txt for BSD license.

USING: kernel ainan.using ;
AINAN-USING: io ;

IN: ainan.learn.parsings

: HELLO
    "HELLO" io:print
; parsing

: Hello
    POSTPONE: HELLO
; parsing

: hello
    POSTPONE: HELLO
;
