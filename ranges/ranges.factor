! Copyright (C) 2008 okomok
! See http://factorcode.org/license.txt for BSD license.

USING: kernel ainan.using ;
AINAN-USING: arrays assoc io lists math quotations sequences sequences.private ;

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


! traversal protocol

GENERIC: iterator-equal?* ( iter iter -- ? )
GENERIC: iterator-increment* ( iter -- iter )
GENERIC: iterator-decrement* ( iter -- iter )
GENERIC: iterator-advance* ( n iter -- iter )
GENERIC: iterator-distance* ( iter iter -- n )
: iterator-equal? iterator-equal?* ; inline
: iterator-increment iterator-increment* ; inline
: iterator-decrement iterator-decrement* ; inline
: iterator-advance iterator-advance* ; inline
: iterator-distance iterator-distance* ; inline


! output protocol

MIXIN: output
GENERIC: output-write* ( elt out -- )
: output-write output-write* ; inline


! iterator traversal tags

TUPLE: single-pass-iterator-tag ;
TUPLE: forward-iterator-tag < single-pass-itarator-tag ;
TUPLE: bidirectional-iterator-tag < forward-iterator-tag ;
TUPLE: random-access-iterator-tag < bidirectional-iterator-tag ;
C: <single-pass-iterator-tag> single-pass-iterator-tag
C: <forward-iterator-tag> forward-iterator-tag
C: <bidirectional-iterator-tag> bidirectional-iterator-tag
C: <random-access-iterator-tag> random-access-pass-iterator-tag


! minimum-traversal-tag

: minimum-traversal-tag ( tag tag -- tag ) ... ;


! delegate-iterator mixin

MIXIN: delegate-iterator

INSTANCE: delegate-iterator iterator
M: delegate-iterator iterator-traversal-tag* base>> iterator-traversal-tag ;
M: delegate-iterator iterator-read* base>> iterator-read ;
M: delegate-iterator iterator-write* base>> iterator-write ;
M: delegate-iterator iterator-swap* [ base>>] bi@ iterator-swap ;
M: delegate-iterator iterator-equal?* [ base>> ] bi@ iterator-equal? ;
M: delegate-iterator iterator-increment* base>> iterator-increment ;
M: delegate-iterator iterator-decrement* base>> iterator-decrement ;
M: delegate-iterator iterator-advance* base>> iterator-advance ;
M: delegate-iterator iterator-distance* [ base>>] bi@ iterator-distance ;


! number-iterator

TUPLE: number-iterator base ;
C: <number-iterator> number-iterator

INSTANCE: number-iterator iterator
M: number-iterator iterator-traversal-tag* <random-access-iterator-tag> ;
M: number-iterator iterator-read* base>> ;
M: number-iterator iterator-equal?* [ base>> ] bi@ = ;
M: number-iterator iterator-increment* [ math:1+ ] change-base ;
M: number-iterator iterator-decrement* [ math:1- ] change-base ;
M: number-iterator iterator-advance* swap [ math:+ ] curry change-base ;
M: number-iterator iterator-distance* [ base>> ] bi@ swap math:- ;


! outdirect-iterator

TUPLE: outdirect-iterator base ;
C: <outdirect-iterator> outdirect-iterator

INSTANCE: outdirect-iterator delegate-iterator
M: outdirect-iterator iterator-read* base>> ;


! counting-iterator ! unneeded?

GENERIC: counting-iterator> ( num-or-iter -- iter )

M: number-iterator counting-iterator> <number-iterator>
M: outdirect-iterator counting-iterator> <outdirect-iterator>


! reverse-iterator

TUPLE: reverse-iterator base ;
C: <reverse-iterator> reverse-iterator

INSTANCE: reverse-iterator delegate-iterator
M: reverse-iterator iterator-increment* base>> iterator-decrement ;
M: reverse-iterator iterator-decrement* base>> iterator-increment ;
M: reverse-iterator iterator-advance* [ math:neg ] slip base>> iterator-advance ;
M: reverse-iterator iterator-distance* [ base>> ] bi@ swap iterator-distance ;


! map-iterator

TUPLE: map-iterator base quot ;
C: <map-iterator> map-iterator

INSTANCE: map-iterator delegate-iterator
M: map-iterator iterator-read* base>> iterator-read quot call ;


! filter-iterator

TUPLE: filter-iterator base ;
C: <filter-iterator> filter-iterator

INSTANCE: filter-iterator delegate-iterator
M: filter-iterator iterator-increment* base>> iterator-decrement ;
M: filter-iterator iterator-decrement* base>> iterator-increment ;
M: filter-iterator iterator-advance* [ math:neg ] slip base>> iterator-advance ;
M: filter-iterator iterator-distance* [ base>> ] bi@ swap iterator-distance ;


