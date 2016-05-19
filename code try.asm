L6:
	MOVE FF var_count1
L6.3:	
	MOVE FF var_count2
L6.2:
	MOVE FF var_count3
	NOP 
	NOP 
L6.1:
	SUB var_count3 imed 1 var_count3
	NOP 
	BRF L6.1 N
	NOP 
	SUB var_count2 imed 1 var_count2
	NOP 
	BRF L6.2 N
	NOP 
	SUB var_count1 imed 1 var_count1
	NOP 
	BRF L6.3 N 
	NOP 
	add pcr imed 1 pcr
	bra L6
	nop
