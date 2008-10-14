! Copyright (C) 2008 okomok
! See http://factorcode.org/license.txt for BSD license.

USING: kernel accessors ainan.using ;
AINAN-USING: arrays io math quotations sequences sequences.private ;

IN: ainan.ranges


! iterator protocol

MIXIN: iterator
GENERIC: iterator-traversal-tag* ( iter -- tag )
: iterator-traversal-tag iterator-traversal-tag* ; inline


! value-access protocol

GENERIC: iterator-read* ( iter -- elt )
GENERIC: iterator-write* ( elt iter -- )
GENERIC: iterator-swap* ( iter iter -- )
: iterator-read iterator-read* ; inline
: iterator-write iterator-write* ; inline
: iterator-swap iterator-swap* ; inline

M: iterator iterator-swap* ! default behavior
    2dup [ iterator-read ] bi@ swap clone swapd swap iterator-write swap iterator-write ;


! single-pass-traversal protocol

GENERIC: iterator-equal?* ( iter iter -- ? )
GENERIC: iterator-increment* ( iter -- iter )
: iterator-equal? iterator-equal?* ; inline
: iterator-increment iterator-increment* ; inline


! forward-traversal protocol

GENERIC: iterator-clone* ( iter -- newiter )
: iterator-clone iterator-clone* ; inline

M: iterator iterator-clone* clone ; ! default behavior


! bidirectional-traversal protocol

GENERIC: iterator-decrement* ( iter -- iter )
: iterator-decrement iterator-decrement* ; inline


! random-access-traversal protocol

GENERIC: iterator-advance* ( n iter -- iter )
GENERIC: iterator-difference* ( iter iter -- n )
: iterator-advance iterator-advance* ; inline
: iterator-difference iterator-difference* ; inline


! output protocol

MIXIN: output
GENERIC: output-write* ( elt out -- )
: output-write output-write* ; inline


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


! delegate-iterator mixin

MIXIN: delegate-iterator

INSTANCE: delegate-iterator iterator
M: delegate-iterator iterator-traversal-tag* base>> iterator-traversal-tag ;
M: delegate-iterator iterator-read* base>> iterator-read ;
M: delegate-iterator iterator-write* base>> iterator-write ;
M: delegate-iterator iterator-swap* [ base>> ] bi@ iterator-swap ;
M: delegate-iterator iterator-equal?* [ base>> ] bi@ iterator-equal? ;
M: delegate-iterator iterator-increment* dup base>> iterator-increment drop ;
M: delegate-iterator iterator-decrement* dup base>> iterator-decrement drop ;
M: delegate-iterator iterator-advance* tuck base>> iterator-advance drop ;
M: delegate-iterator iterator-difference* [ base>> ] bi@ iterator-difference ;


! outdirect-iterator

TUPLE: outdirect-iterator base ;
C: <outdirect-iterator> outdirect-iterator

INSTANCE: outdirect-iterator delegate-iterator
M: outdirect-iterator iterator-read* base>> ;
M: outdirect-iterator iterator-clone* base>> <outdirect-iterator> ;


! reverse-iterator

TUPLE: reverse-iterator base ;
C: <reverse-iterator> reverse-iterator

INSTANCE: reverse-iterator delegate-iterator
M: reverse-iterator iterator-increment* base>> iterator-decrement ;
M: reverse-iterator iterator-clone* base>> <reverse-iterator> ;
M: reverse-iterator iterator-decrement* base>> iterator-increment ;
M: reverse-iterator iterator-advance* [ math:neg ] dip base>> iterator-advance ;
M: reverse-iterator iterator-difference* [ base>> ] bi@ swap iterator-difference ;


! map-iterator

TUPLE: map-iterator base { quot read-only } ;
C: <map-iterator> map-iterator

INSTANCE: map-iterator delegate-iterator
M: map-iterator iterator-read* [ base>> ] [ quot>> ] bi [ iterator-read ] [ call ] bi* ;
M: map-iterator iterator-clone* [ base>> ] [ quot>> ] bi <map-iterator> ;


! filter-iterator

TUPLE: filter-iterator base { quot read-only } ;
C: <filter-iterator> filter-iterator

INSTANCE: filter-iterator delegate-iterator
M: filter-iterator iterator-increment* base>> iterator-decrement ;
M: filter-iterator iterator-clone* [ base>> ] [ quot>> ] bi <filter-iterator> ;
M: filter-iterator iterator-decrement* base>> iterator-increment ;
M: filter-iterator iterator-advance* [ math:neg ] dip base>> iterator-advance ;
M: filter-iterator iterator-difference* [ base>> ] bi@ swap iterator-difference ;


! sequence-iterator

TUPLE: sequence-iterator base { seq read-only } ;
: <sequence-iterator> ( n seq -- newiter ) [ <number-iterator> ] dip sequence-iterator boa ;