! sequence-iterator

TUPLE: sequence-iterator base seq ;
: <sequence-iterator> ( n seq -- newiter ) [ <number-iterator> ] slip sequence-iterator boa ;

INSTANCE: sequence-iterator delegate-iterator
M: sequence-iterator iterator-traversal-tag* <random-access-iterator-tag> ;
M: sequence-iterator iterator-read* dup base>> swap seq>> [ iterator-read ] slip sequences:nth ;
M: sequence-iterator iterator-write* dup base>> swap seq>> [ iterator-read ] slip sequences:set-nth ;


! list-iterator

TUPLE: list-iterator cons ;

INSTANCE: list-iterator iterator ;
M: list-iterator iterator-traversal-tag* <forward-iterator-tag> ;
M: list-iterator iterator-read* cons>> lists:car ;
M: list-iterator iterator-equal?* [ cons>> ] bi@ eq? ;
M: list-iterator iterator-increment* cons>> lists:cdr ;


! iterator output

INSTANCE: iterator output
M: iterator output-write* tuck iterator-write iterator-increment ;


! callable output

INSTANCE: quotations:callable output ! is there callable iterator?
M: quotations:callable output-write* call ;


! stream output

INSTANCE: io:stream output
M: io:stream output-write* io:stream-write1 ;


! begin-end

: begin-end ( rng -- begin end )
    [ begin ] [ end ] bi ; inline


! for-each

: ((iter-for-each)) ( iter quot -- iter quot )
    [ [ iterator-read ] dip call ] [ [ iterator-increment ] dip ] 2bi ;

: (iter-for-each) ( end begin quot -- )
    2over iterator-equal? [ 3drop ] [ ((iter-for-each)) (iter-for-each) ] if ;

: iter-for-each ( begin end quot -- )
    swapd (iter-for-each) ; inline

: for-each ( rng quot -- )
    [ begin-end ] slip ; inline


! accumulate

: iter-accumulate ( begin end identity quot -- final )
    [ -rot ] slip iter-for-each ; inline

: accumulate ( rng identity quot -- )
    [ begin-end ] 2slip ; inline


! iter-swap

: iter-swap iterator-swap* ; inline
M: iterator iterator-swap* 2dup [ iterator-read ] bi@ swap clone swapd swap iterator-write swap iterator-write ;


! iter-advance

GENERIC: (iter-advance) ( iter n tag -- iter )
: advance ( iter n -- iter ) over iterator-traversal-tag (iter-advance) ; inline

M: single-pass-iterator-tag (iter-advance) drop swap [ iterator-increment ] curry math:times ;
M: random-access-iterator-tag (iter-advance) drop swap iterator-advance ;


! iter-distance

GENERIC: (iter-distance) ( begin end tag -- n )
: iter-distance ( begin end -- n ) dup iterator-traversal-tag (iter-distance) ; inline

: single-pass-iterator-tag (iter-distance) drop accumulate ... ! 0 dupd [ iterator-equal? not ] 2curry swap [ iterator-increment ] curry [ ??? ] while ;
: random-access-iterator (iter-distance) drop swap iterator-distance ;


! range mixin

MIXIN: range
GENERIC: begin* ( rng -- iter )
GENERIC: end* ( rng -- iter )
GENERIC: clone* ( from exemplar -- newrng ) ! optional
: begin begin*
: end end*
: clone clone*


! distance

: distance ( rng -- n ) begin end iter-distance ;


! empty?

: empty? ( rng -- ? ) dup begin end iterator-equal? ;


! iter-range

TUPLE: iter-range begin end ;
C: <iter-range> iter-range

INSTANCE: iter-range range
M: iter-range begin begin>> ;
M: iter-range end end>> ;


! sequence random-access-range

INSTANCE: sequences:sequence range
M: sequences:sequence begin swap 0 <sequence-iterator> ;
M: sequences:sequence end dup [ sequences:length ] slip <sequence-iterator> ;
M: sequences:sequence clone sequences:clone-like ;


! random-access-range sequence

INSTANCE: range sequences:sequence
M: range sequences:length dup begin end iterator-distance ;
M: range sequences.private:nth-unsafe begin iterator-advance iterator-read ;
M: range sequences.private:set-nth-unsafe begin iterator-advance iterator-write ;


! list forward-range

INSTANCE: lists:list range
M: lists:list begin <list-iterator> ;
M: lists:list end lists:nil <list-iterator> ;
M: lists:list clone ?? lists:seq>cons ;


! forward-range list

INSTANCE: range lists:list
M: range lists:car begin iterator-read ;
M: range lists:cdr begin iterator-increment ;
M: range lists:nil? empty? ;


! offset

: offset ( rng n m -- newrng ) begin end [ swap iter-advance ] bi* ;











