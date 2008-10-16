! Copyright (C) 2008 okomok
! See http://factorcode.org/license.txt for BSD license.

USING: sequences accessors kernel ainan.qualified
    ainan.ranges.iterator ainan.ranges.iterator-adapter ainan.ranges.numbers ;
AINAN-QUALIFIED: sequences ;

IN: ainan.ranges


! sequence-iterator

TUPLE: sequence-iterator base { seq read-only } ;
: <sequence-iterator> ( n seq -- newiter ) [ <number-iterator> ] dip sequence-iterator boa ;

INSTANCE: sequence-iterator iterator-adapter
M: sequence-iterator iterator-traversal-tag* drop <random-access-iterator-tag> ;
M: sequence-iterator iterator-read* dup base>> swap seq>> [ iterator-read ] dip sequences:nth ;
M: sequence-iterator iterator-write* dup base>> swap seq>> [ iterator-read ] dip sequences:set-nth ;
M: sequence-iterator iterator-clone* [ base>> ] [ seq>> ] bi sequence-iterator boa ; 


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
