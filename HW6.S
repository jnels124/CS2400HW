* This program reads up to 8 hex values entered by the user from the keyboard 
*   and displays the two's compliment of this hex number in decimal form

* Known Bugs to fix :
*	keyboard input of 80000000 will produce -0. 
*
* 	
 
	AREA HW6, CODE
	ENTRY
	
MAIN
	MOV	R1, #0			; Clear register to be used as symbols received counter
	MOV 	R2, #0	     		; Clear register to be used as temp result
	LDR	R4, =DecStr		; Load address of DecStr
	LDR	R5, =TwosComp		; Load address of TwosComp
	LDR	R6, =RvsDecStr		; Load address of RvsDecStr -> Used in STORE_DEC_STR sub routine
 
	BL	READ_CHARS		; Read characters from the keyboard
	CMP	R1, #0			; Verify user has entered at least one value to process
	BEQ	NO_HEX_ENTERED

	MOV	R8, #'-'		; Store the ascii code of the minus sign to be used in the following sub-routine
	BL	STORE_2S_COMP		

	LDR 	R7, [R5]		; Initial quotient for converting TO_DECIMAL
	MOV	R1, R7			; This line ensures TO_DECIMAL executes initially 
	BL 	TO_DECIMAL		

	LDR	R1, =RvsDecStr		; Load address of RvsDecStr to be used as terminating comparison
	BL	STORE_DEC_STR

NO_HEX_ENTERED				; Lable used for an early exit if no valid digits are entered
	SWI 	0x11
	
READ_CHARS				; Branched with link (BL) from main 
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
					; else....		
	STRB	R8, [R4], #1		; Store '-' as first byte in DecStr
	MVN	R2, R2			; [R2] <-  1's complement of R2
	ADD	R2, R2, #1		; [R2] <-  2's complement of R2
;; continue

POSITIVE				; Branched to from STORE_2'S_COMP if value at TwosComp is positive 
	STR	R2, [R5]		; Store all entered hex values as 32-bit Twos compliment in memory at TwosComp

;; continue to next line
DONE_STORE_2S_COMP			; This label is not used directly in a branch call just used for clarity
	MOV 	PC, LR			; Return to BL STORE_2S_COMP (MAIN)
;; End of sub routine STORE_2S_COMP

TO_DECIMAL				; Branched with link (BL) from main 
	CMP	R1, #0			; Is quotient 0?
	BEQ 	DONE_TO_DECIMAL		; if (quotient == 0) then done with modular division
	MOV	R1, #0			; else.... Reset quotient counter and continue

;; continue to next line
UDIV10
	CMP	R7, #10			; Done calculating quotient? 
	BLT	STORE_ASCII_VALUE	; if ( R7 < 10 ) .... Value in R7 will be the remainder 
	SUB	R7, R7, #10		; else..... 
	ADD	R1, R1, #1		; Increase Quotient counter

	B	UDIV10
	
STORE_ASCII_VALUE			; Branched to from UDIV10
	ADD	R7, R7, #'0'		; Convert to ASCII symbol
	STRB	R7, [R6], #1		; Store current remainder
	MOV	R7, R1			; Reset Quotient to new value
	
	B	TO_DECIMAL		; Continue with modular division 
	
DONE_TO_DECIMAL
	SUB	R6, R6, #1		; Reposition offset as it is off by 1. [R6] <- Address of last digit to be added to RvsDecStr 
	MOV	PC, LR			; Return to BL TO_DECIMAL (MAIN)
;; End of sub routine TO_DECIMAL
	
STORE_DEC_STR
	CMP  	R6, R1			; Are we back at the beginning address of RvsDecStr?
	BLT  	DONE			; if ( above comment is true ) we are done copying RvsDecStr to DecStr
	LDRB	R7, [R6], #-1	        ; else....Load a byte from reverse decimal string and decrease the address being pointed to by R6 to point to next byte to come off
	STRB    R7, [R4], #1		; Store byte from RvsDecStr to DecStr increase address by one to store next byte there
	B	STORE_DEC_STR 	
	
DONE	
	MOV	R1, #0			; Hold value to add it to end of DecStr as null terminator
	STRB	R1, [R4]		; Add null terminator
	
	LDR	R0, =ResultMessage	; Load address of ResultMessage to be printed by SWI 2 
	SWI 	2			; Print the contents of R0 -> Result Message	

	LDR	R0, =DecStr		; Load address of DecStr to be printed by SWI 2
	SWI 	2			; Print the contents of R0 -> Print DecStr
	
	MOV	PC, LR			; Return to main 
;; End of sub routine STORE_DEC_STR
	
	AREA data1, DATA	
TwosComp 
	DCD	0
	ALIGN

DecStr
	% 12
	ALIGN
	
RvsDecStr
	% 11
	ALIGN

ResultMessage
	DCB	"\nThe two's compliment of the entered HEX number in decimal form is:\n", 0
	ALIGN

	END