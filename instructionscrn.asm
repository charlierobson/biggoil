;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;
.module INSTRUCTIONS

instructions:
	ld		hl,0
	ld		(frames),hl

	ld		hl,help
	ld		de,dfile
	call	decrunch

	ld		hl,backmsg
	ld		de,dfile+$2FE
	ld		bc,$20
	ldir


_helploop:
	call	framesync
	call	readtitleinput

	ld		a,(begin)
	and		3
	cp		1
	jr		nz,_helploop

	ret