INSTANCE: sequence-iterator delegate-iterator
M: sequence-iterator iterator-traversal-tag* drop <random-access-iterator-tag> ;
M: sequence-iterator iterator-read* dup base>> swap seq>> [ iterator-read ] dip sequences:nth ;
M: sequence-iterator iterator-write* dup base>> swap seq>> [ iterator-read ] dip sequences:set-nth ;
M: sequence-iterator iterator-clone* [ base>> ] [ seq>> ] bi sequence-iterator boa ; 


! iterator output

INSTANCE: iterator output
M: iterator output-write* tuck iterator-write iterator-increment ;


! callable output

INSTANCE: quotations:callable output ! is there callable iterator?
M: quotations:callable output-write* call ;


! stream output

! INSTANCE: io:stream output ! io:stream mixin is missing.
! M: io:stream output-write* io:stream-write1 ;
: stream-output ( stm -- out ) [ io:stream-write1 ] curry ;


! range mixin

MIXIN: range
GENERIC: begin* ( rng -- iter )
GENERIC: end* ( rng -- iter )
GENERIC: clone* ( from exemplar -- newrng ) ! optional
: begin begin* ; inline
: end end* ; inline
: clone clone* ; inline


! begin-end

: begin-end ( rng -- begin end )
    [ begin ] [ end ] bi ; inline


! for-each

: ((iter-for-each)) ( iter quot -- iter quot )
    [ [ iterator-read ] dip call ] [ [ iterator-increment ] dip ] 2bi ; inline

: (iter-for-each) ( end begin quot -- )
    2over iterator-equal? [ 3drop ] [ ((iter-for-each)) (iter-for-each) ] if ; inline

: iter-for-each ( begin end quot -- )
    swapd (iter-for-each) ; inline

: for-each ( rng quot -- )
    [ begin-end ] dip iter-for-each ; inline


! accumulate

: iter-accumulate ( begin end identity quot -- final )
    [ -rot ] dip iter-for-each ; inline

: accumulate ( rng identity quot -- )
    [ begin-end ] 2slip ; inline


! iter-advance

GENERIC: (iter-advance) ( iter n tag -- iter )
: iter-advance ( iter n -- iter ) over iterator-traversal-tag (iter-advance) ; inline

M: single-pass-iterator-tag (iter-advance) drop swap [ iterator-increment ] curry math:times ;
M: random-access-iterator-tag (iter-advance) drop swap iterator-advance ;


! iter-distance

GENERIC: (iter-distance) ( begin end tag -- n )
: iter-distance ( begin end -- n ) dup iterator-traversal-tag (iter-distance) ; inline

M: single-pass-iterator-tag (iter-distance) drop 0 [ drop 1 math:+ ] accumulate ;
M: random-access-iterator-tag (iter-distance) drop swap iterator-difference ;


! distance

: distance ( rng -- n ) begin-end iter-distance ; inline


! empty?

: empty? ( rng -- ? ) begin-end iterator-equal? ; inline


! iter-range

TUPLE: iter-range { begin read-only } { end read-only } ;
C: <iter-range> iter-range

INSTANCE: iter-range range
M: iter-range begin* begin>> ;
M: iter-range end* end>> ;


! map

: map ( rng quot -- rng )
    [ begin-end ] dip [ <map-iterator> ] curry bi@ <iter-range> ;


! numbers

: numbers ( n m -- rng )
    [ <number-iterator> ] bi@ <iter-range> ;


! offset

: offset ( rng n m -- rng )
    [ begin-end ] 2slip [ swap iter-advance ] bi* <iter-range> ;


! sequence random-access-range

INSTANCE: sequences:sequence range
M: sequences:sequence begin* 0 swap <sequence-iterator> ;
M: sequences:sequence end* dup [ sequences:length ] dip <sequence-iterator> ;
M: sequences:sequence clone* sequences:clone-like ;


! random-access-range sequence

! Hmm, seems to result in cyclic recursion.
! INSTANCE: range sequences:sequence
! M: range sequences:length begin-end swap iterator-difference ;
! M: range sequences.private:nth-unsafe begin iterator-advance iterator-read ;
! M: range sequences.private:set-nth-unsafe begin iterator-advance iterator-write ;

! also cyclic recursion.
TUPLE: as-seq { rng read-only } ;
C: <as-seq> as-seq
! INSTANCE: as-seq sequences:sequence
! M: as-seq sequences:length rng>> begin-end swap iterator-difference ;
! M: as-seq sequences.private:nth-unsafe rng>> begin iterator-advance iterator-read ;
! M: as-seq sequences.private:set-nth-unsafe rng>> begin iterator-advance iterator-write ;

: range>seq ( rng -- newseq ) ;


