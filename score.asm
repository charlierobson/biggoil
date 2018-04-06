;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;
.module SCORE
;

; add score in BC
;
addscore:
    ld      hl,(score)
    ld      d,h
    ld      a,l
    add     a,c
    daa
    ld      l,a
    ld      a,h
    adc     a,b
    daa
    ld      h,a
    ld      (score),hl

    sub     d               ; d is high byte of score, 0HHLL0
    cp      1               ; did score just flip the 1000s digit?
    jr      c,displayscore

    bit     0,h             ; return if odd number of 1000s
    jr      nz,displayscore

    ; do bonus here - every 2000 points

displayscore:
    ld      hl,(d_file)
    ld      de,SCORE_OFFS
    add     hl,de
    ex      de,hl

    ld      hl,(score)
    ld      a,h
    call    _bcd_a

    ld      a,l

_bcd_a:
    ld      h,a
    rrca
    rrca
    rrca
    rrca
    and     $0f
    call    show_char
    ld      a,h
    and     $0f

show_char:
    add     a,$1c
    ld      (de),a
    inc     de
    ret


checkhi:
    ld      hl,(hiscore)
    ld      de,(score)
    and     a
    sbc     hl,de           ; results in carry set when score > hiscore
    ret     nc

    ex      de,hl
    ld      (hiscore),hl    ; update hiscore, return with C set

displayhi:
    ld      hl,(d_file)
    ld      de,HISCORE_OFFS
    add     hl,de
    ex      de,hl

    ld      hl,(hiscore)
    ld      a,h
    call    _bcd_a

    ld      a,l
    jp      _bcd_a
