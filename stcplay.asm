;originally written for tasm assembler
; altered for fasm september 2017
; by andy rea
; re-altered for brass a day later :d
; by sirmorris

; zx81 ay player
;
; modified from the soundtracker playback module
;
; 13/8/2011
;
; andy rea
;



; l8003: ;c30980    
;               jp      initalise
; l8006: ;c34481    
;               jp      play_sound                                                              ;this is the call point
	
mute_stc:
	ld	hl,mute_list
	jp	mute_ay
	.byte	0,0,0,0,0,0,0,0,0,0,0,0,0
mute_list:
	.byte	0
	;for intterupt driven
	;sound every 1/50th second
					
init_stc:
	call	framesync
	call	mute_ay
    ld      hl,play_stc
    ld      (irqsnd),hl
	ld      hl,titlestc

;stc_stuff
	ld	a,(hl)									;get delay value
	ld	(pl_delay_value),a							;store it
	ld	(song_start_base_address),hl				;store start of song data
												
	
	inc	hl									;point to next byte in song data
												;this should point to positions map 
	call	get_next_word_and_add_base					;get a word + offset into de, returns pointer to
												;actual byte. i.e. start of song (base) + offset
												;on entry hl = adrress of low byte
												;on exit hl = (entry hl+2)
												;de = word fetched
												
	ld	a,(de)									;get number of patterns in song
												;this is count from zero, so a value of 1 means 2 patterns long
												;a value of 2 means 3 patterns long and so on...
												
	inc	de									;point to next byte in positions map
	inc	a										;see above, a now holds true number of patterns
	
	ld	(number_of_patterns_in_song),a					;save number of patterns
	ld	(ptr_positions_data),de 				;save pointer to positions data
	call	get_next_word_and_add_base					;get a word + offset into de
												;this should point to the ornaments
	ld	(ptr_compiled_ornaments),de				;store pointer to compiled ornaments
	
	push	de									;temp save that pointer value
	
	call	get_next_word_and_add_base					;get a word offset
												;this should point to the pattern data				
					
	ld	(ptr_patterns_data),de					;save pointer to patterns data
	ld	hl,$001b								;offset to compiled samples
												;they always start at offset $001b
												
												;there is some text in the stc file
												;this skips over the text field
    
	call	add_base_address							;adds hl to the base address of 
												;the song data
												;returnd with address to sample in de
												;old de in hl
	
	ex	de,hl									;swap de and hl back
	ld	(ptr_samples_data),hl						;save pointer to samples


;=====================
;the following code clears (set to 0) the channel program data stores
;and also clears (set to 0) the ay_data

;toodo work out what extra byte is for

; i think it may be just to cause the channel pharser to think that the
; end of the pattern data has been reached, and to go to the next pattern.
; the byte it points to is $ff
; pattern data is terminated with $ff

	ld	hl,extra_unknown_byte						;??? not known yet
	
	ld	(ptr_channel_a_pattern_data),hl 			;point channel a to byte $ff 
												
												
	ld	hl,channel_1_prog_store_minus_2 			
	ld	de,channel_1_prog_store_minus_1 
	ld	bc,$002c								;44 bytes
	ld	(hl),b									;load $00 into first byte
	ldir											;fill the rest of the channel control vars and data to sedn to ay with zero

	pop	hl									;retrieve pointer to compiled ornaments...
												
	ld	bc,$0021								;each compiled ornament is 33 bytes long
												;byte 1 = ornament number
												;next 32 = ornament data
												;positive numbers = normal
												;negative numbers = 2's compliment !
	
	xor	a										;zero a register
   
	call	mphlwastpbc					   ;looks for a zero at ornament number
												;and returns with hl pointing there
												;not sure why because if i have read
												;the structure of the stc file correctly
												;the first ornament is always zero
												; but it seems that different compilers can put them in any order....
												
					
       
	dec	a										; make a = 255	   
	ld	(channel_1_prog_store_plus_7),a 			;entry in channel 1 prog data
	ld	(channel_2_prog_store_plus_7),a 			;entry in channel 2 prog data
	ld	(channel_3_prog_store_plus_7),a 			;entry in channel 3 prog data
												;default start values
      
	ld	a,$01									;initial value for delay count
	ld	(delay_count),a 						;when play_song is first called 
												;will make it start at a new line.
       
	inc	hl									;should be pointing to ornament 0, so make it pont to ornament 0 data
	ld	(channel_1_prog_store_plus_5),hl			;entry in channel 1 prog data
	ld	(channel_2_prog_store_plus_5),hl			;entry in channel 2 prog data
	ld	(channel_3_prog_store_plus_5),hl			;entry in channel 3 prog data
												;all channels point to ornament zero (empty ornament, all zeros)
	
	call	send_data_to_ay 						;prog registers
												;all ay data set to zero
												;should silence it.
