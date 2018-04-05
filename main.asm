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

        ld      hl,dfile+$d8
        ld      (playerpos),hl

-:      call    framesync

        ld      a,(down)
        cp      1
        call    z,playerdown
        jr      {-}

;-------------------------------------------------------------------------------

framesync:
        ld      hl,frames
        ld      a,(hl)
-:      cp      (hl)
        jr      z,{-}
        jp      readinput

;-------------------------------------------------------------------------------

PIPE_DOWN = $05
PIPE_HEAD = $34
playerpos:
        .word   0

playerdown:
        ld      hl,(playerpos)
        ld      (hl),PIPE_DOWN
        ld      de,33
        add     hl,de
        ld      (hl),PIPE_HEAD
        ld      (playerpos),hl
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
