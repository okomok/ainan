! Copyright (C) 2008 okomok
! See http://factorcode.org/license.txt for BSD license.

USING: accessors kernel ainan.ranges.iterator ;

IN: ainan.ranges


! range mixin

MIXIN: range

GENERIC: begin* ( rng -- iter )
GENERIC: end* ( rng -- iter )
GENERIC: copy-range* ( from exemplar -- newrng ) ! optional

: begin begin* ; inline
: end end* ; inline
: copy-range copy-range* ; inline


! range-traversal-tag

: range-traversal-tag ( rng -- tag ) begin iterator-traversal-tag ;


! begin-end

: begin-end ( rng -- begin end ) [ begin ] [ end ] bi ; inline


! iter-range

TUPLE: iter-range { begin read-only } { end read-only } ;
C: <iter-range> iter-range

INSTANCE: iter-range range
M: iter-range begin* begin>> ;
M: iter-range end* end>> ;
