! Copyright (C) 2022 Capital Ex.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors combinators.smart factor-jump-game.entities
factor-jump-game.state factor-jump-game.symbols
factor-jump-game.utils kernel math raylib sequences ;
IN: factor-jump-game.entities.player

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

INSTANCE: player drawable
M: player (draw)
    get-position-and-size BLUE draw-rectangle-v ;

INSTANCE: player updatable
M: player (update)
    ?move ?jump ?fall ?separate-from-ground ;
