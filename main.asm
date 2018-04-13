;-------------------------------------------------------------------------------

	.org	$4009

	.exportmode NO$GMB
	.export

versn	.byte	$00
e_ppc	.word	$0000
d_file	.word	dfile
df_cc	.word	dfile+1 
vars	.word	var
dest	.word	$0000 
e_line	.word	var+1 
ch_add	.word	last-1 
x_ptr	.word	$0000 
stkbot	.word	last 
stkend	.word	last 
breg	.byte	$00 
mem		.word	membot 
unuseb	.byte	$00 
df_sz	.byte	$02 
s_top	.word	$0000 
last_k	.word	$ffff 
db_st	.byte	$ff
margin	.byte	55 
nxtlin	.word	line10 
oldpc	.word	$0000
flagx	.byte	$00
strlen	.word	$0000 
t_addr	.word	$0c8d; $0c6b
seed	.word	$0000 
frames	.word	$ffff
coords	.byte	$00 
		.byte	$00 
pr_cc	.byte	188 
s_posn	.byte	33 
s_psn1	.byte	24 
cdflag	.byte	64 
PRTBUF	.fill	32,0
prbend	.byte	$76 
membot	.fill	32,0

UP = 0
RIGHT = 1
DOWN = 2
LEFT = 4

PIPE_VERT = $85
PIPE_HORIZ = $03

PIPE_HEAD1 = $34			; 'O'
PIPE_HEAD2 = $1c			; '0'
FUEL1 = $14
FUEL2 = $16

ZEROZ = $1c					; '0'
ONEZ = $1d					; '1'
DOT = $1b					; '.'
ENEMY = $0c					; '£'

MAP_PIPE = $08				; grey square

SCORE_OFFS = $2fe
SCORE_TITLE_OFFS = $2f8
HISCORE_OFFS = $307
HISCORE_TITLE_OFFS = $313

LVL_OFFS = $311
MEN_OFFS = $317
INITIAL_OFFS = $b7
WINCH_OFFS = $34
FUELLING_OFFS = $7a
TIMER_OFFS = $98

	.include	charmap.asm

;-------------------------------------------------------------------------------

line1:
	.byte	0,1
	.word	line01end-$-2
	.byte	$ea

;-------------------------------------------------------------------------------
;
.module A_MAIN
	call	seedrnd
	call	installirq

	ld		b,100					; give time for crappy LCD tvs to re-sync
	call	waitframes

aaat:
	call	titlescn

	xor		a
	ld		(level),a
	ld		(score),a
	ld		(score+1),a

	ld		a,4
	ld		(lives),a

	ld		a,DOWN
	ld		(retractqueue-1),a

	call	displayscoreline

	call	initsfx

newlevel:
	call	displaylevel
	call	createmap
	call	initentrances

	call	initdrone

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

	xor		a
	ld		(playerhit),a

mainloop:
	call	framesync
	call	readinput

	ld		a,(fire)				; if fire button has just been released then reset the retract tone
	and		3
	cp		2
	call	z,resettone

	call	updatecloud
	call	drone

	call	generateenemy

	ld		a,(frames)
	and		63
	call	z,dotimer				; returns with z set if timer has hit 0
	jr		z,_die

	call	updateenemies
	ld		a,(playerhit)
	and		a
	jr		z,_playon

_die:
	call	loselife
	jp		nz,restart

	ld		b,75
	call	waitframes

	call	gameoverscreen

	jp		titlescn

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
	jr		nz,mainloop

	ld		a,(headchar)			; animate the digging head
	xor		PIPE_HEAD1 ^ PIPE_HEAD2
	ld		(headchar),a

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

	call	countdots
	jp		nz,mainloop

nextlevel:
	ld		a,12
	call	AFXPLAY

	call	tidyup
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
	dec		a
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

countdots:
	ld		hl,dfile+6*33
	ld		de,16*33
	ld		c,0

-:	ld		a,(hl)
	cp		DOT
	jr		nz,{+}

	inc		c

+:	inc		hl
	dec		de
	ld		a,d
	or		e
	jr		nz,{-}

	ld		a,c
	or		a
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


invertscreen:
	ld		hl,dfile
	ld		bc,33*24

_inverter:
	ld		a,(hl)
	cp		$76
	jr		z,_noinvert

	xor		$80
	ld		(hl),a

_noinvert:
	inc		hl
	dec		bc
	ld		a,b
	or		c
	jr		nz,_inverter
	ret

;-------------------------------------------------------------------------------

waitfire:
	ld		(timeout),a

-:	call	framesync
	call	readinput

	ld		a,(fire)
	and		3
	cp		1
	ret		z
	
	ld		a,(timeout)
	dec		a
	ld		(timeout),a
	jr		nz,{-}
	ret

;-------------------------------------------------------------------------------

	.include player.asm
	.include enemies.asm
	.include score.asm
	.include input.asm
	.include sfx.asm
	.include stcplay.asm
	.include irq.asm
	.include ayfxplay.asm
	.include leveldata.asm
	.include whimsy.asm
	.include titlescrn.asm
	.include decrunch.asm
	.include redefinekeys.asm

	.include data.asm

;-------------------------------------------------------------------------------

	.byte	$76
line01end:
line10:
	.byte	0,2
	.word	line10end-$-2
	.byte	$F9,$D4,$C5,$0B				; RAND USR VAL "
	.byte	$1D,$22,$21,$1D,$20	; 16514 
	.byte	$0B							; "
	.byte	076H						; N/L
line10end:

var:
	.byte	080H
last:

	.end
