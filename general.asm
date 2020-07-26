adda2hl:
    add     a,l
    ld      l,a
    ret     nc
    inc     h
    ret

tableget:
    call    adda2hl
    ld		a,(hl)
	inc		hl
	ld		h,(hl)
	ld		l,a
    ret

