USING: kernel tools.test ainan.using ;

AINAN-USING: sequences math ;

[ 1 2 3 ] [ 1 2 3 4 drop ] unit-test
{ 2 3 4 5 } [ { 1 2 3 4 } [ 1 math:+ ] sequences:each ] unit-test
