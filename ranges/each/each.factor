! Copyright (C) 2008 okomok
! See http://factorcode.org/license.txt for BSD license.

USING: accessors kernel ainan.ranges.range ;

IN: ainan.ranges

! SEE: lists:leach


! accum-range

TUPLE: accum-range begin { end read-only } ;
: <accum-range> ( rng -- arng ) begin-end accum-range boa ;
: accum-elt ( arng -- elt ) begin>> iterator-read ;
: accum-next ( arng -- arng ) [ iterator-increment ] change-begin ;
: accum-end? ( arng -- ? ) [ begin>> ] [ end>> ] bi iterator-equal? ;


! each

: ((each)) ( arng quot -- arng quot )
    [ [ accum-elt ] dip call ] [ [ accum-next ] dip ] 2bi ; inline

: (each) ( arng quot -- )
    over accum-end? [ 2drop ] [ ((each)) (each) ] if ; inline

: each ( rng quot -- )
    [ <accum-range> ] dip (each) ; inline
