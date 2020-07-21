.module BONUSES

displayBonuses:
    ld      hl,bonusdefs
    ld      bc,$0301            ; b = bonus count, c = bonus number

-:  push    bc
    push    hl
    call    _checkAndDisplay
    pop     hl
    ld      de,4
    add     hl,de
    pop     bc
    inc     c
    djnz    {-}
    ret



_checkAndDisplay:
    ld      e,(hl)      ; de - address of data to check
    inc     hl
    ld      d,(hl)
    inc     hl
    ld      a,(hl)      ; hl - fn to check
    inc     hl
    ld      h,(hl)
    ld      l,a
    call    jphl
    ret     nz          ; not triggered

_displayBonus:
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

    ld      a,$25
    call    _bcdout
    ld      a,ZEROZ
    ld      (dfile+$17c),a
    ld      b,8
    call    waitframes

    ld      a,$25

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


jphl:
    jp      (hl)


_byteEqualsZero:
    ld      a,(de)
    or      a
    ret


_byteGreaterThan50:
    ld      a,(de)
    cp      50
    ld      a,0     ; if >= 50
    jr      nc,{+}
    ld      a,1     ; if < 50
+:  or      a       ; ret with z if < 50
    ret


_deathsPerLevel:
    .byte   0
_eeaten:
    .byte   0
_eexited:
    .byte   0
