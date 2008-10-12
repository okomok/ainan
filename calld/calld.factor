! Copyright (C) 2008 okomok
! See http://factorcode.org/license.txt for BSD license.

USING: kernel ;

IN: ainan.calld

! x y [ q ] calld => x q y
: ainan-calld ( x y quot -- ) swap >r call r> ;
