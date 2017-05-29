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

	ret
			
RESET_X:

	ldi R21, 5
	ldi R22, 9
	ldi R23, 6

	ldi XL, $0
	ldi XH, $1
	
	ret
