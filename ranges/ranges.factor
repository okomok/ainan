! Copyright (C) 2008 okomok
! See http://factorcode.org/license.txt for BSD license.

USING: kernel ainan.using ainan.calld ;
AINAN-USING: arrays io math quotations sequences sequences.private ;

IN: ainan.ranges



! hmm, mixin seems useless.


! read, write, swappable mixins are really needed?


! readable-iterator mixin

MIXIN: readable-iterator
GENERIC: iterator-read ( iter -- elt )


! writable-iterator mixin

MIXIN: writable-iterator
GENERIC: iterator-write ( elt iter -- )


! swappable-iterator mixin (maybe unneeded.)

MIXIN: swappable-iterator
GENERIC: iterator-swap ( iter iter -- )

INTERSECTION: read-write-iterator readable-iterator writable-iterator
INSTANCE: read-write-iterator swappable-iterator


! iterator traversal tags

GENERIC: iterator-traversal-tag ( iter -- tag )

SINGLETON: single-pass-iterator-tag
SINGLETON: forward-iterator-tag
SINGLETON: bidirectional-iterator-tag
SINGLETON: random-access-iterator-tag


! single-pass-iterator mixin

MIXIN: single-pass-iterator
GENERIC: iterator-equal? ( iter iter -- ? )
GENERIC: iterator-increment ( iter -- iter )
M: single-pass-iterator iterator-traversal-tag single-pass-iterator-tag


! forward-iterator mixin

MIXIN: forward-iterator
INSTANCE: forward-iterator input-iterator
M: forward-iterator iterator-traversal-tag forward-iterator-tag


! bidirectional-iterator mixin

MIXIN: bidirectional-iterator
INSTANCE: bidirectional-iterator forward-iterator
GENERIC: iterator-decrement ( iter -- iter )
M: bidirectional-iterator iterator-traversal-tag bidirectional-iterator-tag


! random-access-iterator mixin

MIXIN: random-access-iterator
INSTANCE: random-access-iterator bidirectional-iterator
GENERIC: iterator-advance ( n iter -- iter )
GENERIC: iterator-distance ( iter iter -- n )
M: random-access-iterator iterator-traversal-tag random-access-iterator-tag


! output-iterator mixin

MIXIN: output-iterator
GENERIC: iterator-output ( elt out -- )


! output-iterator instances

INSTANCE: quotations:callable output-iterator
M: quotations:callable iterator-output call ; ! is there callable iterator?

INTERSECTION: writable-single-pass-iterator writable-iterator single-pass-iterator ;
INSTANCE: writable-single-pass-iterator output-iterator
M: writable-single-pass-iterator iterator-output tuck iterator-write iterator-increment ;

INSTANCE: io:stream output-iterator
M: io:stream iterator-output io:stream-write1 ;


! adapter-iterator mixin

MIXIN: adapter-iterator

M: adapter-iterator iterator-tag base>> iterator-tag ;
M: adapter-iterator iterator-read base>> iterator-read ;
M: adapter-iterator iterator-write base>> iterator-write ;
M: adapter-iterator iterator-swap [ base>>] bi@ iterator-swap ;
M: adapter-iterator iterator-equal? [ base>> ] bi@ iterator-equal? ;
M: adapter-iterator iterator-increment base>> iterator-increment ;
M: adapter-iterator iterator-decrement base>> iterator-decrement ;
M: adapter-iterator iterator-advance base>> iterator-advance ;
M: adapter-iterator iterator-distance [ base>>] bi@ iterator-distance ;
M: adapter-iterator iterator-traversal-tag base>> iterator-traversal-tag ;


! number-iterator

TUPLE: number-iterator base ;
C: <number-iterator> number-iterator

M: number-iterator iterator-read base>> ;
M: number-iterator iterator-equal? [ base>> ] bi@ = ;
M: number-iterator iterator-increment [ math:1+ ] change-base ;
M: number-iterator iterator-decrement [ math:1- ] change-base ;
M: number-iterator iterator-advance swap [ math:+ ] curry change-base ;
M: number-iterator iterator-distance [ base>> ] bi@ swap math:- ;

INSTANCE: number-iterator readable-iterator
INSTANCE: number-iterator random-access-iterator


! outdirect-iterator

TUPLE: outdirect-iterator base ;
C: <outdirect-iterator> outdirect-iterator

M: outdirect-iterator iterator-read base>> ;
INSTANCE: outdirect-iterator adapter-iterator

INSTANCE: outdirect-iterator readable-iterator
INSTANCE: outdirect-iterator depends-on-base


! counting-iterator ! needed?

GENERIC: counting-iterator> ( num-or-iter -- iter )

