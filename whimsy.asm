
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


truckfest:
    ld      c,10
--: ld      b,12
-:  call    framesync
    djnz    {-}
    push    bc
    call    truckdriveoff
    pop     bc
    dec     c
    jr      nz,{--}
    ret


truckdriveoff:
    xor     a
    ld      de,dfile+$41
    ld      hl,dfile+$40
    ld      bc,8
    lddr
    ld      (de),a
    ld      de,dfile+$62
    ld      hl,dfile+$61
    ld      bc,8
    lddr
    ld      (de),a
    ld      de,dfile+$83
    ld      hl,dfile+$82
    ld      bc,8
    lddr
    ld      (de),a
    ld      de,dfile+$a4
    ld      hl,dfile+$a3
    ld      bc,8
    lddr
    ld      (de),a
    ret

39 ->
     41, 40, 3f, 3e ... 39
      1   2   3   4      9

truckdriveoff:
    ld      hl,offscreenmap+$39
    ld      de,dfile+$41
    ld      bc,1
    ldir
    ld      hl,offscreenmap+$39+33
    ld      de,dfile+$41+33
    ld      bc,1
    ldir
    ld      hl,offscreenmap+$39+66
    ld      de,dfile+$41+66
    ld      bc,1
    ldir
    ld      hl,offscreenmap+$39+99
    ld      de,dfile+$41+99
    ld      bc,1
    ldir
    ld      hl,offscreenmap+$39+99+33
    ld      de,dfile+$41+99+33
    ld      bc,1
    ldir
    ret



truckdriveon:
    ld      de,dfile+$41
    ld      hl,dfile+$40
    ld      bc,8
    lddr
    ld      (de),a
    ld      de,dfile+$62
    ld      hl,dfile+$61
    ld      bc,8
    lddr
    ld      (de),a
    ld      de,dfile+$83
    ld      hl,dfile+$82
    ld      bc,8
    lddr
    ld      (de),a
    ld      de,dfile+$a4
    ld      hl,dfile+$a3
    ld      bc,8
    lddr
    ld      (de),a
    ret