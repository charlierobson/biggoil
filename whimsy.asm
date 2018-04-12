
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


showwinch:
        ld      a,(winchframe)
        and     3
        rlca
        or      winchanim & 255
        ld      l,a
        ld      h,winchanim / 256
        ld      b,(hl)
        inc     hl
        ld      c,(hl)
        ld      hl,dfile+WINCH_OFFS
        ld      (hl),b
        inc     hl
        ld      (hl),c
        ret
    

gameoverscreen: 
    ld      hl,end
    ld      de,dfile
    call    decrunch

    ld      hl,titlestc
    call    init_stc
    ld      a,16
    ld	    (pl_current_position),a
    call    next_pattern

    ld      a,63
    ld      (timeout),a

_endloop:
    call    framesync
    push    iy
    call    play_stc
    pop     iy
	ld	    a,(pl_current_position)
    cp      18
    jr      nz,_endloop

    call    mute_stc
    ld      a,150  
    jp      waitfire
