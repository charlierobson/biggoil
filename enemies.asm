;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;
.module ENEMIES

NENEMIES = 10

initialiseenemies:
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
    ret


startenemy:
    ld      iy,enemydata-64     ; can't leave iy dangling past initialised data
    ld      b,NENEMIES
    ld      de,64
    xor     a

-:  add     iy,de
    cp      (iy)
    jr      z,_ehstart
    djnz    {-}
    ret

_ehstart:
    inc     (iy)
    ld      a,r
    and     7                   ; should be 0..entrance count -1 actually
    rlca
    rlca
    or      entrances & 255
    ld      l,a
    ld      h,entrances / 256

    ld      a,(hl)              ; address l
    ld      e,a
    ld      (iy+1),a

    inc     hl
    ld      a,(hl)              ; address h
    ld      d,a
    ld      (iy+2),a

    inc     hl
    ld      a,(hl)              ; direction
    ld      (iy+3),a

    inc     hl
    ld      a,(hl)              ; direction
    ld      (iy+4),a

    ld      a,(de)              ; undraw character
    ld      (iy+5),a
    ret


updateenemies:
    ld      iy,enemydata-64
    ld      b,NENEMIES

-:  ld      de,64
    add     iy,de
    ld      a,(iy)
    cp      1
    call    z,_ehup
    djnz    {-}
    ret

_ehup:
    ld      l,(iy+1)
    ld      h,(iy+2)

    ex      de,hl               ; on the player's head?
    ld      hl,(playerpos)
    and     a
    sbc     hl,de
    ex      de,hl
    jr      z,_ediedwithscore

    ld      a,(frames)
    and     15
    cp      15
    ret     nz

    ld      e,(iy+3)            ; move
    ld      d,(iy+4)
    ld      a,(iy+5)
    ld      (hl),a
    add     hl,de
    ld      a,(hl)              ; get character in target square
    ld      (iy+5),a

    cp      $76                 ; about to wander off screen?
    jr      z,_edied

    ex      de,hl               ; about to wander onto the player's head?
    ld      hl,(playerpos)
    and     a
    sbc     hl,de
    ex      de,hl
    jr      z,_ediedwithscore

    cp      0                   ; blank square
    jr      z,{+}

    and     $7f                 ; see if we've compromised the pipe
    cp      8
    jr      nc,{+}

    ld      (playerhit),a       ; signal life lost

+:  ld      (iy+1),l            ; show where we hit
    ld      (iy+2),h
    ld      (hl),ENEMY
    ret


_ediedwithscore:
    ld      a,(scoretoadd)
    add     a,2
    ld      (scoretoadd),a

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
    ld      l,(iy+1)
    ld      h,(iy+2)
    ld      a,(iy+5)
    ld      (hl),a

+:  djnz    {-}
    ret


    .align  256
enemydata:
    .fill       64*10,0 ; 10 enemies of 64 bytes each
