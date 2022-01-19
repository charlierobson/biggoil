;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;
.module INPUT

inkbin:
	ld		de,_kbin
	ld		bc,$fefe
	ld		l,8

-:	in		a,(c)
	rlc		b
	ld		(de),a
	inc		de

	dec		l
	jr		nz,{-}
	ret


readinput:
	ld		hl,inputstates
    jp      readinputs
