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

resettone:
    ld      hl,newtone+15
    ld      de,newtone
    ld      bc,15
    ldir
    ret

generatetone:
    push    af
	dec		a                   ; effect number in A
    call    updatetone
	ld 		h,0
	ld 		l,a
	add	 	hl,hl
	ld 		bc,soundbank+1
	add 	hl,bc
	ld 		c,(hl)
	inc 	hl
	ld 		b,(hl)
	add 	hl,bc				;the effect address is obtained in hl
    ld      de,newtone
    ex      de,hl
    ld      bc,15
    ldir
    pop     af
    jp      AFXPLAY


alter:
    dec     hl
    dec     hl
    dec     hl
    dec     hl
    dec     hl
    dec     hl
    dec     hl
    dec     hl
    dec     hl
    dec     hl
    dec     hl
    dec     hl
    ret

updatetone:
    ld      hl,(newtonep1)
    call    alter
    ld      (newtonep1),hl
    ld      hl,(newtonep2)
    call    alter
    ld      (newtonep2),hl
    ld      hl,(newtonep3)
    call    alter
    ld      (newtonep3),hl
    ld      hl,(newtonep4)
    call    alter
    ld      (newtonep4),hl
    ret

newtone:
newtonep1=newtone+1
newtonep2=newtone+5
newtonep3=newtone+8
newtonep4=newtone+11
    .byte   $EF,$F9,$03,$00,$AD,$03,$02,$AA,$2D,$01,$A7,$FB,$00,$D0,$20
    .byte   $EF,$F9,$03,$00,$AD,$03,$02,$AA,$2D,$01,$A7,$FB,$00,$D0,$20



soundbank:
    .incbin     biggoil.afb