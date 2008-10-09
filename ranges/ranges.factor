! Copyright (C) 2008 okomok
! See http://factorcode.org/license.txt for BSD license.

USING: kernel ainan.using ;
AINAN-USING: arrays math sequences ;

IN: ainan.ranges


! cursor

MIXIN: single-pass-cursor
MIXIN: forward-cursor
MIXIN: bidirectional-cursor
MIXIN: random-access-cursor

INSTANCE: forward-cursor single-pass-cursor
INSTANCE: bidirectional-cursor forward-cursor
INSTANCE: random-access-cursor bidirectional-cursor

GENERIC: (cursor@) ( cur -- key )
GENERIC: (cursor=) ( cur cur -- ? )
GENERIC: (cursor1+) ( cur -- cur )
GENERIC: (cursor1-) ( cur -- cur )
GENERIC: (cursor+) ( n cur -- cur )

: cursor@ ( cur -- key ) (cursor@) ; inline
: cursor= ( cur cur -- ? ) (cursor=) ; inline
: cursor1+ ( cur -- cur ) (cursor1+) ; inline
: cursor1- ( cur -- cur ) (cursor1-) ; inline
: cursor+ ( n cur -- cur ) (cursor+) ; inline


! reverse-cursor

TUPLE: reverse-cursor { base read-only } ;
C: <reverse-cursor> reverse-cursor

M: reverse-cursor (cursor@) base>> cursor@ ;
M: reverse-cursor (cursor=) base>> base>> cursor= ;
M: reverse-cursor (cursor1+) base>> cursor1- ;
M: reverse-cursor (cursor1-) base>> cursor1+ ;
M: reverse-cursor (cursor+) swap math:neg swap base>> cursor+;

M: reverse-cursor (>base) base>> ;

INSTANCE: reverse-cursor depends-on-base


! counting-cursor

M: math:number (cursor=) = ;
M: math:number (cursor1+) math:1+ ;
M: math:number (cursor1-) math:1- ;
M: math:number (cursor+) math:+ ;

TUPLE: counting-cursor count ; ! count is either a number or cursor.
C: <counting-cursor> counting-cursor

M: counting-cursor (key) count>> ;
M: counting-cursor (eql?) count>> count>> eql? ;
M: counting-cursor (inc) count>> inc ;
M: counting-cursor (dec) count>> dec ;
M: counting-cursor (adv) count>> adv ;

INSTANCE: counting-cursor depends-on-count


! filter-cursor

TUPLE: filter-cursor { base read-only } { pmap read-only } ;
C: <filter-cursor> filter-cursor

M: filter-cursor (cursor@) base>> cursor@ ;
M: filter-cursor (cursor=) base>> base>> cursor= ;
M: filter-cursor (cursor1+) base>> cursor1- ;
M: filter-cursor (cursor1-) base>> cursor1+ ;
M: filter-cursor (cursor+) swap math:neg swap base>> cursor+;


! step-cursor

TUPLE: step-cursor { base read-only } { begin read-only } { end read-only } ;
C: <step-cursor> step-cursor

M: step-cursor (cursor@) base>> cursor@ ;
M: step-cursor (cursor=) base>> base>> cursor= ;
M: step-cursor (cursor1+) base>> cursor1 ;


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

GENERIC: (begin) ( rng -- cur )
GENERIC: (end) ( rng -- cur )
GENERIC: (pmap) ( rng -- pmap )

: begin ( rng -- cur ) (begin) ; inline
: end ( rng -- cur ) (end) ; inline
: pmap ( rng -- pmap ) (pmap) ; inline

! M: range (pmap) <identity-property-map> ;


! sequence range

M: sequences:sequence (begin) 0 <counting-cursor> ;
M: sequences:sequence (end) sequences:length <counting-cursor> ;
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

GENERIC: (begin) ( rng -- cur )
GENERIC: (end) ( rng -- cur )
GENERIC: (read) ( key rng -- elt )
GENERIC: (write) ( elt key rng -- )

: begin ( rng -- cur ) (begin) ; inline
: end ( rng -- cur ) (end) ; inline
: read ( key rng -- elt ) (read) ; inline
: write ( elt key rng -- ) (write) ; inline

: readable-range (write) immutable ;


! cursor-range

TUPLE: cursor-range begin end ;
C: <cursor-range> cursor-range

GENERIC: cursor-range (begin) begin>> ;
GENERIC: cursor-range (end) end>> ;


! base

GENERIC: (>base) ( rng' -- rng )
: >base ( rng' -- rng ) (>base) ; inline


! >immutable

TUPLE: >immutable rng ;

M: >immutable (read) rng>> read ;
M: >immutable (write) immutable ;


! counting-cursor

M: math:number (eql?) = ;
M: math:number (inc) math:1+ ;
M: math:number (dec) math:1- ;
M: math:number (adv) math:+ ;

TUPLE: couting-cursor count ; ! count is either a number or cursor.
C: <couting-cursor> counting-cursor

M: couting-cursor (key) count>> ;
M: couting-cursor (eql?) count>> count>> eql? ;
M: couting-cursor (inc) count>> inc ;
M: couting-cursor (dec) count>> dec ;
M: couting-cursor (adv) count>> adv ;

INSTANCE: counting-cursor random-access-cursor


! counting

TUPLE: counting { from read-only } { to read-only } ;

M: counting (begin) from>> <counting-cursor> ;
M: counting (end) to>> <counting-cursor> ;
M: counting (read) drop ;
M: counting (write) immutable ;

INSTANCE: counting ???-cursor


! reverse-cursor

TUPLE: reverse-cursor { base read-only } ;
C: <reverse-cursor> reverse-cursor

M: reverse-cursor (key) base>> key ;
M: reverse-cursor (inc) base>> dec ;
M: reverse-cursor (dec) base>> inc ;
M: reverse-cursor (adv) base>> negate adv;

M: reverse-cursor (>base) base>> ;


! <reverse-range>

: <reverse-range> ( rng -- rng' )
    dup begin end [ <reverse-cursor> ] bi@ swap <range> ;


! transform-range

TUPLE: transform-range base quot
C: <transform-range> transform-range

M: transform-range (begin) base>> begin ;
M: transform-range (end) base>> end ;
! M: transform-range (begin-end) >base begin-end ;
M: transform-range (read) dup quot>> base>> read call ;
M: transform-range (write) read quot>> call set ;

M: transform-range (>base) >>base ;


! transform-cursor unneeded?

TUPLE: transform-cursor base quot ;

M: transform-cursor (key) count>> ;
M: transform-cursor (inc) base>> inc quot>> transform-cursor boa ;
M: transform-cursor (dec) base>> dec quot>> transform-cursor boa ;
M: transform-cursor (adv) swap base>> adv quot>> transform-cursor boa ;


! sequence

M: sequences:sequence (begin) drop 0 <couting-cursor> ; ! index is a key.
M: sequences:sequence (end) sequences:length <couting-cursor> ;
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













