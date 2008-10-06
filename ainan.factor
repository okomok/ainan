! Copyright (C) 2008 okomok
! See http://factorcode.org/license.txt for BSD license.

USING: kernel calendar threads io.launcher qualified ;

IN: ainan

QUALIFIED: calendar
QUALIFIED: threads
QUALIFIED: io.launcher

! USAGE: "E:/Application/app.exe" 12 later-run
!        "./factor.exe" 10 later-run
: minutes-later ( path min -- )
    calendar:minutes threads:sleep io.launcher:run-process drop ;
