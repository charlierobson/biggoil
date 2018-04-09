;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;
.module LEV

level:
	.byte	0

	.align	64
leveldata:
	.word	level1, level2, level3, level4

level1:
	.include	lvl1.txt

level2:
	.include	lvl2.txt

level3:
	.include	lvl3.txt

level4:
	.include	lvl4.txt

title:
	.include 	title.txt

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
	ld		a,23
	jr		{+}

displayscreen:
	ld		a,24

+:	ld		de,dfile

-:	inc		de
	ld		bc,32
	ldir
	dec		a
	jr		nz,{-}
	ret


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


entrancecount:
	.byte	0

	.align	128
entrances:
	.fill	12*8,0					; up to 10 entrances, 8 bytes apiece


scoreline:
        .include scoreline.asm
