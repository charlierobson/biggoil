.module BONUSES

displayBonuses:
    ld      a,1                 ; no discernable pause
    ld      (_eobdp),a

    ld      hl,bonusdefs
    ld      bc,$0601            ; b = bonus count, c = initial bonus number

-:  push    bc
    push    hl
    call    _checkAndDisplay
    pop     hl
    ld      de,6
    add     hl,de
    pop     bc
    inc     c                   ; next bonus number to check
    djnz    {-}

    ld      a,(_eobdp)          ; if any bonuses were hit we pause here a second or 2
    ld      b,a
    jp      waitframes


_checkAndDisplay:
    ld      a,(hl)
    ld      (_bonus),a
    inc     hl
    ld      a,(hl)
    push    af          ; stash compare value
    inc     hl
    ld      a,(hl)      ; address of compare fn
    ld      (_comparer+1),a
    inc     hl
    ld      a,(hl)
    ld      (_comparer+2),a
    ld      a,(hl)      ; hl - data address to check
    inc     hl
    ld      h,(hl)
    ld      l,a
    pop     af
_comparer:
    call    0
    ret     nz           ; no points to add

_displayBonus:
    ld      a,50        ; delay after showinf the bonuses
    ld      (_eobdp),a

    ld      a,ZEROZ
    add     a,c
    ld      (bonustext+15),a

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
    call    _bcdout
    ld      a,ZEROZ
    ld      (dfile+$17d),a
    ld      b,8
    call    waitframes

    ld      a,(_bonus)

-:  dec     a
    daa
    push    af
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
    ld      (dfile+$17b),a
    pop     af
    and     $0f
    add     a,ZEROZ
    ld      (dfile+$17c),a
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



_byteEQ:
    cp      (hl)
    ret     z           ; return with z if bonus is coming

_nope:
    or      $ff         ; nz if no bonus
    ret

_yep:
    xor     a
    ret

_byteGE:
    cp      (hl)
    jr      nc,_yep
    jr      _nope


_byteLT:
    cp      (hl)
    jr      c,_yep
    jr      _nope
