! Copyright (C) 2008 okomok
! See http://factorcode.org/license.txt for BSD license.

USING: sequences sequences.private accessors kernel ainan.qualified
    ainan.ranges.iterator ainan.ranges.iterator ainan.ranges.iterator-adapter
    ainan.ranges.numbers ainan.ranges.range ;
AINAN-QUALIFIED: sequences sequences.private ;

IN: ainan.ranges


! sequence-iterator

TUPLE: sequence-iterator base { seq read-only } ;
: <sequence-iterator> ( n seq -- newiter ) [ <number-iterator> ] dip sequence-iterator boa ;

INSTANCE: sequence-iterator iterator-adapter
M: sequence-iterator iterator-traversal-tag* drop <random-access-iterator-tag> ;
M: sequence-iterator iterator-read* dup base>> swap seq>> [ iterator-read ] dip sequences:nth ;
M: sequence-iterator iterator-write* dup base>> swap seq>> [ iterator-read ] dip sequences:set-nth ;
M: sequence-iterator iterator-clone* [ base>> iterator-clone ] [ seq>> ] bi sequence-iterator boa ; 


! sequence random-access-range

INSTANCE: sequences:sequence range
M: sequences:sequence begin* 0 swap <sequence-iterator> ;
M: sequences:sequence end* dup [ sequences:length ] dip <sequence-iterator> ;
M: sequences:sequence copy-range* sequences:clone-like ;


! random-access-range sequence

! INSTANCE: range sequences:sequence ! results in cyclic recursion.

<PRIVATE TUPLE: as-seq-wrapper { rng read-only } ; PRIVATE>
C: as-seq as-seq-wrapper

INSTANCE: as-seq-wrapper sequences:sequence
M: as-seq-wrapper sequences:length rng>> begin-end swap iterator-difference ;
M: as-seq-wrapper sequences.private:nth-unsafe rng>> begin iterator-clone iterator-advance iterator-read ;
M: as-seq-wrapper sequences.private:set-nth-unsafe rng>> begin iterator-clone iterator-advance iterator-write ;
