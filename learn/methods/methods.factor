! Copyright (C) 2008 okomok
! See http://factorcode.org/license.txt for BSD license.

USING: kernel qualified arrays ;

IN: ainan.learn.methods

QUALIFIED: arrays

! LEARN: Don't miss Stack effect declarations, or you will get warnings.
GENERIC: (is-array?) ( object -- ? )

: is-array?
    (is-array?) ; inline

M: arrays:array (is-array?)
    drop t ;

M: object (is-array?)
    drop f ;
