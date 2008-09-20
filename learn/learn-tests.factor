! Copyright (C) 2008 okomok
! See http://factorcode.org/license.txt for BSD license.

! LEARN: Testing steps
! 1. USE: ainan.learn
! 2. "ainan.learn" test
! 3. "ainan.learn" reload
! 4. try 2. again

USING: ainan.learn tools.test ;

[ "bcdefghijkl" ] [ "abcadeafgahiajkl" remove-a ] unit-test
[ "" ] [ "" remove-b ] unit-test
