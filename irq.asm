installirq:
	ld	ix,relog
	ld	(iy+$34),$ff
	ret

relog:
	ld	    a,r
	ld	    bc,$1901
	ld	    a,$f5
	call	$02b5
	call	$0292
	call	$0220

	; do here
        push    iy
        call    AFXFRAME
        pop     iy

+:	ld      ix,relog
	jp      $02a4
