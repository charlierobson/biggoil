;
.module KEYS


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
;    .byte	%10000000,2,%00000001,0        ; up      (Q)
;             js      row   mask

    .align  64
_keychar:
    .asc    0,"zxcv"
    .asc    "asdfg"
    .asc    "qwert"
    .asc    "12345"
    .asc    "09876"
    .asc    "poiuy"
    .asc    2,"lkjh"
    .asc    1,".mnb"

_kcs:
    .word   _ksh,_ksp,_knl
_ksh:
    .asc    "shift  ",$ff
_ksp:
    .asc    "space  ",$ff
_knl:
    .asc    "newline",$ff

_keydata:
_keymask = $                ; aka mask when ued to detect key
_keyrow = $+1
    .byte   0,0

_bit2byte:
    .byte   1,2,4,8,16,0

redefinekeys:
    call    framesync
    call    inkbin
    call    getcolbit
    cp      $ff
    jr      z,redefinekeys

    xor     $ff             ; flip so we have a 1 bit where the key is

    ld      hl,_keydata
    ld      (hl),a
    inc     hl
    ld      (hl),c

    ld      hl,_bit2byte
    ld      bc,6
    cpir
    ld      a,b
    or      c
    jr      z,redefinekeys  ; continue if key bit wasn't found, perhaps 2 keys pressed at once

    ld      a,5
    sub     c             ; a is bit number
    push    af

    ld      hl,_keychar

    ld      a,(_keyrow)
    ld      c,a
    add     a,a
    add     a,a
    add     a,c             ; a = c * 5
    add     a,l

    pop     bc              ; recover bit offset
    add     a,b

    ld      l,a
    ld      a,(hl)
    cp      8
    jr      c,_isstring

    ld      (dfile+1),a
    xor     a
    ld      (dfile+2),a
    ld      (dfile+3),a
    ld      (dfile+4),a
    ld      (dfile+5),a
    ld      (dfile+6),a
    ld      (dfile+7),a
    jr      redefinekeys

_isstring:
    ld      hl,_kcs
    add     a,a
    add     a,l
    ld      l,a
    ld      a,(hl)
    inc     hl
    ld      h,(hl)
    ld      l,a
    ld      de,dfile+1
-:  ldi
    ld      a,(hl)
    cp      $ff
    jr      nz,{-}
    jr      redefinekeys

getcolbit:
    ld      bc,$0800        ; b is loop count, c is row index
    ld      hl,INPUT._kbin

-:  ld      a,(hl)          ; byte will have a 0 bit if a key is pressed
    or      $e0
    cp      $ff
    ret     nz
    inc     c
    inc     hl
    djnz    {-}
    ret
