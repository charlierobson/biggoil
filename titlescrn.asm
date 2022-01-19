;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;
.module TSC

titlescn:
    ld      hl,titleconfig
    call    setupdisplay

	call	init_stc

	ld		hl,0
	ld		(frames),hl

_titleredraw:
	ld		hl,title
	ld		de,dfile
	call	decrunch
	call	displayscoreonts
	call	displayhionts
	
_titleloop:
	call	framesync


    ld      a,(frames)  ; AB------
    rlca                ; -------A
    rlca                ; ------AB
    rlca                ; -----AB-
    and     6           ; 00000AB0  :- 0,2,4,6

    ld      hl,_titletextlist
    call    tableget

+:  ld		de,dfile+$300
	ld		bc,16
	ldir

_nochangetext:
	ld		  a,(frames)
	and		 16
	jr		  nz,_noflash

	ld		  hl,dfile+$300
	ld		  b,16
_ilop:
	set     7,(hl)
	inc		 hl
	djnz		_ilop

_noflash:
	ld		hl,titleinputstates
    call    readinputs

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

    call	instructions
    jr      _titleredraw

+:
	ld		  a,(begin)
	and		 3
	cp		  1
	jr		  nz,_titleloop
	ret
