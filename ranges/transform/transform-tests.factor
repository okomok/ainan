USING: math kernel ainan.using tools.test ainan.ranges ainan.ranges.transform
ainan.ranges.to-seq ainan.ranges.sequence vectors ;

[ t ] [ t ] unit-test
! [ V{ 11 21 31 41 } ] [ { 10 20 30 40 } [ 1+ ] transform as-seq to-seq ] unit-test
[ V{ 11 21 31 41 } ] [ { 10 20 30 40 } [ 1+ ] transform as-seq >vector ] unit-test
