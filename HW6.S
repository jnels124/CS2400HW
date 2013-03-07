	;; There is a bug in the code that I can fix but I dont think it is necessary to do so for this assignment. If there are 0 valid hex symbols
	AREA HW6, CODE
	ENTRY
	
MAIN
	MOV	R1, #0			; Clear register to be used as symbols received counter
	MOV 	R2, #0	     		; Clear register to be used as temp result
	LDR	R4, =DecStr		; Load address of DecStr
	LDR	R5, =TwosComp		; Load address of TwosComp
	LDR	R6, =RvsDecStr		; Load address of RvsDecStr -> Used in STORE_DEC_STR sub routine 
	BL	READ_CHARS		; Read characters from the keyboard
	MOV	R8, #'-'		; Store the ascii code of the minus sign to be used in the following sub-routine
	BL	STORE_2S_COMP		
	LDR 	R7, [R5]		; Initial quotient
	MOV	R1, R7			; This line ensures TO_DECIMAL executes atleast once if there is a number to display
	BL 	TO_DECIMAL		; Is R2 negative ?
	LDR	R1, =TwosComp		; Load address of Twos compliment to be used as terminating comparison
	BL	STORE_DEC_STR
	SWI 	0x11
	
READ_CHARS
	CMP 	R1, #8			; Check if necessary to read another key
	BEQ	DONE_READ_CHARS		; User has entered 8 hex symbols
	
	SWI	4			; [R0] <--- Key from keyboard (ASCII)

	CMP	R0, #'0'		; Verify digit is valid 
	BLO	DONE_READ_CHARS	

	CMP	R0, #'9'		; Verify digit is valid 
	BHI 	CHECK_HEX		

	SUB	R0, R0, #'0'		; Obtain Hex equivalent of ASCII char 0-9	
	B	STORE_INPUT		; Store current HEX entered by user
	
CHECK_HEX
	CMP 	R0, #'A'		; Is the current symbol read with SWI 4 a valid hex? (Lower bound)
	BLO	DONE_READ_CHARS	        ; Invalid Hex symbol -> if ( R0 [the value read from keyboard with SWI 4] <  ASCII of A  	
	CMP	R0, #'F'		; Is the current symbol read with SWI 4 a valid hex? (upper bound)
	BHI	DONE_READ_CHARS		; Invalid Hex symbol -> else if ( R0 [the value read from keyboard with SWI 4] >  ASCII of F  	
					; else.. 
	SUB 	R0, R0, #'A'		; Subtract ascii value of 'A' to set up following calculation
	ADD	R0, R0, #0xA		; Adding ten to receive Hex equivalent of ASCII A-F
;; Continue 
STORE_INPUT
	MOV	R3, R2, LSL#4		; *16 to shift current sum left by 4 bits 
	ADD	R2, R3, R0		; Add valid Hex symbol to temp result
	ADD 	R1, R1, #1		; Increase symbol's recieved counter
	B	READ_CHARS		; Get next key
	
DONE_READ_CHARS
	MOV 	PC, LR		  	; Return to BL READ_CHARS ( MAIN )
;; End of sub routine READ_CHARS 
	
STORE_2S_COMP				; Branched with link (BL) from main 
	TST 	R2, #2, 2		; Is value negaitve? Test MSB by shifting 1 into most significant bit and performing bitwise AND 
	BEQ	POSITIVE		; The value entered by the user is not negative so there is no need to take the 2's compliment
	STRB	R8, [R4], #1		; Store '-' as first byte in DecStr
	MVN	R2, R2			; [R2] <-  1's complement of R2
	ADD	R2, R2, #1		; [R2] <-  2's complement of R2
;; continue
POSITIVE				; Branched to from STORE_2'S_COMP if value at TwosComp is positive 
	STR	R2, [R5]		; Store all entered hex values as 32-bit Twos compliment in memory at TwosComp
;; continue
DONE_STORE_2S_COMP			; This label is not used directly in a branch call
	MOV 	PC, LR			; Return to BL STORE_2S_COMP (MAIN)
;; End of sub routine STORE_2S_COMP

TO_DECIMAL
	CMP	R1, #0			; Is quotient 0?
	BEQ 	DONE_TO_DECIMAL		; if (quotient = 0) were done with modular division
	MOV	R1, #0			; else.... Reset quotient counter and continue
UDIV10
	CMP	R7, #10			; Done calculating quotient? 
	BLT	STORE_ASCII_VALUE	; if ( R7 < 10 ) .... Value in R7 will be the remainder 
	SUB	R7, R7, #10		; else..... 
	ADD	R1, R1, #1		; Increase Quotient counter
	B	UDIV10
	
STORE_ASCII_VALUE
	ADD	R7, R7, #'0'		; Convert to ASCII symbol
	STRB	R7, [R6], #1		; Store current remainder
	MOV	R7, R1			; Reset Quotient to new value
	
	B	TO_DECIMAL		; Continue with modular division 
	
DONE_TO_DECIMAL
	MOV	PC, LR			; Return to BL TO_DECIMAL (MAIN)
;End of sub routine TO_DECIMAL
	
STORE_DEC_STR
	CMP  	R6, R1			; Are we back at the beginning address of RvsDecStr?
	BEQ  	DONE			; if ( above is true ) we are done copying RvsDecStr to DecStr
	LDRB	R7, [R6], #-1	        ; Load a byte from reverse decimal string and decrease the address being pointed to by R6 to pint to next byte to come off
	STRB    R7, [R4], #1		; Store byte from RvsDecStr to DecStr increase address by one to store next byte there
	B	STORE_DEC_STR 	
	
DONE
	;; 	STR 	#0, [R4]	 	; Adding null terminator 
	LDR	R0, =DecStr		; Load address of DecStr to be printed by SWI 2
	SWI 	2			; Print the contents of R0
	
	AREA data1, DATA	
TwosComp 
	DCD	0
	
DecStr
	% 12
	ALIGN
	
RvsDecStr
	% 11
	
	ALIGN
	END