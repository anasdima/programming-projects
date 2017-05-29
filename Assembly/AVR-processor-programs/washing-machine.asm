.include "m16def.inc"

.def PROG_BUTTON_3 = R17
.def PROG_BUTTON_4 = R18
.def PROG_BUTTON_5 = R19
.def PRE_WASH_BUTTON = R20
.def DOOR_BUTTON = R21
.def OVERLOAD_BUTTON = R22
.def COUNT_INNER = R23
.def COUNT_OUTERL = R24
.def COUNT_OUTERH = R25

RESET:

.org $0000
rjmp init

INIT:

	ldi R16, LOW(RAMEND)
	out SPL, R16
	ldi R16, HIGH(RAMEND)
	out SPL, R16

	ldi R16, 0b11111111
	out DDRB, R16			; PORTB output
	ldi R16, 0b10000000		; LED7 ON
	out PORTB, R16

	ldi R16, 0b00000000
	out DDRD, R16			; PORTD input

	ldi PROG_BUTTON_3, 0
	ldi PROG_BUTTON_4, 0
	ldi PROG_BUTTON_5, 0
	ldi PRE_WASH_BUTTON, 0

PROGRAM:

	sbis PORTD, 0
	rjmp BUTTON_0

	sbis PORTD, 1
	rjmp BUTTON_1_1

	sbis PORTD, 2
	rjmp BUTTON_2

	sbis PORTD, 3
	rjmp BUTTON_3

	sbis PORTD, 4
	rjmp BUTTON_4

	sbis PORTD, 5
	rjmp BUTTON_5

	sbis PORTD, 6
	rjmp BUTTON_6

	rjmp PROGRAM

BUTTON_0:

	sbis PORTD, 0
	rjmp BUTTON_0

	ldi DOOR_BUTTON, 1
	cbi PORTB, 0
	
	rjmp PROGRAM

BUTTON_0_1:			; Door closed

	sbis PORTD, 0
	rjmp BUTTON_0_1

	ldi DOOR_BUTTON, 1
	cbi PORTB, 0

	rjmp DOOR_STACK

BUTTON_0_2:			; Door open

	sbis PORTD, 0
	rjmp BUTTON_0_2

	ldi DOOR_BUTTON, 0
	sbi PORTB, 0

	rjmp DOOR_OPEN

BUTTON_1_1:			; Washer overloaded

	sbis PORTD, 1
	rjmp BUTTON_1_1

	ldi OVERLOAD_BUTTON, 1
	cbi PORTB, 1

	rjmp PROGRAM

BUTTON_1_2:			; Washer not overloaded

	sbis PORTD, 1
	rjmp BUTTON_1_2

	ldi OVERLOAD_BUTTON, 0
	sbi PORTB, 1

	rjmp DOOR_CHECK

BUTTON_2:

	sbis PORTD, 2
	rjmp BUTTON_2

	ldi PRE_WASH_BUTTON, 1
	cbi PORTB, 2 

	rjmp PROGRAM

BUTTON_3:

	sbis PORTD, 3
	rjmp BUTTON_3

	ldi PROG_BUTTON_3, 1
	cbi PORTB, 3 

	rjmp PROGRAM

BUTTON_4:

	sbis PORTD, 4
	rjmp BUTTON_4

	ldi PROG_BUTTON_4, 1
	cbi PORTB, 4 

	rjmp PROGRAM

BUTTON_5:

	sbis PORTD, 5
	rjmp BUTTON_5

	ldi PROG_BUTTON_5, 1
	cbi PORTB, 5 

	rjmp PROGRAM

BUTTON_6:

	sbis PORTD, 6
	rjmp BUTTON_6
	
	rjmp OVERLOAD_CHECK

BUTTON_7_1:				; Apply water supply

	sbis PORTD, 7
	rjmp BUTTON_7_1

	cbi PORTB, 6

	rjmp WATTER_SUPPLY_STACK

BUTTON_7_2:

	sbis PORTD,7 
	rjmp BUTTON_7_2

	sbi PORTB, 6

	rjmp WATER_SUPPLY

OVERLOAD_CHECK:

	sbrc OVERLOAD_BUTTON, 0
	rjmp OVERLOAD

DOOR_CHECK:

	sbrs DOOR_BUTTON, 0
	rcall DOOR_OPEN

	;turn off stage leds
	sbi PORTB, 2
	sbi PORTB, 3
	sbi PORTB, 4
	sbi PORTB, 5

;-----Start working------

PRE_WASH_CHECK:

	sbrc PRE_WASH_BUTTON, 0
	rjmp PRE_WASH

WASH:

;PROGRAM 0 = 8s
;PROGRAM 1 = 12s
;PROGRAM 2 = 24s
;PROGRAM 3 = 32s

	sbrs PROG_BUTTON_3, 0
	rjmp PROGRAMS_0_2

	rjmp PROGRAMS_1_3

