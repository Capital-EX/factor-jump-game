! Copyright (C) 2022 Capital Ex.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors factor-jump-game.entities kernel raylib ;
IN: factor-jump-game.entities.ground

TUPLE: ground < entity ;

: <ground> ( -- ground )
    ground new
        0 500 <Vector2>   >>position
        800 100 <Vector2> >>size ;

INSTANCE: ground drawable
M: ground (draw)
    get-position-and-size DARKGREEN draw-rectangle-v ;
