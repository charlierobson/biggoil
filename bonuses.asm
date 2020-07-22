.module BONUSES

displayBonuses:
    ld      a,1                 ; no discernable pause
    ld      (_eobdp),a

    ld      hl,bonusdefs
    ld      bc,$0B01            ; b = bonus count, c = initial bonus number

-:  push    bc
    push    hl
    call    _checkAndDisplay
    pop     hl
    ld      de,6
    add     hl,de
    pop     bc

    ld      a,c                 ; bonus number in c, bcd
    inc     a
    daa
    ld      c,a

    djnz    {-}

    ld      a,(_eobdp)          ; if any bonuses were hit we pause here a second or 2
    ld      b,a
    jp      waitframes


_checkAndDisplay:
    ld      a,(hl)      ; score if bonus achieved
    ld      (_bonus),a
    inc     hl

    ld      a,(hl)      ; value to use in compare function
    push    af
    inc     hl

    ld      a,(hl)      ; address of compare fn
    ld      (_comparer+1),a
    inc     hl
    ld      a,(hl)
    ld      (_comparer+2),a
    inc     hl

    ld      a,(hl)      ; hl - data address to check
    inc     hl
    ld      h,(hl)
    ld      l,a

    pop     af          ; recover value

_comparer:
    call    0
    ret     nz           ; no points to add

_displayBonus:
    ld      a,50        ; delay after showinf the bonuses
    ld      (_eobdp),a

    ld      a,c
    ld      de,bonustext+14
    call    _bcdout

    ld      a,8
    ld      hl,dfile+$0ee
    ld      bc,$1407        ; 20 across, 7 high
    call    _drrect
    ld      a,0
    ld      hl,dfile+$110
    ld      bc,$1205        ; 18 across, 5 high
    call    _drrect

    ld      hl,bonustext
    ld      de,dfile+$132
    ld      bc,16
    ldir

    ld      a,(_bonus)
    ld      de,dfile+$17b
    call    _bcdout
    ld      a,ZEROZ
    ld      (dfile+$17d),a
    ld      b,8
    call    waitframes

    ld      a,(_bonus)

-:  dec     a
    daa
    push    af
    ld      de,dfile+$17b
    call    _bcdout
    ld      bc,1
    call    addscore
    ld      a,18
    call    AFXPLAY
    call    framesync
    call    framesync
    pop     af
    and     a
    jr      nz,{-}

    ret

_bcdout:
    push    af
    srl     a
    srl     a
    srl     a
    srl     a
    add     a,ZEROZ
    ld      (de),a
    inc     de
    pop     af
    and     $0f
    add     a,ZEROZ
    ld      (de),a
    ret


_drrect:
    push    hl
    push    bc              ; preserve B
    call    _drline
    pop     bc
    pop     hl
    ld      de,33
    add     hl,de
    dec     c
    jr      nz,_drrect
    ret

_drline:
    ld      (hl),a
    inc     hl
    djnz    _drline
    ret



    ; a is value to check against, (hl) is variable
    ; i.e. if lives > 4
    ; a = 4, hl = lives
    ; 4 - (hl) results in z set if lives = 4, c set if lives > 4

_byteEQ:
    cp      (hl)
    ret     z           ; return with z if bonus is coming

_nope:
    or      $ff         ; nz if no bonus
    ret

_yep:
    xor     a
    ret


_byteGT:
    cp      (hl)
    jr      c,_yep
    jr      _nope


_byteGTE:
    cp      (hl)
    jr      z,_yep
    jr      c,_yep
    jr      _nope


_byteLT:
    cp      (hl)
    jr      z,_nope
    jr      c,_nope
    jr      _yep


_byteLTE:
    cp      (hl)
    jr      c,_nope
    jr      _yep
