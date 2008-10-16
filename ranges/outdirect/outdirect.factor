! Copyright (C) 2008 okomok
! See http://factorcode.org/license.txt for BSD license.

USING: accessors kernel
    ainan.ranges.iterator ainan.ranges.iterator-adapter ainan.ranges.iter-range ainan.ranges.range ;

IN: ainan.ranges


! outdirect-iterator

TUPLE: outdirect-iterator base ;
C: <outdirect-iterator> outdirect-iterator

INSTANCE: outdirect-iterator iterator-adapter
M: outdirect-iterator iterator-read* base>> ;
M: outdirect-iterator iterator-clone* base>> iterator-clone <outdirect-iterator> ;


! outdirect

: outdirect ( rng -- rng ) begin-end [ <outdirect-iterator> ] bi@ <iter-range> ;
