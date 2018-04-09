;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;
.module ENEMIES

NENEMIES = 10

EO_ENA = 0  ; enemy enable 1 = active
EO_ADL = 1  ; screen address lo
EO_ADH = 2  ; screen address hi
EO_MDL = 3  ; move delta lo
EO_MDH = 4  ; move delta hi
EO_ANL = 5  ; animation ptr lo
EO_ANH = 6  ; animation ptr hi
EO_BG = 7   ; background redraw char
EO_FNO = 8  ; frame num

initialiseenemies:
    ld      iy,$4000

    ld      hl,enemydata
    ld      de,enemydata+1
    ld      bc,64*10-1
    ld      (hl),0
    ldir

	ld		a,(margin)
	ld		b,NENEMIES
    ld      hl,enemydata-5      ; -3 because I use a cheat to offset to the MARGIN address

-:  ld		de,$28+5            ; +3 takes into account addresses after the CDFlag
	add		hl,de
	ld		(hl),a				; MARGIN
	ld		de,$3B-$28
	add		hl,de
	ld		(hl),$c0			; CDFLAG
    djnz    {-}

    ld      iy,enemydata
    ret


startenemy:
    ld      a,3
    call    AFXPLAY

    xor     a
    ld      de,64
    ld      b,NENEMIES

    ld      iy,enemydata
    jr      {+}

-:  add     iy,de
+:  cp      (iy)
    jr      z,_ehstart
    djnz    {-}
    ret


_ehstart:
    inc     (iy)

    ld      a,(entrancecount)   ; shonky fixed point multiply
    ld      b,a                 ; get a random byte, treat it as a n/256 fraction
    call    xrnd8               ; add it to a total (entrancecount) times
    ld      c,a                 ; integer part is incremented when carry over
    xor     a
    ld      l,a
-:  add     a,c
    jr      nc,{+}
    inc     l
+:  djnz    {-}

    ld      a,l                 ; l is integer 0..entranceCount-1
    and     a                   ; clear carry
    rlca
    rlca
    rlca
    or      entrances & 255
    ld      l,a
    ld      h,entrances / 256

    ld      a,(hl)              ; address l
    ld      e,a
    ld      (iy+EO_ADL),a

    inc     hl
    ld      a,(hl)              ; address h
    ld      d,a
    ld      (iy+EO_ADH),a

    inc     hl
    ld      a,(hl)              ; direction
    ld      (iy+EO_MDL),a

    inc     hl
    ld      a,(hl)              ; direction
    ld      (iy+EO_MDH),a

    inc     hl
    ld      a,(hl)              ; animation number
    and     a
    rlca
    ld      (iy+EO_ANL),a
    ld      (iy+EO_ANH),enemyanims / 256

    ld      a,(de)              ; get the 'undraw' character
    cp      DOT                 ; undraw safety net
    jr      z,{+}
    xor     a                   ; crossing enemies destroy oil! muaaahahhaa
+:  ld      (iy+EO_BG),a
    ret


updateenemies:
    ld      b,NENEMIES
    ld      iy,enemydata
    jr      {+}

-:  ld      de,64               ; de is corrupted in call so need to re-init
    add     iy,de
+:  ld      a,(iy)
    cp      1
    call    z,_ehup
    djnz    {-}
    ret

_ehup:
    ld      l,(iy+EO_ADL)
    ld      h,(iy+EO_ADH)

    ex      de,hl               ; check if the player has eaten this enemy
    ld      hl,(playerpos)
    and     a
    sbc     hl,de
    ex      de,hl
    jr      z,_ediedwithscore

    ld      a,(frames)          ; only update every few frames
    and     15
    cp      15
    ret     nz

    inc     (iy+EO_FNO)         ; internal frame counter

    ld      a,(iy+EO_BG)        ; undraw at old pos
    ld      (hl),a

    ld      e,(iy+EO_MDL)       ; move
    ld      d,(iy+EO_MDH)
    add     hl,de

    ex      de,hl               ; about to wander onto the player's head in the updated position?
    ld      hl,(playerpos)
    and     a
    sbc     hl,de
    ex      de,hl
    jr      z,_ediedwithscore

    ld      a,(hl)              ; get character in target square

    cp      $76                 ; about to wander off screen?
    jr      z,_edied

    ld      (iy+EO_BG),a        ; store bg char for undrawing next frame
    cp      DOT                 ; if not a dot then zero it as it's a space or another enemy
    jr      z,{+}

    ld      (iy+EO_BG),0        ; force bg char

+:  cp      0                   ; blank square? if so end update
    jr      z,_eupd

    cp      128                 ; block wall - reverse!
    jr      nz,_testhit

    ld      e,(iy+EO_MDL)       ; move
    ld      d,(iy+EO_MDH)
    xor     a
    sub     e
    ld      e,a
    sbc     a,a
    sub     d
    ld      d,a
    ld      (iy+EO_MDL),e       ; move
    ld      (iy+EO_MDH),d
    add     hl,de
    add     hl,de
    jr      _eupd

_testhit:
    ld      e,a
    and     $7f                 ; see if we've compromised the pipe
    cp      8
    jr      nc,_eupd

    ld      (iy+EO_BG),e        ; replace the bg character as it will have been zeroed
    ld      (playerhit),a       ; signal life lost
    ld      a,7
    call    AFXPLAY

_eupd:
    ld      (iy+EO_ADL),l       ; store updated position
    ld      (iy+EO_ADH),h

    ld      e,(iy+EO_ANL)       ; animate
    ld      d,(iy+EO_ANH)
    ld      a,(iy+EO_FNO)
    and     1
    or      e
    ld      e,a
    ld      a,(de)
    ld      (hl),a
    ret


_ediedwithscore:
    ld      a,(scoretoadd)
    add     a,2
    ld      (scoretoadd),a
    ld      a,14
    call    AFXPLAY

_edied:
    dec     (iy)
    ret


resetenemies:
    ld      iy,enemydata-64
    ld      b,NENEMIES

-:  ld      de,64
    add     iy,de
    ld      a,(iy)
    cp      1
    jr      nz,{+}

    dec     (iy)
    ld      l,(iy+EO_ADL)
    ld      h,(iy+EO_ADH)
    ld      a,(iy+EO_BG)
    ld      (hl),a

+:  djnz    {-}
    ret



seedrnd:
    ld      a,r
    and     a
    jr      z,seedrnd
    ld      l,a
    ld      a,r
    ld      h,a
    ld      (xrnd16+1),hl
    ret


xrnd8:
    ld      a,(xrnd16+1)
    ld      c,a
    rrca
    rrca
    rrca
    xor     $1f
    add     a,c
    sbc     a,255
    ld      (xrnd16+1),a
    ret


xrnd16:
    ld      hl,1       ; seed must not be 0
    ld      a,h
    rra
    ld      a,l
    rra
    xor     h
    ld      h,a
    ld      a,l
    rra
    ld      a,h
    rra
    xor     l
    ld      l,a
    xor     h
    ld      h,a
    ld      (xrnd16+1),hl
    ret

    .align  256
enemydata:
    .fill       64*10,0 ; 10 enemies of 64 bytes each


MINUS = $16
ERLCHAR = $12
ELRCHAR = $13

enemyanimL2R = 0
enemyanimR2L = 1

    .align 256
enemyanims:
    .byte       ENEMY,ENEMY|128       ; enemyanim0
    .byte       ENEMY,ENEMY|128       ; enemyanim1 etc
