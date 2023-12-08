	AREA code_area, CODE, READONLY
		ENTRY

float_number_series EQU 0x0450
sorted_number_series EQU 0x00018AEC
final_result_series EQU 0x00031190

;========== Do not change this area ===========

initialization
	LDR r0, =0xDEADBEEF				; seed for random number
	LDR r1, =float_number_series	
	LDR r2, =10000  				; The number of element in stored sereis
	LDR r3, =0x0EACBA90				; constant for random number

save_float_series
	CMP r2, #0
	BEQ ms_init
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
;load array address
ms_init
	LDR r4, =float_number_series
	LDR r11, =sorted_number_series

;copy array
storeArray
	;r1 end of float_number_series
	;r2 element
	;r4 start of float_number_series
	;r11 start of sorted_number_series
	CMP r1, r4
	LDRNE r2, [r4], #4             
    STRNE r2, [r11], #4        
    BNE storeArray		
	MOVEQ r0, #2	
	MOVEQ r10, r11	
	BEQ init

init
	;r0 the size of comparing memory
	;r1 the address of left array
	;r2 the address of right array
	;r10 the end of sorted number series
	;r11 write address
	;r12 read address
	LDR r9, =sorted_number_series
	ADD r9, r9, r0
	CMP r9, r10			;if r0 is greater than the size of sorted_number_series
	BGE resultArea		;end sorting
	LSL r0, #1			;increase the size of comparing array
	MOV r12, r11		
	CMP r10, r12
	;read sorted array, wirte final array
	LDREQ r11, =final_result_series	
	LDREQ r1, =sorted_number_series
	;read final array, wirte sorted array
	LDRNE r11, =sorted_number_series
	LDRNE r1, =final_result_series	
	;set the start address of right array
	ADD r2, r1, r0
	B merge					

merge
	;r7 the left data in left array
	;r8 the left data in right array
	CMP r2, r12					;if right array is end of array
	BEQ init		
	ADD r2, r1, r0				;set right array's start address
	MOV r7, r0					;set the size of left array
	MOV r8, r0					;set the size of right array
	CMP r2, r12					;if right array is end of array
	MOVGE r2, r12				
	MOVGE r8, #0				;set the size of right array is zero
	BGE RightIsEmpty
	B loop
		
loop
	;r3 the element of left array
	;r4 the element of right array
	;r5 the sign bit of left element
	;r6 the sign bit of right element
	LDR r3, [r1]				;load left element
	LDR r4, [r2]				;load right element
	;get sign bit
	MOV r5, r3, LSR #31
	MOV r6, r4, LSR #31
	CMP r5, r6
	;different sign bit
	STRGT r3, [r11], #4			;r3 is negative
	ADDGT r1, r1, #4			;increase the start point of left array
	SUBGT r7, r7, #4			;decrease the size of left array
	STRLT r4, [r11], #4			;r4 is negative
	ADDLT r2, r2, #4			;increase the start point of right array
	SUBLT r8, r8, #4			;decrease the size of right array
	;sort same MSB
	BLEQ sortSameMSB		
	CMP r2, r12					;if the range of r2 is larger than the end of array
	MOVGE r8, #0
	CMP r1, r12					;if the range of r1 is larger than the end of array
	MOVGE r7, #0
	CMP r7, #0					;if left array is empty
	BEQ LeftIsEmpty
	CMP	r8, #0					;if right array is empty
	BEQ RightIsEmpty
	B loop

;sort same sign bit elements (positive)
sortSameMSB
	CMP r5, #1 		
	BEQ sortNeg 				;sign bit is negative
	CMP r3, r4
	;r3 > r4
	STRLE r3, [r11], #4
	ADDLE r1, r1, #4			;increase the start point of left array
	SUBLE r7, r7, #4			;decrease the size of left array
	;r3 <= r4
	STRGT r4, [r11], #4			;r4 is negative
	ADDGT r2, r2, #4			;increase the start point of right array
	SUBGT r8, r8, #4			;decrease the size of right array
	BX lr
	
;sort same sign bit elements (negative)
sortNeg	
	CMP r3, r4
	;r3 < r4
	STRLE r4, [r11], #4			
	ADDLE r2, r2, #4			;increase the start point of right array
	SUBLE r8, r8, #4			;decrease the size of right array
	;r3 >= r4
	STRGT r3, [r11], #4
	ADDGT r1, r1, #4			;increase the start point of left array
	SUBGT r7, r7, #4			;decrease the size of left array
	BX lr
	
;if left array is empty
LeftIsEmpty
   CMP r2, r12					;if r2 is the end of array
   BEQ init
   CMP r8, #0   				;if right array is empty
   MOVEQ r1, r2
   BEQ merge
   STRNE r4, [r11], #4			;store elements in right array
   SUBNE r8, r8, #4
   ADDNE r2, r2, #4
   LDRNE r4, [r2]
   BNE LeftIsEmpty				;right array is not empty
   
;if right array is empty
RightIsEmpty
	CMP r1, r12					;if r2 is the end of array
	BEQ init
	CMP r7, #0   				;if left array is empty
	MOVEQ r1, r2
	BEQ merge
	STRNE r3, [r11], #4			;store elements in left array
	SUBNE r7, r7, #4
	ADDNE r1, r1, #4
	LDRNE r3, [r1]
	BNE RightIsEmpty			;left array is not empty


;========== End your code here ===========
;merge sort is done
resultArea
	CMP r12, r10 	
	BNE exit			;result is stored in final_result_series
	LDR r1, =sorted_number_series 
	LDR r2, =final_result_series  
	B storeResult

;result is stored in sorted_number_series
storeResult
	;r1, the start address of sorted_number_series
	;r2, the start address of final_result_series
	;r3, element
	;r10, the end address of sorted_number_series
	CMP r1, r10
	BGT exit
	LDR r3, [r1], #4          
    STR r3, [r2], #4                                 
    B storeResult

;ternimate program
exit
	MOV pc, #0
	END