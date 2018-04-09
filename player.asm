;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;
.module PLAYER

tryup:
        ld      a,(up)
        ld      de,-33
        ld      c,UP
        jr      doturn

tryright:
        ld      a,(right)
        ld      de,1
        ld      c,RIGHT
        jr      doturn

trydown:
        ld      a,(down)
        ld      de,33
        ld      c,DOWN
        jr      doturn

tryleft:
        ld      a,(left)
        ld      de,-1
        ld      c,LEFT

doturn:
        and     1                       ; movement in the queried direction?
        jr      nz,_moveavail

_nomove:
        or      $ff                     ; nope - continue to check others
        ret

_moveavail:
        ld      a,17
        ld      (psound),a

        ld      hl,(playerpos)
        ld      (oldplayerpos),hl
        add     hl,de
        ld      a,(hl)
        cp      0
        jr      z,_intothevoid
        cp      DOT                     ; obstruction ahead
        jr      z,_intothescore

        ; enemies from $0b..$1a inclusive
        and     127
        cp      $0b
        jr      c,_nomove               ; is either pipe or background
        cp      $1a
        jr      nc,_nomove              ; is either pipe or background

        jr      _intothevoid            ; probably an enemy

_intothescore:
        ld      a,1                     ; oil get!
        ld      (scoretoadd),a          ; defer adding of score because it's register intensive
        ld      a,4
        ld      (psound),a

_intothevoid:
        ld      a,(winchframe)          ; update winch animation
        dec     a
        ld      (winchframe),a

        ld      (playerpos),hl          ; store updated player position

        ld      a,(playerdirn)          ; determine pipe topography
        and     a
        rlca
        rlca
        rlca
        ld      b,a                     ; b = old player direction * 8

        ld      a,c
        call    setdirection            ; store new player direction in var & queue

        or      b                       ; a = old player direction * 8 + new player direction
        or      turntable & 255         ; index in to table of characters that describe a pipe
        ld      e,a                     ; join from old -> new direction
        ld      d,turntable / 256
        ld      a,(de)

        ld      hl,(oldplayerpos)
        ld      (hl),a

        ld      a,(psound)
        call    AFXPLAY

        xor     a
        ret

psound:
        .byte   0


retract:
        ld      hl,(retractptr)         ; because the retract buffer sits on a 256 byte
        xor     a                       ; boundary we can use the lsb to tell when it's empty
        cp      l
        ret     z

        ld      a,(winchframe)          ; update winch animation
        inc     a
        ld      (winchframe),a

        dec     hl                      ; get the direction the player last moved
        ld      (retractptr),hl
        dec     hl
        ld      a,(hl)                  ; reset player direction to the one that brought us here
        ld      (playerdirn),a          ; so that bends work when the player resumes digging
        inc     hl                      ; use the last move direction to re-position player
        ld      a,(hl)

        and     a                       ; get offset to the screen position that the player
        rlca                            ; arrived from last frame
        or      reversetab & 255
        ld      l,a
        ld      h,reversetab / 256
        ld      a,(hl)
        inc     hl
        ld      d,(hl)
        ld      e,a

        ld      hl,(playerpos)          ; reset head
        ld      (hl),0

        add     hl,de                   ; update head to previous position
        ld      (playerpos),hl
        ld      (hl),PIPE_HEAD1         ; no animation when retracting
        ret


setdirection:
        ld      (playerdirn),a          ; stash player direction and extend the pipe queue
        ld      hl,(retractptr)
        ld      (hl),a
        inc     hl
        ld      (retractptr),hl
        ret


headchar:
        .byte   PIPE_HEAD1

playerpos:
        .word   0

playerhit:
        .byte   0

playerhome:
        .byte   0

oldplayerpos:
        .word   0

playerdirn:
        .word   0

retractptr:
        .word   0

        .word   0       ; padding byte - do not remove
        .align  256
retractqueue:
        .fill   256,$ff

        ;.align 256
turntable:
        .byte   $85,$85,$00,$00,$84,$00,$00,$00
        .byte   $03,$03,$84,$00,$00,$00,$00,$00
        .byte   $00,$02,$85,$00,$03,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $02,$00,$85,$00,$03,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00

        ;.align 16
reversetab:
        .word   33,-1,-33,0,1


scoretoadd:
        .byte   0

score:
        .word   0

hiscore:
        .word   0

lives:
        .byte   0