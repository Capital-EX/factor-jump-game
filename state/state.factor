! Copyright (C) 2022 Capital Ex.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs factor-jump-game.entities
factor-jump-game.symbols math namespaces sequences ;
IN: factor-jump-game.state

TUPLE: state
    { entities assoc }
    { score integer initial: 0 }
    { health integer initial: 3 }
    { state maybe{ +game-state+ } } ;

: get-health ( -- health )
    game-state get health>> ;

: get-score ( -- score )
    game-state get score>> ;

: get-entities ( -- entities )
    game-state get entities>> values ;

: get-entity ( name -- entities )
    game-state get entities>> at ;

: draw-entities ( -- )
    get-entities [ draw ] each ;

: update-entities ( -- )
    get-entities [ update ] each ;

:: add-entity ( game-state ent name -- )
    ent name game-state entities>> set-at ;

:: remove-entity ( game-state name -- )
    name game-state entities>> delete-at ;