;               ei                                                                                      ;initializze complete
	ret											;yeah
	
;=============
; play control vars
;=============

ptr_positions_data:
	.word	$0000
ptr_compiled_ornaments:
	.word	$0000
ptr_patterns_data:
	.word	$0000
ptr_samples_data:
	.word	$0000
pl_delay_value: 
	.byte	$00
delay_count:
	.byte	$01
number_of_patterns_in_song:
	.byte	$01
	

ptr_channel_a_pattern_data:
	.word $e745
	
ptr_channel_b_pattern_data:
	.word $678c
	
ptr_channel_c_pattern_data:
	.word $67d8
	
extra_unknown_byte:	  
	.byte	$ff

channel_1_prog_store_minus_2:
	.byte	0							;some kind of flag, $00 = ornanment , $01 = ay_envelope , $02 = use noise
								;think it is to say what last byte of pattern data is used for.
channel_1_prog_store_minus_1:
	.byte	0							;could be dual purpose...
								;but one use is to hold the number of blank lines, used to reset the blank lines counter
								; i think it also holds the repeat counter for the samples
	   
channel_1_prog_store_base: 

;toodo  work out what +$00 is ?

	.byte	0							;??? current sample/ornament step ???
	.byte	0							;??? note value ???
	.byte	0							;blank lines counter
channel_1_prog_store_plus_3:   
	.byte	0							;points to sample data for channel
	.byte	0 
channel_1_prog_store_plus_5: 
	.byte	0							;points to ornamewnt data for channel
	.byte	0
channel_1_prog_store_plus_7:
	.byte	0							;repeat length
								;counts down
								;reset to 32 when a new note starts

;channel_2_prog_store_minus_2
c2psm2:
	.byte	0
;channel_2_prog_store_minus_1
c2psm1:
	.byte	0
	
channel_2_prog_store_base: 
	.byte	0
	.byte	0
	.byte	0
channel_2_prog_store_plus_3:   
	.byte	0							;points to sample data for channel
	.byte	0
channel_2_prog_store_plus_5: 
	.byte	0
	.byte	0
channel_2_prog_store_plus_7:
	.byte	0
	
;channel_3_prog_store_minus_2
l8096:
	.byte	0     
;channel_3_prog_store_minus_1
l8097:
	.byte	0  

channel_3_prog_store_base: 
	.byte	0
	.byte	0
	.byte	0
channel_3_prog_store_plus_3:   
	.byte	0							;points to sample data for channel
	.byte	0 
channel_3_prog_store_plus_5: 
	.byte	0
	.byte	0
channel_3_prog_store_plus_7:
	.byte	0
	
	
pl_current_position:
 
	.byte	0 

data_to_send_to_ay:  
	
ay_data_tone_chan_a:
ay_reg0:				;tone channel a, fine
	.byte	0
ay_reg1:				;tone channel a, coarse (lower 4 bits, high byte)
	.byte	0
	
ay_data_tone_chan_b:
ay_reg2:				;tone channel b, fine
	.byte	0
ay_reg3:				;tone channel b, coarse (lower 4 bits, high byte)
	.byte	0
	
ay_data_tone_chan_c:
ay_reg4:				;tone channel c, fine
	.byte	0
ay_reg5:				;tone channel c, coarse (lower 4 bits, high byte)
	.byte	0
	
ay_data_noise_freq:
ay_reg6:				;noise gen control (lower 5 bits only)
	.byte	0
ay_data_mixer:
ay_reg7:				;mixer contolr, b6,b7 io control, b5,b4,b3 = noise c,b,a, b2,b1,b0 = tone c,b,a - a zero = on.
	.byte	0
