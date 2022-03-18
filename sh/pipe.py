#!/usr/bin/python
import sys
#filename = open(input('What is the VCF file name? '))
#datafile = open("datafile.txt", 'w')
datafile = open(sys.argv[2], 'w')
filename = open(sys.argv[3])
snps = {}
insertions = {}

if sys.argv[1] == "Insertions":
	for line in filename:
		if not line.startswith("#"):
			split_line = line.rstrip("\r\n").split("\t")
			if len(split_line[3]) < len(split_line[4]):
				if "{0}->{1}".format(split_line[3], split_line[4]) not in insertions:
					insertions["{0}->{1}".format(split_line[3], split_line[4])] = 1
				else:
					insertions["{0}->{1}".format(split_line[3], split_line[4])] += 1
	datafile.write("Insertions\t Variants\r\n")
	for key, value in insertions.items():
		datafile.write(key+"\t"+str(value)+"\r\n")
elif sys.argv[1] == "SNPs":
	for line in filename:
		if not line.startswith("#"):
			split_line = line.rstrip("\r\n").split("\t")
			if split_line[3] != split_line[4] and len(split_line[3]) == 1 and len(split_line[4]) == 1:
				if "{0}->{1}".format(split_line[3], split_line[4]) not in snps:
					snps["{0}->{1}".format(split_line[3], split_line[4])] = 1
				else:
					snps["{0}->{1}".format(split_line[3], split_line[4])] += 1
	datafile.write("SNPs\t Variants\r\n")
	for key, value in snps.items():
		datafile.write(key+"\t"+str(value)+"\r\n")
#return datafile
datafile.close()
