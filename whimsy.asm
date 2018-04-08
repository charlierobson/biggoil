START1 = 0
LEN1 = 18
START2 = 23
LEN2 = 10

cldfrm:
    .byte   0

    .align  128
clouds:
	.byte	$00, $0a, $08, $09, $00, $00, $00, $00, $00, $00, $00, $0a, $0a, $09, $09, $00, $00, $00, $08, $08, $0a, $00, $00, $00, $00, $00, $00, $09, $08, $08, $0a, $00
	.byte	$00, $00, $00, $09, $09, $00, $00, $00, $00, $0a, $08, $00, $00, $00, $00, $09, $0a, $00, $00, $00, $09, $09, $08, $00, $00, $00, $00, $00, $00, $0a, $09, $00
	.byte	$00, $0a, $08, $09, $00, $00, $00, $00, $00, $00, $00, $0a, $0a, $09, $09, $00, $00, $00, $08, $08, $0a, $00, $00, $00, $00, $00, $00, $09, $08, $08, $0a, $00

updatecloud:
    ld      a,(frames)
    and     a
    ret     nz

    ld      a,(cldfrm)
    inc     a
    and     63
    ld      (cldfrm),a
    or      clouds & 255
    ld      l,a
    ld      h,clouds / 256
    ld      de,dfile+1+START1
    ld      bc,LEN1
    ldir
    inc     hl
    inc     hl
    inc     hl
    inc     hl
    inc     de
    inc     de
    inc     de
    inc     de
    ld      bc,LEN2
    ldir
    ret


lorryfill:
    ld      a,(fuelchar)            ; show fuel pumping into lorry
    xor     FUEL1 ^ FUEL2
    ld      (fuelchar),a
    ld      (dfile+FUELLING_OFFS),a
    ret