ay_data_amp_a:
ay_reg8:				;applitude control channel a, b7,b6,b5 not used, b4 = amplitude 'mode', b3,b2,b1,b0 = amplitude
	.byte	0
ay_data_amp_b:
ay_reg9:				;applitude control channel b, see above
	.byte	0
ay_data_amp_c:
ay_reg10:				;applitude control channel c, see above
	.byte	0
ay_data_env_freq:		;the code only seems to ever change the fine, coarse remains at 0
ay_reg11:				;envelope frequency fine
	.byte	0	
ay_reg12:				;envelope frequecy	coarse
	.byte	0
	

end_data_to_send_to_ay:
ay_data_env_shape:
ay_reg13:
	.byte	0			;envelope shape (effect)   
		

;==============             
;= tests for a match
;= between contents of memory pointed to by hl
;= with contents of a. if a match is found returns imediatly
;=
;= else hl incremented by bc and the new location is retested
;=
;= preserved de, bc, a
;= altered hl, points to address of match
;==============

mphlwastpbc:
	
	cp	(hl)		;test byte pointed to by hl with a
	ret	z			;return if equal
	add	hl,bc		;else add bc
	jp	mphlwastpbc		   ;and loop round
	
;==============             
;=            =
;= subroutine =
;=            =
;= gets the word pointed to by hl
;= adds contents of (song_start_base_address) tot hat word
;= and returns result in de
;=
;= preserved a
;= borked bc, holds base address
;= altered de = new address
;= altered hl = hl + 2
;==============         
	
get_next_word_and_add_base:	
       
	ld	e,(hl)	      
	inc	hl	 
	ld	d,(hl)	      
	inc	hl	 
	ex	de,hl
	
song_start_base_address = $+1
add_base_address:    
	ld	bc,$0000	;self modifing code !
					      
	add	hl,bc	    
	ex	de,hl	    
	ret 

;==============
;=            =
;= subroutine =
;=            =
;==============

; on entry iy points to sample data for the channel
; ib entry a = curent step
;
; on exit
;
; h = noise value for current step
; l = env value
; de = effect value (bit 4 of d is sign, value is 3 nibbles)
;
; b = 2 for tone, 0 for no tone
; c = 16 for noise, 0 for no noise


process_sample_data:	
	ld	d,$00
	ld	e,a				; de = a
	add	a,a				; a = a *2
	add	a,e				; a = a * 3
	ld	e,a				; de = a * 3
	add	iy,de				; iy now points to current sample data, for this step
	ld	a,(iy+$01)			; b7 noise mask, b6 env mask, b5 sign for effect, b4-0 noise val
	bit	7,a				; test bit 7, noise mask
	ld	c,$10				; prepare c = 16
	jp	nz,keep_c			; 
	ld	c,d				; else c = zero
keep_c:
	bit	6,a				; test bit 6, tone mask
	ld	b,$02				; prepare b = 2
	jp	nz,keep_b
	ld	b,d				; else b =0
keep_b:
	and	$1f				; noise val only
	ld	h,a				; keep it in h
	ld	e,(iy+$02)			; low byet effect 
	ld	a,(iy+$00)			; b7-4 high part of effect. b3-0 env vol
	push	af				; temp save
	and	$f0				; high part of effect
	rrca	
	rrca	
	rrca	
	rrca	
	ld	d,a				; high part of effect, de now holds effect
	pop	af				; retrieve previous 
	and	$0f				; env vol only
	ld	l,a				; env volume
							; so h holds noise val, l holds env val
							
	bit	5,(iy+$01)			; test sign of effect
	ret	z					; return if zero. for addition
      
	set	4,d				; else set bit 4 in d, for subtraction
	ret   
	
;==============
;=            =
;= subroutine = 
;=            =
;=====================================
;=                                   =
;= sets the next pattern to play     =
;=                                   =
;=====================================

next_pattern:
   
	ld	a,(pl_current_position) 			;current position 
										;first run position = 0
	ld	c,a
	ld	hl,number_of_patterns_in_song		;point to number of patterns
										
										
	cp	(hl)							;a - (hl) carry set if (hl) > a
    
	jp	c,next_position 				;jp if (hl) > a, more positions to go
	
	;else back to position 1.
	xor	a								;reset current position
	ld	c,a							
	
