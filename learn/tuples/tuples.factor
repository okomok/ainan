! Copyright (C) 2008 okomok
! See http://factorcode.org/license.txt for BSD license.

USING: kernel ;
USING: accessors ; ! >>position
USING: qualified ;

IN: ainan.learn.tuples

QUALIFIED: accessors ! no effects?

TUPLE: employee
    name position slaray ;

: <manager> ( -- employee )
    employee new "project manager" >>position ;

: <person> ( name position -- person )
    40000 employee boa ;

: <manager>_ ( name -- person )
    "manager" <person> ;

