	AREA HW6, CODE
	ENTRY
MAIN
	MOV	R1, #0			; Clear register to be used as counter
	MOV 	R2, #0			; Clear register to be used as temp result
	;LDR	R2, =Twos
	BL	READ_CHARS
READ_CHARS
	CMP 	R1, #8
	BEQ	DONE_READ_CHARS
	ADD	R1, R1, #1
	SWI	4			; [R0] <--- Key from keyboard (ASCII)

	CMP	R0, #0			; Verify digit is valid (lower Bound)
	BLO	INVALID_DIGIT	
	CMP	R0, #0xF		; Verify digit is valid (Upper Bound)
	BHI 	INVALID_DIGIT		

	MOV	R3, R2, LSL#4		; *16
	ADD	R2, R3, R0		; Add current HEX value to total
	
	
	
	AREA data1, DATA
TwosComp 
	DCD	0		
DecStr	% 12 