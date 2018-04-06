;-------------------------------------------------------------------------------

        .org    $4009

        .exportmode NO$GMB
        .export

versn	.byte   $00
e_ppc	.word   $0000
d_file	.word   dfile
df_cc	.word   dfile+1 
vars	.word   var
dest	.word   $0000 
e_line	.word   var+1 
ch_add	.word   last-1 
x_ptr	.word   $0000 
stkbot	.word   last 
stkend	.word   last 
breg	.byte   $00 
mem     .word   membot 
unuseb	.byte   $00 
df_sz	.byte   $02 
s_top	.word   $0000 
last_k	.word   $ffff 
db_st	.byte   $ff
margin	.byte   55 
nxtlin	.word   line10 
oldpc   .word   $0000
flagx   .byte   $00
strlen  .word   $0000 
t_addr  .word   $0c8d; $0c6b
seed    .word   $0000 
frames  .word   $ffff
coords  .byte   $00 
        .byte   $00 
pr_cc   .byte   188 
s_posn  .byte   33 
s_psn1  .byte   24 
cdflag  .byte   64 
PRTBUF  .fill   32,0
prbend  .byte   $76 
membot  .fill   32,0

UP = 0
RIGHT = 1
DOWN = 2
LEFT = 4

PIPE_VERT = $85
PIPE_HORIZ = $03

PIPE_HEAD1 = $34        ; 'O'
PIPE_HEAD2 = $1c        ; '0'
FUEL1 = $14
FUEL2 = $16

DOT = $1b               ; '.'
ENEMY = $0c             ; '£'

SCORE_OFFS = $2fe
HISCORE_OFFS = $307
LVL_OFFS = $311
MEN_OFFS = $317
INITIAL_OFFS = $b7
WINCH_OFFS = $34
FUELLING_OFFS = $7a


;-------------------------------------------------------------------------------

line1:  .byte   0,1
        .word   line01end-$-2
        .byte   $ea

;-------------------------------------------------------------------------------
;
.module A_MAIN
;
        ld      hl,level1
        call    displaylevel
	call	initentrances

restart:
        call    initialiseenemies

        ld      hl,dfile+INITIAL_OFFS   ; set initial position and direction
        ld      (playerpos),hl
        ld      a,DOWN
        ld      (playerdirn),a

        ld      hl,retractqueue         ; initialise the pipeline retract lifo
        ld      (retractptr),hl

        xor     a
        ld      (playerhit),a

mainloop:
        call    framesync
        call    readinput

        ld      a,(frames)
        and     a
        call    z,startenemy

        call    updateenemies
        ld      a,(playerhit)
        and     a
        jr      z,_playon

        call    loselife
        jr      restart

_playon:
        ld      a,(fire)                ; retract happens quickly so check every frame
        and     1
        jr      z,_noretract

        call    retract                 ; retract the head
        call    showwinch

        jr      mainloop

_noretract:
        ld      a,(frames)              ; only dig every nth frame
        and     3                       ; could be game speed controller?
        cp      3
        jr      nz,mainloop

        ld      a,(headchar)            ; animate the digging head
        xor     PIPE_HEAD1 ^ PIPE_HEAD2
        ld      (headchar),a

        call    tryup                   ; the tryxxx functions return with z set
        jr      z,_headupdate           ; if that direction was taken

        call    trydown
        jr      z,_headupdate

        call    tryleft
        jr      z,_headupdate

        call    tryright

_headupdate:
        call    showwinch               ; animate the winch

        ld      hl,(playerpos)          ; update the digging head
        ld      a,(headchar)
        ld      (hl),a

        ld      a,(scoretoadd)          ; any score last frame?
        and     a        
        jr      z,mainloop

        ld      c,a                     ; add score
        xor     a
        ld      (scoretoadd),a
        ld      b,a
        call    addscore
        call    checkhi

        ld      a,(fuelchar)            ; show fuel pumping into lorry
        xor     FUEL1 ^ FUEL2
        ld      (fuelchar),a
        ld      (dfile+FUELLING_OFFS),a

        call    countdots
        jr      nz,mainloop

nextlevel:
        call    tidyup
        jp      restart


;-------------------------------------------------------------------------------

countdots:
        ld      hl,dfile+6*33
        ld      de,16*33
        ld      c,0

-:      ld      a,(hl)
        cp      DOT
        jr      nz,{+}

        inc     c

+:      inc     hl
        dec     de
        ld      a,d
        or      e
        jr      nz,{-}

        ld      a,c
        or      a
        ret


;-------------------------------------------------------------------------------

loselife:
        call    tidyup

        ret


tidyup:
        ld      b,4
-:      push    bc
        call    framesync
        call    invertscreen
        pop     bc
        djnz    {-}

        call    resetenemies

-:      call    framesync
        call    retract                 ; retract the head
        call    showwinch
        ld      a,(retractptr)
        and     a
        jr      nz,{-}
        ret


invertscreen:
        ld      hl,dfile
        ld      bc,33*24

_inverter:
        ld      a,(hl)
        cp      $76
        jr      z,_noinvert

        xor     $80
        ld      (hl),a

_noinvert:
        inc     hl
        dec     bc
        ld      a,b
        or      c
        jr      nz,_inverter
        ret

;-------------------------------------------------------------------------------

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
        ld      a,(hl)                  ; reset player direction so that bends work when
        ld      (playerdirn),a          ; the player resumes digging

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

        or      $ff                     ; nope - continue to check others
        ret

_moveavail:
        ld      hl,(playerpos)
        ld      (oldplayerpos),hl
        add     hl,de
        ld      a,(hl)
        cp      0
        jr      z,_intothevoid

        cp      ENEMY
        jr      z,_intothevoid
        
        cp      DOT                     ; obstruction ahead
        ret     nz

        ld      a,1                     ; oil get!
        ld      (scoretoadd),a          ; defer adding of score because it's register intensive

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
        xor     a
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

;-------------------------------------------------------------------------------

showwinch:
        ld      a,(winchframe)
        and     3
        rlca
        or      winchanim & 255
        ld      l,a
        ld      h,winchanim / 256
        ld      b,(hl)
        inc     hl
        ld      c,(hl)
        ld      hl,dfile+WINCH_OFFS
        ld      (hl),b
        inc     hl
        ld      (hl),c
        ret

fuelchar:
        .byte   FUEL1

winchframe:
        .byte   0

        .align  16
winchanim:
        .byte   $00,$01
        .byte   $00,$04
        .byte   $87,$00
        .byte   $02,$00
        
;-------------------------------------------------------------------------------

framesync:
        ld      hl,frames
        ld      a,(hl)
-:      cp      (hl)
        jr      z,{-}
        ret

;-------------------------------------------------------------------------------

        .include enemies.asm
        .include score.asm
        .include input.asm
        .include ayfxplay.asm

        .include leveldata.asm

;-------------------------------------------------------------------------------

        .byte   $76
line01end:
line10:
        .byte   0,2
        .word   line10end-$-2
        .byte   $F9,$D4,$C5,$0B         ; RAND USR VAL "
        .byte   $1D,$22,$21,$1D,$20	; 16514 
        .byte   $0B                     ; "
        .byte   076H                    ; N/L
line10end:

dfile:
        .repeat 24
          .byte   076H
          .fill   32,0
        .loop
        .byte   076H

var:
        .byte   080H
last:

        .end
