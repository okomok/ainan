! Copyright (C) 2008 okomok
! See http://factorcode.org/license.txt for BSD license.

USING: accessors kernel ainan.ranges.range ainan.ranges.iterator ainan.ranges.iterator-adapter ;

IN: ainan.ranges


! reverse-iterator

TUPLE: reverse-iterator base ;
C: <reverse-iterator> reverse-iterator

INSTANCE: reverse-iterator iterator-adapter
M: reverse-iterator iterator-increment* base>> iterator-decrement ;
M: reverse-iterator iterator-clone* base>> <reverse-iterator> ;
M: reverse-iterator iterator-decrement* base>> iterator-increment ;
M: reverse-iterator iterator-advance* [ math:neg ] dip base>> iterator-advance ;
M: reverse-iterator iterator-difference* [ base>> ] bi@ swap iterator-difference ;