next_position:
	inc	a								; a = 1 if reset curren position
										; or a = a+1 (next position) 
										
	ld	(pl_current_position),a 			; store new current position.
	 
	ld	l,c							; current position number less one !
	ld	h,$00							; into hl
	add	hl,hl							; double it (index to ,2 bytes per value, table
	ld	de,(ptr_positions_data) 		; get the start of the positions table )
	add	hl,de							; add the index into table
	ld	c,(hl)							; get values from the positions map
	inc	hl							;
	ld	a,(hl)							; c (low byte [pattern to use]) and a (heigth of pattern)
	ld	(pl_current_height),a				; save height byte
	ld	a,c							; pattern number into a
	ld	hl,(ptr_patterns_data)			; get pointer to patterns data table
										;
										; this is a table with 7 bytes per entry
										; byte 1 = pattern number
										; bytes 2/3 = offset to channel a pattern data
										; bytes 4/5 = offset to channel b pattern data
										; bytes 6/7 = offset to channel c pattern data
						
    
	ld	bc,$0007						; use as increment when stepping through pattern data table
	call	mphlwastpbc			   ; step through patterns data until a match is found
	inc	hl							; routine above leaves hl pointing at the pattern number that matched
										; inc hl so it points to next byte in pattern data table
   
	call	get_next_word_and_add_base			; get the pointer to channel a pattern
	ld	(ptr_channel_a_pattern_data),de 	; store it
	call	get_next_word_and_add_base			; channel b
	ld	(ptr_channel_b_pattern_data),de 	; store it
	call	get_next_word_and_add_base			; channel c
	ld	(ptr_channel_c_pattern_data),de 	; and store it
	ret 
	
;==============
;=            =
;= subroutine =
;=            =
;==============

decrement_counter:	    
	dec	(iy+$02)		;decrement the current channels blank line counter.	 
	ret	p				;return if bit 7 reset set above
	
						;as that memory location holds zero on first run, this operation will always continue here
						; but the values are still meaningless (on first run)
						
	ld	a,(iy-$01)		;else get reset value	 
	ld	(iy+$02),a		;and reset it	   
	ret 
	
;==================
;=                =
;= main play loop =
;=                =
;=============================
;=                           =
;= call every 1/50 th second =
;=                           =
;=============================
	
play_stc:    
   
	ld	a,(delay_count) 				;get current delay count       
	dec	a								;decrement it
	ld	(delay_count),a 				;and save new value	
	jp	nz,process_channels				;jp if delay count has not reached zero
										;in other words
										;conrinue to post process the channels
										;still doing same line in pattern
										
;on first call to play_sound (after initalise) the delay count was set to 1
;so we will always arrive here...
	
delay_countdown_reached_zero:	
	ld	a,(pl_delay_value)					;get the delay value for this song.    
	ld	(delay_count),a 				;reset delay counter  
	
	
	ld	iy,channel_1_prog_store_base		;set up index register for channel 1
	call	decrement_counter				;decrement blank line counter
										;and resets it when it reaches 0
										;ready for next data ???  
										
										
										;if blank line counter was reset then we
										;will skip the following jump and
										;process the next pattern data byte for 
										;channel 1
										
										 
	jp	p,new_data_channel_2				;if still positive (sub called above)
										;then jump (skip channel)
										
;on first run we will end up here...

new_data_channel_1:

;===============
;if we are here then there should be new data in the pattern data for channel 1                                 
   
	ld	hl,(ptr_channel_a_pattern_data) 	;points to channel data in current pattern ?
										;
										;on first run this is pointing to $ff (from the initalise routine)
										
										;pattern data terminated with $ff 
	ld	a,(hl)							;get the byte pointed to
	inc	a								;is it the terminator ?
	call	z,next_pattern					;then get the next pattern for all channels	
										;notice this is a "call..."
										
	;so when we return here, the pattern data pointer for each of the channels are set
	;and point to the matching patterns for position 1.
										
	ld	hl,(ptr_channel_a_pattern_data) 	;points to channel data 
										;iy still pointing to channel_1_prog_store_base
	call	process_channel_data				;process channel data
										;returns with hl pointing to the 
										;next un-processed byte in that channel
	ld	(ptr_channel_a_pattern_data),hl
	
	
