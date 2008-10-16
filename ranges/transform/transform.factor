! Copyright (C) 2008 okomok
! See http://factorcode.org/license.txt for BSD license.

USING: accessors kernel
    ainan.ranges.iterator ainan.ranges.iterator-adapter ainan.ranges.range ;

IN: ainan.ranges


! transform-iterator

TUPLE: transform-iterator base { quot read-only } ;
C: <transform-iterator> transform-iterator

INSTANCE: transform-iterator iterator-adapter
M: transform-iterator iterator-read* [ base>> ] [ quot>> ] bi [ iterator-read ] [ call ] bi* ;
M: transform-iterator iterator-clone* [ base>> ] [ quot>> ] bi <transform-iterator> ;


! transform

: transform ( rng quot -- rng )
    [ begin-end ] dip [ <transform-iterator> ] curry bi@ <iter-range> ;
