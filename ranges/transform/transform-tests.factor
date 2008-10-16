USING: math kernel ainan.using tools.test ainan.ranges ainan.ranges.transform
ainan.ranges.to_seq ainan.ranges.sequence ;

[ t ] [ t ] unit-test
[ V{ 11 21 31 41 } ] [ { 10 20 30 40 } [ 1+ ] transform range>seq ] unit-test
