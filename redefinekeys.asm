;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;
.module REDEF


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

	.align  64
_keychar:
	.asc	0,"zxcv"
	.asc	"asdfg"
	.asc	"qwert"
	.asc	"12345"
	.asc	"09876"
	.asc	"poiuy"
	.asc	2,"lkjh"
	.asc	1,".mnb"

_kcs:
	.word	_ksh,_ksp,_knl
_ksh:
	.asc	"shift  ",$ff
_ksp:
	.asc	"space  ",$ff
_knl:
	.asc	"newline",$ff

_keydata:
_keymask = $						; aka mask when ued to detect key
_keyrow = $+1
	.byte	0,0

_keyaddress:
	.word	0

_bit2byte:
	.byte	1,2,4,8,16,0

_pkf:
	.asc	"press key for:"
_upk:
	.asc	"		up		"
_dnk:
	.asc	"	down	"
_lfk:
	.asc	"	left	"
_rtk:
	.asc	"	right  "
_frk:
	.asc	"	fire	"

redefinekeys:
	ld		hl,dfile+$2b5			; stash content at bottom of screen
	ld		de,offscreenmap+$2b5
	ld		bc,3*33
	ldir

	ld		hl,_pkf					; install 'press key for:' text
	ld		de,dfile+$2bf
	ld		bc,14
	ldir

	ld		de,up-2
	ld		hl,_upk
	call	_redeffit

	ld		de,down-2
	ld		hl,_dnk
	call	_redeffit

	ld		de,left-2
	ld		hl,_lfk
	call	_redeffit

	ld		de,right-2
	ld		hl,_rtk
	call	_redeffit
	
	ld		de,fire-2
	ld		hl,_frk
	call	_redeffit

	ld		hl,(fire-2)				 ; copy fire button definition to title screen input states
	ld		(begin-2),hl

	ld		hl,offscreenmap+$2b5	; restore bottom of screen
	ld		de,dfile+$2b5
	ld		bc,3*33
	ldir
	ret


_redeffit:
	ld		(_keyaddress),de		; the input data we're altering

	ld		de,dfile+$303			; copy key text to screen
	ld		bc,10
	ldir

_redefloop:
	call	framesync
	call	inkbin
	call	getcolbit
	cp		$ff
	jr		z,_redefloop

	xor		$ff				 		; flip so we have a 1 bit where the key is

	ld		hl,(_keyaddress)
	ld		(hl),c
	inc		hl
	ld		(hl),a

_redefnokey:
	call	framesync
	call	inkbin
	call	getcolbit
	cp		$ff
	jr		nz,_redefnokey
	ret




getcolbit:
	ld		bc,$0800				; b is loop count, c is row index
	ld		hl,INPUT._kbin

-:	ld		a,(hl)					; byte will have a 0 bit if a key is pressed
	or		$e0
	cp		$ff
	ret		nz
	inc		c
	inc		hl
	djnz	{-}
	ret



_showkey:
	ld		hl,_bit2byte
	ld		bc,6
	cpir
	ld		a,b
	or		c
	ret		z						; continue if key bit wasn't found, perhaps 2 keys pressed at once

	ld		a,5
	sub		c				 		; a is bit number

	ld		hl,_keychar

	ld		a,(_keyrow)
	ld		c,a
	add		a,a
	add		a,a
	add		a,c						; a = c * 5
	add		a,l

	pop		bc						; recover bit offset
	add		a,b

	ld		l,a
	ld		a,(hl)
	cp		8
	jr		c,_isstring

	ld		(dfile+1),a
	xor		a
	ld		(dfile+2),a
	ld		(dfile+3),a
	ld		(dfile+4),a
	ld		(dfile+5),a
	ld		(dfile+6),a
	ld		(dfile+7),a
	ret


_isstring:
	ld		hl,_kcs
	add		a,a
	add		a,l
	ld		l,a
	ld		a,(hl)
	inc		hl
	ld		h,(hl)
	ld		l,a
	ld		de,dfile+1
-:	ldi
	ld		a,(hl)
	cp		$ff
	jr		nz,{-}
	ret