new_data_channel_2:	
	ld	iy,channel_2_prog_store_base		;index for channel 2   
	call	decrement_counter
	jp	p,new_data_channel_3
	
	ld	hl,(ptr_channel_b_pattern_data)
	call	process_channel_data
	ld	(ptr_channel_b_pattern_data),hl
	
new_data_channel_3:
  
	ld	iy,channel_3_prog_store_base		;index for channel 3
	call	decrement_counter
	jp	p,process_channels
  
	ld	hl,(ptr_channel_c_pattern_data)
	call	process_channel_data
	ld	(ptr_channel_c_pattern_data),hl
	jp	process_channels					;channel processing done
										;now lets turn that into ay data
	
	
;==============
;=            =
;= subroutine =
;=            =
;==============
;
; this routine does not return to calling code
; directly, but returns from one of the 
; sections of code jumped to
; according to the data byte value

process_channel_data:
	
	ld	a,(hl)							;get next byte of pattern data for channel
	cp	$60							;a < $60 then is note data.
	jp	c,note_data						;a = $0 thru $5f ~ bits 0-4 = note in semitones $00 = c-1
     
	cp	$70							;a => $60 < $70 ?
	jp	c,sample_number 				;a = $60 thru $6f ~ bits 0-4 = sample number	  
	cp	$80							;a => $70 < $80 ?
	jp	c,ornament_number						;a = $70 thru $7f ~ bits 0-4 = ornament number
	jp	z,plrest							;a = $80 ~ rest (stop channel)
	cp	$81							;a = $81 ?
	jp	z,empty_location					;a = $81 ~ empty location ???
	cp	$82							;a = $82
	jp	z,ornament_zero 				;a = $82 ~ selects ornament 0
	cp	$8f							;a => $83 < $8f
	jp	c,effect_number 				; a = $83 < $8e ~ selects effect
	sub	$a1							; else subract 161 from a
    
	ld	(iy+$02),a						; counter for number of blank lines 
	ld	(iy-$01),a						; and erm ???
	inc	hl							; point to next byte
	jp	process_channel_data				; and loop round to process next byte
	
	
	
;===============
;=             =
;= routine      =
;=             =
;=================================
;=                               =
;= deals with semitone note data =
;=                               =
;=================================

note_data:
	ld	(iy+$01),a						; store the note data byte (in semitones)
	ld	(iy+$00),$00					; new note starts at step 0
	ld	(iy+$07),$20					; and 32 steps
	
;= this point is jumped ot for an empty location

empty_location:
	inc	hl							; point ot next byte
	ret									; done
	
;===============
;=             =
;= routine      =
;=             =
;=================================
;=                               =
;= deals with sample number data =
;=                               =
;=================================

sample_number:
	     
	sub	$60							; subtract $60 to get a 0 to 15 number
	push	hl							; temp save channel data pointer 
	ld	bc,$0063						; sample are 99 bytes long
	ld	hl,(ptr_samples_data)				; base address of samples data
	call	mphlwastpbc			   ; step through samples data
										; until sample number is found 
	inc	hl							; point to first byte of sample
	ld	(iy+$03),l
	ld	(iy+$04),h						; save ptr to sample in channel prog data
	pop	hl							;retrieve channel data pointer
	inc	hl							;point to next byte
	jp	process_channel_data				;loop back and deal with next byte
	
;===============
;=             =
;=  routine     =
;=             =
;=================================
;=                               =
;= turns off channel             =
;=                               =
;=================================              
	
plrest:        
	inc	hl						;point to next byte in channel data
plrest_2:  
	ld	(iy+$07),$ff				; code for off (no sound from channel)
									; that location is the sample/orn step
	ret							;done
	
	
;===========
;=         =
;= routine =  
;=         =
;=====================
;=                   =
;= select ornament 0 =
;=                   =
;=====================

ornament_zero:	      
	xor	a	
	jr	ornament_zero_2 			;jump to ornament select routine, but jump over normalize sub
	
