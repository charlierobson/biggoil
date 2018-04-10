;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;
.module LEV

displaylevel:
	ld		a,(level)			; level to HL
	and		a
	rlca
	or		leveldata & 255
	ld		l,a
	ld		h,leveldata / 256
	ld		a,(hl)
	inc		hl
	ld		h,(hl)
	ld		l,a
	ld		de,dfile
	call	decrunch
	call	displayscore
	call	displayhi
	call	displaymen

displaylvl:
	ld		a,(level)
	add		a,ONEZ
	ld		hl,dfile+LVL_OFFS
	ld		(hl),a
	ret


displaymen:
	ld		a,(lives)
	add		a,ZEROZ
	ld		hl,dfile+MEN_OFFS
	ld		(hl),a
	ret


displayscoreline:
	ld		hl,scoreline			; render the scoreline
	ld		de,dfile+23*33+1
	ld		bc,32
	ldir
	ret


initentrances:
	ld		hl,entrances

_c1:
	xor		a
	ld		(entrancecount),a
	ld		(_adval1),a
	inc		a
	ld		(_adval0),a
	ld		a,enemyanimL2R
	ld		(_animnum),a
	ld		de,dfile+$c7-33		; start checking at row 5
	call	checkcolumn

_c2:
	ld		a,$ff
	ld		(_adval0),a
	ld		(_adval1),a
	ld		a,enemyanimR2L
	ld		(_animnum),a
	ld		de,dfile+$e6-33

checkcolumn:
	ld		b,17

_nextrow:
	push	hl
	ld		hl,33
	add		hl,de
	ex		de,hl
	pop		hl

	ld		a,(de)
	cp		DOT
	call	z,_add
	djnz	_nextrow
	ret

_add:
	ld		(hl),e
	inc		hl
	ld		(hl),d
	inc		hl
_adval0 = $+1
	ld		(hl),0
	inc		hl
_adval1 = $+1
	ld		(hl),0
	inc		hl
_animnum = $+1
	ld		(hl),0
	inc		hl
	inc		hl
	inc		hl
	inc		hl

	ld		a,(entrancecount)
	inc		a
	ld		(entrancecount),a
	ret


createmap:
	