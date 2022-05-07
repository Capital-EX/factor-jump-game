! Copyright (C) 2022 Capital Ex.
! See http://factorcode.org/license.txt for BSD license.
USING: math.vectors namespaces ;
IN: factor-jump-game.symbols

SYMBOL: screen-size
SYMBOL: game-state
SYMBOL: entities
TUPLE: +playing+ ; TUPLE: +game-over+ ;
UNION: +game-state+ +playing+ +game-over+ ;

: half-screen-size ( -- hss )
    screen-size get 2 v/n ;
