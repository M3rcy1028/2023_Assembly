	AREA ARMex,CODE,READONLY
		ENTRY

main
	LDR r0, STEMEM				;Load memory address
	LDR r10, =NUM1				
	LDR r11, =NUM2				
	MOV r1, #0x3F800000			
	ADD r1, r1, #0x40000000		;r1 = 0x3F800000 + 0x40000000
	
	LDR r2,[r10]				;Load NUM1
	CMP r2,#0x80000000			;compare r2 - 0x80000000
	MOVLS r3, #0				;Positive 
	MOVHI r3, #1				;Negative Number
	
	CMP r2, r1					;NUM1 is postive infinite
	BEQ NUM1pi

								
	CMP r2, #0xFF800000			;NUM1 is negative infinite
	BEQ NUM1ni
	
	MOV r2, r2, ROR#23			;Bit Clear
	BIC r4, r2, #0xFFFFFF00		;extract Exponent
	
	MOV r5, r2, LSR#9			;extract Mantissa value
	MOV r2, r2, ROR#9			;recover original value
	
	LDR r6,[r11]				;Load NUM2
	CMP r6,#0x80000000			;compare r6 - 0x80000000
	MOVLS r7, #0				;Positive 
	MOVHI r7, #1				;Negative Number
	
	CMP r6, r1					;NUM2 is postive infinite	
	BEQ NUM2pi
	
	CMP r6, #0xFF800000			;NUM2 is negative infinite
	BEQ NUM2ni
	
	MOV r6, r6, ROR#23			;Bit Clear
	BIC r8, r6, #0xFFFFFF00		;extract Exponent
	
	MOV r9, r6, LSR#9			;extract Mantissa value
	MOV r6, r6, ROR#9			;recover original values
	
	CMP r3,r7					;compare sign bit r3 - r7
	BEQ EQUAL					;sign bit is equal
	BNE NEQUAL					;sign bit is not equal
	
EQUAL
	ADD r5, r5, #0x00800000		;add 1 for Mantissa type
	ADD r9, r9, #0x00800000		
	
	CMP r4, r8					;Compare Exponent r4 - r8
	SUBGT r10, r4, r8			;r4 is greater than r8
	SUBGT r13, r4, #0x0000007F	;Subtract 127 
	
	SUBLT r10, r8, r4			;small Exponent - large Exponent
	SUBLT r13, r8, #0x0000007F	;Subtract 127 
	
	MOVGT r11, r9, LSR r10		;Shift num
	MOVLT r11, r5, LSR r10		
	
	ADDGT r12, r5, r11
	ADDLT r12, r9, r11			
	
	CMP r12, #0x01000000		;Normalize
	MOVHS r12, r12, LSR #1		;shift right 1
	ADDHS r13, r13, #1			;add 1 to the exponent value
	
	MOV r2, #0					;Initialization
	MOV r3, r3, ROR#1			
	ADD r2, r2, r3				;extract sign bit
	MOV r12, r12, LSL#9
	MOV r12, r12, LSR#9
	ADD r2, r2, r12				;extract Mantissa
	ADD r13, r13, #0x000007F
	MOV r13, r13, ROR#9
	ADD r2, r2, r13				;add 127 to extract exponent	
	B StrToR0					;store

NEQUAL
	CMP r5, r9					;compare r5 - r9
	MOVHI r1, #1				;extract sign bit
	MOVLS r1, #0				
	
	ADD r5, r5, #0x00800000		;add 1 for Mantissa type
	ADD r9, r9, #0x00800000		
	
	CMP r5, r9					;compare r5 - r9
	CMPEQ r4, r8				;compare expoenet
	MOVEQ r2, #0				
	BEQ StrToR0					

	CMP r4, r8					;Compare r4 - r8
	SUBGT r10, r4, r8
	SUBGT r13, r4, #0x0000007F
	SUBLE r10, r8, r4			;small Exponent - large Exponent
	SUBLE r13, r8, #0x0000007F	;subtract 127 
	
	MOVGT r9, r9, LSR r10		;shift right
	MOVLE r5, r5, LSR r10		
		
	CMP r1, #1					;compare r1 - 1
	SUBEQ r12, r5, r9
	SUBNE r12, r9, r5			;small value - large value

LOOP
	CMP r12, #0x00800000		;Normalization
	MOVLS r12, r12, LSL #1		;Shift left 1
	SUBLS r13, r13, #1			;Subtract 1
	CMP r12, #0x00800000		;compare r12 - 0x00800000
	BLO LOOP					;less than 0x00800000
	BHS RESULT					;greater than 0x00800000

RESULT
	MOV r2, #0					;initialize r2
	CMP r1, #1					;check sign bit
	MOVEQ r3, r3, ROR#1
	MOVNE r7, r7, ROR#1
	ADDEQ r2, r2, r3
	ADDNE r2, r2, r7			;extract sign bit
	MOV r12, r12, LSL#9
	MOV r12, r12, LSR#9
	ADD r2, r2, r12				;extract Mantissa
	ADD r13, r13, #0x000007F
	MOV r13, r13, ROR#9
	ADD r2, r2, r13				;add 127 to extract exponent
	B StrToR0
	
NUM1pi	;positive infinite
	LDR r6,[r11]				
	CMP r6, #0xFF800000			
	MOVEQ r2, #0x00000000		
	B StrToR0					
								
	
NUM1ni	;negative infinite
	LDR r6,[r11]				
	CMP r6, r1					
	MOVEQ r2, #0x00000000		
	B StrToR0					
								
	
NUM2pi
	CMP r2, #0xFF800000			
	MOVEQ r2, #0x00000000		
	MOVNE r2, r1				
	B StrToR0					
	
NUM2ni
	CMP r2, r1						
	MOVEQ r2, #0x00000000		
	MOVNE r2, r6				
	
StrToR0
	STR r2, [r0]				;Store r2 value in the memory address value of r0
	B exit
	
NUM1 & 0x42347df4				;45.123
NUM2 & 0xc268a2d1 				;-58.159
STEMEM DCD 0x40000000

exit
	END
		