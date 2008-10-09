! Copyright (C) 2008 okomok
! See http://factorcode.org/license.txt for BSD license.

USING: ainan.learn.mixins tools.test ;

[ "default" ] [ 1 2 1 2 <ellipse> draw ] unit-test
[ "rectangle" ] [ 1 2 1 2 <rectangle> draw ] unit-test
[ "default" ] [ 1 2 1 2 <polygon> draw ] unit-test
