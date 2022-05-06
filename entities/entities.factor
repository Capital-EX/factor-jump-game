! Copyright (C) 2022 Capital Ex.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel math raylib ;
IN: factor-jump-game.entities

TUPLE: entity
    { position Vector2 }
    { size Vector2 } ;

: change-position-y ( ent quot -- ent )
    '[ [ _ call( ... x -- x ) ] change-y ] change-position ;

: change-position-x ( ent quot -- ent )
    '[ [ _ call( ... x -- x ) ] change-x ] change-position ;

: get-position-and-size ( ent -- pos size )
    [ position>> ] [ size>> ] bi ;

: get-top ( ent -- top )
    position>> y>> ;

: get-right ( ent -- right )
    get-position-and-size [ x>> ] bi@ + ;

: get-bottom ( ent -- bottom )
    get-position-and-size [ y>> ] bi@ + ;

: get-left ( ent -- left )
    position>> x>> ;


GENERIC: draw ( drawable -- )
GENERIC: update ( updatable -- )
