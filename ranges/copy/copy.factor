! Copyright (C) 2008 okomok
! See http://factorcode.org/license.txt for BSD license.

USING: kernel ainan.ranges.each ainan.ranges.output ;

IN: ainan.ranges


: copy ( rng out -- out ) tuck [ output-write ] curry each ; inline
