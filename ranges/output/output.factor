! Copyright (C) 2008 okomok
! See http://factorcode.org/license.txt for BSD license.

USING: io quotations kernel ainan.qualified ainan.ranges.iterator ;
AINAN-QUALIFIED: io quotations ;

IN: ainan.ranges


! output protocol

MIXIN: output
GENERIC: output-write* ( elt out -- )
: output-write output-write* ; inline


! iterator output

INSTANCE: iterator output
M: iterator output-write* tuck iterator-write iterator-increment ;


! callable output

INSTANCE: quotations:callable output ! is there callable iterator?
M: quotations:callable output-write* call ;


! stream output

! INSTANCE: io:stream output ! io:stream mixin is missing.
! M: io:stream output-write* io:stream-write1 ;
: stream-output ( stm -- out ) [ io:stream-write1 ] curry ;
