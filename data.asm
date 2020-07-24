	; AIMING TO HAVE DFILE AT $5000

	.align  1024
.if $ != $5000
.warn "DFILE needs to be at $x000 boundary"
.endif
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



	.align 4
enemyanims:
	.byte   ENEMY,ENEMY|128 ; enemyanim0
	.byte   ENEMY,ENEMY|128 ; enemyanim1 etc

leveldata:
	.word	level1, level2, level3, level4

reversetab:
	.word   33,-1,-33,0,1

winchframe:
	.byte   0

winchanim:
	.byte   $00,$01
	.byte   $00,$04
	.byte   $87,$00
	.byte   $02,$00




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
; key row offset 0-7,
; key mask, or $ff/%11111111 for no key
; trigger impulse

_kbin:
	.fill	8

_lastJ:
	.byte	$ff

titleinputstates:
	.byte	%00001000,7,%00000001,0		; startgame	    (SP)
	.byte	%10000000,2,%00001000,0		; redefine	    (R)
	.byte	%11111111,5,%00000100,0		; instructions  (I)
	.byte	%11111111,7,%11111111,0
	.byte	%11111111,7,%11111111,0

inputstates:
	.byte	%00001000,7,%00000001,0		; fire	(SP)
	.byte	%10000000,2,%00000001,0		; up    (Q)
	.byte	%01000000,1,%00000001,0		; down	(A)
	.byte	%00100000,5,%00000010,0		; left	(O)
	.byte	%00010000,5,%00000001,0		; right	(P)

; calculate actual input impulse addresses
;
begin	= titleinputstates + 3
redef	= titleinputstates + 7
instr	= titleinputstates + 11

fire	= inputstates + 3
up		= inputstates + 7
down	= inputstates + 11
left	= inputstates + 15
right	= inputstates + 19
    .endmodule ; ----------------- END MODULE ---------------


clouds:
	.byte	$00, $0a, $08, $09, $00, $00, $00, $00, $00, $00, $00, $0a, $0a, $09, $09, $00, $00, $00, $08, $08, $0a, $00, $00, $00, $00, $00, $00, $09, $08, $08, $0a, $00
	.byte	$00, $00, $00, $09, $09, $00, $00, $00, $00, $0a, $08, $00, $00, $00, $00, $09, $0a, $00, $00, $00, $09, $09, $08, $00, $00, $00, $00, $00, $00, $0a, $09, $00
	.byte	$00, $0a, $08, $09, $00, $00, $00, $00, $00, $00, $00, $0a, $0a, $09, $09, $00, $00, $00, $08, $08, $0a, $00, $00, $00, $00, $00, $00, $09, $08, $08, $0a, $00


bonustext:
    .asc    "secret bonus: 00"


	.align  1024
.if $ != $5400
.warn "offscreen map needs to be at $x400 boundary"
.endif
offscreenmap:
	.fill   33*24



newtone:
newtonep1=newtone+1
newtonep2=newtone+5
newtonep3=newtone+8
newtonep4=newtone+11
	.byte   $EF,$F9,$03,$00,$AD,$03,$02,$AA,$2D,$01,$A7,$FB,$00,$D0,$20
	.byte   $EF,$F9,$03,$00,$AD,$03,$02,$AA,$2D,$01,$A7,$FB,$00,$D0,$20



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

scoretoadd:
	.byte   0

score:
	.word   0

hiscore:
	.word   0

lives:
	.byte   0



    .module BONUSES ; ----------------- MODULE ---------------
bonusdefs:
    .byte   $20,0
    .word   BONUSES._byteEQ,BONUSES._deathsPerLevel         ; #1 - clear a level w/o dying

    .byte   $20,0
    .word   BONUSES._byteEQ,BONUSES._eexited                ; #2 - no escapees

    .byte   $25,50
    .word   BONUSES._byteGTE,BONUSES._eeaten                ; #3 eat 50 or more

    .byte   $30,3
    .word   BONUSES._byteLT,timerv                          ; #4 finish with less than 3 on the clock

    .byte   $40,2
    .word   BONUSES._byteEQ,BONUSES._levelsWithoutADeath    ; #5 clear 2 levels w/o dying

    .byte   $50,4
    .word   BONUSES._byteGTE,BONUSES._levelsWithoutADeath   ; #6 clear 4+ levels w/o dying

    .byte   $10,3
    .word   BONUSES._byteEQ,level                           ; #7 reach level 4

    .byte   $15,4
    .word   BONUSES._byteEQ,level                           ; #8 reach level 5

    .byte   $20,5
    .word   BONUSES._byteEQ,level                           ; #9 reach level 6

    .byte   $25,6
    .word   BONUSES._byteEQ,level                           ; #10 reach level 7

    .byte   $30,7
    .word   BONUSES._byteEQ,level                           ; #11 hit level 7

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
_titletextlist:
    .word   _titletexts+36,_titletexts+18,_titletexts+36,_titletexts

_titletexts:
    .asc    "game by sirmorris."
    .asc    "music by yerzmyey."
    .asc    "<fire> to go back."
    .endmodule

	.word   0               ; padding byte - do not remove
	.align  256
retractqueue:
	.fill   256,$ff

enemydata:
	.fill   64*10,0         ; 10 enemies of 64 bytes each

	.align	128
entrances:
	.fill	12*8,0          ; up to 10 entrances, 8 bytes apiece


timeout:
	.byte   0

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

scoreline:
	.byte	$38, $28, $34, $37, $2a, $0e, $1c, $1c, $1c, $1c, $1c, $00, $2d, $2e, $0e, $1c, $1c, $1c, $1c, $1c, $00, $31, $3b, $31, $0e, $1d, $00, $32, $2a, $33, $0e, $20


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

_bit2byte:
	.byte	1,2,4,8,16,0

_pkf:
	.asc	"press key for:"
_upk:
	.asc	"    up    "
_dnk:
	.asc	"   down   "
_lfk:
	.asc	"   left   "
_rtk:
	.asc	"   right  "
_frk:
	.asc	"   fire   "
    .endmodule ; ----------------- END MODULE ---------------


    .module TSC
_tt1:
	.asc	"press fire"
_tt2:
	.asc	"r:redefine"
    .endmodule

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

help:
	.incbin instructions.binlz

