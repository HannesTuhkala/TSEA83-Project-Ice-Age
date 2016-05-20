CONST var_count1 0 
CONST var_count2 1
CONST var_count3 2
CONST var_count4 3
CONST pcr 64
	MOVE $FF var_count1
	MOVE $FF var_count2
	MOVE $FF var_count3
	MOVE $FF var_count4
	NOP 
	NOP 
START:
	SUB var_count3 imed 1 var_count3
	NOP
	NOP 
	BRF LA N
	NOP
	NOP
	BRA START
	NOP
	NOP
LA:
	NOP
	NOP
	MOVE $FF var_count3
	NOP
	NOP
	SUB var_count2 imed 1 var_count2
	NOP
	NOP
	NOP 
	BRF LB N
	NOP
	NOP
	NOP
	BRA START
	NOP
	NOP
LB:
	NOP
	NOP
	MOVE $FF var_count2
	NOP
	NOP
	SUB var_count4 imed 1 var_count4
	NOP
	NOP
	NOP 
	BRF LC N
	NOP
	NOP
	NOP
	BRA START
	NOP
	NOP
LC:
	NOP
	NOP
	MOVE $FF var_count4
	NOP
	NOP
	SUB var_count1 imed 1 var_count1
	NOP 
	NOP 
	add pcr imed 1 pcr
	NOP
	NOP
	BRF RESET N 
	NOP
	NOP
	NOP
	BRA START
	NOP
	NOP
	NOP 
RESET:
	NOP
	MOVE $FF var_count1
	NOP
	NOP
	add pcr imed 1 pcr
	NOP
	NOP
	BRA START
