;-----variables
PWM1 DATA 0x20
PWM2 DATA 0x21


ORG 0H
	SJMP 30H ;jump to init


ORG 0BH;;timer0 interrupt vector
	LJMP MOTOPWM1OFF
	
ORG 23H;;serial interrupt vector
	JB RI, URX
	JB TI, UTX
	RETI
	
ORG 2BH;;timer2 interrupt vector
	LJMP MOTOPWM2OFF

;---------init everything
ORG 30H
	;setup UART
	MOV PCON, #0x80 ;;set SMOD, double data rate
	MOV SCON, #0x50 ;;set SCON, SMODE 1, REN, RI, TI
	MOV TMOD, #0x22 ;;8-bit auto reload from TH1
	MOV TH1, #0xF2 	;;4800 baud with DDR
	;;start all timers
	SETB TR1
	SETB TR0
	SETB TR2

	;;setup timer 2 values
	MOV RCAP2H, #0xFF
	MOV RCAP2L, #0xFE
	MOV TH2, #0xFF

	MOV IE,#0xB2	;;enable serial interrupt, timer0&2 
	
	LJMP LOOP
	
;-------main loop
LOOP:
	MOV PWM1, #0
	MOV PWM2, #0
		



	SJMP LOOP
	
;;-----------serial port 
;;serial transmit handle
UTX:
	CLR TI
	RETI
;;serial receive handle
URX:
	;; if first byte = 0x30, continue receiving, else dump everything

	MOV 0x2
	
	MOV A,  SBUF
	XRL A, #0x30	     ;XOR SBUF with 0x20, to compare themxs
	JZ A, FIRSTURX 		;first byte is not 0x20, break innterrupt
	


	CLR RI
	RETI
FIRSTURX:
	
	
BREAKURX:
	CLR RI
	RETI
;Sacrificing timers for PWM
;if PWM1 or PWM2 is 0, the duty cycle is 50%
;if they are 255, the duty cycle is ~95%
;------PWM1
MOTOPWM1OFF:	
	CLR TR0				;stop timer0	
	JB P0.0,MOTOPWM1ON	;jump if pin set
	SETB P0.0			;set pin
	CLR C				;clear carry bit, so it doesn't interfere
	MOV A, #0xFF		;move 255 to A
	SUBB A, PWM1		;subtract PWM1 from A
	MOV TH0,A			;move result from A to TH0
	SETB TR0			;start timer
	RETI				;return from interrupt
MOTOPWM1ON:
	CLR P0.0			;clear pin
	MOV TH0,#0x00		;move 0 to TH0
	SETB TR0			;start timer
	RETI				;return from interrupt

;------PWM2
MOTOPWM2OFF:	
	CLR TR2		
	JB P0.1,MOTOPWM2ON
	SETB P0.1
	MOV A, #0xFF
	SUBB A, PWM2
	MOV RCAP2L,A
	CLR TF2 ;;clear timer 2 interrupt
	SETB TR2
	RETI
MOTOPWM2ON:
	CLR P0.1
	MOV RCAP2L,#0x00
	CLR TF2 ;;clear timer 2 interrupt
	SETB TR2
	RETI	

END
