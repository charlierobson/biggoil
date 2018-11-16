seedrnd:
	ld		a,r
	and		a
	jr		z,seedrnd
	ld		l,a
	ld		a,r
	ld		h,a
	ld		(rndseed),hl
	ret


xrnd8:
	ld		a,(rndseed)
	ld		c,a
	rrca
	rrca
	rrca
	xor		$1f
	add		a,c
	sbc		a,255
	ld		(rndseed),a
	ret


xrnd16:
	ld		hl,(rndseed)	    ; rndseed must not be 0
	ld		a,h
	rra
	ld		a,l
	rra
	xor		h
	ld		h,a
	ld		a,l
	rra
	ld		a,h
	rra
	xor		l
	ld		l,a
	xor		h
	ld		h,a
	ld		(rndseed),hl
	ret
