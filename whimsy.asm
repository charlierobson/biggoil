;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;
.module WHIMSY

updatecloud:
	ld		a,(frames)
	and		a
	ret		nz

	ld		a,(cldfrm)
	inc		a
	and		63
	ld		(cldfrm),a
	or		clouds & 255
	ld		l,a
	ld		h,clouds / 256
	ld		de,dfile+1+CLDSTART1
	ld		bc,CLDLEN1
	ldir
	inc		hl
	inc		hl
	inc		hl
	inc		hl
	inc		de
	inc		de
	inc		de
	inc		de
	ld		bc,CLDLEN2
	ldir
	ret


lorryfill:
	ld		a,(fuelchar)				; show fuel pumping into lorry
	xor		FUEL1 ^ FUEL2
	ld		(fuelchar),a
	ld		(dfile+FUELLING_OFFS),a
	ret


showwinch:
	ld		a,(winchframe)
	and		3
	rlca
	or		winchanim & 255
	ld		l,a
	ld		h,winchanim / 256
	ld		b,(hl)
	inc		hl
	ld		c,(hl)
	ld		hl,dfile+WINCH_OFFS
	ld		(hl),b
	inc		hl
	ld		(hl),c
	ret



invertscreen:
	ld		hl,dfile
	ld		bc,33*24

_inverter:
	ld		a,(hl)
	cp		$76
	jr		z,_noinvert

	xor		$80
	ld		(hl),a

_noinvert:
	inc		hl
	dec		bc
	ld		a,b
	or		c
	jr		nz,_inverter
	ret
