

	.byte	0					; retract code requires a buffer byte before the queue
	.align	256
retractqueue:
	.fill   128,$ff

	.align	128
entrances:
	.fill	12*8,0				; up to 10 entrances, 8 bytes apiece




turntable:
	.byte   $85,$85,$00,$00,$84,$00,$00,$00
	.byte   $03,$03,$84,$00,$00,$00,$00,$00
	.byte   $00,$02,$85,$00,$03,$00,$00,$00
	.byte   $00,$00,$00,$00,$00,$00,$00,$00
	.byte   $02,$00,$85,$00,$03,$00,$00,$00
	.byte   $00,$00,$00,$00,$00,$00,$00,$00


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

lives:
	.byte   0



    .module BONUSES ; ----------------- MODULE ---------------
bonusdefs:
    .byte   $20,0
    .word   BONUSES._byteEQ,BONUSES._deathsPerLevel         ; #1 - survivor

    .byte   $20,0
    .word   BONUSES._byteEQ,BONUSES._eexited                ; #2 - alcatraz guard

    .byte   $25,50
    .word   BONUSES._byteGTE,BONUSES._eeaten                ; #3 - hungry guy

    .byte   $30,3
    .word   BONUSES._byteLT,timerv                          ; #4 - brinksman

    .byte   $40,2
    .word   BONUSES._byteEQ,BONUSES._levelsWithoutADeath    ; #5 - superskill

    .byte   $50,4
    .word   BONUSES._byteGTE,BONUSES._levelsWithoutADeath   ; #6 - godskill

    .byte   $50,90
    .word   BONUSES._byteEQ,retractptr                      ; #7 - bigg boy

    .byte   $10,3
    .word   BONUSES._byteEQ,level                           ; #8 - clocker

    .byte   $15,4
    .word   BONUSES._byteEQ,level                           ; #9 - clocker ii electric boogaloo

    .byte   $20,5
    .word   BONUSES._byteEQ,level                           ; #10 - clocker iii wowee

    .byte   $25,6
    .word   BONUSES._byteEQ,level                           ; #11 - clocker iv big score

    .byte   $30,7
    .word   BONUSES._byteEQ,level                           ; #12 - roy castle
bonusdefsend:
bonuscount = (bonusdefsend-bonusdefs)/6

_eobdp:                 ; end of bonus display pause
    .byte   0
_bonus:
    .byte   0
_deathsPerLevel:
    .byte   0
_levelsWithoutADeath:
    .byte   0
_eeaten:
    .byte   0
_eexited:
    .byte   0
    .endmodule ; ----------------- END MODULE ---------------

    .module INSTRUCTIONS
_instcreds:
    .word   _ic3,_ic2,_ic3,_ic1

_ic1:
    .asc    "game : sirmorris"
_ic2:
    .asc    "music : yerzmyey"
_ic3:
    .asc    "<reel> to return"
    .endmodule






soundbank:
	.incbin biggoil.afb

titlestc:
	.incbin yerz.stc


    .module REDEFDATA ; ----------------- MODULE ---------------

; -----  4  3  2  1  0
;
; $FE -  V, C, X, Z, SH	0
; $FD -  G, F, D, S, A	 1
; $FB -  T, R, E, W, Q	 2
; $F7 -  5, 4, 3, 2, 1	 3
; $EF -  6, 7, 8, 9, 0	 4
; $DF -  Y, U, I, O, P	 5
; $BF -  H, J, K, L, NL	6
; $7F -  B, N, M, ., SP	7
;
;		 js mask	row	kb mask  -
; .byte	%10000000, 2, %00000001, 0  ; up (Q)

_keyaddress:
	.word	0

_ipindex:
	.byte	0

_bit2byte:
	.byte	1,2,4,8,16,0

_pkf:
	.asc	"press key for:"
_upk:
    .byte   0
	.asc	" up  "
_dnk:
    .byte   1
	.asc	"down "
_lfk:
    .byte   2
	.asc	"left "
_rtk:
    .byte   3
	.asc	"right"
_frk:
    .byte   4
	.asc	"reel "
    .endmodule ; ----------------- END MODULE ---------------



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

help:
	.incbin instructions.binlz

enemydata:
	.fill	ENEMYSIZE*NENEMIES,0

