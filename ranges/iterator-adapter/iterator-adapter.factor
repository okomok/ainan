! Copyright (C) 2008 okomok
! See http://factorcode.org/license.txt for BSD license.

USING: accessors kernel ainan.ranges.iterator ;

IN: ainan.ranges


MIXIN: iterator-adapter

INSTANCE: iterator-adapter iterator
M: iterator-adapter iterator-traversal-tag* base>> iterator-traversal-tag ;
M: iterator-adapter iterator-read* base>> iterator-read ;
M: iterator-adapter iterator-write* base>> iterator-write ;
M: iterator-adapter iterator-equal?* [ base>> ] bi@ iterator-equal? ;
M: iterator-adapter iterator-increment* [ iterator-increment ] change-base ; ! dup base>> iterator-increment drop ;
M: iterator-adapter iterator-decrement* [ iterator-decrement ] change-base ; ! dup base>> iterator-decrement drop ;
M: iterator-adapter iterator-advance* [ iterator-advance ] with change-base ; ! tuck base>> iterator-advance drop ;
M: iterator-adapter iterator-difference* [ base>> ] bi@ iterator-difference ;
