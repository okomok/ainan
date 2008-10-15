USING: kernel ainan.using tools.test ainan.ranges ainan.ranges.transform ;

AINAN-USING: sequences math ;

[ t ] [ t ] unit-test
[ V{ 11 21 31 41 } ] [ { 10 20 30 40 } [ math:1+ ] transform range>seq ] unit-test
