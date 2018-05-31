ORG 0H
	SJMP 30H
	
ORG 0BH				;timer0 overflow interrupt vector
	MOV TH0,#0x3C		;reset timer
	MOV TL0,#0xB0 
	LJMP BLINKENLIGHTS

ORG 1BH 			;timer1 overflow interrupt vector
	LJMP MOTOPWM
	
ORG 30H
	MOV TMOD,#33		;enable timer0 and timer1 in 16-bit mode
	MOV IE,#138		;enable timer0 and timer 1 overflow interrupt
	SETB TR0		;turn on timer0
	MOV TH0,#0x3C		;set timer0 to overflow every 50ms
	MOV TL0,#0xB0
	MOV R7,#5		;count number of overflows, 250ms

	MOV TH1, #0x00
	SETB 0x7F
	SETB TR1
	
	SJMP LOOP
	
LOOP:	
	ACALL SLEDS

	JB P2.2, MOTOFWD
	JB P2.3, MOTOL
	JB P2.1, MOTOR
	
	ACALL MOTOSTOP
	SJMP LOOP	
SLEDS:				;get sensors status and show on leds
 	MOV A, P2
	RL A
	RL A
	CPL A
	MOV P3, A
	RET
	
MOTOFWD:			;set motors to go forward
	SETB P1.1
	CLR P1.2
	SETB P1.3
	CLR P1.4
	SJMP LOOP
MOTOBWD:			;motor backwards
	CLR P1.1
	SETB P1.2
	CLR P1.3
	SETB P1.4
	RET
MOTOR:				;motor right
	SETB P1.1
	CLR P1.2
	CLR P1.3
	CLR P1.4
	SJMP LOOP
MOTOL:				;motor left
	CLR P1.1
	CLR P1.2
	SETB P1.3
	CLR P1.4
	SJMP LOOP
MOTOSR:				;motor sharp right
	SETB P1.1
	CLR P1.2
	CLR P1.3
	SETB P1.4
	SJMP LOOP
MOTOSL:				;motor sharp left

	CLR P1.1
	SETB P1.2
	SETB P1.3
	CLR P1.4
	SJMP LOOP
MOTOSTOP:
	CLR P1.1
	CLR P1.2
	CLR P1.3
	CLR P1.4
	SJMP LOOP
	
MOTOPWM:			;needed to setup PWM because one motor is faster
	JB 0x7F,MOTOPWMON
	CLR P0.2
	SETB 0x7F
	MOV TH1,#0x00
	RETI
MOTOPWMON:
	SETB P0.2
	CLR 0x7F
	MOV TH1,#0xAF
	RETI


BLINKENLIGHTS:
	DEC R7			    ;count down to 0
	CJNE R7,#0,ABANDONINTERRUPT ;if R7 doesn't equal 0, jump to ABANDONINTERRUPT
	CPL P1.0		;toggle LED
	MOV R7,#5		;reset counter
	RETI
	
ABANDONINTERRUPT:
	RETI
END
