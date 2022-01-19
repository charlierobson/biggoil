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

    xor     a                       ; clear key line
	ld		hl,dfile+$300
	ld		de,dfile+$301
    ld      (hl),a
    ld      bc,16
    ldir

	ld		de,up-2
	ld		hl,REDEFDATA._upk
	call	_redeffit               ; up
	call	_redeffit               ; down
	call	_redeffit               ; left
	call	_redeffit               ; right
	call	_redeffit               ; fire

	ld		hl,(fire-2)				 ; copy fire button definition to title screen input states
	ld		(begin-2),hl

	ld		hl,offscreenmap+$2b5	; restore bottom of screen
	ld		de,dfile+$2b5
	ld		bc,3*33
	ldir
	ret


_redeffit:
	ld		(REDEFDATA._keyaddress),de		; the input data we're altering

	ld		de,dfile+$306			; copy key text to screen
	ld		bc,5
	ldir

    push    hl                      ; next key string

-:  call    _testkeys
	jr		z,{-}

	xor		$ff				 		; flip so we have a 1 bit where the key is

	ld		hl,(REDEFDATA._keyaddress)
	ld		(hl),c
	inc		hl
	ld		(hl),a
    inc     hl
    inc     hl
    push    hl

-:  call    _testkeys
	jr		nz,{-}

    pop     de
    pop     hl
	ret


_testkeys:
	call	framesync
	call	inkbin
	call	getcolbit
	cp		$ff
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

