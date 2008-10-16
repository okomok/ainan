! Copyright (C) 2008 okomok
! See http://factorcode.org/license.txt for BSD license.

USING: math stack-checker accessors kernel
    ainan.ranges.iterator ainan.ranges.iterator-adapter ainan.ranges.range ;

IN: ainan.ranges


! transform-iterator

TUPLE: suppress-inference { quot read-only } ;
C: <suppress-inference> suppress-inference
M: suppress-inference infer drop [ 1+ ] infer ;

TUPLE: transform-iterator base { quot read-only } ;
C: <transform-iterator> transform-iterator

INSTANCE: transform-iterator iterator-adapter
M: transform-iterator iterator-read*
    [ base>> ] [ drop [ 1+ ] ] bi [ iterator-read ] [ call ] bi* ; ! compiles
    ! [ base>> ] [ quot>> <suppress-inference> ] bi [ iterator-read ] [ call ] bi* ; ! infer error...
    ! [ base>> ] [ quot>> ] bi [ iterator-read ] [ call ] bi* ; ! infer error...

M: transform-iterator iterator-clone* [ base>> iterator-clone ] [ quot>> ] bi <transform-iterator> ;


! transform

: transform ( rng quot -- rng )
    [ begin-end ] dip [ <transform-iterator> ] curry bi@ <iter-range> ;
