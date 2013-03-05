	AREA HW6, CODE
	ENTRY
MAIN
	MOV	R1, #0			; Clear register to be used as counter
	MOV 	R2, #0	     		;Clear register to be used as temp result
	BL	READ_CHARS
	SWI 	0x11

READ_CHARS
	SWI	4			; [R0] <--- Key from keyboard (ASCII)

	CMP	R0, #'0'		; Verify digit is valid 
	BLO	DONE_READ_CHARS	

	CMP	R0, #'9'		; Verify digit is valid 
	BHI 	CHECK_HEX		

	SUB	R0, R0, #'0'		; Obtain Hex equivalent of ASCII char	
	B	STORE_INPUT		
	
CHECK_HEX
	CMP 	R0, #'A'
	BLO	DONE_READ_CHARS	        ; Invalid Hex symbol
	CMP	R0, #'F'
	BHI	DONE_READ_CHARS

	SUB 	R0, R0, #'A'
	ADD	R0, R0, #0xA		; Adding ten to receive Hex equivalent of ASCII
	
STORE_INPUT
	MOV	R3, R2, LSL#4		; *16
	ADD	R2, R3, R0		; Add valid Hex symbol to temp result
	B	READ_CHARS		; Get next key

DONE_READ_CHARS
	STR	R2, TwosComp
	MOV 	PC, LR		  	; Return to BL READ_CHARS ( MAIN )
	
	AREA data1, DATA	
TwosComp 
	DCD	0
	
	
DecStr	% 12

	ALLIGN
	END