PROGRAMS_0_2:

	sbrs PROG_BUTTON_4, 0
	rjmp PROGRAM_0

	rjmp PROGRAM_2

PROGRAMS_1_3:

	sbrs PROG_BUTTON_4, 0
	rjmp PROGRAM_1

	rjmp PROGRAM_3

PROGRAM_0:

	cbi PORTB, 3				; Stage 3 running

	;----3590 in decimal----
	ldi COUNT_OUTERL, 0b00000110
	ldi COUNT_OUTERH, 0b00001110

PROGRAM_0_OUTER:

	ldi COUNT_INNER, 255

PROGRAM_0_INNER:

	sbis PORTD, 0
	rcall BUTTON_0_2

	sbis PORTD, 7
	rcall BUTTON_7_2

	dec COUNT_INNER
	brne PROGRAM_0_INNER

;PROGRAM_0_INNER_END

	sbiw COUNT_OUTERL, 1
	brne PROGRAM_0_OUTER

	rjmp RINSING_OUT

;==========================
;==========================

PROGRAM_1:

	cbi PORTB, 3				; Stage 3 running

	;----5380 in decimal----
	ldi COUNT_OUTERL, 0b00000100
	ldi COUNT_OUTERH, 0b00010101

PROGRAM_1_OUTER:

	ldi COUNT_INNER, 255

PROGRAM_1_INNER:

	sbis PORTD, 0
	rcall BUTTON_0_2

	sbis PORTD, 7
	rcall BUTTON_7_2

	dec COUNT_INNER
	brne PROGRAM_1_INNER

;PROGRAM_1_INNER_END

	sbiw COUNT_OUTERL, 1
	brne PROGRAM_1_OUTER

	rjmp RINSING_OUT

;==========================
;==========================

PROGRAM_2:

	cbi PORTB, 3				; Stage 3 running

	;----10760 in decimal----
	ldi COUNT_OUTERL, 0b00001000
	ldi COUNT_OUTERH, 0b00101010

PROGRAM_2_OUTER:

	ldi COUNT_INNER, 255

PROGRAM_2_INNER:

	sbis PORTD, 0
	rcall BUTTON_0_2

	sbis PORTD, 7
	rcall BUTTON_7_2

	dec COUNT_INNER
	brne PROGRAM_2_INNER

;PROGRAM_2_INNER_END

	sbiw COUNT_OUTERL, 1
	brne PROGRAM_2_OUTER

	rjmp RINSING_OUT

;==========================
;==========================

PROGRAM_3:

	cbi PORTB, 3				; Stage 3 running

	;----13450 in decimal----
	ldi COUNT_OUTERL, 0b10001010
	ldi COUNT_OUTERH, 0b00110100

PROGRAM_3_OUTER:

	ldi COUNT_INNER, 255

PROGRAM_3_INNER:

	sbis PORTD, 0
	rcall BUTTON_0_2

	sbis PORTD, 7
	rcall BUTTON_7_2

	dec COUNT_INNER
	brne PROGRAM_3_INNER

;PROGRAM_3_INNER_END

	sbiw COUNT_OUTERL, 1
	brne PROGRAM_3_OUTER

	rjmp RINSING_OUT

;==========================
;==========================

RINSING_OUT:

	cbi PORTB, 4				; Stage 4 running

	;----450 in binary----
	ldi COUNT_OUTERL, 0b11000010
	ldi COUNT_OUTERH, 0b00000001

RINSING_OUT_OUTER:

	ldi COUNT_INNER, 255

RINSING_OUT_INNER:

	sbis PORTD, 0
	rcall BUTTON_0_2

	sbis PORTD, 7
	rcall BUTTON_7_2

	dec COUNT_INNER
	brne RINSING_OUT_INNER

;RINSING_OUT_INNER_END

	sbiw COUNT_OUTERL, 1
	brne RINSING_OUT_OUTER

DRYING_CHECK:

	sbrs PROG_BUTTON_5, 0
	rjmp DRY

	rjmp RESET

DRY:

	cbi PORTB, 5				; Stage 5 running

	;----900 in binary----
	ldi COUNT_OUTERL, 0b10000100
	ldi COUNT_OUTERH, 0b00000011

DRY_OUTER:

	ldi COUNT_INNER, 255

DRY_INNER:

	sbis PORTD, 0
	rcall BUTTON_0_2

	sbis PORTD, 7
	rcall BUTTON_7_2

	dec COUNT_INNER
	brne DRY_INNER

;DRY_INNER_END

	sbiw COUNT_OUTERL, 1
	brne DRY_OUTER

	rjmp RESET

OVERLOAD:

;-------LED OFF 0,5s--------

	sbi PORTB, 1
	;----315 in decimal----
	ldi COUNT_OUTERL, 0b00111011
	ldi COUNT_OUTERH, 0b00000001

OVERLOAD_OUTER_1:

	ldi COUNT_INNER, 255

