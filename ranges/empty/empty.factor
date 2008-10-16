! Copyright (C) 2008 okomok
! See http://factorcode.org/license.txt for BSD license.

USING: ainan.ranges ainan.ranges.iterator ;

IN: ainan.ranges

: empty ( rng -- ? ) begin-end iterator-equal? ; inline
: empty? empty ; inline
