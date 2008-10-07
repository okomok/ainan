! Copyright (C) 2008 okomok
! See http://factorcode.org/license.txt for BSD license.

USING: kernel ainan.using ;
AINAN-USING: calendar threads io.launcher ;

IN: ainan

! USAGE: "E:/Application/app.exe" 12 minutes-later
!        "./factor.exe" 10 minutes-later
: minutes-later ( path min -- )
    calendar:minutes threads:sleep io.launcher:run-process drop ;
