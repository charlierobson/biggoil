game:
	xor		a
	ld		(level),a
	ld		(score),a
	ld		(score+1),a
    ld      (BONUSES._levelsWithoutADeath),a

	ld		a,4
	ld		(lives),a

	call	displayscoreline

	call	initsfx

    call    INPUT._setgame

newlevel:
	call	displaylevel
	call	createmap
	call	initentrances

	call	initdrone

    xor     a
    ld      (BONUSES._deathsPerLevel),a
    ld      (BONUSES._eexited),a

restart:
	ld		a,$99
	ld		(timerv),a
	call	inittimer

	call	initialiseenemies
	call	initenemytimer

	call	displaymen

	ld		hl,dfile+INITIAL_OFFS	; set initial position and direction
	ld		(playerpos),hl

	ld		a,DOWN					; player's 'last' move was down so correct pipe can be drawn
	ld		(playerdirn),a

	ld		hl,retractqueue			; initialise the pipeline retract lifo
	ld		(retractptr),hl
	dec		hl
	ld		a,DOWN
	ld		(hl),a

	xor		a
	ld		(playerhit),a

mainloop:
	call	framesync

	ld		a,(fire)				; if fire button has just been released then reset the retract tone
	and		3
	cp		2
	call	z,resettone

	call	updatecloud
	call	drone

	call	generateenemy

    ld      a,(timestop)           ; decrement timestop to zero
    and     a
    jr      z,{+}
    dec     a
    ld      (timestop),a 

+:	ld		a,(frames)
	and		63
	call	z,dotimer				; returns with z set if timer has hit 0
	jr		z,_die

	call	updateenemies
	ld		a,(playerhit)
	and		a
	jr		z,_playon

_die:
    ld      hl,BONUSES._deathsPerLevel
    inc     (hl)
    ld      hl,BONUSES._levelsWithoutADeath
    ld      (hl),0

	call	loselife
	jp		nz,restart

	ld		b,75
	call	waitframes
    ret

_playon:
	ld		a,(fire)				; retract happens quickly so check every frame
	and		1
	jr		z,_noretract

	ld		hl,(retractptr)			; because the retract buffer sits on a 256 byte
	xor		a						; boundary we can use the lsb to tell when it's empty
	cp		l
	jr		z,mainloop				; even if we can't retract, jump back

	call	retract					; retract the head
	ld		a,(frames)
	and		1
	call	z,retract				; do an extra retract every other frame

	ld		a,(winchframe)			; update winch animation
	inc		a
	ld		(winchframe),a

	call	showwinch				; so it's about a speed and a half
	ld		a,(frames)
	and		3						; prepare the z flag
	ld		a,18					; set up sound number in case it's time
	call	z,generatetone
	jp		mainloop

_noretract:
	ld		a,(frames)				; only dig every nth frame
	and		3						; could be game speed controller?
	cp		3
	jp		nz,mainloop

	ld		a,(headchar)			; animate the digging head
	xor		PIPE_HEAD1 ^ PIPE_HEAD2
	ld		(headchar),a

    ld      a,(retractptr)          ; pipe length
    inc     a
    jr      z,_headupdate           ; is 255 so can't move

	call	tryup					; the tryxxx functions return with z set
	jr		z,_headupdate			; if that direction was taken

	call	trydown
	jr		z,_headupdate

	call	tryleft
	jr		z,_headupdate

	call	tryright

_headupdate:
	call	showwinch				; animate the winch

	ld		hl,(playerpos)			; update the digging head
	ld		a,(headchar)
	ld		(hl),a

	ld		a,(scoretoadd)			; any score last frame?
	and		a			
	jp		z,mainloop

	ld		c,a						; add score
	xor		a
	ld		(scoretoadd),a
	ld		b,a
	call	addscore
	call	checkhi

	call	lorryfill

    call    detectdot
    jp      z,mainloop

    ; next level

    ld      a,(BONUSES._deathsPerLevel)         ; did player die at all this level?
    and     a
    jr      nz,{+}

    ld      hl,BONUSES._levelsWithoutADeath     ; no, so track how many levels we did without dying
    inc     (hl)

+:  ld		a,12
	call	AFXPLAY

	call	tidyup

    call    displayBonuses

	call	levelup
	call	displaylvl

	jp		newlevel


;-------------------------------------------------------------------------------


inittimer:
	ld		a,(timerv)
	jr		_timerdd

dotimer:
	ld		a,(timerv)
	and		a
	ret		z
	sub		1
	daa
	ld		(timerv),a
_timerdd:
	push	af
	and		$f0
	rrca
	rrca
	rrca
	rrca
	add		a,ZEROZ+128
	ld		de,dfile+TIMER_OFFS
	ld		(de),a
	pop		af
	and		$0f
	add		a,ZEROZ+128
	inc		de
	ld		(de),a
	ret


;-------------------------------------------------------------------------------


loselife:
	ld		a,(lives)
	cp		1
	jr		nz,{+}

	ld		a,13
	call	AFXPLAY

+:	call	tidyup
	ld		a,(lives)
	dec		a
	ld		(lives),a
	ret


;-------------------------------------------------------------------------------


tidyup:
	ld		b,4
-:	push	bc
	call	framesync
	call	invertscreen
	pop		bc
	djnz	{-}

	call	resetenemies

-:	call	framesync
	call	retract						; retract the head
	call	retract
	call	retract
	ld		a,(winchframe)			; update winch animation
	inc		a
	ld		(winchframe),a
	call	showwinch
	ld		a,(retractptr)
	and		a
	jr		nz,{-}
	ret
