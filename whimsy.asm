
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


truckdrive:
    ld      de,dfile+$41
    ld      hl,dfile+$40
    ld      bc,9
    lddr
    ld      (hl),0
    ld      de,dfile+$62
    ld      hl,dfile+$61
    ld      bc,9
    lddr
    ld      (hl),0
    ld      de,dfile+$83
    ld      hl,dfile+$82
    ld      bc,9
    lddr
    ld      (hl),0
    ld      de,dfile+$94
    ld      hl,dfile+$93
    ld      bc,9
    lddr
    ld      (hl),0
    ret