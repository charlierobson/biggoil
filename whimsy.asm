
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

src 39 ->
dest len
 41   1
 40   2
 
    ld      a,1
    ld      hl,dfile+$41
    call    truckin
    ld      de,33
    add     hl,de
    inc     a


truckin:
    push    af
    push    hl
    ld      d,h
    ld      e,l
    ld      hl,offscreen
    ld      c,a
    ld      b,0
    ldir
    pop     hl
    pop     af
    ret
