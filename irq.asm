;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;
.module IRQ

; ***************************************
; *      ZX81 Display Driver Demo       *
; * Using Custom Generated VSync Pulses *
; ***************************************
; (c)2022 Paul Farrow, www.fruitcake.plus.com
;
; You are free to use and modify this driver in your own programs.
;
; V1.00  18 JAN 2022  Initial version.

; ======================================================================================================================================================

; -----------
; Entry Point
; -----------

; Special display code.
;
; In order to give 50hz systems enough time to play the music in the bottom margin we need to reduce the screen height by 2 lines.

setupdisplay:
    CALL framesync

    LD   IX,GENERATE_DISPLAY        ; Select to run the custom display driver.

    IN   A,($FE)                    ; Nothing to do if 50hz
    AND  64
    RETNZ

    JP   (HL)

titleconfig:
    LD   A,32-1                     ; setup display driver for 60hz
    LD   (TMARGIN),a
    LD   A,40-1                     ; lose 8 lines in the bottom margin
    LD   (BMARGIN),a
    LD   A,22+1
    LD   (_dlines),a
    RET

gameconfig:
    LD   A,32-1                     ; setup display driver for 60hz
    LD   (TMARGIN),a
    LD   (BMARGIN),a
    LD   A,24+1
    LD   (_dlines),a
    RET

TMARGIN:
    .word   56-1
BMARGIN:
    .word   56-1

; ======================================================================================================================================================

; ==============
; Display Driver
; ==============
;
; This display driver uses a custom routine to handle the generation of the vertical sync pulse. This allows
; the actions performed during the VSync period to be chosen as required for the needs of the user program.