OVERLOAD_INNER_1:

	sbis PORTD, 1
	rjmp BUTTON_1_2
	
	dec COUNT_INNER
	brne OVERLOAD_INNER_1

;OVERLOAD_INNER_1_END

	dec COUNT_OUTERL
	brne OVERLOAD_OUTER_1
;--------------------------

;-------LED ON 0,5s--------

	cbi PORTB, 1
	;----315 in decimal----
	ldi COUNT_OUTERL, 0b00111011
	ldi COUNT_OUTERH, 0b00000001

OVERLOAD_OUTER_2:
	
	ldi COUNT_INNER, 255

OVERLOAD_INNER_2:

	sbis PORTD, 1
	rjmp BUTTON_1_2	
	
	dec COUNT_INNER
	brne OVERLOAD_INNER_2

;OVERLOAD_INNER_2_END

	sbiw COUNT_OUTERL, 1
	brne OVERLOAD_OUTER_2

;--------------------------

	rjmp OVERLOAD	; Loop until user "removes clothes"

;==========================
;==========================

DOOR_OPEN:

	push COUNT_INNER
	push COUNT_OUTERL
	push COUNT_OUTERH

;-------LED OFF 0,5s--------

	sbi PORTB, 0
	;----315 in decimal----
	ldi COUNT_OUTERL, 0b00111011
	ldi COUNT_OUTERH, 0b00000001

DOOR_OUTER_1:

	ldi COUNT_INNER, 255

DOOR_INNER_1:

	sbis PORTD, 0
	rjmp BUTTON_0_1
	
	dec COUNT_INNER
	brne DOOR_INNER_1

;DOOR_INNER_1_END

	dec COUNT_OUTERL
	brne DOOR_OUTER_1
;--------------------------

;-------LED ON 0,5s--------

	cbi PORTB, 0
	;----315 in decimal----
	ldi COUNT_OUTERL, 0b00111011
	ldi COUNT_OUTERH, 0b00000001

DOOR_OUTER_2:
	
	ldi COUNT_INNER, 255

DOOR_INNER_2:

	sbis PORTD, 0
	rjmp BUTTON_0_1
	
	dec COUNT_INNER
	brne DOOR_INNER_2

;DOOR_INNER_2_END

	dec COUNT_OUTERL
	brne DOOR_OUTER_2

;--------------------------

	rjmp DOOR_OPEN	; Loop until user "closes door"

DOOR_STACK:

	pop COUNT_INNER
	pop COUNT_OUTERL
	pop COUNT_OUTERH
	ret

;==========================
;==========================

WATER_SUPPLY:

	push COUNT_INNER
	push COUNT_OUTERL
	push COUNT_OUTERH

;-------LED OFF 0,5s--------

	sbi PORTB, 6
	;----315 in decimal----
	ldi COUNT_OUTERL, 0b00111011
	ldi COUNT_OUTERH, 0b00000001

WATER_SUPPLY_OUTER_1:

	ldi COUNT_INNER, 255

WATER_SUPPLY_INNER_1:

	sbis PORTD, 7
	rjmp BUTTON_7_1
	
	dec COUNT_INNER
	brne WATER_SUPPLY_INNER_1

;WATER_SUPPLY_INNER_1_END

	dec COUNT_OUTERL
	brne WATER_SUPPLY_OUTER_1
;--------------------------

;-------LED ON 0,5s--------

	cbi PORTB, 6
	;----315 in decimal----
	ldi COUNT_OUTERL, 0b00111011
	ldi COUNT_OUTERH, 0b00000001

WATER_SUPPLY_OUTER_2:
	
	ldi COUNT_INNER, 255

WATER_SUPPLY_INNER_2:

	sbis PORTD, 7
	rjmp BUTTON_7_1
	
	dec COUNT_INNER
	brne WATER_SUPPLY_INNER_2

;WATER_SUPPLY_INNER_2_END

	dec COUNT_OUTERL
	brne WATER_SUPPLY_OUTER_2

;--------------------------

	rjmp WATER_SUPPLY			; Loop until user "reapplies supply"

WATTER_SUPPLY_STACK:

	pop COUNT_INNER
	pop COUNT_OUTERL
	pop COUNT_OUTERH
	ret

;==========================
;==========================

PRE_WASH:

	cbi PORTB, 2 				; Stage one running

	;---1795 in decimal---
	ldi COUNT_OUTERL, 0b00000011
	ldi COUNT_OUTERH, 0b00000111

PRE_WASH_OUTER:

	ldi COUNT_INNER, 255

PRE_WASH_INNER:
	
	sbis PORTD, 0
	rcall BUTTON_0_2

	sbis PORTD, 7
	rcall BUTTON_7_2

	dec COUNT_INNER
	brne PRE_WASH_INNER

;PRE_WASH_INNER_END

	sbiw COUNT_OUTERL, 1
	brne PRE_WASH_OUTER

	rjmp WASH
	

	





	
	
	


