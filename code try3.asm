const pcr 64 
const joy 66 
CONST DIR 4 
CONST TEMP 0 
L1: 
	cmp joy IMED 0 
	add joy IMED 0 DIR 
	NOP 
	BRF L1 Z 
	CMP DIR IMED 7 
	NOP 
	BRF UP Z 
	CMP DIR IMED 6 
	NOP 
	BRF DOWN Z 
	CMP DIR IMED 5 
	NOP 
	BRF RIGHT Z 
	NOP 
	BRA LEFT 
	NOP 
UP: 	
	SUB PCR IMED 16 TEMP 
	NOP 
	NOP 
	COL TEMP TEMP 
	NOP 
	NOP 
	CMP TEMP IMED 1		--CHECK FOR ROCK
	NOP
	BRF L1 Z
	NOP 
	SUB PCR IMED 16 PCR 
	BRA POST 
	NOP 
DOWN:	
	ADD PCR IMED 16 TEMP 
	NOP 
	NOP 
	COL TEMP TEMP 
	NOP 
	NOP 
	CMP TEMP IMED 1		--CHECK FOR ROCK
	NOP 
	BRF L1 Z 
	NOP 
	ADD PCR IMED 16 PCR 
	BRA POST 
	NOP 
LEFT:	
	SUB PCR IMED 1 TEMP 
	NOP 
	NOP 
	COL TEMP TEMP 
	NOP 
	NOP 
	CMP TEMP IMED 1		--CHECK FOR ROCK
	NOP 
	BRF L1 Z 
	NOP 
	SUB PCR IMED 1 PCR
	BRA POST 
	NOP
RIGHT:
	ADD PCR IMED 1 TEMP 
	NOP 
	NOP 
	COL TEMP TEMP 
	NOP 
	NOP 
	CMP TEMP IMED 1		--CHECK FOR ROCK
	NOP 
	BRF L1 Z 
	NOP 
	ADD PCR IMED 1 PCR
	BRA POST
	NOP
POST:
	CMP JOY IMED 0 
	NOP 
	BRF L1 Z 
	NOP 
	BRA POST 
	NOP 