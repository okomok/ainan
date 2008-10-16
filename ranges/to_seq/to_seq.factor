! Copyright (C) 2008 okomok
! See http://factorcode.org/license.txt for BSD license.

USING: sequences vectors kernel ainan.qualified ainan.ranges.accumulate ;
AINAN-QUALIFIED: sequences vectors ;

IN: ainan.ranges


: to_seq ( rng -- newseq )
    0 vectors:<vector> [ sequences:suffix ] accumulate ; inline

: range>seq to_seq ; inline

