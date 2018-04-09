;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;
.module SFX

initsfx:
    ld      hl,soundbank
    call    INIT_AFX
    ret


; haha this is cheeky.
;
longplay:
    ld      (droneframe),a          ; prevent drone from taking over for the duration of this effect
    ld      a,b
    jp      AFXPLAYON3


initdrone:
    ld      a,(level)               ; drone rate
    rlca
    rlca
    rlca
    ld      b,a
    ld      a,40
    sub     b
    ld      (dronerate),a
    xor     a
    ld      (dronetype),a
    ld      (droneframe),a
    ret
      

drone:
    ld      a,(droneframe)
    and     a
    jr      z,_dronetime

    dec     a
    ld      (droneframe),a
    ret

_dronetime:
    ld      a,(dronerate)
    ld      (droneframe),a
    ld      a,(dronetype)
    xor     1
    ld      (dronetype),a
    add     a,15
    jp      AFXPLAYON3

droneframe:
    .byte   0
dronerate:
    .byte   0
dronetype:
    .byte   0



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