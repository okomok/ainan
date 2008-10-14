USING: kernel ainan.using tools.test ;

AINAN-USING: sequences math ;
AINAN-USING: ainan.ranges ;

[ t ] [ t ] unit-test
! [ { 2 3 4 5 } ] [ { 1 2 3 4 5 6 7 } -1 -2 ainan.ranges:offset } unit-test

