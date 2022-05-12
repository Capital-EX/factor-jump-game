! Copyright (C) 2022 Capital Ex.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs factor-jump-game.entities
factor-jump-game.symbols kernel math namespaces sequences timers ;
IN: factor-jump-game.state

TUPLE: state
    { entities assoc }
    { score float initial: 0.0 }
    { health integer initial: 3 }
    { state maybe{ +game-state+ } }
    { spawn-timer float }
    ;

: add-entity ( ent name -- )
    game-state get entities>> set-at ;

: remove-entity ( name -- )
    game-state get entities>> delete-at ;

: get-health ( -- health )
    game-state get health>> ;

: get-score ( -- score )
    game-state get score>> ;

: get-entities ( -- entities )
    game-state get entities>> values ;

: get-entity ( name -- entities )
    game-state get entities>> at ;

: ?draw ( drawable -- )
    dup drawable? [ draw ] [ drop ] if ;

: ?update ( updatable -- )
    dup updatable? [ update ] [ drop ] if ;

: draw-entities ( -- )
    get-entities [ ?draw ] each ;

: update-entities ( -- )
    get-entities [ ?update ] each ;
