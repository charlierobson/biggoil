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

ZEROZ = $1c             ; '0'
ONEZ = $1d              ; '1'
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
        call    seedrnd
        call    initsfx
        call    installirq

        ld      b,50
-:      call    framesync               ; give time for crappy LCD tvs to re-sync
        djnz    {-}

titlescn:
        ld      hl,title
        ld      de,dfile
        call    decrunch
        ld      hl,titlestc
        call    init_stc

-:      call    framesync
        push    iy
        call    play_stc
        pop     iy
        call    readinput
        ld      a,(fire)
        cp      1
        jr      nz,{-}

        call    mute_ay
        call    initsfx

        xor     a
        ld      (level),a
        ld      (score),a
        ld      (score+1),a

        ld      a,4
        ld      (lives),a

        ld      a,DOWN
        ld      (retractqueue-1),a

        call    displayscoreline

newlevel:
        call    displaylevel
	call	initentrances

        call    initdrone

restart:
        call    initialiseenemies

        call    displaymen

        ld      hl,dfile+INITIAL_OFFS   ; set initial position and direction
        ld      (playerpos),hl

        ld      a,DOWN                  ; player's 'last' move was down so correct pipe can be drawn
        ld      (playerdirn),a

        ld      hl,retractqueue         ; initialise the pipeline retract lifo
        ld      (retractptr),hl

        xor     a
        ld      (playerhit),a

mainloop:
        call    framesync
        call    readinput

        ld      a,(fire)                ; if fire button has just been released then reset the retract tone
        and     3
        cp      2
        call    z,resettone

        call    updatecloud

        call    drone

        ld      a,(frames)
        and     127
        call    z,startenemy

        call    updateenemies
        ld      a,(playerhit)
        and     a
        jr      z,_playon

        call    loselife
        jp      nz,restart
        jp      titlescn

_playon:
        ld      a,(fire)                ; retract happens quickly so check every frame
        and     1
        jr      z,_noretract

        ld      hl,(retractptr)         ; because the retract buffer sits on a 256 byte
        xor     a                       ; boundary we can use the lsb to tell when it's empty
        cp      l
        jr      z,mainloop              ; even if we can't retract, jump back

        call    retract                 ; retract the head
        ld      a,(frames)
        and     1
        call    z,retract               ; do an extra retract every other frame
        call    showwinch               ; so it's about a speed and a half
        ld      a,(frames)
        and     3                       ; prepare the z flag
        ld      a,18                    ; set up sound number in case it's time
        call    z,generatetone
        jp      mainloop

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
        jp      z,mainloop

        ld      c,a                     ; add score
        xor     a
        ld      (scoretoadd),a
        ld      b,a
        call    addscore
        call    checkhi

        call    lorryfill

        call    countdots
        jp      nz,mainloop

nextlevel:
        ld      a,12
        call    AFXPLAY

        call    tidyup

        ld      a,(level)
        inc     a
        cp      4
        jr      nz,{+}
        xor     a
+:      ld      (level),a

        call    displaylvl

        jp      newlevel

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
        ld      a,(lives)
        cp      1
        jr      nz,{+}

        ld      a,13
        call    AFXPLAY

+:      call    tidyup
        ld      a,(lives)
        dec     a
        ld      (lives),a
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
        call    retract
        call    retract
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

;-------------------------------------------------------------------------------

framesync:
        ld      hl,frames
        ld      a,(hl)
-:      cp      (hl)
        jr      z,{-}
        ret

;-------------------------------------------------------------------------------

        .include player.asm
        .include enemies.asm
        .include score.asm
        .include input.asm
        .include sfx.asm
        .include stcplay.asm
        .include irq.asm
        .include ayfxplay.asm
        .include leveldata.asm
        .include whimsy.asm
        .include decrunch.asm

        .include data.asm

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
