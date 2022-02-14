;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;
.module INPUT


_settitle:
	ld		hl,titleinputstates
    jr      {+}

_setgame:
	ld		hl,inputstates
+:  ld      (_inputptr),hl
    ret


; 724T, constant

_read:
	ld		bc,$e007				; initiate a zxpand joystick read
	ld		a,$a0
	out		(c),a

_inputptr=$+1
	ld		hl,titleinputstates		; !! self modified
	nop								; timing

	in		a,(c)
	ld		d,a

	ld		c,$fe					; keyboard input port

	; point at first input state block,
	; return from update function pointing to next
	;
	call	_update ; (up)
	call	_update ; (down)
	call	_update ;  etc.
	call	_update ;

	; fall into here for last input

_update:
	ld		a,d						; js value
	and		(hl)					; and with js mask, 0 if dirn pressed
	sub		1						; carry set if result was 0. have to SUB, DEC doesnt affect carry :(
	rl		e						; js result: bit 0 set if dirn detected. starting value of e is irrelevant
	inc		hl						; -> kb port address
	ld		b,(hl)
	in		a,(c)					; read keyboard
	inc		hl						; -> key row mask
	and		(hl)					; result will be 0 if key pressed
	sub		1						; carry set if key pressed
	rla								; carry into bit 0
	or		e						; integrate js results, only care about bit 0
	rra								; completed result back into carry
	inc		hl						; ->key state
	rl		(hl)					; shift carry into input bit train, job done
	inc		hl						; -> next input in table
	ret
