;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;
.module LEVELDATA

leveldata:

level1:
	.include	level1.asm.txt


; hl points to level data
;
displaylevel:
	ld		de,dfile
	ld		a,24

-:	inc		de
	ld		bc,32
	ldir
	dec		a
	jr		nz,{-}
	ret


initentrances:
	ld		hl,entrances

	xor		a
	ld		(_adval1),a
	inc		a
	ld		(_adval0),a
	ld		de,dfile+$c7-33		; start checking at row 5
	call	checkcolumn

	ld		a,$ff
	ld		(_adval0),a
	ld		(_adval1),a
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
	ld		a,(entrancecount)
	inc		a
	ld		(entrancecount),a
	ret


entrancecount:
	.byte	0

	.align	32
entrances:
	.fill	10*4,0					; up to 10 entrances, 4 bytes apiece
