;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;
.module SFX

initsfx:
    ld      hl,soundbank
    call    INIT_AFX
    ret



soundbank:
    .incbin     biggoil.afb