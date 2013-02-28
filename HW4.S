 	AREA	HW4, CODE
	ENTRY				; mark the first instruction
main	
	LDR		R0, =0x13579BDF
	LDR		R1, =0x12000000	
	MOV		R4, #0
	BL		calculate
	MOV		R2, R3		; R2 will hold the value returned to R3 from calculate
	SWI		0x11		; exit
	LTORG
calculate
	MOV 		R3, R0
WHILE	
	CMP		R4, #3
	BGE		DONE
	ADD		R3, R3, R1
	ADD		R4, R4, #1
	B		WHILE
DONE   	
	MOV 		PC, LR		; Return calculate
					
city	DCB 		"Greenwood Village", 0	; Null terminated String
sales 	DCD 		28, 39, 34, 26, 50 	; create array of words
fifoQ			% 5000			; Allocate a 5000-byte-long piece of memory initialized to 0
	END