M: number-iterator counting-iterator> <number-iterator>
M: outdirect-iterator counting-iterator> <outdirect-iterator>


! reverse-iterator

TUPLE: reverse-iterator base ;
C: <reverse-iterator> reverse-iterator

M: reverse-iterator iterator-increment base>> iterator-decrement ;
M: reverse-iterator iterator-decrement base>> iterator-increment ;
M: reverse-iterator iterator-advance [ math:neg ] ainan-calld base>> iterator-advance ;
M: reverse-iterator iterator-distance [ base>> ] bi@ swap iterator-distance ;
INSTANCE: reverse-iterator adapter-iterator

INSTANCE: reverse-iterator bidirectional-iterator
INSTANCE: reverse-iterator random-access-iterator if base is so.


! map-iterator

TUPLE: map-iterator base quot ;
C: <map-iterator> map-iterator

M: map-iterator iterator-read base>> iterator-read quot call ;
M: map-iterator iterator-write immutable ;
INSTANCE: map-iterator adapter-iterator

INSTANCE: map-iterator readable-iterator


! sequence-iterator

TUPLE: sequence-iterator base seq ;
: <sequence-iterator> ( n seq -- newiter ) [ <number-iterator> ] ainan-calld sequence-iterator boa ;

M: sequence-iterator iterator-read dup base>> swap seq>> [ iterator-read ] ainan-calld sequences:nth ;
M: sequence-iterator iterator-write dup base>> swap seq>> [ iterator-read ] ainan-calld sequences:set-nth ;
INSTANCE: sequence-iterator adapter-iterator

INSTANCE: sequence-iterator random-access-iterator


! advance

GENERIC: (advance) ( n iter -- iter )

M: single-pass-iterator (advance) [ iterator-increment ] curry math:times ;
M: random-access-iterator (advance) iterator-advance ;

: advance ( iter n -- iter ) swap (advance) ;


! iterator-swap

M: read-write-iterator iterator-swap
    2dup [ iterator-read ] bi@ swap clone swapd swap iterator-write swap iterator-write ;


! range mixin

MIXIN: range
GENERIC: begin ( rng -- iter )
GENERIC: end ( rng -- iter )

MIXIN: clonable-range
INSTANCE: clonable-range range
GENERIC: clone-range ( from exemplar -- newrng )

M: sequences:sequence clone-range sequences:clone-like ;
INSTANCE: sequences:sequence clonable-range


! iterator-range

TUPLE: iterator-range begin end ;
C: <iterator-range> iterator-range

M: iterator-range begin begin>> ;
M: iterator-range end end>> ;


! sequence range

M: sequences:sequence begin swap 0 <sequence-iterator> ;
M: sequences:sequence end dup [ sequences:length ] ainan-calld <sequence-iterator> ;

INSTANCE: sequences:sequence range


! range sequence

M: range sequences:length dup begin end iterator-distance ;
M: range sequences.private:nth-unsafe begin iterator-advance iterator-read ;
M: range sequences.private:set-nth-unsafe begin iterator-advance iterator-write ;

INSTANCE: range sequences:sequence


! do-accumulate

: (accumulate)

: accumulate ( rng seed quot -- result ) swap dup begin end quot (accumulate)


! distance

GENERIC: (distance) ( begin end -- n )