scoreline:
	.byte	$38, $28, $34, $37, $2a, $0e, $1c, $1c, $1c, $1c, $1c, $00, $2d, $2e, $0e, $1c, $1c, $1c, $1c, $1c, $00, $31, $3b, $31, $0e, $1d, $00, $32, $2a, $33, $0e, $20

    .align  1024

dfile:
	.repeat 12
	  .byte 076H
	  .fill 32,0
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


timeout:
	.byte   0

entrancecount:
	.byte	0

level:
	.byte	0


	.align 4
enemyanims:
	.byte   ENEMY,ENEMY|128 ; enemyanim0
	.byte   ENEMY,ENEMY|128 ; enemyanim1 etc

leveldata:
	.word	level1, level2, level3, level4

reversetab:
	.word   33,-1,-33,0,1




    .module INPUT ; ----------------- MODULE ---------------

; -----  4  3  2  1  0
;
; $FE -  V, C, X, Z, SH	  0  11111110
; $FD -  G, F, D, S, A	  1  11111101
; $FB -  T, R, E, W, Q	  2  11111011
; $F7 -  5, 4, 3, 2, 1	  3  11110111
; $EF -  6, 7, 8, 9, 0	  4  11101111
; $DF -  Y, U, I, O, P	  5  11011111
; $BF -  H, J, K, L, NL	  6  10111111
; $7F -  B, N, M, ., SP	  7  01111111
;
; input state data:
;
; joystick bit, or $ff/%11111111 for no joy
; key row IN address,
; key mask, or $ff/%11111111 for no key
; trigger impulse

titleinputstates:
	.byte	%00001000,$7F,%00000001,0		; startgame	    (SP)
	.byte	%11111111,$FB,%00001000,0		; redefine	    (R)
	.byte	%11111111,$DF,%00000100,0		; instructions  (I)
	.byte	%11111111,$FE,%11111111,0
	.byte	%11111111,$FE,%11111111,0

inputstates:
	.byte	%10000000,$FB,%00000001,0		; up    (Q)
	.byte	%01000000,$FD,%00000001,0		; down	(A)
	.byte	%00100000,$DF,%00000010,0		; left	(O)
	.byte	%00010000,$DF,%00000001,0		; right	(P)
	.byte	%00001000,$7F,%00000001,0		; fire	(SP)

; calculate actual input impulse addresses
;
begin	= titleinputstates + 3
redef	= titleinputstates + 7
instr	= titleinputstates + 11

up		= inputstates + 3
down	= inputstates + 7
left	= inputstates + 11
right	= inputstates + 15
fire	= inputstates + 19
    .endmodule ; ----------------- END MODULE ---------------


clouds:
	.byte	$00, $0a, $08, $09, $00, $00, $00, $00, $00, $00, $00, $0a, $0a, $09, $09, $00, $00, $00, $08, $08, $0a, $00, $00, $00, $00, $00, $00, $09, $08, $08, $0a, $00
	.byte	$00, $00, $00, $09, $09, $00, $00, $00, $00, $0a, $08, $00, $00, $00, $00, $09, $0a, $00, $00, $00, $09, $09, $08, $00, $00, $00, $00, $00, $00, $0a, $09, $00
	.byte	$00, $0a, $08, $09, $00, $00, $00, $00, $00, $00, $00, $0a, $0a, $09, $09, $00, $00, $00, $08, $08, $0a, $00, $00, $00, $00, $00, $00, $09, $08, $08, $0a, $00


bonustext:
    .asc    "secret bonus: 00"

score:
    .word   0

scoretoadd:
    .word   0

hiscore:
    .word   0

newtone:
newtonep1=newtone+1
newtonep2=newtone+5
newtonep3=newtone+8
newtonep4=newtone+11
	.byte   $EF,$F9,$03,$00,$AD,$03,$02,$AA,$2D,$01,$A7,$FB,$00,$D0,$20
	.byte   $EF,$F9,$03,$00,$AD,$03,$02,$AA,$2D,$01,$A7,$FB,$00,$D0,$20

winchframe:
	.byte   0

winchanim:
	.byte   $00,$01
	.byte   $00,$04
	.byte   $87,$00
	.byte   $02,$00

fuelchar:
	.byte   FUEL1

lx:
	.byte	0

cldfrm:
	.byte   0

generatimer:
	.byte	0

timestop:
    .byte   0

leveltrig:
	.byte	0

rndseed:
    .word   0

psound:
	.byte	0

    .align 1024
offscreenmap:
	.fill   33*24

