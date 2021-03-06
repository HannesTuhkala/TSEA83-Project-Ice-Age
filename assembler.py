#coding=utf-8
import sys

OP_CODES = {
	"NOP" : 0,
	"MOVE" : 1,
	"ADD" : 3,
	"SUB" : 4,
	"SHIFT" : 6,
	"CMP" : 8,
	"SETF" : 9,
	"BRF" : 10,
	"BRA" : 11,
}

# Different modes and different constants used in code
MODES = {
	"IMED" : "00",
	"DIR" : "01",
	"Z0" : "10",
	"Z1" : "11",
	"N0" : "00",
	"N1" : "01",
	"Z" : "00",
	"N" : "01",
}

lines = []
outputcode = {}
labels = {}
constants = {}
currentLine = 0

# Assembles the assemblycode to machine code.
def assemble(filename):
	global currentLine, lines, outputcode, labels, constants

	# Read all lines in file
	with open(filename) as f:
		lines = f.readlines()

	# preassembles the file by adding constants and labels to dictionaries and converting hex values to decimal values.
	lines = preAssemble(lines, labels)

	# puts in all numeric values for labels and constants and converts each instruction to machine code.
	for line in lines:
		# Parse current line
		outputcode[currentLine] = parseLine(line, currentLine, labels)
		currentLine += 1

	# Outputs the code.
	printCode(outputcode)
	print(currentLine)

def preAssemble(lines, labels):
	currentLine = 0
	newlines = []
	for key, line in enumerate(lines):
		# Remove the newline and tab character
		line = line.replace("\n", "")
		line = line.replace("\t", "")

		line = line.upper()
		words = line.split(" ")

		for key, word in enumerate(words):
			# Remove comments
			if word == "--":
				break;
			if isLabel(word):
				labels[word[0:-1]] = currentLine
				currentLine -= 1
			if isConstant(word):
				constants[words[1]] = words[2]
				currentLine -= 1
				break;
			elif word in constants:
				words[key] = constants[word]
			elif isHex(word):
				words[key] = int(word[1:], 16)
		
		if (not isConstant(words[0]) and not isLabel(words[0])):
			newlines.append(" ".join(map(str, words)))

		currentLine += 1

	return newlines

def printCode(outputcode):
	# Output the machine code: line: machine code: hex code
	currentLine = 0
	for line in outputcode:
		# If current line is empty, skip it (can happen when using labels)
		if (outputcode[line] == ""):
			continue;
		#print(str(currentLine) + ": " + outputcode[line] + " : " + "{0:0>4X}".format(int(outputcode[line], 2)))
		print('\"'+outputcode[line]+"\",")
		currentLine += 1

# Parse a line into machine code
def parseLine(line, currentLine, labels):
	outputLine = ""
	print (currentLine)	
	# Make line uppercase and split into words by delimiter 'space'.	
	line = line.upper()
	words = line.split(" ")
	
	opcode = words[0]
	print (opcode)
	outputLine += getOP(opcode)
	
	if opcode == "NOP" or opcode == "HALT":
		outputLine += toBinary(0, 26)
	elif opcode == "MOVE":
		outputLine += addZeros(10)
		outputLine += toBinary(words[1], 8)
		outputLine += toBinary(words[2], 8)
	elif opcode == "MAPS":
		outputLine += addZeros(8)
		outputLine += getMode(words[1])
		outputLine += toBinary(words[2], 8)
		outputLine += toBinary(words[3], 8)
	elif opcode == "SHIFT":
		outputLine += getTerm1(words[1])
		outputLine += addZeros(10)
		outputLine += toBinary(words[2], 8)
	elif opcode == "SETF":
		outputLine += addZeros(8)
		outputLine += getMode(words[1])
		outputLine += addZeros(16)
	elif opcode == "COL":
		outputLine += addZeros(10)
		outputLine += toBinary(words[1], 8)
		outputLine += toBinary(words[2], 8)
	elif opcode == "BRF":
		outputLine += getTerm1(words[1])
		outputLine += getMode(words[2])
		outputLine += addZeros(16)
	elif opcode == "BRA":
		outputLine += getTerm1(words[1])
		outputLine += "01"
		outputLine += addZeros(16)
	elif opcode == "CMP":
		outputLine += getTerm1(words[1])
		outputLine += getMode(words[2])
		outputLine += toBinary(words[3], 8)
		outputLine += addZeros(8)
	else:
		outputLine += getTerm1(words[1])
		outputLine += getMode(words[2])
		outputLine += toBinary(words[3], 8)
		outputLine += toBinary(words[4], 8)
	
	return outputLine

# If the current word is a hex, returns a boolean
def isHex(word):
	return word.startswith("$")

# If the current word is a label, returns a boolean
def isLabel(word):
	return word.endswith(':')

# If the current word is a CONST, returns a boolean
def isConstant(word):
	return word == "CONST"

# Converts a decimal number to a binary number and adds remaining leading zeros to the n bit.
def toBinary(number, n):
	return format(int(number), 'b').zfill(n)

# Returns the mode or constant value from MODES or "00"
def getMode(word):
	if word in MODES:
		return MODES[word]
	else:
		return "00"

# Returns the binary value of the opcode and adds 2 zeros for am1, exits if not a valid op code.
def getOP(opcode):
	if opcode in OP_CODES:
		return toBinary(int(OP_CODES[opcode]), 4) + toBinary(0, 2)
	else:
		print("Invalid OP code '" + opcode + "'.")
		sys.exit(-1)

# Returns label if already defined, otherwise it converts word to binary value
def getTerm1(word):
	if word in labels:
		return toBinary(labels[word], 8)
	else:
		try:
			return toBinary(int(word), 8)
		except ValueError:
			print("'" + word + "' is not a valid label.")
			sys.exit(-1)

# Adds n zeros
def addZeros(n):
	return toBinary(0, n)

# Main function
if __name__ == "__main__":
	if len(sys.argv) < 2:
		print("Please specify an input file")
		sys.exit(-1)
	
	assemble(sys.argv[1])