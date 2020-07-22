;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;
.module LEV

levelup:
	ld		a,(level)
	inc		a
	cp		8
	jr		nz,{+}
	ld		a,7
+:	ld		(level),a
	ret


;-------------------------------------------------------------------------------


displaylevel:
	ld		a,(level)			    ; level to HL, caps at 8
	and		3					    ; cycle of 4 levels, stick on level 4 after 2 cycles
	rlca
    ld      hl,leveldata
    add     a,l
    ld      l,a
    jr      nc,{+}
    inc     h
+:  ld		a,(hl)
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


;-------------------------------------------------------------------------------


displaymen:
	ld		a,(lives)
	add		a,ZEROZ
	ld		hl,dfile+MEN_OFFS
	ld		(hl),a
	ret


;-------------------------------------------------------------------------------


displayscoreline:
	ld		hl,scoreline			; render the scoreline
	ld		de,dfile+23*33+1
	ld		bc,32
	ldir
	ret


;-------------------------------------------------------------------------------


createmap:
	ld		hl,dfile
	ld		de,offscreenmap
	ld		bc,33*5
	ldir
	
	ld		bc,33*19

_scryit:
	ld		a,(hl)
	cp		0
	jr		z,_storeit
	cp		DOT
	jr		z,_storeit
	cp		$76
	jr		z,_storeit
	ld		a,128
_storeit:
	ld		(de),a
	inc		hl
	inc		de
	dec		bc
	ld		a,b
	or		c
	jr		nz,_scryit
	ret


;-------------------------------------------------------------------------------


countdots:
	ld		hl,dfile+6*33
	ld		de,16*33
	ld		c,0

-:	ld		a,(hl)
	cp		DOT
	jr		nz,{+}

	inc		c

+:	inc		hl
	dec		de
	ld		a,d
	or		e
	jr		nz,{-}

	ld		a,c
	or		a
	ret


;-------------------------------------------------------------------------------


detectdot:
	ld		hl,dfile+6*33
	ld		bc,16*33
	ld		a,DOT
	cpir
	ret


;-------------------------------------------------------------------------------


;# self-modifying
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
	ld		de,dfile+$c7-33		    ; start checking at row 5
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


