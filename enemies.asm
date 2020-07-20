;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;
.module ENEMIES

initialiseenemies:
	ld		iy,$4000

	ld		hl,enemydata
	ld		de,enemydata+1
	ld		bc,ENEMYSIZE*NENEMIES-1
	ld		(hl),0
	ldir

    xor     a
    ld      (eeaten),a
    ld      (eexited),a

	ld		a,(margin)
	ld		b,NENEMIES
	ld		hl,enemydata-5			; -3 because I use a cheat to offset to the MARGIN address

-:	ld		de,$28+5				; +3 takes into account addresses after the CDFlag
	add		hl,de
	ld		(hl),a					; MARGIN
	ld		de,$3B-$28
	add		hl,de
	ld		(hl),$c0				; CDFLAG
	djnz	{-}

	ld		iy,enemydata
	ret


initenemytimer:
	xor		a						; reset count
	ld		(generatimer),a

	ld		a,(level)				; 0..7
	and		a
	rlca
	rlca
	rlca							; 0..56
	ld		b,a
	ld		a,110
	sub		b
	ld		(leveltrig),a			; 110 .. 54
	ret


generateenemy:
	ld		a,(leveltrig)
	ld		b,a

	ld		a,(generatimer)
	inc		a
	cp		b
	jr		nz,{+}

	call	startenemy
	xor		a

+:	ld		(generatimer),a
	ret


startenemy:
	ld		a,3
	call	AFXPLAY

	xor		a
	ld		de,ENEMYSIZE
	ld		b,NENEMIES

	ld		iy,enemydata
	jr		{+}

-:	add		iy,de
+:	cp		(iy)
	jr		z,_ehstart
	djnz	{-}
	ret


_ehstart:
	inc		(iy)

	ld		a,(entrancecount)		; shonky fixed point multiply
	ld		b,a						; get a random byte, treat it as a n/256 fraction
	call	xrnd8					; add it to a total (entrancecount) times
	ld		c,a						; integer part is incremented when carry over
	xor		a
	ld		l,a
-:	add		a,c
	jr		nc,{+}
	inc		l
+:	djnz	{-}

	ld		a,l						; l is integer 0..entranceCount-1
	and		a						; clear carry
	rlca
	rlca
	rlca
	or		entrances & 255
	ld		l,a
	ld		h,entrances / 256

	ld		a,(hl)					; address l
	ld		(iy+EO_ADL),a

	inc		hl
	ld		a,(hl)					; address h
	ld		(iy+EO_ADH),a

	inc		hl
	ld		a,(hl)					; direction
	ld		(iy+EO_MDL),a

	inc		hl
	ld		a,(hl)					; direction
	ld		(iy+EO_MDH),a

	inc		hl
	ld		a,(hl)					; animation number
	and		a
	rlca
	or		enemyanims & 255
	ld		(iy+EO_ANL),a
	ld		(iy+EO_ANH),enemyanims / 256

	ret


updateenemies:
	ld		b,NENEMIES
	ld		iy,enemydata
	jr		{+}

-:	ld		de,ENEMYSIZE			; de is corrupted in call so need to re-init
	add		iy,de
+:	ld		a,(iy)
	cp		1
	call	z,_ehup
	djnz	{-}
	ret

_ehup:
	ld		l,(iy+EO_ADL)
	ld		h,(iy+EO_ADH)

	ex		de,hl					; check if the player has eaten this enemy
	ld		hl,(playerpos)
	and		a
	sbc		hl,de
	ex		de,hl
	jr		z,_ediedwithscore

	ld		a,(frames)				; only update every few frames
	and		15
	cp		15
	ret		nz

	inc		(iy+EO_FNO)				; internal frame counter

	set		2,h
	ld		a,(hl)					; undraw at old pos using char from map
	res		2,h
	ld		(hl),a

	ld		e,(iy+EO_MDL)			; move
	ld		d,(iy+EO_MDH)
	add		hl,de

	ex		de,hl					; about to wander onto the player's head in the updated position?
	ld		hl,(playerpos)
	and		a
	sbc		hl,de
	ex		de,hl
	jr		z,_ediedwithscore

	set		2,h
	ld		a,(hl)					; get character in target square in map
	res		2,h

	cp		$76						; about to wander off screen?
	jr		z,_edied

	cp		128						; wall?
	jr		nz,_testhit

	ld		e,(iy+EO_MDL)			; move
	ld		d,(iy+EO_MDH)
	xor		a
	sub		e
	ld		e,a
	sbc		a,a
	sub		d
	ld		d,a
	ld		(iy+EO_MDL),e			; move
	ld		(iy+EO_MDH),d
	add		hl,de
	add		hl,de
	jr		_eupd

_testhit:
	cp		MAP_PIPE
	jr		nz,_eupd

	ld		a,(hl)					; the pipe character we collided with on-screen
	set		2,h
	ld		(hl),a					; stuff it in off screen map for undrawing
	res		2,h						; it will be erased anyway so why not

	ld		(playerhit),a			; signal life lost
	ld		a,7
	call	AFXPLAY

_eupd:
	ld		(iy+EO_ADL),l			; store updated position
	ld		(iy+EO_ADH),h

	ld		e,(iy+EO_ANL)			; animate
	ld		d,(iy+EO_ANH)
	ld		a,(iy+EO_FNO)
	and		1
	or		e
	ld		e,a
	ld		a,(de)
	ld		(hl),a
	ret


_ediedwithscore:
	ld		a,(scoretoadd)
	add		a,2
	ld		(scoretoadd),a
	ld		a,14
	call	AFXPLAY
    ld      hl,eexited          ; pre-correct the 'escapee' count
    dec     (hl)                ; 
    ld      hl,eeaten           ; omnomnom
    inc     (hl)

_edied:
    ld      hl,eexited          ; escapees (special bonus #01) count
    inc     (hl)
	dec		(iy)
	ret

resetenemies:
	ld		iy,enemydata-ENEMYSIZE
	ld		b,NENEMIES

-:	ld		de,ENEMYSIZE
	add		iy,de
	ld		a,(iy)
	cp		1
	jr		nz,{+}

	dec		(iy)
	ld		l,(iy+EO_ADL)
	ld		h,(iy+EO_ADH)
	set		2,h
	ld		a,(hl)
	res		2,h
	ld		(hl),a

+:	djnz	{-}
	ret
