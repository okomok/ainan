! Copyright (C) 2008 okomok
! See http://factorcode.org/license.txt for BSD license.

USING: kernel ainan.ranges.each ;

IN: ainan.ranges

! SEE: lists:foldl


: accumulate ( rng identity quot -- ) swapd each ; inline
