! Copyright (C) 2008 okomok
! See http://factorcode.org/license.txt for BSD license.

USING: kernel ainan.using ;
AINAN-USING: arrays math sequences ;

IN: ainan.ranges


! cursor methods

GENERIC: (key) ( cur -- key )
GENERIC: (eql) ( cur cur -- ? )
GENERIC: (inc) ( cur -- cur )
GENERIC: (dec) ( cur -- cur )
GENERIC: (adv) ( n cur -- cur )
: key ( cur -- key ) (key) ; inline
: eql ( cur cur -- ? ) (eql) ; inline
: inc ( cur -- cur ) (inc) ; inline
: dec ( cur -- cur ) (dec) ; inline
: adv ( cur n -- cur ) swap (adv) ; inline


! immutable

TUPLE: immutable rng ;
: immutable ( rng -- * ) \ immutable boa throw ;


! range methods

TUPLE: range begin end ;


GENERIC: (begin) ( rng -- cur )
GENERIC: (end) ( rng -- cur )
: begin ( rng -- cur ) (begin) ; inline
: end ( rng -- cur ) (end) ; inline

! better?

GENERIC: (begin-end) ( rng -- cur cur )
: >begin-end ( rng -- cur cur ) (>range) ; inline

GENERIC: (>base) ( rng' -- rng )
: >base ( rng' -- rng ) (>base) ; inline

: begin ( rng -- cur ) >range drop ;
: end ( rng -- cur ) >range nip ;

GENERIC: (read) ( key rng -- elt )
GENERIC: (write) ( elt key rng -- ) immutable ;
: read ( cur rng -- elt ) key (read) ; inline
: write ( elt cur rng -- ) swap key swap (write) ; inline


! >immutable


TUPLE: >immutable rng ;

M: >immutable (read) rng>> read ;
M: >immutable (write) immutable ;


! couting-cursor

M: math:number (inc) math:1+
M: math:number (dec) math:1-
M: math:number (adv) math:+

TUPLE: couting-cursor count ; ! count is either a number or cursor.
: <couting-cursor> ( count -- couting-cursor ) couting-cursor boa ;

M: couting-cursor (key) count>> ;
M: couting-cursor (inc) count>> inc ;
M: couting-cursor (dec) count>> dec ;
M: couting-cursor (adv) count>> adv ;


! reverse-cursor

TUPLE: reverse-cursor base ;
M: reverse-cursor (>base) base>> ;
: <reverse-cursor> ( cur -- reverse-cursor ) reverse-cursor boa ;

M: couting-cursor (key) >base key ;
M: couting-cursor (inc) >base dec ;
M: couting-cursor (dec) >base inc ;
M: couting-cursor (adv) count>> adv ;


! <reverse-range>
: <reverse-range> ( rng -- rng' )
    begin-end [ <reverse-cursor> ] bi@ swap <range> ;


! counting

TUPLE: counting from to ;

M: counting (begin) from>> <counting-cursor> ;
M: counting (end) to>> <counting-cursor> ;
M: counting (read) drop ;


! transform-range

TUPLE: transform-range base quot
M: transform-range (>base) >>base ;

: <transform-range> ( rng quot -- rng' )
    transform-range boa ;

M: transform-range (begin-end) >base begin-end ;
M: transform-range (read) dup >>quot >base read call ;
M: transform-range (write) read >>quot call set ;

! M: transform-range (begin) base>> begin ;
! M: transform-range (end) base>> end ;


! transform-cursor unneeded?

TUPLE: transform-cursor base quot ;

M: transform-cursor (key) count>> ;
M: transform-cursor (inc) base>> inc quot>> transform-cursor boa ;
M: transform-cursor (dec) base>> dec quot>> transform-cursor boa ;
M: transform-cursor (adv) swap base>> adv quot>> transform-cursor boa ;


! array
!   key is index
M: arrays:array (begin) drop 0 <couting-cursor> ;
M: arrays:array (end) sequences:length <couting-cursor> ;
M: arrays:array (read) arrays:nth
M: arrays:array (write) arrays:set-nth



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













