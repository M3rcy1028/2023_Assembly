	AREA code_area, CODE, READONLY
		ENTRY

float_number_series EQU 0x0450			;store all random numbers
sorted_number_series EQU 0x00018AEC		;sorting array
final_result_series EQU 0x00031190		;final result array

;========== Do not change this area ===========

initialization
	LDR r0, =0xDEADBEEF				; seed for random number
	LDR r1, =float_number_series	
	LDR r2, =10000  				; The number of element in stored sereis
	LDR r3, =0x0EACBA90				; constant for random number

save_float_series
	CMP r2, #0
	BEQ is_init
	BL random_float_number
	STR r0, [r1], #4
	SUB r2, r2, #1
	MOV r5, #0
	B save_float_series

random_float_number
	MOV r5, LR
	EOR r0, r0, r3
	EOR r3, r0, r3, ROR #2
	CMP r0, r1
	BLGE shift_left
	BLLT shift_right
	BX r5

shift_left
	LSL r0, r0, #1
	BX LR

shift_right
	LSR r0, r0, #1
	BX LR
	
;============================================

;========== Start your code here ===========
is_init
	LDR r4, =float_number_series	;load array address
	LDR r12, =sorted_number_series

;copy array
storeArray
	;r1 end of float_number_series
	;r2 element
	;r4 start of float_number_series
	;r12 start of sorted_number_series
	CMP r1, r4
	LDRNE r2, [r4] ,#4
	STRNE r2, [r12], #4
	BNE storeArray
	MOVEQ r1, r12
	LDREQ r4, =sorted_number_series	;r4 current element address
	;ADDEQ r4, r4, #4
	LDREQ r1, =sorted_number_series
	SUBEQ r1, r1, #4
	BEQ loopi
	
loopi
	;r1 is front address of stored_number_series
	;r4 current element address
	;r8 copy of current element address
	;r12 end of stored_number_series
	;j = r8, i = r4
	CMP r4, r12			;if the r12 is the end of array
	ADDNE r4, r4, #4	;i++
	MOVNE r8, r4		;j = i
	BNE loopj
	;sorting end
	ADDEQ r1, r1, #4
	LDREQ r4, =final_result_series
	BEQ storeResult		
	
loopj
	;if r8 is out of array
	LDR r5, [r8]		;r5
	SUB r8, r8, #4		;j--
	CMP r8, r1
	BEQ loopi
	BNE exec			;sorting exec
	
;sorting area	
exec	
	;r2 MSB of r5
	;r3 MSB of r6
	;r5 target element
	;r6 compared element
	;r7 temporary element
	LDR r6, [r8]			;r6
	MOV r2, r5, LSR #31		;get sign bit
	MOV r3, r6, LSR #31
	CMP r2, r3				;compare sign bit
	BEQ sortSameMSB
	BNE sortDiffMSB

sortSameMSB	;positive sign bit
	CMP r2, #0 		
	BEQ sortPos				;positive
	BNE sortNeg				;negative

sortPos
	CMP r6, r5
	MOVGT r7, r5			;if r6 is greater than r5
	ADDGT r8, r8, #4		;r5 address
	STRGT r6, [r8], #-4		;r5 -> r6
	STRGT r7, [r8]			;r6 -> r5
	BGT loopj
	B loopi					;r6 is not greater than r5 -> end sorting
	
sortNeg	;negative sign bit
	;r2, r5 without MSB
	;r3, r6 without MSB
	;MOV r2, r5, LSL #1
	;MOV r3, r6, LSL #1
	CMP r5, r6				;compare exponent
	;r5 (r2) is greater than r6 (r3)
	MOVGT r7, r5			;store r5
	ADDGT r8, r8, #4		;r4, r5 position
	STRGT r6, [r8], #-4		;store r6 and move to r6 position
	STRGT r7, [r8]			;store r5 (r7)
	BGT	loopj				;r5 >= r6, move to start branch
	B loopi					;no need to sorting
	
sortDiffMSB	;different sign bit
	CMP r2, #0				;r5 is positive
	BEQ loopi				;no need to swap
	MOVNE r7, r5			;swap value
	ADDNE r8, r8, #4
	STRNE r6, [r8], #-4
	STRNE r7, [r8]
	BNE loopj

;========== End your code here ===========

;copy array
storeResult
	;r1 the start of sorted_number_series
	;r12 the end of ..
	;r2 element
	;r4 the start of final_result_series
	CMP r1, r12
	LDRNE r2, [r1] ,#4
	STRNE r2, [r4], #4
	BNE storeResult
	BEQ exit
	
exit
	MOV pc, #0;
	END