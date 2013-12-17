#!/usr/bin/python

import sys, getopt

def main(argv):
	inputfile = ''
	outputfile = ''
	
	if len(argv) == 0:
		print 'replace_mif.py -i <inputfile> -o <outputfile>'
		sys.exit(2)
		
	try:
		opts, args = getopt.getopt(argv,"hi:o:",["ifile=","ofile="])
	except getopt.GetoptError:
		print 'replace_mif.py -i <inputfile> -o <outputfile>'
		sys.exit(2)
		
	for opt, arg in opts:
		if opt == '-h':
			print 'test.py -i <inputfile> -o <outputfile>'
			sys.exit()		
		elif opt in ("-i", "--ifile"):
			inputfile = arg
		elif opt in ("-o", "--ofile"):
			outputfile = arg
	
	print argv
	print 'Input file is "', inputfile
	print 'Output file is "', outputfile

	#sys.exit()
	# Leggo il file origine
	fin = open(inputfile, "r")

	# Leggo file destinazione
	fout = open(outputfile, "w")

	to_search="307100 "
	to_replace="307000 "
	
	for line in fin:
		print "Header: [" + line[0:2] + "]"
		
		cod_beg=27
		cod_end=34
		print "Ente: [" + line[cod_beg:cod_end] + "]"
		if line[0:2]=="HR":
			if line[cod_beg:cod_end] == to_search:
				line = line[:cod_beg] + to_replace + line[cod_end:]

		cod_beg=175
		cod_end=182	
		if line[0:2]=="RR":
			if line[cod_beg:cod_end] == to_search:
				line = line[:cod_beg] + to_replace + line[cod_end:]				

		cod_beg=27
		cod_end=34	
		if line[0:2]=="ER":
			if line[cod_beg:cod_end] == to_search:
				line = line[:cod_beg] + to_replace + line[cod_end:]
				
		fout.write(line)

	fout.close()
	fin.close

   
if __name__ == "__main__":
   main(sys.argv[1:])


