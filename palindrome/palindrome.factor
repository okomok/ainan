! Copyright (C) 2008 okomok
! See http://factorcode.org/license.txt for BSD license.

USING: kernel sequences unicode.categories unicode.case qualified ;

IN: palindrome

QUALIFIED: sequences
QUALIFIED: unicode.categories
QUALIFIED-WITH: unicode.case filter

: filter ( x -- ) drop ;

: normalize ( str -- newstr ) [ unicode.categories:Letter? ] sequences:filter filter:>lower ;

: palindrome? ( string -- ? ) normalize dup sequences:reverse = ;