;===========
;=         =
;= routine =  
;=         =
;=====================
;=                   =
;= select ornament   =
;=                   =
;=====================          
ornament_number:		
	sub	$70						; subtract $70 to give a 0 to 15 value
ornament_zero_2:
	push	hl						; save channel data pointer
    
	ld	bc,$0021					; ornaments are 33 bytes long (1 byte, number + 32 bytes, data)
	ld	hl,(ptr_compiled_ornaments)	; ornaments base address
	call	mphlwastpbc		   ; step over ornamenst until a match is found
	inc	hl						; point to first byte of ornament data
	ld	(iy+$05),l					; 
	ld	(iy+$06),h					; save address of ornament in channel prog data
	ld	(iy-$02),00					; and set flag to say ornament in use
	pop	hl						; retrieve channel data pointer
	inc	hl						; point to next byte
	jp	process_channel_data			; loop back and process next byte
	
;===============
;=             =
;= routine      =
;=             =
;=================================
;=                               =
;= select an effect              =
;=                               =
;=================================      
	
effect_number:	    
	sub	$80						; subtract $80
	ld	(ay_data_env_shape),a			; store in the data to send to ay table
	inc	hl						; point to next byte in channel data
	ld	a,(hl)						; next byte is env freq value.
	inc	hl						; point to next byte in the channel data
	ld	(ay_data_env_freq),a			; store in the data to send to ay table
	ld	(iy-$02),$01				; set the flag to ay_env_shape in use
	push	hl						; temp save channel data pointer

;when using an effect ornament is set to zero
	
	xor	a
	ld	bc,$0021					; 33 bytes in each ornament
	ld	hl,(ptr_compiled_ornaments)	; compiled ornaments base address
	call	mphlwastpbc		   ; step over each ornament till
									; a match is found
	inc	hl						;point to first byte of ornament data
	ld	(iy+$05),l
	ld	(iy+$06),h					; store ornament ptr in channel_prog store
	pop	hl						; retrieve channel data pointer
	jp	process_channel_data			; loop back and process next byte
	
	
;==============
;=            =
;= subroutine =
;=            =
;==============
	
do_repeat:		
	ld	a,(iy+$07)					; get current repeat countdown ? 
	inc	a
	ret	z							; return if a was $ff (now $00), channel stay muted till new note
	
	dec	a							; restore a to previous value	
	dec	a							; and decrement counter
	
	;	!!! zero flag used below !!!
	
	ld	(iy+$07),a					; store new count down value 
	push	af						; temp save new count value and flags !!!
	
	ld	a,(iy+$00)					; get sample/orn step
	ld	c,a						; put it in c
	inc	a							; increment it
	and	$1f						; keep only lowest 5 bits
	ld	(iy+$00),a					; store it
	pop	af						; retrieve previous a and flags !!!
	
	ret	nz						; return if double dec a above result was <> 0
    
	ld	e,(iy+$03)					; else 
	ld	d,(iy+$04)					; retrieve the sample ptr for this channel
	ld	hl,$0060
	add	hl,de						; add $0060 to the sample ptr (points to repeat value)
	ld	a,(hl)						; 
	dec	a							; if repeat value is 0 then play only once.
	
	jp	m,plrest_2					; jump if reapeat count rolls from 255 to 0
									; to silence channel, stores $ff in repeat counter and ret's to calling code
	
	ld	c,a						; repeat - 1 into c
	inc	a							; restore previous value
	and	$1f						; keep lowest 5 bits ( 0 to 31 )
	ld	(iy+$00),a					; store start step for repeat
	
	inc	hl						; point to reapeat length
	ld	a,(hl)						; get repeat length
	inc	a							; +1 before storing
	ld	(iy+$07),a					; store it
	
	ret	
	
;==============
;=            =
;= subroutine =
;=            =
;==============
	
set_noise_freq:       
	ld	a,c
	or	a							; is a = 0
	ret	nz						; nope leave noise freq as is
	ld	a,h						; else h holds noise freq to use
	ld	(ay_data_noise_freq),a
	ret  
	
;==============
;=            =
;= subroutine =
;=            =
;==============

