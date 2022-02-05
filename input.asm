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


readtitleinput:
	ld		hl,titleinputstates
	jr		_ri

readinput:
	ld		hl,inputstates
_ri:
	push	hl
	ld		bc,$e007				; initiate a zxpand joystick read
	ld		a,$a0
	out		(c),a

	call	inkbin

	ld		bc,$e007				; retrieve joystick byte
	in		a,(c)
	ld		(_lastJ),a

	; point at first input state block,
	; return from update function pointing to next
	;
	pop		hl
	call	updateinputstate ; (up)
	call	updateinputstate ; (down)
	call	updateinputstate ;  etc.
	call	updateinputstate ;

	; fall into here for last input

updateinputstate:
	ld		a,(hl)					; input info table
	ld		(_uibittest),a			; get mask for j/s bit test
	ld		a,(_lastJ)
    ld      b,a

	inc		hl
	ld		a,(hl)					; half-row index
	inc		hl
	ld		de,_kbin				; keyboard bits table pointer - must not straddle page boundary
    add     a,e                     ; because we don't adjust MSB
    ld      e,a
	ld		a,(de)					; get key input bits
	and		(hl)					; result will be a = 0 if required key is down
	inc		hl
	jr		z,{+}					; skip joystick read if key detected

    ld      a,b

_uibittest = $+1
+:	and		0						; self modifies: result is 0 if key detected or js & mask == 0
    sub     1                       ; carry set if result was 0 ie direction detected, dec doesnt affect carry :()
    rl      (hl)
    inc		hl						; ready for next input in table
	ret
