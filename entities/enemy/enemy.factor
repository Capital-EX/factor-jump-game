! Copyright (C) 2022 Your name.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors combinators factor-jump-game.entities
factor-jump-game.state factor-jump-game.symbols formatting
kernel math namespaces random raylib ;
IN: factor-jump-game.entities.enemy

SYMBOLS: +spawn-left+ +spawn-right+ ;

TUPLE: enemy < entity
    { x-vel float }
    { name string initial: "" }
    direction ;

CONSTANT: left-spawn-point -48
CONSTANT: right-spawn-point 848

: next-enemy-count ( -- n )
    enemy-count get 1 + dup enemy-count set ;

: next-enemy-name ( -- name )
    next-enemy-count "Enemy@%d" sprintf ;

: <enemy> ( -- enemy )
    enemy new
        0 500 32 - <Vector2> >>position
        32 32 <Vector2> >>size ;

: spawned-left ( enemy -- |enemy )
    [ left-spawn-point >>x ] change-position
    t >>direction ;

: spawned-right ( enemy -- enemy| )
    [ right-spawn-point >>x ] change-position
    f >>direction ;

: moving-left ( enemy -- <=enemy )
    -4 >>x-vel ;

: moving-right ( enemy -- enemy=> )
    4 >>x-vel ;

: spawn-enemy-left ( -- enemy )
    <enemy> spawned-left moving-right ;

: spawn-enemy-right ( -- enemy )
    <enemy> spawned-right moving-left ;

: random-side ( -- ? )
    random-unit 0.5 > ;

: spawn-enemy ( -- )
    random-side [ spawn-enemy-left ]
                [ spawn-enemy-right ] if
    next-enemy-name [ >>name ] [ add-entity ] 2bi
    dup name>> add-entity ;

INSTANCE: enemy drawable
M: enemy (draw)
    get-position-and-size RED draw-rectangle-v ;

: remove-enemy ( enemy -- enemy )
    dup name>> remove-entity ;

INSTANCE: enemy updatable
M: enemy (update)
    dup '[ _ x-vel>> + ] change-position-x
    dup [ position>> x>> ] [ direction>> ] bi
        [ right-spawn-point > ] [ left-spawn-point < ] if
        [ remove-enemy ] when
    drop ;
