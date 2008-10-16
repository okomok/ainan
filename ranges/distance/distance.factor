! Copyright (C) 2008 okomok
! See http://factorcode.org/license.txt for BSD license.

USING: math kernel ainan.qualified ainan.ranges.iterator ainan.ranges.range ;
AINAN-QUALIFIED: math ;

IN: ainan.ranges


GENERIC: (distance) ( rng tag -- n )
: distance ( rng -- n ) dup range-traversal-tag (distance) ; inline

M: single-pass-iterator-tag (distance) drop 0 [ drop math:1+ ] accumulate ;
M: random-access-iterator-tag (distance) drop begin-end swap iterator-difference ;
