;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;
.module SFX

initsfx:
    ld      hl,soundbank
    call    INIT_AFX
    ret


playlo:
        push    af
        ld      a,16
        call    AFXPLAYON3
        pop     af
        ret

playloer:
        push    af
        ld      a,15
        call    AFXPLAYON3
        pop     af
        ret


soundbank:
    .incbin     biggoil.afb