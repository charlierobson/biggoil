;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;
.module SCORE

; add score in BC
;
addscore:
	ld		hl,(score)
	ld		d,h
	ld		a,l
	add		a,c
	daa
	ld		l,a
	ld		a,h
	adc		a,b
	daa
	ld		h,a
	ld		(score),hl

	sub		d						; d is high byte of score, 0HHLL0
	cp		1						; did score just flip the 1000s digit?
	jr		c,displayscore

	ld		a,h						; h contains 1000s digits
	and		$0f						; when 0 or 5 then extra man!
	jr		z,_addbonus
	cp		5
	jr		nz,displayscore

_addbonus:
	ld		a,(lives)				; every 5000 points an extra man!
	inc		a
	ld		(lives),a
	call	displaymen

	ld		a,$47					; length of uninterruptable sample
	ld		b,10					; sfx number
	call	longplay

displayscore:
	ld		de,dfile+SCORE_OFFS
_dselse:
	ld		hl,(score)
	ld		a,h
	call	_bcd_a

	ld		a,l

_bcd_a:
	ld		h,a
	rrca
	rrca
	rrca
	rrca
	and		$0f
	call	show_char
	ld		a,h
	and		$0f

show_char:
	add		a,$1c
	ld		(de),a
	inc		de
	ret

displayscoreonts:
	ld		de,dfile+SCORE_TITLE_OFFS
	jr		_dselse

checkhi:
	ld		hl,(hiscore)
	ld		de,(score)
	and		a
	sbc		hl,de					; results in carry set when score > hiscore
	ret		nc

	ex		de,hl
	ld		(hiscore),hl			; update hiscore, return with C set

displayhi:
	ld		de,dfile+HISCORE_OFFS
_dhielse:
	ld		hl,(hiscore)
	ld		a,h
	call	_bcd_a

	ld		a,l
	jp		_bcd_a


displayhionts:
	ld		de,dfile+HISCORE_TITLE_OFFS
	jr		_dhielse
