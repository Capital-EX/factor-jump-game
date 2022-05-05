! Copyright (C) 2022 Your name.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs combinators continuations hash-sets
hashtables kernel math math.vectors namespaces prettyprint
raylib sequences sets ui.tools.listener vocabs.loader ;
FROM: namespaces => set ;
IN: jump-game

: unpair ( p -- x y )
    [ first ] [ second ] bi ;

: jumping? ( -- ? )
    KEY_SPACE is-key-down ;

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

: fall ( player -- player )
    dup '[ [ _ y-vel>> + ] change-y ] change-position
    [ dup 30 < [ 4 + ] [ drop 30 ] if ] change-y-vel ;

: ?fall ( player -- player )
    dup on-ground>> not [ fall ] when ;

: on-ground? ( player -- ? )
    get-ground [ get-bottom ] [ get-top ] bi* > ;

: separate-from-ground ( player -- )
    dup get-ground [ get-bottom ] [ get-top ] bi* -
        swap [ [ swap - ] change-y ] change-position drop ;

: ?separate-from-ground ( player -- )
    dup on-ground>> [ separate-from-ground ] [ drop ] if ;

M: player update
    dup on-ground>> jumping? and [ -30 >>y-vel f >>on-ground ] when
    dup ?fall on-ground? >>on-ground ?separate-from-ground ;

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
