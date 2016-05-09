#coding=utf-8
import sys

OP_CODES = {
	"NOP" : 0,
	"MOVE" : 1,
	"ADD" : 3,
	"SUB" : 4,
	"MULT" : 5,
	"SHIFT" : 6,
	"COL" : 7,
	"CMP" : 8,
	"SETF" : 9,
	"BRF" : 10,
	"BRA" : 11,
	"HALT" : 15,
}

MODES = {
	"IMED" : "00",
	"DIR" : "01",
	"LEFT" : "00",
	"RIGHT" : "01",
	"Z0" : "00",
	"Z1" : "01",
	"N0" : "10",
	"N1" : "11",
	"Z" : "00",
	"N" : "10",
}

COL = {
	"UP" : "00",
	"DOWN" : "01",
	"LEFT" : "10",
	"RIGHT" : "11",
}

def assemble(filename):
	currentLine = 0
	lines = {}
	outputcode = {}
	labels = {}

	with open(filename) as f:
		lines = f.readlines()
	
	for line in lines:
		# Remove the newline and tab character
		line = line.replace("\n", "")
		line = line.replace("\t", "")
		outputcode[currentLine] = parseLine(line, currentLine, labels)
		currentLine += 1
	
	currentLine = 0
	for line in outputcode:
		if (outputcode[line] == ""):
			continue;
		print(str(currentLine) + ": " + outputcode[line] + " : " + "{0:0>4X}".format(int(outputcode[line], 2)))
		currentLine += 1
	
def parseLine(line, currentLine, labels):
	outputLine = ""
	
	line = line.upper()
	words = line.split(" ")
	
	for key, word in enumerate(words):
		if isHex(word):
			words[key] = int(word[1:], 16)
	
	if isLabel(words[0]):
		labels[words[0][0:-1]] = currentLine
	else:
		opcode = words[0]
		outputLine += getOP(opcode)
		
		if opcode == "NOP" or opcode == "HALT":
			outputLine += toBinary(0, 26)
		elif opcode == "SHIFT":
			outputLine += getTerm1(words[1])
			outputLine += getMode(words[2])
			outputLine += toBinary(0, 16)
		elif opcode == "SETF":
			outputLine += addLeadingZeros(8)
			outputLine += getMode(words[1])
			outputLine += addLeadingZeros(16)
		elif opcode == "COL":
			outputLine += toBinary(int(words[1]), 8)
			outputLine += addLeadingZeros(2)
			outputLine += COL[words[2]]
			outputLine += addLeadingZeros(14)
		elif opcode == "BRF":
			term1 = words[1]
			
			if term1 in labels:
				outputLine += toBinary(labels[term1], 8)
			else:
				outputLine += toBinary(int(term1), 8)
			
			outputLine += getMode(term1)
			outputLine += addLeadingZeros(16)
		elif opcode == "BRA":
			term1 = words[1]
			
			if term1 in labels:
				outputLine += toBinary(int(labels[term1]), 8)
			else:
				outputLine += toBinary(int(term1), 8)
			
			outputLine += addLeadingZeros(18)
		elif opcode == "CMP":
			outputLine += getTerm1(words[1])
			outputLine += getMode(words[2])
			outputLine += toBinary(int(words[3]), 8)
			outputLine += addLeadingZeros(8)
		else:
			outputLine += getTerm1(words[1])
			outputLine += getMode(words[2])
			outputLine += toBinary(int(words[3]), 8)
			outputLine += toBinary(int(words[4]), 8)

	return outputLine

def isHex(word):
	return word.startswith("$")
	
def isLabel(word):
	return word.endswith(':')

def toBinary(number, n):
	return format(number, 'b').zfill(n)

def getMode(word):
	if word in MODES:
		return MODES[word]
	else:
		return "00"
	
def getOP(opcode):
	if opcode in OP_CODES:
		return toBinary(int(OP_CODES[opcode]), 4) + toBinary(0, 2)
	else:
		print("Invalid OP code '" + opcode + "'.")
		sys.exit(-1)

def getTerm1(word):
	if int(word) >= 0 and int(word) < 33:
		return toBinary(int(word), 8)
	else:
		print("You can only use a register between 0 and 32, you tried to use '" + word + "'.")
		sys.exit(-1)

def addLeadingZeros(n):
	return toBinary(0, n)

if __name__ == "__main__":
	if len(sys.argv) < 2:
		print("Please specify an input file")
		sys.exit(-1)
	
	assemble(sys.argv[1])
