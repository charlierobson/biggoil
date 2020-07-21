.module BONUSES

displayBonuses:
    ld      hl,bonusdefs
    ld      bc,$0201            ; b = bonus count, c = bonus number

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

    call    _displayBonus

    ld      b,100      ; 2 seconds
    call    waitframes
    ret


_displayBonus:
    ld      a,ZEROZ
    add     a,c
    ld      (_bonustext+15),a

    ld      a,8
    ld      hl,dfile+$0ee
    ld      bc,$1407        ; 20 across, 7 high
    call    _drrect
    ld      a,0
    ld      hl,dfile+$110
    ld      bc,$1205        ; 18 across, 5 high
    call    _drrect

    ld      hl,_bonustext
    ld      de,dfile+$132
    ld      bc,16
    ldir
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

_bonustext:
    .asc    "secret bonus: 00"


jphl:
    jp      (hl)

_byteEqualsZero:
    ld      a,(de)
    or      a
    ret

_deathsPerLevel:
    .byte   0
_eeaten:
    .byte   0
_eexited:
    .byte   0
