.include "m16def.inc"

.def temp_1  = R13
.def temp_2  = R14
.def lo		 = R16
.def hi		 = R17
.def counter = R18

.def inner_count  = R20
.def outer_count_L= R24
.def outer_count_H= R25

;-----Initialize stack pointer-----

SPI:
	ldi R16, low(RAMEND)
	out SPL, R16
	ldi R16, high(RAMEND)
	out SPH, R16

;-----Initialize ports, Z and X registers

INIT:

	ldi lo, 0b00000000
	ldi hi, 0b11111111
	out DDRB, hi 		;Make PORTB an ouput port
	out PORTB, hi		;All pins of portb are 1 (leds off)

	ldi ZL, LOW(2*AEM)
	ldi ZH, HIGH(2*AEM)
	ldi XL, $0
	ldi XH, $1

	ldi counter, 8

STORE_DATA:			;Load DATA from PM and store it in SRAM

	tst counter
	breq CHECK -1
	lpm R19, Z+		
	subi R19, 48	;Convert ascii to decimal
	st X+, R19
	dec counter
	rjmp STORE_DATA

	rcall RESET_X
	
CHECK:

	ld R0, X 		;Current digit of first AEM
	adiw XL, 4		;Current digit of second AEM
	ld R1, X+
	cp R1, R0
	brne CONTINUE		
	sbiw XL, 4
	rjmp CHECK 		;Move to the next digit

CONTINUE:
	ldi counter, 4	;This doesn't affect N
	brmi SKIP   	;If AEM1 > AEM2 skip rcall swap_aem, else swap them
	rcall RESET_X
	rcall SWAP_AEM

SKIP:
	rcall RESET_X
	
	;-----At this point $100-$103 definitely holds the greater AEM----

	out DDRD, lo	;Make PORTD an input port

WAIT_PUSH:

	sbis PIND, 0
	rjmp WAIT_RELEASE_0

	sbis PIND, 1
	rjmp WAIT_RELEASE_1

	sbis PIND, 2
	rjmp WAIT_RELEASE_2

	sbis PIND, 3
	rjmp WAIT_RELEASE_3

	sbis PIND, 7
	rjmp WAIT_RELEASE_7

	rjmp WAIT_PUSH

WAIT_RELEASE_0:

	sbis PIND, 0
	rjmp WAIT_RELEASE_0
	ld temp_1, X+		;First digit of greater AEM
	ld temp_2, X		;Second digit of greater AEM
	swap temp_1
	or temp_1,temp_2
	com temp_1
	out PORTB, temp_1
	rcall DELAY
	out PORTB, hi
	rcall RESET_X
	rjmp WAIT_PUSH
				
WAIT_RELEASE_1:	

	sbis PIND, 1
	rjmp WAIT_RELEASE_1
	adiw XL, 2			
	ld temp_1, X+		;Third digit of greater AEM
	ld temp_2, X		;Fourth digit of greater AEM
	swap temp_1
	or temp_1,temp_2
	com temp_1
	out PORTB, temp_1
	rcall DELAY
	out PORTB, hi
	rcall RESET_X
	rjmp WAIT_PUSH

WAIT_RELEASE_2:	

	sbis PIND, 2
	rjmp WAIT_RELEASE_2
	adiw XL, 4			
	ld temp_1, X+		;First digit of lesser AEM
	ld temp_2, X		;Second digit of lesser AEM
	swap temp_1
	or temp_1,temp_2
	com temp_1
	out PORTB, temp_1
	rcall DELAY
	out PORTB, hi
	rcall RESET_X
	rjmp WAIT_PUSH

WAIT_RELEASE_3:	

	sbis PIND, 3
	rjmp WAIT_RELEASE_3
	adiw XL, 6
	ld temp_1, X+		;Third digit of lesser AEM
	ld temp_2, X		;Fourth digit of lesser AEM
	swap temp_1
	or temp_1,temp_2
	com temp_1
	out PORTB, temp_1
	rcall DELAY
	out PORTB, hi
	rcall RESET_X
	rjmp WAIT_PUSH

WAIT_RELEASE_7:
	
	sbis PIND, 7
	rjmp WAIT_RELEASE_7			
	adiw XL, 3			;Fourth digit of greater AEM
	ld R0, X 
	sbrc R0, 0
	sbi PORTB, 1	
	sbrs R0, 0
	cbi PORTB, 1

	adiw XL, 4			;Fourth digit of lesser AEM
	ld R0, X
	sbrc R0, 0
	sbi PORTB, 0	
	sbrs R0, 0
	cbi PORTB, 0

INF_LOOP:

	rjmp INF_LOOP

RESET_X:
	ldi XL, $0
	ldi XH, $1
	ret

SWAP_AEM:

	tst counter
	breq EXIT_SWAP_AEM

	ld temp_1, X
	adiw XL, 4
	ld temp_2, X
	st X, temp_1
	sbiw XL, 4
	st X+, temp_2
	dec counter
	rjmp SWAP_AEM

EXIT_SWAP_AEM:

	ret

DELAY:

	;---outer_count has 25000 in decimal---
	ldi outer_count_L, 0b10101000
	ldi outer_count_H, 0b01100001

OUTER_LOOP:

	ldi inner_count, 250

INNER_LOOP:
	
	nop
	dec inner_count
	brne INNER_LOOP

FALSE:

	sbiw outer_count_L, 1
	brne OUTER_LOOP
	ret

AEM:

	.db 55,54,48,49 	;7 6 0 1
	.db 55,52,50,50		;7 4 2 2
