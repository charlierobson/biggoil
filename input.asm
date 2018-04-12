;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;
.module INPUT

; -----  4  3  2  1  0
;
; $FE -  V, C, X, Z, SH   0
; $FD -  G, F, D, S, A    1
; $FB -  T, R, E, W, Q    2
; $F7 -  5, 4, 3, 2, 1    3
; $EF -  6, 7, 8, 9, 0    4
; $DF -  Y, U, I, O, P    5
; $BF -  H, J, K, L, NL   6
; $7F -  B, N, M, ., SP   7
;
; input state data:
;
; joystick bit, or $ff/%11111111 for no joy
; key row offset 0-7,
; key mask, or $ff/%11111111 for no key
; trigger impulse

titleinputstates:
    .byte	%00001000,7,%00000001,0        ; startgame   (SP)
    .byte	%10000000,2,%00001000,0        ; redefine    (R)
    .byte	%11111111,1,%11111111,0
    .byte	%11111111,7,%11111111,0
    .byte	%11111111,7,%11111111,0

inputstates:
    .byte	%00001000,7,%00000001,0        ; fire    (SP)
    .byte	%10000000,2,%00000001,0        ; up      (Q)
    .byte	%01000000,1,%00000001,0        ; down    (A)
    .byte	%00100000,5,%00000010,0        ; left    (O)
    .byte	%00010000,5,%00000001,0        ; right   (P)

; calculate actual input impulse addresses
;
begin    = titleinputstates + 3
redef    = titleinputstates + 7
fire     = inputstates + 3
up       = inputstates + 7
down     = inputstates + 11
left     = inputstates + 15
right    = inputstates + 19

; kbin is filled by the display interrupt

    .align  8
_kbin:
    .fill   8

_lastJ:
    .byte   $ff


inkbin:
    ld      de,_kbin
    ld      bc,$fefe
    ld      l,8

-:  in      a,(c)
    rlc     b
    ld      (de),a
    inc     de

    dec     l
    jr      nz,{-}
    ret


readtitleinput:
    ld      hl,titleinputstates
    jr      _ri

readinput:
    ld      hl,inputstates
_ri:
    push    hl
    ld      bc,$e007        ; initiate a zxpand joystick read
    ld      a,$a0
    out     (c),a

    call    inkbin

    ld      bc,$e007        ; retrieve joystick byte
    in      a,(c)
    ld      (_lastJ),a

    ; point at first input state block,
    ; return from update function pointing to next
    ;
    pop     hl
    call    updateinputstate ; (up)
    call    updateinputstate ; (down)
    call    updateinputstate ;  etc.
    call    updateinputstate ;

    ; fall into here for last input

updateinputstate:
    ld      a,(hl)          ; input info table
    ld      (_uibittest),a  ; get mask for j/s bit test

    inc     hl
    ld      a,(hl)          ; half-row index
    inc     hl
    ld      de,_kbin        ; keyboard bits table pointer - 8 byte aligned
    or      e
    ld      e,a             ; add offset to table
    ld      a,(de)          ; get key input bits
    and     (hl)            ; result will be a = 0 if required key is down
    inc     hl
    jr      z,{+}           ; skip joystick read if pressed

    ld      a,(_lastJ)

+:  sla     (hl)            ; (key & 3) = 0 - not pressed, 1 - just pressed, 2 - just released and >3 - held

_uibittest = $+1
    and     0               ; if a key was already detected a will be 0 so this test succeeds
    jr      nz,{+}          ; otherwise joystick bit is tested - skip if bit = 1 (not pressed)

    set     0,(hl)          ; signify impulse

+:  inc     hl              ; ready for next input in table
    ret

