! Copyright (C) 2008 okomok
! See http://factorcode.org/license.txt for BSD license.

USING: kernel accessors ainan.using ;
AINAN-USING: arrays io math quotations sequences sequences.private vectors ;

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
M: delegate-iterator iterator-equal?* [ base>> ] bi@ iterator-equal? ;
M: delegate-iterator iterator-increment* [ iterator-increment ] change-base ; ! dup base>> iterator-increment drop ;
M: delegate-iterator iterator-decrement* [ iterator-decrement ] change-base ; ! dup base>> iterator-decrement drop ;
M: delegate-iterator iterator-advance* [ iterator-advance ] with change-base ; ! tuck base>> iterator-advance drop ;
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
GENERIC: copy-range* ( from exemplar -- newrng ) ! optional
: begin begin* ; inline
: end end* ; inline
: copy-range copy-range* ; inline


! range-traversal-tag

: range-traversal-tag ( rng -- tag ) begin iterator-traversal-tag ;


! begin-end

: begin-end ( rng -- begin end ) [ begin ] [ end ] bi ; inline


! accum-range

TUPLE: accum-range begin { end read-only } ;
: <accum-range> ( rng -- arng ) begin-end accum-range boa ;
: accum-elt ( arng -- elt ) begin>> iterator-read ;
: accum-next ( arng -- arng ) [ iterator-increment ] change-begin ;
: accum-end? ( arng -- ? ) [ begin>> ] [ end>> ] bi iterator-equal? ;


! for-each ( SEE: lists:leach )

: ((for-each)) ( arng quot -- arng quot ) [ [ accum-elt ] dip call ] [ [ accum-next ] dip ] 2bi ; inline
: (for-each) ( arng quot -- ) over accum-end? [ 2drop ] [ ((for-each)) (for-each) ] if ; inline
: for-each ( rng quot -- ) [ <accum-range> ] dip (for-each) ; inline


! accumulate ( SEE: lists:foldl )

: accumulate ( rng identity quot -- ) swapd for-each ; inline


! copy

: copy ( rng out -- out ) tuck [ output-write ] curry for-each ; inline


! count

! : count ( rng pred -- n ) filter 0 <counter> copy base>> ;


! iter-swap

: iter-swap ( iter1 iter2 -- )
    [ [ iterator-read ] dip iterator-write ] 2keep iterator-read swap iterator-write ;


! iter-advance

GENERIC: (iter-advance) ( iter n tag -- iter )
: iter-advance ( iter n -- iter ) over iterator-traversal-tag (iter-advance) ; inline

M: single-pass-iterator-tag (iter-advance) drop swap [ iterator-increment ] curry math:times ;
M: random-access-iterator-tag (iter-advance) drop swap iterator-advance ;


! distance

GENERIC: (distance) ( rng tag -- n )
: distance ( rng -- n ) dup range-traversal-tag (distance) ; inline

M: single-pass-iterator-tag (distance) drop 0 [ drop math:1+ ] accumulate ;
M: random-access-iterator-tag (distance) drop begin-end swap iterator-difference ;


! empty?

: empty? ( rng -- ? ) begin-end iterator-equal? ; inline


! iter-range

TUPLE: iter-range { begin read-only } { end read-only } ;
C: <iter-range> iter-range

INSTANCE: iter-range range
M: iter-range begin* begin>> ;
M: iter-range end* end>> ;


! numbers

: numbers ( n m -- rng ) [ <number-iterator> ] bi@ <iter-range> ;


! offset

: offset ( rng n m -- rng ) [ begin-end ] 2slip [ swap iter-advance ] bi* <iter-range> ;


! sequence random-access-range

INSTANCE: sequences:sequence range
M: sequences:sequence begin* 0 swap <sequence-iterator> ;
M: sequences:sequence end* dup [ sequences:length ] dip <sequence-iterator> ;
M: sequences:sequence copy-range* sequences:clone-like ;


! random-access-range sequence

! Hmm, seems to result in cyclic recursion.
! INSTANCE: range sequences:sequence
! M: range sequences:length begin-end swap iterator-difference ;
! M: range sequences.private:nth-unsafe begin iterator-advance iterator-read ;
! M: range sequences.private:set-nth-unsafe begin iterator-advance iterator-write ;

! also makes some problem.
TUPLE: as-seq { rng read-only } ;
C: <as-seq> as-seq
! INSTANCE: as-seq sequences:sequence
! M: as-seq sequences:length rng>> begin-end swap iterator-difference ;
! M: as-seq sequences.private:nth-unsafe rng>> begin iterator-advance iterator-read ;
! M: as-seq sequences.private:set-nth-unsafe rng>> begin iterator-advance iterator-write ;


! range>seq

: range>seq ( rng -- newseq ) 0 vectors:<vector> [ sequences:suffix ] accumulate ;

