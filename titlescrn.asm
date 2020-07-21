;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;
.module TSC

_tt1:
	.asc	"press fire"
_tt2:
	.asc	"r:redefine"

titlescn:
	call	init_stc

_titleredraw:
	ld		hl,title
	ld		de,dfile
	call	decrunch
	call	displayscoreonts
	call	displayhionts
	
_titleloop:
	call	framesync

	ld		a,(frames)
	and		127
	jr		nz,_nochangetext

	ld		hl,_tt1
	ld		a,(frames)
	and		128
	jr		nz,{+}
	ld		hl,_tt2
+:  ld		de,dfile+$303
	ld		bc,10
	ldir

_nochangetext:
	ld		  a,(frames)
	and		 15
	jr		  nz,_noflash

	ld		  hl,dfile+$303
	ld		  b,10
_ilop:
	ld		  a,(hl)
	xor		 $80
	ld		  (hl),a
	inc		 hl
	djnz		_ilop

_noflash:
	call		readtitleinput

	ld		  a,(redef)				; redefine when r released
	and		 3
	cp		  2
	jr      nz,{+}
    call		redefinekeys
    jr      _titleloop

+:
	ld		  a,(instr)				; show instruction screen with I
	and		 3
	cp		  2
	jr      nz,{+}
	call		instructions
    jr      _titleredraw

+:
	ld		  a,(begin)
	and		 3
	cp		  1
	jr		  nz,_titleloop
	ret
