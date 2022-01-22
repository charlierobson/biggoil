;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;
.module IRQ

installirq:
	ld		ix,relog
	ld		(iy+$34),$ff
_dummy:
	ret

relog:
	ld		a,r
	ld		bc,$1901
	ld		a,$f5
	call	$02b5
	call	$0292
	call	$0220

	; do here
	push	iy
irqsnd = $+1
	call	_dummy
	pop		iy

+:	ld		ix,relog
	jp		$02a4



waitframes:
	call	framesync
	djnz	waitframes
	ret


framesync:
	ld		hl,frames
	ld		a,(hl)
-:	cp		(hl)
	jr		z,{-}
	ret
