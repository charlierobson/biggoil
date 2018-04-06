;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;
.module ENEMIES

NENEMIES = 10

initialiseenemies:
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

    ld      iy,enemydata        ; magic!
    ret

startenemy:
    ld      iy,enemydata
    ld      b,NENEMIES
    ld      de,64
    xor     a

_search:
    cp      (iy)
    jr      z,gotone
    add     iy,de
    djnz    _search
    ret

gotone:
    ld      a,r
    and     7                   ; should be 0..entrance count -1 actually
    rlca
    rlca
    or      entrances & 255
    ld      l,a
    ld      h,entrances / 256

    ld      a,(hl)              ; address l
    ld      (iy+1),a
    inc     hl
    ld      a,(hl)              ; address h
    ld      (iy+2),a
    inc     hl
    ld      a,(hl)              ; direction
    ld      (iy+3),a
    xor     a
    ld      (iy+4),a
    ret

    .align  256
enemydata:
    .fill       64*10   ; 10 enemies of 64 bytes each
