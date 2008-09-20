! Copyright (C) 2008 okomok
! See http://factorcode.org/license.txt for BSD license.

! LEARN: Testing steps
! 1. USE: ainan.learn.sequences
! 2. "ainan.learn.sequences" dup reload test

USING: ainan.learn.sequences tools.test ;

[ "bcdefghijkl" ] [ "abcadeafgahiajkl" remove-a ] unit-test
[ "" ] [ "" remove-b ] unit-test
