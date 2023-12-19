    AREA ARMex, CODE, READONLY
        ENTRY

main
	LDR r0, STRMEM	;Load memory to r0
	MOV r1, #1		;1 ~ 10
	MOV r3, #1		;initialization
	B Num			;branch Num

Num
	CMP r1, #10		;compare with 10	
	BGT exit		;branch exit
	BLE Fac			; branch factorial function
		
Fac	;factorial function
	MUL r3, r2, r3	;r3 = r2 * r3
	ADD r2, r2, #1	;r2 + 1
	CMP r2, r1		
	BLE Fac
	BGT StrToMem	;end loop
	
StrToMem ;initialization & store results
	STR r3, [r0], #4;move address after storing vaule
	MOV r3, #1		;initialization
	MOV r2, #1		;1 ~ r1
	ADD r1, r1, #1	;r1 + 1
	B Num			;branch Num
		
	
STRMEM	&	&40000000	;memory

exit
	END				;terminate program
	