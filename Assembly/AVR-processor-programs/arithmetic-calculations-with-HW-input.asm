.include "m16def.inc"

.def lo		= R4
.def hi		= R5
.def temp 	= R16
.def digit_1_1 = R17
.def digit_1_2 = R18
.def digit_1_3 = R19
.def digit_1_4 = R20
.def digit_2_1 = R21
.def digit_2_2 = R22
.def digit_2_3 = R23
.def digit_2_4 = R24


SPI:

	ldi temp, LOW(RAMEND)
	out SPL, temp
	ldi temp, HIGH(RAMEND)
	out SPH, temp

INIT:

	clr lo
	com hi

	out DDRB, hi
	out PORTB, hi
	out DDRD, lo	;Make PORTD an input port

	ldi XL, $0
	ldi XH, $1

STORE:

	ldi temp, 0b00000111	;7
	st X+, temp
	ldi temp, 0b00000110	;6
	st X+, temp
	ldi temp, 0b00000000	;0
	st X+, temp
	ldi temp, 0b00000001	;1
	st X+, temp

	ldi temp, 0b00000111	;7
	st X+, temp
	ldi temp, 0b00000100	;4
	st X+, temp
	ldi temp, 0b00000010	;2
	st X+, temp
	ldi temp, 0b00000010	;2
	st X, temp

	rcall RESET_X

	ld digit_1_1, X+
	ld digit_1_2, X+
	ld digit_1_3, X+
	ld digit_1_4, X+

	ld digit_2_1, X+
	ld digit_2_2, X+
	ld digit_2_3, X+
	ld digit_2_4, X

	ldi temp, 10

DIGIT_4:

	clc
	mov R0, digit_1_4
	adc R0, digit_2_4
	cp R0, temp
	clc					; cpi affects carry
	brmi DIGIT_3
	sub R0, temp
	sec

DIGIT_3:

	mov R1, digit_1_3
	adc R1, digit_2_3
	cp R1, temp
	clc
	brmi DIGIT_2
	sub R1, temp
	sec


DIGIT_2:

	mov R2, digit_1_2
	adc R2, digit_2_2
	cp R2, temp
	clc
	brmi DIGIT_1
	sub R2, temp
	sec

DIGIT_1:

	mov R3, digit_1_1
	adc R3, digit_2_1


WAIT_PUSH_1:

	sbis PIND, 1
	rjmp WAIT_RELEASE_1

	rjmp WAIT_PUSH_1

WAIT_RELEASE_1:	

	sbis PIND, 1
	rjmp WAIT_RELEASE_1

	swap digit_1_1
	swap digit_1_2
	swap digit_1_3
	swap digit_1_4

	com digit_1_1
	com digit_1_2
	com digit_1_3
	com digit_1_4

	out PORTB, digit_1_1
	rcall DELAY

	out PORTB, digit_1_2
	rcall DELAY

	out PORTB, digit_1_3
	rcall DELAY

	out PORTB, digit_1_4
	rcall DELAY

	out PORTB, hi		;turn off leds

WAIT_PUSH_2:

	sbis PIND, 2
	rjmp WAIT_RELEASE_2

	rjmp WAIT_PUSH_2

WAIT_RELEASE_2:	

	sbis PIND, 2
	rjmp WAIT_RELEASE_2

	swap digit_2_1
	swap digit_2_2
	swap digit_2_3
	swap digit_2_4

	com digit_2_1
	com digit_2_2
	com digit_2_3
	com digit_2_4

	out PORTB, digit_2_1
	rcall DELAY

	out PORTB, digit_2_2
	rcall DELAY

	out PORTB, digit_2_3
	rcall DELAY

	out PORTB, digit_2_4
	rcall DELAY

	out PORTB, hi		;turn off leds

	ldi temp, 4

WAIT_PUSH_4:

	sbis pind, 3
	rjmp WAIT_RELEASE_4

	rjmp WAIT_PUSH_4

WAIT_RELEASE_4:

	sbis PIND, 3
	rjmp WAIT_RELEASE_4
	
	dec temp
	breq CONTINUE
	rjmp WAIT_PUSH_4
	
CONTINUE:

	swap R0
	swap R1
	swap R2
	swap R3
	
	com R0
	com R1
	com R2
	com R3
	
	out PORTB, R0
	rcall DELAY	

	out PORTB, R1
	rcall DELAY	

	out PORTB, R2
	rcall DELAY	

	out PORTB, R3
	rcall DELAY	

	ret	
						
RESET_X:

	ldi XL, $0
	ldi XH, $1
	ret

DELAY:

	push R23
	push R24
	push R25

	;---17000 in decimal---
	ldi R24, 0b01101000	;low
	ldi R25, 0b01000010	;high

OUTER_LOOP:

	ldi R23, 250

INNER_LOOP:
	
	nop
	dec R23
	brne INNER_LOOP

FALSE:

	sbiw R24, 1
	brne OUTER_LOOP

	pop R25
	pop R24
	pop R23

	ret
