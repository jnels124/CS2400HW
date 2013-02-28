* This program will add two 2's compliment numbers together, a and b.
* 	a will be a negative number and b will be positive. i.e (-a + b)
*
* @Author Jesse Nelson
* @Version 02/26/13 Windows 8 (x64)

	AREA	HW5A, CODE
	ENTRY
MAIN
	LDR	R0, =A_MSD
	LDR	R1, =A_LSD
	BL	HEX2BIN
	TST	R2, #2, 2
	BNE	DONE
	MVN	R5, R2		; A's 1s compliment
	ADD	R5, R5, #1 	; A's 2s compliment

	LDR	R0, =B_MSD
	LDR	R1, =B_LSD
	BL	HEX2BIN
	TST	R2, #2, 2
	BNE	DONE
	MOV	R6, R2

	ADDS 	R7, R5, R6
	BVS	INVALIDHEX	; 2's compliment overflow occured after addition
	LDR	R8, =RESULT
	STR	R7, [R8]

DONE	SWI 0x11

HEX2BIN	
	MOV 	R2, #0		; Clear result register

LOOP_HEX_2_BIN
	MOV	R3, #0x0	; Clear tmp value
	LDRB	R3, [R0], #1
	CMP	R3, #0x0	; Check lower bound of range
	BLO	INVALIDHEX	; invalid digit
	CMP	R3, #0xF	; Check upper bound of range
	BHI	INVALIDHEX	; invalid digit

	MOV	R4, R2, LSL #1
	TST	R4, #2, 2
	BNE	INVALIDHEX

	MOV	R4, R4, LSL #1
	TST	R4, #2, 2
	BNE	INVALIDHEX
	
	MOV	R4, R4, LSL #1
	TST	R4, #2, 2
	BNE	INVALIDHEX
	
	MOV	R4, R4, LSL #1
	TST	R4, #2, 2
	BNE	INVALIDHEX

	ADD	R2, R3, R4
	TST 	R2, #2, 2
	BNE	INVALIDHEX

	CMP	R0, R1
	BHI	DONE_HEX2BIN
	B	LOOP_HEX_2_BIN

DONE_HEX2BIN
	MOV	PC, LR

INVALIDHEX	
	MOV	R2, #0x0 	; Out of range

	AREA	data, DATA	
A_MSD	DCB	0xA
	DCB	0x8
A_LSD	DCB	0xF
	ALIGN

B_MSD	DCB	0x4
	DCB	0x7
	DCB	0x6
	DCB	0x0
	DCB	0x5
	DCB	0x3
	DCB	0x1
B_LSD	DCB	0x2
	ALIGN			

RESULT	
	DCD	0		; % 4 instead of DCD?		

	END