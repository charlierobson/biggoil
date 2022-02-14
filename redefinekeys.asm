;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;
.module REDEF


redefinekeys:
	ld		hl,dfile+$2b5-3*33			; stash content at bottom of screen
	ld		de,offscreenmap+$2b5-3*33
	ld		bc,3*33
	ldir

	ld		hl,REDEFDATA._pkf			; install 'press key for:' text
	ld		de,dfile+$2bf-2*33
	ld		bc,14
	ldir

	xor		a							; clear key line
	ld		hl,dfile+$300-3*33
	ld		de,dfile+$301-3*33
	ld		(hl),a
	ld		bc,16
	ldir

	ld		hl,REDEFDATA._upk			; input table index 0
	call	_redeffit

	ld		hl,REDEFDATA._dnk
	call	_redeffit

	ld		hl,REDEFDATA._lfk
	call	_redeffit

	ld		hl,REDEFDATA._rtk
	call	_redeffit
	
	ld		hl,REDEFDATA._frk
	call	_redeffit

	ld		hl,(fire-2)					; copy fire button definition to title screen input states
	ld		(begin-2),hl

	ld		hl,offscreenmap+$2b5-3*33	; restore bottom of screen
	ld		de,dfile+$2b5-3*33
	ld		bc,3*33
	ldir
	ret


_redeffit:
	ld		a,(hl)						; input state array index
	ld		(REDEFDATA._ipindex),a
	inc		hl
	sla		a
	sla		a
	ld		de,inputstates				; inputstates must not straddle a page
	add		a,e
	ld		e,a
	inc		de
	ld		(REDEFDATA._keyaddress),de	; the input data we're altering

	ld		de,dfile+$306-3*33			; copy key text to screen
	ld		bc,5
	ldir

_redefloop:
	call	framesync
	call	getcolbit
	cp		$ff
	jr		z,_redefloop

	xor		$ff							; flip bits to create column mask
	ld		c,a							; column mask in c, port num in b from getcolbit

	ld		hl,inputstates+1
	ld		de,(REDEFDATA._keyaddress)
_testNext:
	and		a
	sbc		hl,de						; done when we are about to check the current input state
	jr		z,_oktogo

	add		hl,de						; otherwise check to see if port/mask combo is already used
	ld		a,(hl)
	inc		hl
	cp		b
	jr		nz,nomatchport

	ld		a,(hl)
	cp		c
	jr		nz,nomatchport

	ld		b,4							; combo already used, warn user
-:  call	framesync
	ld		e,b
	call	invertscreen
	ld		b,e
	djnz	{-}
	call	_redefnokey
	jr		_redefloop

nomatchport:
	inc		hl
	inc		hl
	inc		hl
	jr		_testNext

_oktogo:
	ld		hl,(REDEFDATA._keyaddress)
	ld		(hl),b
	inc		hl
	ld		(hl),c

_redefnokey:
	call	framesync
	call	getcolbit
	cp		$ff
	jr		nz,_redefnokey
	ret




getcolbit:
	ld		bc,$fefe

-:	in		a,(c)						; byte will have a 0 bit if a key is pressed
	or		$e0
	cp		$ff
	ret		nz
	rlc		b
	jr		c,{-}
	ret

