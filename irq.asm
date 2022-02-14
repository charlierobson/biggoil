;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;
.module IRQ


; To install the display driver simply:
;	ld 	ix,DISPLAY._GENERATE

_GENERATE_VSYNC:
	IN		A,($FE)						; Start the VSync pulse.

	; The user actions must always take the same length of time.
	; Should be at least 3.3 scanlines (684 T-states) in duration for Chroma 81 compatibility.
	CALL	INPUT._read

	OUT		($FF),A						; End the VSync pulse.

	LD		HL,(frames)
	INC		HL
	LD		(frames),hl

.ifdef TOP_BORDER_USER_ACTIONS
	LD		A,(margin)					; Fetch or specify the number of lines in the top border (must be a multiple of 8).
	NEG									; The value could be precalculated to avoid the need for the NEG and INC A here.
	INC		A
	EX		AF,AF'

	OUT		($FE),A						; Turn on the NMI generator to commence generating the top border lines.

	;		OUT	($FD),A					; @ Turn off the NMI generator to visually see how long the user actions take, i.e. how many extra top border lines it introduces.
	CALL	DO_TOP_USER_ACTIONS			; The user actions must not take longer than the time to generate the top border at either 50Hz or 60Hz.
	;		OUT	($FE),A					; @ Turn on the NMI generator to stop timing the user actions.

	LD		IX,_GENERATE_DISPLAY		; Set the display routine pointer to generate the main picture area next.
	JP		$02A4						; Return to the user program.

.else

	LD		A,(margin)					; Fetch or specify the number of lines in the top border (must be a multiple of 8).
	LD		IX,_GENERATE_DISPLAY		; Set the display routine pointer to generate the main picture area next.
	JP		$029E						; Commence generating the top border lines and return to the user program.

.endif

_GENERATE_DISPLAY:
	LD		A,R							; Fine tune delay.
_SCRLINES=$+2
	LD		BC,$1901					; B=Row count (24 in main display + 1 for the border). C=Scan line counter for the border 'row'.
	LD		A,$F5						; Timing constant to complete the current border line.
	CALL	$02B5						; Complete the current border line and then generate the main display area.

_GENERATE_BOTTOM_MARGIN:
	LD		A,(bmargin)					; Fetch or specify the number of lines in the bottom border (does not have to be a multiple of 8).
	NEG									; The value could be precalculated to avoid the need for the NEG and INC A here.
	INC		A
	EX		AF,AF'

	OUT		($FE),A						; Turn on the NMI generator to commence generating the bottom border lines.
	PUSH	IY
irqsnd=$+1
	CALL	_dummy						; The user actions must not take longer than the time to generate the bottom border at either 50Hz or 60Hz.
	POP		IY

	LD		IX,_GENERATE_VSYNC			; Set the display routine pointer to generate the VSync pulse next.
	JP		$02A4						; Return to the user program.

bmargin:
	.byte	55							; 50hz default

framesync:
	ld		hl,frames
	ld		a,(hl)
-:	cp		(hl)
	jr		z,{-}

ledsoff:
    ld      a,$b7                       ; green off
    call    ledctl
    ld      a,$b9                       ; red off
ledctl:
    push    bc
    ld      bc,$e007                    ; zxpand LED control
    out     (c),a
    pop     bc
    ret

waitframes:
	call	framesync
	djnz	waitframes
_dummy:
	ret
