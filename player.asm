;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;
.module PLAYER

tryup:
	ld		a,(up)
	ld		de,-33
	ld		c,UP
	jr		doturn

tryright:
	ld		a,(right)
	ld		de,1
	ld		c,RIGHT
	jr		doturn

trydown:
	ld		a,(down)
	ld		de,33
	ld		c,DOWN
	jr		doturn

tryleft:
	ld		a,(left)
	ld		de,-1
	ld		c,LEFT

doturn:
	and		1								; movement in the queried direction?
	jr		nz,_moveavail

_nomove:
	or		$ff								; nope - continue to check others
	ret

_moveavail:
	ld		a,17						; preempt the sound - snuffle
	ld		(psound),a

	ld		hl,(playerpos)				; stash the current head offset
	ld		(oldplayerpos),hl
	add		hl,de						; update position
	ld		a,(hl)

	cp		0							; check space and dots
	jr		z,_intothevoid
	cp		DOT
	jr		z,_intothescore

	and		127							; pipe is 1..7 incl, greys are 8..10
	cp		$0b
	jr		c,_nomove					; is either pipe or background
	cp		$1a
	jr		nc,_nomove					; is either pipe or background

	jr		_intothevoid				; probably an enemy, allow movement on to it

_intothescore:
	ld		a,(scoretoadd)				; oil get!
	inc		a
	ld		(scoretoadd),a				; defer adding of score because it's register intensive

	ld		a,4							; update sound - gloop
	ld		(psound),a

_intothevoid:
	ld		a,(winchframe)				; update winch animation
	dec		a
	ld		(winchframe),a

	ld		(playerpos),hl				; store updated player position

	ld		a,(playerdirn)				; determine pipe topography
	and		a
	rlca
	rlca
	rlca
	ld		b,a							; b = old player direction * 8

	ld		a,c
	call	setdirection				; store new player direction in var & queue

	or		b							; a = old player direction * 8 + new player direction
	or		turntable & 255				; index in to table of characters that describe a pipe
	ld		e,a							; join from old -> new direction
	ld		d,turntable / 256
	ld		a,(de)

	ld		hl,(oldplayerpos)			; update pipe
	ld		(hl),a
	set		2,h
	ld		(hl),MAP_PIPE
	res		2,h

	ld		a,(psound)
	call	AFXPLAY

	xor		a
	ret


retract:
	ld		hl,(retractptr)				; because the retract buffer sits on a 256 byte
	xor		a							; boundary we can use the lsb to tell when it's empty
	cp		l
	ret		z

	dec		hl							; get the direction the player last moved
	ld		(retractptr),hl
	dec		hl
	ld		a,(hl)						; reset player direction to the one that brought us here
	ld		(playerdirn),a				; so that bends work when the player resumes digging
	inc		hl								; use the last move direction to re-position player
	ld		a,(hl)

	and		a							; get offset to the screen position that the player
	rlca								; arrived from last frame
	or		reversetab & 255
	ld		l,a
	ld		h,reversetab / 256
	ld		a,(hl)
	inc		hl
	ld		d,(hl)
	ld		e,a

	ld		hl,(playerpos)				; reset head
	ld		(hl),0
	set		2,h
	ld		(hl),0
	res		2,h
	add		hl,de						; update head to previous position
	ld		(hl),PIPE_HEAD1				; no animation when retracting
	ld		(playerpos),hl
	ret


setdirection:
	ld		(playerdirn),a				; stash player direction and extend the pipe queue
	ld		hl,(retractptr)
	ld		(hl),a
	inc		hl
	ld		(retractptr),hl
	ret

