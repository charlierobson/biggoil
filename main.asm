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

PIPE_HEAD1 = $34 ; 'O'
PIPE_HEAD2 = $1c ; '0'

DOT = $1b       ; '.'

;-------------------------------------------------------------------------------

line1:  .byte   0,1
        .word   line01end-$-2
        .byte   $ea

;-------------------------------------------------------------------------------
;
.module A_MAIN
;
        ld      hl,leveldata
        ld      de,dfile
        ld      bc,24*33+1
        ldir

        ld      hl,dfile+$b7            ; set initial position and direction
        ld      (playerpos),hl
        ld      a,DOWN
        ld      (playerdirn),a

        ld      hl,retractqueue         ; initialise the pipeline retract lifo
        ld      (retractptr),hl

mainloop:
        call    framesync
        call    readinput

        ld      a,(fire)                ; retract happens quickly so check every frame
        and     1
        jr      z,{+}

        call    retract
        jr      mainloop

+:      ld      a,(frames)              ; only dig every 4th frame
        and     3
        cp      3
        jr      nz,mainloop

        ld      a,(headchar)
        xor     PIPE_HEAD1 ^ PIPE_HEAD2
        ld      (headchar),a

        call    tryup                   ; the tryxxx functions return with z set
        jr      z,mainloop              ; if that direction was taken

        call    trydown
        jr      z,mainloop

        call    tryleft
        jr      z,mainloop

        call    tryright
        jr      z,mainloop

        ld      hl,(playerpos)
        ld      a,(headchar)
        ld      (hl),a
        jr      mainloop

;-------------------------------------------------------------------------------

retract:
        ld      hl,(retractptr)         ; because the retract buffer sits on a 256 byte
        xor     a                       ; boundary we can use the lsb to tell when it's empty
        cp      l
        ret     z

        dec     hl                      ; get the direction the player last moved
        ld      (retractptr),hl
        ld      a,(hl)                  ; reset player direction so that bends work when
        ld      (playerdirn),a          ; the player resumes digging

        and     a                       ; get offset to position that player arrived from last frame
        rlca
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
        ld      (playerdirn),a
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
        and     1
        jr      nz,{+}

        or      $ff
        ret

+:      ld      hl,(playerpos)
        ld      (oldplayerpos),hl
        add     hl,de
        ld      a,(hl)
        cp      0
        jr      z,{+}

        cp      DOT
        ret     nz

+:      ld      a,(headchar)
        ld      (hl),a
        ld      (playerpos),hl
        ld      a,(playerdirn)
        and     a
        rlca
        rlca
        rlca
        ld      b,a
        ld      a,c
        call    setdirection
        or      b
        or      turntable & 255
        ld      e,a
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

;-------------------------------------------------------------------------------

framesync:
        ld      hl,frames
        ld      a,(hl)
-:      cp      (hl)
        jr      z,{-}
        ret

;-------------------------------------------------------------------------------

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

;-------------------------------------------------------------------------------

dfile:
        .repeat 24
          .byte   076H
          .fill   32,0
        .loop
        .byte   076H

;-------------------------------------------------------------------------------

var:
        .byte   080H
last:

        .end
