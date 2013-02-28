* This program will take two hard coded strings and merge them together
*   letter by letter until one string is finished. If one string finishes
*   before the other, the unfinished string will just be added to the end
*   of the mixed string.
* @Author Jesse Nelson
* @Version 02/26/13 Windows 8 (x64)

NULL	EQU	0

	AREA 	HW5B, CODE
	ENTRY

MAIN	
	LDR	R0, =StrOne				; Address of string one 
	LDR	R1, =StrTwo				; Address of string two
	LDR	R2, =MixStr				; Address of mixed string

MIX_LOOP 
	LDRB	R3, [R0], #1				; Get byte of StrOne
	CMP	R3, #NULL
	BEQ	Copy_StrTwo				; String one finished 
	
	LDRB	R4, [R1], #1				; Get byte of StrTwo
	CMP 	R4, #NULL				
	BEQ	Copy_StrOne				; String two finished before string one
	
	STRB	R3, [R2], #1
	STRB	R4, [R2], #1

	B	MIX_LOOP

Copy_StrTwo
	LDRB	R4, [R1], #1				; Get byte of StrTwo
	CMP	R4, #NULL
	BEQ	DONE_MIX_LOOP
	STRB	R4, [R2], #1
	B	Copy_StrTwo

Copy_StrOne
	STRB	R3, [R2], #1				; Byte is already known to be valid
	LDRB	R3, [R0], #1
	CMP	R3, #NULL
	BEQ	DONE_MIX_LOOP
	B	Copy_StrOne

DONE_MIX_LOOP
	STRB	R3, [R2], #1				; Add null character to end of MixStr. Not sure if this is necessary since memory already zeroed
	SWI	0x11
	
	AREA	Data1, DATA

MAX_LEN	EQU	100

StrOne	DCB	"I sleep too heavily!", NULL	 	
StrTwo	DCB	"I need a louder alarm clock!", NULL
	ALIGN

MixStr	% ( MAX_LEN + 1 )
	ALIGN

	END
