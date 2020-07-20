;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;
.module REDEFDATA

; -----  4  3  2  1  0
;
; $FE -  V, C, X, Z, SH	0
; $FD -  G, F, D, S, A	 1
; $FB -  T, R, E, W, Q	 2
; $F7 -  5, 4, 3, 2, 1	 3
; $EF -  6, 7, 8, 9, 0	 4
; $DF -  Y, U, I, O, P	 5
; $BF -  H, J, K, L, NL	6
; $7F -  B, N, M, ., SP	7
;
;		 js mask	row	kb mask  -
; .byte	%10000000, 2, %00000001, 0  ; up (Q)

	.align  64
_keychar:
	.asc	0,"zxcv"
	.asc	"asdfg"
	.asc	"qwert"
	.asc	"12345"
	.asc	"09876"
	.asc	"poiuy"
	.asc	2,"lkjh"
	.asc	1,".mnb"

_kcs:
	.word	_ksh,_ksp,_knl
_ksh:
	.asc	"shift  ",$ff
_ksp:
	.asc	"space  ",$ff
_knl:
	.asc	"newline",$ff

_keydata:
_keymask = $						; aka mask when ued to detect key
_keyrow = $+1
	.byte	0,0

_keyaddress:
	.word	0

_bit2byte:
	.byte	1,2,4,8,16,0

_pkf:
	.asc	"press key for:"
_upk:
	.asc	"    up    "
_dnk:
	.asc	"   down   "
_lfk:
	.asc	"   left   "
_rtk:
	.asc	"   right  "
_frk:
	.asc	"   fire   "
