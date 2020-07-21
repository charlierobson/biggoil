;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;
.module REDEF


redefinekeys:
	ld		hl,dfile+$2b5			; stash content at bottom of screen
	ld		de,offscreenmap+$2b5
	ld		bc,3*33
	ldir

	ld		hl,REDEFDATA._pkf		; install 'press key for:' text
	ld		de,dfile+$2bf
	ld		bc,14
	ldir

	ld		de,up-2
	ld		hl,REDEFDATA._upk
	call	_redeffit

	ld		de,down-2
	ld		hl,REDEFDATA._dnk
	call	_redeffit

	ld		de,left-2
	ld		hl,REDEFDATA._lfk
	call	_redeffit

	ld		de,right-2
	ld		hl,REDEFDATA._rtk
	call	_redeffit
	
	ld		de,fire-2
	ld		hl,REDEFDATA._frk
	call	_redeffit

	ld		hl,(fire-2)				 ; copy fire button definition to title screen input states
	ld		(begin-2),hl

	ld		hl,offscreenmap+$2b5	; restore bottom of screen
	ld		de,dfile+$2b5
	ld		bc,3*33
	ldir
	ret


_redeffit:
	ld		(REDEFDATA._keyaddress),de		; the input data we're altering

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

	ld		hl,(REDEFDATA._keyaddress)
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

