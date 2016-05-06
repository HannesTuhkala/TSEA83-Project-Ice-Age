
# converts text file to map array:
# ice = i
# rock = r
# ground = #
	
def convertFileToMap(filename):
	map=[]
	newMap=[]
	for line in open(filename+".txt"):
		    map.append(line.rstrip('\n')) # .rstrip('\n') removes the line break
	for item in map:
		tmpString=""
		for char in item:
			if char == 'r':
				tmpString=tmpString+"\"10\", "
			elif char == '#':
				tmpString=tmpString+"\"01\", "
			else:
				tmpString=tmpString+"\"00\", "
		newMap.append(tmpString)
	newMap[15]=newMap[15]+");"
	for all in newMap:
		print(all)
				






convertFileToMap("test");
