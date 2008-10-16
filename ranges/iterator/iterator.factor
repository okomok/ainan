! Copyright (C) 2008 okomok
! See http://factorcode.org/license.txt for BSD license.

USING: math kernel ainan.qualified ;
AINAN-QUALIFIED: math ;

IN: ainan.ranges


! iterator protocol

MIXIN: iterator
GENERIC: iterator-traversal-tag* ( iter -- tag )
: iterator-traversal-tag iterator-traversal-tag* ; inline


! iterator-incompatible-error

TUPLE: iterator-incompatible-error iter1 iter2 ;
: iterator-incompatible-error ( iter1 iter2 -- * ) \ iterator-incompatible-error boa throw ;


! element-access protocol

GENERIC: iterator-read* ( iter -- elt )
GENERIC: iterator-write* ( elt iter -- )
: iterator-read iterator-read* ; inline
: iterator-write iterator-write* ; inline


! single-pass-traversal protocol

GENERIC: iterator-equal?* ( iter1 iter2 -- ? )
GENERIC: iterator-increment* ( iter -- iter )
: iterator-equal? iterator-equal?* ; inline
: iterator-increment iterator-increment* ; inline


! forward-traversal protocol

GENERIC: iterator-clone* ( iter -- newiter )
: iterator-clone iterator-clone* ; inline


! bidirectional-traversal protocol

GENERIC: iterator-decrement* ( iter -- iter )
: iterator-decrement iterator-decrement* ; inline


! random-access-traversal protocol

GENERIC: iterator-advance* ( n iter -- iter )
GENERIC: iterator-difference* ( iter1 iter2 -- n )
: iterator-advance iterator-advance* ; inline
: iterator-difference iterator-difference* ; inline


! iterator traversal tags

TUPLE: single-pass-iterator-tag ;
TUPLE: forward-iterator-tag < single-pass-iterator-tag ;
TUPLE: bidirectional-iterator-tag < forward-iterator-tag ;
TUPLE: random-access-iterator-tag < bidirectional-iterator-tag ;
C: <single-pass-iterator-tag> single-pass-iterator-tag
C: <forward-iterator-tag> forward-iterator-tag
C: <bidirectional-iterator-tag> bidirectional-iterator-tag
C: <random-access-iterator-tag> random-access-iterator-tag


! minimum-traversal-tag

: minimum-traversal-tag ( tag tag -- tag ) ;


! iter-swap

: iter-swap ( iter1 iter2 -- )
    [ [ iterator-read ] dip iterator-write ] 2keep iterator-read swap iterator-write ;


! iter-advance

GENERIC: (iter-advance) ( iter n tag -- iter )
: iter-advance ( iter n -- iter ) over iterator-traversal-tag (iter-advance) ; inline

M: single-pass-iterator-tag (iter-advance) drop swap [ iterator-increment ] curry math:times ;
M: random-access-iterator-tag (iter-advance) drop swap iterator-advance ;
