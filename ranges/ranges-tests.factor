USING: kernel ainan.using tools.test ainan.ranges ;

AINAN-USING: sequences math ;
AINAN-USING: ainan.ranges ;

[ t ] [ t ] unit-test
! [ { 2 3 4 5 } ] [ { 1 2 3 4 5 6 7 } -1 -2 ainan.ranges:offset ] unit-test
[ { 2 3 4 5 } ] [ { 1 2 3 4 } [ math:1+ ] map as-seq ] unit-test
