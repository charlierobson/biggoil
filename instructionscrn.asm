;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;
.module INSTRUCTIONS

instructions:
	ld		hl,0
	ld		(frames),hl

	ld		hl,help
	ld		de,dfile
	call	decrunch

_helploop:
	call	framesync
    call    updatecloud

    ld      a,(frames)  ; AB------
    rlca                ; -------A
    rlca                ; ------AB
    rlca                ; -----AB-
    and     6           ; 00000AB0  :- 0,2,4,6

    ld      hl,_instcreds
    call    tableget

    ld      de,dfile+$300
    ld      bc,16
    ldir

	ld		a,(begin)
	and		3
	cp		1
	jr		nz,_helploop

	ret
