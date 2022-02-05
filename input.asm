;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;
.module INPUT


_settitle:
	ld		hl,titleinputstates
    jr      {+}

_setgame:
	ld		hl,inputstates
+:  ld      (_inputs),hl
    ret

_read:
_inputs=$+1
    ld      hl,titleinputstates     ; self modified

	ld		bc,$e007				; initiate a zxpand joystick read
	ld		a,$a0
	out		(c),a

    nop
    nop

	in		a,(c)
	ld		e,a                     ; cache joystick read value in e

    ld      c,$fe                   ; keyboard input port

	; point at first input state block,
	; return from update function pointing to next
	;
	call	updateinputstate ; (up)
	call	updateinputstate ; (down)
	call	updateinputstate ;  etc.
	call	updateinputstate ;

	; fall into here for last input

updateinputstate:
	ld		a,(hl)					; joystick mask
	ld		(_jstest),a			    ; self modify mask for j/s bit test

	inc		hl                      ; kb port address
	ld		b,(hl)
    in      a,(c)                   ; get key input bits
	inc		hl                      ; key row mask
	and		(hl)					; result will be a = 0 if required key is down
	jr		z,{+}					; skip joystick read if key detected

    ld      a,e                     ; retrieve cached js read

_jstest = $+1
+:	and		0						; self modified - result is 0 if key detected _or_ js & mask == 0
    sub     1                       ; carry set if result was 0 ie direction detected, DEC doesnt affect carry :(
    inc		hl						; key state
    rl      (hl)                    ; shift carry into bit train
    inc		hl						; leave hl ready for next input in table
	ret
