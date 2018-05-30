ORG 0H
	SJMP 30H
	
ORG 0BH				;timer 0 overflow interrupt vector
	MOV TH0,#0x3C		;reset timer
	MOV TL0,#0xB0
	LJMP BLINKENLIGHTS
	
ORG 30H
	MOV TMOD,#1
	MOV IE,#130
	SETB TR0
	MOV TH0,#0x3C
	MOV TL0,#0xB0
	MOV R7,#5
LOOP:	
	ACALL SLEDS
	ACALL MOTORFWD
	ACALL LOOP	
SLEDS:				;get sensors status and show on leds
	MOV A, P2
	RL A
	RL A
	CPL A
	MOV P3, A
	RET
	
MOTORFWD:			;set motors to go forward
	SETB P1.1
	CLR P1.2
	SETB P1.3
	CLR P1.4
	RET

BLINKENLIGHTS:
	DEC R7			    ;count down to 0
	CJNE R7,#0,ABANDONINTERRUPT ;if R7 doesn't equal 0, jump to ABANDONINTERRUPT
	CPL P1.0		;toggle LED
	MOV R7,#5		;reset counter
ABANDONINTERRUPT:
	RETI
END
