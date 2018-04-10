
soundbank:
        .incbin biggoil.afb

titlestc:
        .incbin yerz.stc

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


newtone:
newtonep1=newtone+1
newtonep2=newtone+5
newtonep3=newtone+8
newtonep4=newtone+11
        .byte   $EF,$F9,$03,$00,$AD,$03,$02,$AA,$2D,$01,$A7,$FB,$00,$D0,$20
        .byte   $EF,$F9,$03,$00,$AD,$03,$02,$AA,$2D,$01,$A7,$FB,$00,$D0,$20


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

	.align	128
entrances:
	.fill	12*8,0          ; up to 10 entrances, 8 bytes apiece

        .align 16
enemyanims:
        .byte   ENEMY,ENEMY|128 ; enemyanim0
        .byte   ENEMY,ENEMY|128 ; enemyanim1 etc

        .align 256
turntable:
        .byte   $85,$85,$00,$00,$84,$00,$00,$00
        .byte   $03,$03,$84,$00,$00,$00,$00,$00
        .byte   $00,$02,$85,$00,$03,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00
        .byte   $02,$00,$85,$00,$03,$00,$00,$00
        .byte   $00,$00,$00,$00,$00,$00,$00,$00

        .align 16
reversetab:
        .word   33,-1,-33,0,1



entrancecount:
	.byte	0


scoreline:
        .include scoreline.asm


level:
	.byte	0

	.align	64
leveldata:
	.word	level1, level2, level3, level4

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



START1 = 0
LEN1 = 18
START2 = 23
LEN2 = 10

cldfrm:
    .byte   0

    .align  128
clouds:
	.byte	$00, $0a, $08, $09, $00, $00, $00, $00, $00, $00, $00, $0a, $0a, $09, $09, $00, $00, $00, $08, $08, $0a, $00, $00, $00, $00, $00, $00, $09, $08, $08, $0a, $00
	.byte	$00, $00, $00, $09, $09, $00, $00, $00, $00, $0a, $08, $00, $00, $00, $00, $09, $0a, $00, $00, $00, $09, $09, $08, $00, $00, $00, $00, $00, $00, $0a, $09, $00
	.byte	$00, $0a, $08, $09, $00, $00, $00, $00, $00, $00, $00, $0a, $0a, $09, $09, $00, $00, $00, $08, $08, $0a, $00, $00, $00, $00, $00, $00, $09, $08, $08, $0a, $00