; -----------------------------------
; Generate VSync Pulse and Top Border
; -----------------------------------
; The ZX81 ROM routines output a picture consisting of the following number of scanlines:
;
;                 60Hz   50Hz
;                 ====   ====
;  Vertical Sync    6      6
;  Top Border      32     56
;  Active Area    192    192
;  Bottom Border   32     56
;                 ---    ---
;                 262    310
;
; 50Hz : 310 * 207 = 64170, which corresponds to a frame period of 19.745ms (98.725%).
; 60Hz : 262 * 207 = 54234, which corresponds to a frame period of 16.687ms (100.044%).
;
; The standard ZX81 display driver generates a VSync pulse of 1232 T-states (as measured from IN $FE to OUT $FF),
; which equates to 379.08us and corresponds to a duration of 5.95 scanlines (each of 207 T-states).
;
; Using a custom VSync routine instead of the ROM's routine offers a number of advantages:
; - Specific keys required by the user program could be read during this time rather than all keys.
; - A joystick interface could be read during this time.
; - Rather than read the 50Hz/60Hz input line every frame, this signal could be read just once at start up.
; - The number of rows in the main picture area could be increased with a corresponding decrease in the number of border
;   lines, which would give a larger usable screen area for the program to write to at the expense of a larger display file.
; - The number of rows in the main picture area could be decreased with a corresponding increase in the number of border
;   lines, which would give a slight performance boost to the user program and save RAM due to the smaller display file.
; - The ROM display routines output a VSync pulse of 6 scanlines duration. The smallest valid VSync pulse according to the TV
;   specification is 2.5 scanlines, although the smallest duration supported by the Chroma 81 interface is 3.3 scanlines, i.e.
;   684 T-states.
; - The system variables LAST_K, FRAMES and MARGIN can be freed up for alternate use by the program.
; - The IY register pair can be freed up for use by the program.
; - The position of the main display area does not have to be centred with an equal number of border lines above and below it,
;   but the number of border lines above the main display area should always be a multiple of 8 (those below don't have to be).
;
; The actions performed duration the VSync period must always take the exactly the same length of time to execute else jitter
; will be visible in the TV picture.
;
; The ROM display driver determines the number of border lines by reading bit 6 of port $FE and stores the result of its
; calculation in system variable MARGIN. It does this every frame. However, a custom VSync routine could simply rely on the ROM
; driver having already populated MARGIN or the program could calculate the number of border lines itself at start up and store
; the result somewhere in RAM for use by the custom VSync routine. Althernatively, the custom VSync routine could perform the
; input line read everytime and use the value directly without storing the result in RAM.
; The following shows how the number of lines to output in the top and bottom border areas can be determined:
;
;       IN   A,($FE)                    ; Read the 50Hz/60Hz input line.
;       RLA                             ; Rotate the bit into the carry flag.
;       RLA
;       SBC  A,A                        ; $FF (50Hz) or $00 (60Hz).
;       AND  $18                        ; $18 (50Hz) or $00 (60Hz).
;       ADD  A,$1F                      ; $37 (50Hz) or $1F (60Hz).
;       LD   (MARGIN),A                 ; Store the result.
;
; Note that an extra line is always output in addition to the value calculated above, i.e. $38 = 56 (50Hz) and $20 = 32 (60Hz).

GENERATE_VSYNC:
        IN   A,($FE)                    ; 11    Start the VSync pulse.

; T-states=11.

; The following example replicates the actions of the ROM VSync routine. It pads to be the exactly same duration as the ROM
; generated VSync pulse, which ensures a smooth transition back to BASIC and the standard ROM display driver. Note that the
; IY register pair is not used and so is free for use by the user program, giving an immediate benefit over using the standard
; ROM driver.

; You would replace the following with different operations as required for your program.

; Note that since the reading the keyboard is done using a IN from port $FE, the IN instruction above could be discarded and
; reading of the keyboard could double up as starting the VSync pulse.

        CALL $02BB                      ; 17+755=772    Read the keyboard.
        LD   (last_k),HL                ; 16    Store the returned key code.

; T-states=799.

        LD   HL,(frames)                ; 16    Fetch the frames count.
        DEC  HL                         ; 6     Decrement it.
        SET  7,H                        ; 8     Ensure bit 15 is always set to signal not being PAUSEd.
        LD   (frames),HL                ; 16    Store the new frames count.

; T-states=845.

        LD   A,(TMARGIN)                ; 13    Fetch the number of top border lines.

; T-states=858.

        LD   B,$1C                      ; 7     Padding delay constant.
        
GV_DELAY:
        DJNZ GV_DELAY                   ; 13/8  Pad out the VSync duration to be identical to that of the ROM display routine.

        NOP                             ; 4     Fine tune the pad duration.
        NOP                             ; 4     Fine tune the pad duration.

; T-states=1232.

        OUT  ($FF),A                    ; 11    End the VSync pulse.

; The vertical sync pulse has now been output, so continue to output the top border. The IX register pair is set to
; the address of the routine that generates the main display area, i.e. the custom driver, so that it will be output
; once all top border lines have been generated. A return to the user program is made and the lines of the top border
; will be automatically generated, interrupting the user program via NMIs for every border line. The NMI handler
; counts down the number of border lines and once it reaches 0 then the routine pointed to by IX is jumped to.

        LD   IX,GENERATE_DISPLAY        ; Set the video handler pointer to the active area generation routine.
        JP   $029E                      ; Return to user program and start generating the top border lines.

; --------------------------------------------
; Generate Main Display Area and Bottom Border
; --------------------------------------------
; After the top border has been generated, a jump to this address occurs via the IX register pair. The main display area
; is now generated.

GENERATE_DISPLAY:
        LD   A,R                        ; Fine tune delay.
_dlines=$+2
        LD   BC,$1901                   ; B=Row count (24 in main display + 1 for the border). C=Scan line counter for the border 'row'.
        LD   A,$F5                      ; Timing constant to complete the current border line.
        CALL $02B5                      ; Complete the current border line and then generate the main display area.

; All lines of the active area have been output, so continue to output the lower border. This is generated in exactly
; the same way as the top border. The IX register is set to the address of the routine that generates the vertical sync
; pulse so that a new frame will be produced once all bottom border lines have been generated. A return to the user
; program is made and the lines of the bottom border will be automatically generated, interrupting the user program via
; NMIs for every border line. The NMI handler counts down the number of border lines and once it reaches 0 then the routine
; pointed to by IX is jumped to. The following fetches the number of border lines from the system variable MARGIN, but to
; free up this location you could fetch the number of border lines from a different location you have previously set or
; could even read the 50Hz/60Hz input line and calculate the number of border lines every time.

; You could perform other tasks here is you wished, e.g. output sound or read a joystick.

        LD   A,(TMARGIN)                ; Fetch the number of bottom border lines. You could replace this to avoid using system variable MARGIN.
        
        LD   IX,GENERATE_VSYNC          ; Set the video handler pointer to the VSync generation routine.
        JP   $029E                      ; Return to user program and start generating the bottom border lines.

; ======================================================================================================================================================

irqsnd=$+1
    call    0


waitframes:
	call	framesync
	djnz	waitframes
	ret


framesync:
	ld		hl,frames
	ld		a,(hl)
-:	cp		(hl)
	jr		z,{-}
	ret
