! Copyright (C) 2022 Your name.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs combinators combinators.smart
continuations hash-sets hashtables kernel math math.vectors
namespaces prettyprint raylib sequences sets ui.tools.listener
vocabs.loader ;
FROM: namespaces => set ;
IN: jump-game

: unpair ( p -- x y )
    [ first ] [ second ] bi ;



GENERIC: draw ( drawable -- )
GENERIC: update ( updatable -- )

SYMBOL: screen-size
SYMBOL: game-state
SYMBOL: entities
TUPLE: +playing+ ; TUPLE: +game-over+ ;
UNION: +game-state+ +playing+ +game-over+ ;

TUPLE: state
    { entities assoc }
    { score integer }
    { state maybe{ +game-state+ } } ;

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

: half-screen-size ( -- hss )
    screen-size get 2 v/n ;

TUPLE: entity
    { position Vector2 }
    { size Vector2 } ;

: change-position-y ( ent quot -- ent )
    '[ [ _ call( ... x -- x ) ] change-y ] change-position ;

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

TUPLE: player < entity
    { on-ground boolean }
    { y-vel float } ;

: <player> ( -- player )
    half-screen-size 32 32 <Vector2> f 0.0 player boa ;

M: player draw
    get-position-and-size BLUE draw-rectangle-v ;

: get-ground ( -- ground )
    "ground" get-entity ;

: get-distance-from-ground ( player -- dist )
    get-ground [ get-bottom ] [ get-top ] bi* - ;

: apply-velocity ( player -- player )
    dup '[ _ y-vel>> + ] change-position-y ;

: (apply-gravity) ( y-vel -- y-vel' )
    [ 30 < ] [ 4 + ] [ 30 ] smart-if* ;

: apply-gravity ( player -- player )
    [ (apply-gravity) ] change-y-vel ;

: on-ground? ( player -- ? )
     get-distance-from-ground 0 > ;

: fall ( player -- player )
    apply-velocity apply-gravity ;

: ?fall ( player -- ? )
    dup on-ground>> not [ fall ] when on-ground? ;

: separate-from-ground ( player -- )
    dup get-distance-from-ground '[ _ - ] change-position-y drop ;

: ?separate-from-ground ( player -- )
    [ on-ground>> ] [ separate-from-ground ] smart-when* ;

: jumping? ( player -- ? )
    on-ground>> KEY_SPACE is-key-down and ;

: jump ( player -- )
    -30 >>y-vel f >>on-ground drop ;

: ?jump ( player -- )
    [ jumping? ] [ jump ] smart-when* ;

M: player update
    {
        [ ?jump ]
        [ ?fall ]
        [ on-ground<< ]
        [ ?separate-from-ground ]
    } cleave ;

TUPLE: ground < entity ;

: <ground> ( -- ground )
    0 500 <Vector2> 800 100 <Vector2> ground boa ;

M: ground draw
    get-position-and-size DARKGREEN draw-rectangle-v ;

M: ground update
    drop ;

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
        +playing+ new >>state
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
