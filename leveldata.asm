;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;
.module LEVELDATA

level:
	.byte	0

	.align	64
leveldata:
	.word	level1, level2

level1:
	.include	level1.asm.txt
level2:
	.include	level2.asm.txt


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
	ld		a,23

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
	add		a,ONEZ
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
	.fill	12*4,0					; up to 10 entrances, 4 bytes apiece


scoreline:
        .include scoreline.asm
