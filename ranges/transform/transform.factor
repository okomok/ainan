! Copyright (C) 2008 okomok
! See http://factorcode.org/license.txt for BSD license.

USING: kernel accessors ainan.using ainan.ranges ;
AINAN-USING: arrays io math quotations sequences sequences.private vectors ;

IN: ainan.ranges


! transform-iterator

TUPLE: transform-iterator base { quot read-only } ;
C: <transform-iterator> transform-iterator

INSTANCE: transform-iterator delegate-iterator
M: transform-iterator iterator-read* [ base>> ] [ quot>> ] bi [ iterator-read ] [ call ] bi* ;
M: transform-iterator iterator-clone* [ base>> ] [ quot>> ] bi <transform-iterator> ;


! transform

: transform ( rng quot -- rng )
    [ begin-end ] dip [ <transform-iterator> ] curry bi@ <iter-range> ;
