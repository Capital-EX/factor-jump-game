! Copyright (C) 2022 Capital Ex.
! See http://factorcode.org/license.txt for BSD license.
USING: ;
IN: factor-jump-game.utils

: unpair ( p -- x y )
    [ first ] [ second ] bi ;

: all-true? ( seq -- ? )
    [ ] all? ;

: any-true? ( seq -- ? )
    [ ] any? ;
