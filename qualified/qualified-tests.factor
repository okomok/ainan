USING: kernel ainan.qualified eval ;

AINAN-QUALIFIED: sequences math ;
AINAN-QUALIFIED: tools.test ;
AINAN-QUALIFIED: ;

[ 1 2 3 ] [ 1 2 3 4 drop ] tools.test:unit-test
{ 2 3 4 5 } [ { 1 2 3 4 } [ 1 math:+ ] sequences:each ] tools.test:unit-test
[ "1 2 +" eval ] tools.test:must-fail
[ "{ 1 2 3 4 } [ 1 math:+ ] each" eval ] tools.test:must-fail
