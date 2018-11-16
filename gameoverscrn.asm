gameoverscn: 
	ld		hl,end
	ld		de,dfile
	call	decrunch

	call	init_stc
	ld		a,16
	ld		(pl_current_position),a
	call	next_pattern

	ld		a,150
	ld		(timeout),a

_endloop:
	call	framesync
	call	readinput

	ld		a,(pl_current_position)
	cp		18
	call	z,initsfx

	ld		a,(fire)
	and		3
	cp		1
	ret		z

	ld		a,(timeout)
	dec		a
	ld		(timeout),a
	jr		nz,_endloop
	ret
