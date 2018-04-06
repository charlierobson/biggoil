.module LEVELDATA

leveldata:

level1:
	.include	level1.asm


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


; hl points to level data
;
initentrances:
	ex		de,hl
	ld		hl,entrances
	ld		bc,32*24

_entranceloop:
	ld		a,(de)
	cp		ENTRANCE
	jr		nz,_next

	ld		(hl),e			; store address of marked entrance
	inc		hl
	ld		(hl),d
	inc		hl

	ld		a,DOT			; replace entrance marker with oil
	ld		(de),a

_next:
	inc		de
	dec		bc
	ld		a,b
	or		c
	jr		nz,_entranceloop

	ld		de,entrances			; get entrance count
	and		a
	sbc		hl,de
	ld		a,e
	rrca
	ld		(entrancecount),a
	ret


entrancecount:
	.byte	0

entrances:
	.fill	20,0