clear_ay_env_shape:    
	ld	a,(iy+$07)
	inc	a							; mute channel ?
	ret	z							; yes leave ay enevlope alone
	
	ld	a,(iy-$02)
	or	a							; else test flag byte
	ret	z							; ornament in use
	
	cp	$02						; test for noise in use
	jp	z,ay_env_zero				; if noise in use then set ay_env_shape to zero
	
	ld	(iy-$02),$02				; ?? set noise in use.
	jp	ay_env_skip
ay_env_zero:	    
	xor	a
	ld	(ay_data_env_shape),a
ay_env_skip:	  
	set	4,(hl)						; set the ay_amplitude_mode bit for this channel
									; ie. use sample envelope value for volume
									; instead of ay_envelope
	ret   
	
;==============
;=
;= routine continues from channel processor
;=
;==============

;process channel 1
process_channels:
 
	ld	iy,channel_1_prog_store_base			; proccess channel 1 
	call	do_repeat							; do repeats ect ?
											; returns current step value in c ???
	ld	a,c								;
	
	ld	(ornament_step_number),a				; store it (maybe self modifing code again)
	ld	iy,(channel_1_prog_store_plus_3)		;
	call	process_sample_data					; on exit
											;
											; h = noise value for current step
											; l = env value
											; de = effect value (bit 4 of d is sign, value is 3 nibbles)
											;
											; b = 0 for tone, 2 for no tone
											; c = 0 for noise, 16 for no noise 
	ld	a,c
	or	b									; mix the noise and tone masks
	rrca										; move into correct position
	ld	(ay_data_mixer),a					; and store it
  
	ld	iy,channel_1_prog_store_base			; index register back to channel prog store
	ld	a,(iy+$07)							; test for tune off channel $ff means turn off channel
	inc	a
	jp	z,channel_1_vol_zero					; 
											; 
	call	set_noise_freq						; else do noise freq
	call	get_note_frequency
	ld	(ay_data_tone_chan_a),hl				; store frequency for this channel
channel_1_vol_zero:
	ld	hl,ay_data_amp_a
	ld	(hl),a								; is either sample envelope value or zero
	call	clear_ay_env_shape
	
;process channel 2
	ld	iy,channel_2_prog_store_base
	call	do_repeat
	
	ld	a,(iy+$07)
	inc	a
	jp	z,channel_2_vol_zero
	ld	a,c								; samplw/orn step
	ld	(ornament_step_number),a
	ld	iy,(channel_2_prog_store_plus_3)
	call	process_sample_data
	ld	a,(ay_data_mixer)					; get channel 1 ay_mixer value
	or	c
	or	b									; mix in channel 2 masks
	ld	(ay_data_mixer),a					; store new mixer value
	call	set_noise_freq
	ld	iy,channel_2_prog_store_base
	call	get_note_frequency
	ld	(ay_data_tone_chan_b),hl
channel_2_vol_zero:	
	ld	hl,ay_data_amp_b
	ld	(hl),a
	call	clear_ay_env_shape
	
;process channel 3
	ld	iy,channel_3_prog_store_base
	call	do_repeat
	ld	a,(iy+$07)
	inc	a
	jp	z,channel_3_vol_zero
	ld	a,c
	ld	(ornament_step_number),a
	ld	iy,(channel_3_prog_store_plus_3)
	call	process_sample_data
	ld	a,(ay_data_mixer)
	rlc	c
	rlc	b
	or	b
	or	c									;mix channel 3 masks
	ld	(ay_data_mixer),a
	call	set_noise_freq
	ld	iy,channel_3_prog_store_base
	call	get_note_frequency
	ld	(ay_data_tone_chan_c),hl
channel_3_vol_zero:    
	ld	hl,ay_data_amp_c
	ld	(hl),a
	call	clear_ay_env_shape
	jp	send_data_to_ay 		;processign done set the registers
	

;==============
;=            =
;= subroutine =
;=            =
;==============

get_note_frequency:			
	ld	a,l					
	push	af					; save sample env value
	push	de					; save effect value
	ld	l,(iy+$05)
	ld	h,(iy+$06)				; hl points to ornament data
ornament_step_number = $+1			     ; low byte of ld de,$nnnn only
	ld	de,$0005				; self modifying code, added to base address in hl
	add	hl,de					; hl now points to the correct step in ornament
	ld	a,(iy+$01)				; get the current note 
	add	a,(hl)					; add the ornament value (single byte signed, so can subtract too)
	
