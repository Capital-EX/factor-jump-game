! Copyright (C) 2022 Capital Ex.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs calendar combinators combinators.smart
continuations factor-jump-game.entities.enemy
factor-jump-game.entities.ground
factor-jump-game.entities.player factor-jump-game.state
factor-jump-game.symbols factor-jump-game.utils formatting
hash-sets hashtables kernel math math.parser math.vectors
namespaces prettyprint raylib sequences sets timers io ;
FROM: namespaces => set ;
IN: factor-jump-game

:: from-right ( text x -- text x' )
    text 32 measure-text :> len
    800 len x + - :> x'
    text x' ;

: score>text ( score -- text )
    "Score: %d" sprintf ; inline

: draw-score ( -- )
    get-score
        score>text 10 10 32 BLACK draw-text ;

: health>text ( health -- text )
    "Health: %d" sprintf ; inline

: draw-health ( -- )
    get-health
        health>text 10 from-right 10 32 BLACK draw-text ;

: draw-ui ( -- )
     draw-score
     draw-health ;

: open-window ( -- )
    screen-size get unpair "Jump Game" init-window
    60 set-target-fps ;

: clear-window ( -- )
    SKYBLUE clear-background ;

: update-timers ( -- )
    game-state get
        [ get-frame-time - ] change-spawn-timer
        [ drop get-time ] change-score-timer
        [ dup 0 <= [ spawn-enemy drop 3 ] when ] change-spawn-timer
    drop ;

: game-load ( -- )
    800 600 <Vector2> screen-size set
    0 enemy-count set
    state new
        32 <hashtable> >>entities
        +playing+ new >>state
        3.0 >>spawn-timer
    game-state set
    <player> "player" add-entity
    <ground> "ground" add-entity ;

: game-draw ( -- )
    begin-drawing
        clear-window draw-entities draw-ui
    end-drawing ;

: game-update ( -- )
    update-entities
    update-timers ;

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
