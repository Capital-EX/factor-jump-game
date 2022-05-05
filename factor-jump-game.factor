! Copyright (C) 2022 Capital Ex.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs combinators combinators.smart
continuations hash-sets hashtables kernel math math.vectors
namespaces prettyprint raylib sequences sets ui.tools.listener
vocabs.loader ;
FROM: namespaces => set ;
IN: jump-game

: unpair ( p -- x y )
    [ first ] [ second ] bi ;

: all-true? ( seq -- ? )
    [ ] all? ;

: any-true? ( seq -- ? )
    [ ] any? ;

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

TUPLE: player < entity
    { on-ground boolean }
    { y-vel float }
    { x-vel float } ;

CONSTANT: PLAYER-SPEED 8
CONSTANT: JUMP-FORCE 30

: <player> ( -- player )
    player new
        half-screen-size >>position
        32 32 <Vector2>  >>size
        f                >>on-ground
        0.0              >>y-vel
        0.0              >>x-vel ;

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

: ?fall ( player -- player )
    dup dup on-ground>> not [ fall ] when on-ground? >>on-ground ;

: separate-from-ground ( player -- )
    dup get-distance-from-ground '[ _ - ] change-position-y drop ;

: ?separate-from-ground ( player -- )
    [ on-ground>> ] [ separate-from-ground ] smart-when* ;

: jumping? ( player -- ? )
    on-ground>> KEY_SPACE is-key-down and ;

: jump ( player -- )
    -30 >>y-vel f >>on-ground drop ;

: ?jump ( player -- player )
    dup [ jumping? ] [ jump ] smart-when* ;

: released-and-down? ( key key -- ? )
    [ is-key-released ] [ is-key-down ] bi* and ;

: all-keys-up? ( seq -- ? )
    [ is-key-up ] map all-true? ;

: ?set-x-vel-left ( player ? -- player )
    [ PLAYER-SPEED neg >>x-vel ] when ;

: ?set-x-vel-right ( player ? -- player )
    [ PLAYER-SPEED >>x-vel ] when ;

: ?continue-left ( player -- player )
    KEY_D KEY_A released-and-down? ?set-x-vel-left ;

: ?continue-right ( player -- player )
    KEY_A KEY_D released-and-down? ?set-x-vel-right ;

: ?move-left ( player -- player )
    KEY_A is-key-pressed ?set-x-vel-left ?continue-right ;

: ?move-right ( player -- player )
    KEY_D is-key-pressed ?set-x-vel-right ?continue-left ;

: ?stay-still ( player -- player )
    { KEY_D KEY_A } all-keys-up? [ 0 >>x-vel ] when ;

: update-position ( player -- )
    dup '[ _ x-vel>> + ] change-position-x drop ;

: ?move ( player -- player )
    dup ?move-left ?move-right ?stay-still update-position ;

M: player update
    ?move ?jump ?fall ?separate-from-ground ;

TUPLE: ground < entity ;

: <ground> ( -- ground )
    ground new
        0 500 <Vector2>   >>position
        800 100 <Vector2> >>size ;

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
