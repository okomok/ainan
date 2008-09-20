! Copyright (C) 2008 okomok
! See http://factorcode.org/license.txt for BSD license.

! LEARN: The same named file as folder must be placed in it. 

! LEARN: For some reason, comments can't be placed in single USINGs.
USING: kernel ; ! =
USING: qualified ;
USING: sequences ; ! filter

IN: ainan.learn.sequences

QUALIFIED-WITH: sequences seq

: remove-a ( seq -- subseq  )
    [ CHAR: a = not ] seq:filter
;

: remove-b ( seq -- subseq  )
    [ CHAR: b = not ] seq:filter
;
