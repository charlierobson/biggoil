readinputs:
	push	hl
	ld		bc,$e007				; initiate a zxpand joystick read
	ld		a,$a0
	out		(c),a

	call	inkbin

	ld		bc,$e007				; retrieve joystick byte
	in		a,(c)
	ld		(INPUT._lastJ),a

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

	inc		hl
	ld		a,(hl)					; half-row index
	inc		hl
	ld		de,INPUT._kbin      	; keyboard bits table pointer - 8 byte aligned
    add     a,e
    ld      e,a
    jr      nc,{+}
    inc     d
+:	ld		a,(de)					; get key input bits
	and		(hl)					; result will be a = 0 if required key is down
	inc		hl
	jr		z,{+}					; skip joystick read if pressed

	ld		a,(INPUT._lastJ)

+:	sla		(hl)					; (key & 3) = 0 - not pressed, 1 - just pressed, 2 - just released and >3 - held

_uibittest = $+1
	and		0						; if a key was already detected a will be 0 so this test succeeds
	jr		nz,{+}					; otherwise joystick bit is tested - skip if bit = 1 (not pressed)

	set		0,(hl)					; signify impulse

+:	inc		hl						; ready for next input in table
	ret
