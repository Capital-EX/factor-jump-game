! Copyright (C) 2022 Capital Ex.
! See http://factorcode.org/license.txt for BSD license.

USING: classes.struct kernel raylib sequences typed ;
IN: factor-jump-game.utils

: unpair ( p -- x y )
    [ first ] [ second ] bi ;


: all-true? ( seq -- ? )
    [ ] all? ;

: any-true? ( seq -- ? )
    [ ] any? ;

TYPED: rectangle-v ( pos: Vector2 size: Vector2 -- rectangle: Rectangle )
    [ unpair ] bi@ Rectangle boa ;
