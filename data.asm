        ; AIMING TO HAVE DFILE AT $5000

        .align  1024
.if $ != $5000
.fail "DFILE needs to be at $x000 boundary"
.endif
dfile:
        .repeat 12
          .byte   076H
          .fill   32,0
        .loop
        .byte   $76
        .fill   14,0
        .byte   $3c,$26,$2e,$39
        .fill   14,0
        .repeat 11
          .byte   076H
          .fill   32,0
        .loop
        .byte   076H

        .align 16
reversetab:
        .word   33,-1,-33,0,1

        .align 16
enemyanims:
        .byte   ENEMY,ENEMY|128 ; enemyanim0
        .byte   ENEMY,ENEMY|128 ; enemyanim1 etc

	.align	64
leveldata:
	.word	level1, level2, level3, level4

        .align  16
winchanim:
        .byte   $00,$01
        .byte   $00,$04
        .byte   $87,$00
        .byte   $02,$00

winchframe:
        .byte   0

	.align	128
entrances:
	.fill	12*8,0          ; up to 10 entrances, 8 bytes apiece

scoreline:
	.byte	$38, $28, $34, $37, $2a, $0e, $1c, $1c, $1c, $1c, $1c, $00, $2d, $2e, $0e, $1c, $1c, $1c, $1c, $1c, $00, $31, $3b, $31, $0e, $1d, $00, $32, $2a, $33, $0e, $20

        .align  1024
.if $ != $5400
.fail "offscreen map needs to be at $x400 boundary"
.endif
offscreenmap:
        .fill   33*24

soundbank:
        .incbin biggoil.afb

titlestc:
        .incbin yerz.stc

headchar:
        .byte   PIPE_HEAD1

playerpos:
        .word   0

oldplayerpos:
        .word   0

playerhit:
        .byte   0

playerdirn:
        .word   0

retractptr:
        .word   0

timerv:
        .byte   0

scoretoadd:
        .byte   0

score:
        .word   0

hiscore:
        .word   0

lives:
        .byte   0

MINUS = $16
ERLCHAR = $12
ELRCHAR = $13

enemyanimL2R = 0
enemyanimR2L = 1

        .word   0               ; padding byte - do not remove
        .align  256
retractqueue:
        .fill   256,$ff

        .align  256
enemydata:
        .fill   64*10,0         ; 10 enemies of 64 bytes each

    .align  128
clouds:
	.byte	$00, $0a, $08, $09, $00, $00, $00, $00, $00, $00, $00, $0a, $0a, $09, $09, $00, $00, $00, $08, $08, $0a, $00, $00, $00, $00, $00, $00, $09, $08, $08, $0a, $00
	.byte	$00, $00, $00, $09, $09, $00, $00, $00, $00, $0a, $08, $00, $00, $00, $00, $09, $0a, $00, $00, $00, $09, $09, $08, $00, $00, $00, $00, $00, $00, $0a, $09, $00
	.byte	$00, $0a, $08, $09, $00, $00, $00, $00, $00, $00, $00, $0a, $0a, $09, $09, $00, $00, $00, $08, $08, $0a, $00, $00, $00, $00, $00, $00, $09, $08, $08, $0a, $00

newtone:
newtonep1=newtone+1
newtonep2=newtone+5
newtonep3=newtone+8
newtonep4=newtone+11
        .byte   $EF,$F9,$03,$00,$AD,$03,$02,$AA,$2D,$01,$A7,$FB,$00,$D0,$20
        .byte   $EF,$F9,$03,$00,$AD,$03,$02,$AA,$2D,$01,$A7,$FB,$00,$D0,$20


        .align 256
turntable:
        .byte   $85,$85,$00,$00,$84,$00,$00,$00
        .byte   $03,$03,$84,$00,$00,$00,$00,$00
        .byte   $00,$02,$85,$00,$03,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $02,$00,$85,$00,$03,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00


entrancecount:
	.byte	0

level:
	.byte	0

level1:
	.incbin lvl1.binlz

level2:
	.incbin	lvl2.binlz

level3:
	.incbin	lvl3.binlz

level4:
	.incbin	lvl4.binlz

title:
	.incbin title.binlz

end:
	.incbin end.binlz

timeout:
        .byte   0

fuelchar:
        .byte   FUEL1

START1 = 0
LEN1 = 18
START2 = 23
LEN2 = 10
cldfrm:
    .byte   0

