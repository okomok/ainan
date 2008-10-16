! Copyright (C) 2008 okomok
! See http://factorcode.org/license.txt for BSD license.

USING: math accessors kernel ainan.qualified
    ainan.ranges.iterator ainan.ranges.range ;
AINAN-QUALIFIED: math ;

IN: ainan.ranges


! number-iterator

TUPLE: number-iterator base ;
C: <number-iterator> number-iterator

INSTANCE: number-iterator iterator
M: number-iterator iterator-traversal-tag* drop <random-access-iterator-tag> ;
M: number-iterator iterator-read* base>> ;
M: number-iterator iterator-equal?* [ base>> ] bi@ = ;
M: number-iterator iterator-increment* [ math:1+ ] change-base ;
M: number-iterator iterator-clone* base>> <number-iterator> ;
M: number-iterator iterator-decrement* [ math:1- ] change-base ;
M: number-iterator iterator-advance* swap [ math:+ ] curry change-base ;
M: number-iterator iterator-difference* [ base>> ] bi@ swap math:- ;


! numbers

: numbers ( n m -- rng ) [ <number-iterator> ] bi@ <iter-range> ;
