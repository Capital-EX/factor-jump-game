! Copyright (C) 2022 Capital Ex.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs combinators combinators.smart
continuations factor-jump-game.entities.ground
factor-jump-game.entities.player factor-jump-game.state
factor-jump-game.symbols factor-jump-game.utils hash-sets
hashtables kernel math math.vectors namespaces prettyprint
raylib sequences sets ui.tools.listener vocabs.loader ;
FROM: namespaces => set ;
IN: factor-jump-game

: open-window ( -- )
    screen-size get unpair "Jump Game" init-window
    60 set-target-fps ;

: clear-window ( -- )
    SKYBLUE clear-background ;

: game-load ( -- )
    800 600 <Vector2> screen-size set
    state new
        32 <hashtable> >>entities
            dup <player> "player" add-entity
            dup <ground> "ground" add-entity
        +playing+ new  >>state
    game-state set ;

: game-draw ( -- )
    begin-drawing
        clear-window draw-entities
    end-drawing ;

: game-update ( -- )
    update-entities ;

: main-loop ( -- )
    game-load open-window clear-window
    [
        game-draw
        game-update
        window-should-close not
    ] loop ;

: main ( -- )
    [ main-loop ] [ close-window ] [ ] cleanup ;

MAIN: main