pl_current_height = $+1
	add	a,$00					; add the pattern height
	
	add	a,a					; double a (tone table is words)
	ld	e,a
	ld	d,$00					; de is offset into tone table
								; no bounds checking ???
	ld	hl,tone_table			; base address of tone table
	add	hl,de					; hl now points to word for tone data
	ld	e,(hl)
	inc	hl
	ld	d,(hl)					; pick up tone data
	ex	de,hl					; hl holds tone data
	pop	de					; retrieve additional effect (from sample data)
	pop	af					; retrieve env value
	bit	4,d					; test sign bit in effect val (it's not really a signed value)
								; buit has a bit to say wether we add or sub the value
						
	; this looks back to front, but...
	; a hihger value for tone results in a lower frequency
	; in sound output
	;
	; so an additional effect (higher in frequency output)
	; must be subtracted from tone data.
	;
	; and the oposite is true for lower frequency
								  
	jr	z,sub_effect
	res	4,d					; clear bit before adding effect value
	add	hl,de					; else add effect (lower frequency)		|
	ret			
					
sub_effect:
	and	a						; clear carry in prep for subraction
								; does not affect sample env value
	sbc	hl,de					; subtract effect (higher frequency)
	ret
	
	
;==============
;=
;= tone table 
;=
;============
 
tone_table:
	.word	$0ef8, $0e10, $0d60, $0c80, $0bd8, $0b28, $0a88, $09f0, $0960, $08e0, $0858, $07e0
	.word	$077c, $0708, $06b0, $0640, $05ec, $0594, $0544, $04f8, $04b0, $0470, $042c, $03f0
	.word	$03be, $0384, $0358, $0320, $02f6, $02ca, $02a2, $027c, $0258, $0238, $0216, $01f8
	.word	$01df, $01c2, $01ac, $0190, $017b, $0165, $0151, $013e, $012c, $011c, $010b, $00fc
	.word	$00ef, $00e1, $00d6, $00c8, $00bd, $00b2, $00a8, $009f, $0096, $008e, $0085, $007e
	.word	$0077, $0070, $006b, $0064, $005e, $0059, $0054, $004f, $004b, $0047, $0042, $003f
	.word	$003b, $0038, $0035, $0032, $002f, $002c, $002a, $0027, $0025, $0023,	$0021, $001f
	.word	$001d, $001c, $001a, $0019, $0017, $0016, $0015, $0013, $0012, $0011, $0010, $000f     
 

;==============         
;=            =         
;= subroutine =
;=            =
;====================
;=                  =
;= set ay registers =
;=                  =
;====================   

send_data_to_ay:
	   
	ld	hl,end_data_to_send_to_ay			;points to end of data to send, env shape working backwards
mute_ay:
	xor	a								;zero a
	or	(hl)							;test env shape
	ld	a,0dh							;load a with 13, will loop 14 times
										;loop ends when a rolls round from 0 to 255 
      
	jr	nz,send_ay_data 				;if env shape = 0 then only send new channel data
										;else continue (take the jr) with new effect data also
      
	sub	$03							;else send only 11 bytes, start at amplitude for channel c
	dec	hl			 
	dec	hl							; 
	dec	hl							; skip 3 bytes in data
	
send_ay_data:
l842d: ;0efd	  
;               ld      c,$fd                                                   ;low byte port address (spectrum)
										;register select
	
	ld	   b,$ff							;high byte port address (zx81)
										;register select
ay_write_loop:
l842f: ;06ff	  
;               ld      b,$ff                                                   ;high byte port address (spectrum)
										;register select
					
	ld	   c,$df							;low byte port address (zx81)
										;register select
										;needed to swap order as its inside a loop
     
	out	(c),a							;select the register to write to
      
;               ld      b,$bf                                                   ;high byte port address (spectrum)
										;data port
	
	ld	   c,$1f							;low byte port adreess (zx81)
	outd									;output contents of (hl) to port (bc)
										;and decrement hl
	dec	a								;decrement register selector / counter
	jp	p,ay_write_loop 				;if not minus (has not rolled round to $ff, then go round again      
	ret									;done for now

	