: (distance-iteration) ( n begin test -- n' begin test )

: single-pass-iterator (distance) ( begin end -- n ) accumulate ... ! 0 dupd [ iterator-equal? not ] 2curry swap [ iterator-increment ] curry [ ??? ] while ;
: random-access-iterator (distance) ( begin end -- n ) iterator-distance ;

: distance ( rng -- n ) begin end (distance) ;


! offset

: offset ( rng -- newrng ) begin end [ swap iter-advance ] bi* ;



! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!














! cursor

MIXIN: cursor

GENERIC: cursor-key ( cur -- key )
GENERIC: cursor-equal? ( cur cur -- ? )
GENERIC: cursor-increment ( cur -- cur )
GENERIC: cursor-decrement ( cur -- cur )
GENERIC: cursor-advance ( n cur -- cur )

M: single-pass-iterator cursor-key ;
M: single-pass-iterator cursor-equal? iterator-equal? ;
M: single-pass-iterator cursor-increment iterator-increment ;
M: bidirectional-iterator cursor-decrement iterator-decrement ;
M: random-access-iterator cursor-advance iterator-advance ;


! property-map

MIXIN: property-map

GENERIC: property-map-read ( key pmap -- elt )
GENERIC: property-map-write ( elt key pmap -- )


! property-map-iterator

TUPLE: property-map-iterator cur pmap ;
C: <property-map-iterator> property-map-iterator

M: property-map-iterator iterator-read dup >>cur cursor-key swap pmap>> property-map-read ;
M: property-map-iterator iterator-write dup >>cur cursor-map-key swap pmap>> property-map-write ;
M: property-map-iterator iterator-equal? [ cur>> ] bi@ cursor-equal? ;
M: property-map-iterator iterator-increment cur>> cursor-increment ;
M: property-map-iterator iterator-decrement cur>> cursor-decrement;
M: property-map-iterator iterator-advance cur>> cursor-advance ;

INSTANCE: property-map-iterator depends-on-base


! sequence-property-map

TUPLE: sequence-property-map ;
C: <sequence-property-map> sequence-property-map

M: sequence-property-map property-map-read sequences:nth ; ! index is key.
M: sequence-property-map property-map-write sequences:set-nth ;


TUPLE: sequence-iterator { seq read-only } n ;
C: <sequence-iterator> sequence-iterator

M: sequence-iterator iterator@ dup n>> swap seq>> sequences:nth;
M: sequence-iterator iterator= [ n>> ] bi@ = ;
M: sequence-iterator iterator1+ [ math:1+ ] change-n ;
M: sequence-iterator iterator1- [ math:1- ] change-n ;
M: sequence-iterator iterator+ swap [ math:+ ] curry change-n ;

INSTANCE: sequence-iterator random-access-iterator


! reverse-iterator

TUPLE: reverse-iterator { base read-only } ;
C: <reverse-iterator> reverse-iterator

M: reverse-iterator iterator@ base>> iterator@ ;
M: reverse-iterator iterator= base>> swap base>> iterator= ;
M: reverse-iterator iterator1+ base>> iterator1- ;
M: reverse-iterator iterator1- base>> iterator1+ ;
M: reverse-iterator iterator+ swap math:neg swap base>> iterator+;

M: reverse-iterator (>base) base>> ;

INSTANCE: reverse-iterator depends-on-base


INSTANCE: counting-iterator depends-on-count


! filter-iterator

TUPLE: filter-iterator { base read-only } { pmap read-only } ;
C: <filter-iterator> filter-iterator

M: filter-iterator (iterator@) base>> iterator@ ;
M: filter-iterator (iterator=) base>> base>> iterator= ;
M: filter-iterator (iterator1+) base>> iterator1- ;
M: filter-iterator (iterator1-) base>> iterator1+ ;
M: filter-iterator (iterator+) swap math:neg swap base>> iterator+;


! step-iterator

TUPLE: step-iterator { base read-only } { begin read-only } { end read-only } ;
C: <step-iterator> step-iterator

M: step-iterator (iterator@) base>> iterator@ ;
M: step-iterator (iterator=) base>> base>> iterator= ;
M: step-iterator (iterator1+) base>> iterator1 ;


! property-map

MIXIN: readable-property-map
MIXIN: writable-property-map
MIXIN: read-write-property-map

INSTANCE: read-write-property-map readable-property-map
INSTANCE: read-write-property-map writable-property-map

GENERIC: (read) ( key pmap -- value )
GENERIC: (write) ( value key pmap -- )
: read ( key pmap -- value ) (read) ; inline
: write ( value key pmap -- ) (write) ; inline


! immutable

TUPLE: immutable pmap ;
: immutable ( pmap -- * ) \ immutable boa throw ;


! immutable-property-map

TUPLE: immutable-property-map { base read-only } ;
C: <immutable-property-map> immutable-property-map

M: immutable-property-map (read) base>> read ;
M: immutable-property-map (write) immutable ;


! identity-property-map

TUPLE: identity-property-map ;
C: <identity-property-map> identity-property-map

M: identity-property-map (read) drop ;
M: identity-property-map (write) nip swap set ;


! transform-property-map

TUPLE: transform-property-map { base read-only } { quot read-only } ;
C: <transform-property-map> transform-property-map ;

M: transform-property-map (read) base>> quot>> call ;
M: transform-property-map (write) ?? ;


! sequence-property-map

TUPLE: sequence-property-map ;
C: <sequence-property-map> sequence-property-map

M: sequence-property-map (read) sequences:nth ; ! index is key.
M: sequence-property-map (write) sequences:set-nth ;


! range

MIXIN: range

GENERIC: (begin) ( rng -- iter )
GENERIC: (end) ( rng -- iter )
GENERIC: (pmap) ( rng -- pmap )

: begin ( rng -- iter ) (begin) ; inline
: end ( rng -- iter ) (end) ; inline
: pmap ( rng -- pmap ) (pmap) ; inline

! M: range (pmap) <identity-property-map> ;


! sequence range

M: sequences:sequence (begin) 0 <counting-iterator> ;
M: sequences:sequence (end) sequences:length <counting-iterator> ;
M: sequences:sequence (pmap) <sequence-property-map> ;


! TUPLE: iterator-range { begin read-only } { end read-only } { pmap initial: <identity-property-map> } ;
! C: <iterator-range> iterator-range










! range methods

MIXIN: readable-range
MIXIN: writable-range
MIXIN: read-write-range

INSTANCE: writable-range basic-range
INSTANCE: read-write-range readable-range
INSTANCE: read-write-range writable-range

GENERIC: (begin) ( rng -- iter )
GENERIC: (end) ( rng -- iter )
GENERIC: (read) ( key rng -- elt )
GENERIC: (write) ( elt key rng -- )

: begin ( rng -- iter ) (begin) ; inline
: end ( rng -- iter ) (end) ; inline
: read ( key rng -- elt ) (read) ; inline
: write ( elt key rng -- ) (write) ; inline

: readable-range (write) immutable ;


! iterator-range

TUPLE: iterator-range begin end ;
C: <iterator-range> iterator-range

GENERIC: iterator-range (begin) begin>> ;
GENERIC: iterator-range (end) end>> ;


! base

GENERIC: (>base) ( rng' -- rng )
: >base ( rng' -- rng ) (>base) ; inline


! >immutable

TUPLE: >immutable rng ;

M: >immutable (read) rng>> read ;
M: >immutable (write) immutable ;


! counting-iterator

M: math:number (eql?) = ;
M: math:number (inc) math:1+ ;
M: math:number (dec) math:1- ;
M: math:number (adv) math:+ ;

TUPLE: couting-iterator count ; ! count is either a number or iterator.
C: <couting-iterator> counting-iterator

M: couting-iterator (key) count>> ;
M: couting-iterator (eql?) count>> count>> eql? ;
M: couting-iterator (inc) count>> inc ;
M: couting-iterator (dec) count>> dec ;
M: couting-iterator (adv) count>> adv ;

INSTANCE: counting-iterator random-access-iterator


! counting

TUPLE: counting { from read-only } { to read-only } ;

M: counting (begin) from>> <counting-iterator> ;
M: counting (end) to>> <counting-iterator> ;
M: counting (read) drop ;
M: counting (write) immutable ;

INSTANCE: counting ???-iterator


! reverse-iterator

TUPLE: reverse-iterator { base read-only } ;
C: <reverse-iterator> reverse-iterator

M: reverse-iterator (key) base>> key ;
M: reverse-iterator (inc) base>> dec ;
M: reverse-iterator (dec) base>> inc ;
M: reverse-iterator (adv) base>> negate adv;

M: reverse-iterator (>base) base>> ;


! <reverse-range>

: <reverse-range> ( rng -- rng' )
    dup begin end [ <reverse-iterator> ] bi@ swap <range> ;


! transform-range

TUPLE: transform-range base quot
C: <transform-range> transform-range

M: transform-range (begin) base>> begin ;
M: transform-range (end) base>> end ;
! M: transform-range (begin-end) >base begin-end ;
M: transform-range (read) dup quot>> base>> read call ;
M: transform-range (write) read quot>> call set ;

M: transform-range (>base) >>base ;


! transform-iterator unneeded?

TUPLE: transform-iterator base quot ;

M: transform-iterator (key) count>> ;
M: transform-iterator (inc) base>> inc quot>> transform-iterator boa ;
M: transform-iterator (dec) base>> dec quot>> transform-iterator boa ;
M: transform-iterator (adv) swap base>> adv quot>> transform-iterator boa ;


! sequence

M: sequences:sequence (begin) drop 0 <couting-iterator> ; ! index is a key.
M: sequences:sequence (end) sequences:length <couting-iterator> ;
M: sequences:sequence (read) sequences:nth
M: sequences:sequence (write) sequences:set-nth



! trivial algorithms

: length ( rng -- n ) dup begin end - ;
: nth ( rng n -- elt ) over begin adv swap read ;

: (each) ( quot end begin -- quot end begin' )
    pick ! quot end begin quot
    2over ! quot end begin quot end begin
    equal ! quot end begin quot ?
    swap swap ! quot end ? begin quot
    [ call ] 2curry ! quot end ? [ begin quot call ]
    [] swap ! quot end ? [] [ begin quot call ]
    if
    (each)
;

: (each-quote) ( quot -- quot )

: each ( rng quot -- )
    dupd dupd ! rng rng rng quot
    with ! rng rng quot'
    swap swap ! quot' rng rng
    end ! quot' rng end
    swap ! quot' end rng
    begin ! quot' end begin
;













