! Copyright (C) 2008 okomok
! See http://factorcode.org/license.txt for BSD license.

USING: ainan.learn.tuples tools.test ;

[ T{ employee f f "project manager" f } ] [ <manager> ] unit-test
[ T{ employee f "john" "manager" 40000 } ] [ "john" <manager>_ ] unit-test
