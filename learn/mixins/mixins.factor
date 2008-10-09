! Copyright (C) 2008 okomok
! See http://factorcode.org/license.txt for BSD license.

USING: kernel ainan.using ;
AINAN-USING: ;

IN: ainan.learn.mixins

TUPLE: rectangle w h ;
C: <rectangle> rectangle
TUPLE: ellipse major minor ;
C: <ellipse> ellipse
TUPLE: polygon file1 file2 ;
C: <polygon> polygon

MIXIN: shape

GENERIC: draw ( x y shape -- ) ! top of the stack (shape) is used to dispatch.
M: shape draw drop drop drop "default" ;
M: rectangle draw drop drop drop "rectangle" ;

INSTANCE: rectangle shape
INSTANCE: ellipse shape ! makes "default" output.

MIXIN: shape-ex
INSTANCE: shape-ex shape ! makes "default" output.

INSTANCE: polygon shape-ex
