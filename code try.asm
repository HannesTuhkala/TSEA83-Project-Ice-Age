CONST var_count1 0 
CONST var_count2 1
CONST var_count3 2
CONST pcr 64
	MOVE $FF var_count1
	MOVE $FF var_count2
	MOVE $FF var_count3
	NOP 
	NOP 
START:
	SUB var_count3 imed 1 var_count3
	NOP 
	BRF LA N
	NOP
	BRA START
LA:
	MOVE $FF var_count3
	SUB var_count2 imed 1 var_count2
	NOP 
	BRF LB N
	NOP
	NOP
	NOP
	BRA START
LB:
	MOVE $FF var_count2
	SUB var_count1 imed 1 var_count1
	NOP 
	BRF RESET N 
	NOP
	NOP
	add pcr imed 1 pcr
	NOP
	BRA START
	NOP 
RESET:
	MOVE $FF var_count3
	add pcr imed 1 pcr
	NOP
	BRA START
