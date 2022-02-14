;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;
.module TSC

titlescn:
    call    INPUT._settitle

	call	init_stc

	ld		hl,0
	ld		(frames),hl

	ld		a,(margin)						; steal 24 scanlines for music player
	add		a,24
	ld		(bmargin),a
	ld		a,$16
	ld		(IRQ._SCRLINES),a

_titleredraw:
	ld		hl,title
	ld		de,dfile
	call	decrunch

	ld		de,offscreenmap					; copy 'bigg oil co to offscreen
	ld		hl,dfile+15*33
	ld		bc,3*33
	ldir
	ld		hl,dfile+21*33					; copy text to offscreen
	ld		bc,3*33
	ldir

	call	displayscoreonts
	call	displayhionts
	
_titleloop:
	call	framesync

    ld      a,(frames)  ; AB------
    rlca                ; -------A
    rlca                ; ------AB
    rlca                ; -----AB-
    and     6           ; 00000AB0  :- 0,2,4,6

    ld      hl,_titletextlist
    call    tableget

+:  ld		de,dfile+$300-3*33
	ld		bc,16
	ldir

_nochangetext:
	ld		a,(frames)
	and		16
	jr		nz,_noflash

	ld		hl,dfile+$300-3*33
	ld		b,16
_ilop:
	set		7,(hl)
	inc		hl
	djnz	_ilop

_noflash:
	ld		a,(frames)
	ld		hl,offscreenmap
	and		64
	jr		z,{+}

	ld		hl,offscreenmap+3*33

+:	ld		de,dfile+15*33
	ld		bc,3*33
	ldir

	ld		a,(redef)				; redefine when r released
	and		3
	cp		2
	jr		nz,{+}
	call	redefinekeys
	jr		_titleloop

+:	ld		a,(instr)				; show instruction screen with I
	and		3
	cp		2
	jr		nz,{+}
	call	instructions
	jp		_titleredraw

+:
	ld		a,(begin)
	and		3
	cp		1
	jr		nz,_titleloop

	ld		a,(margin)						; restore stolen scanlines
	ld		(bmargin),a
	ld		a,$19
	ld		(IRQ._SCRLINES),a

	ret
