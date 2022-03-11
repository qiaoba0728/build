#!/usr/bin/python
import sys
import getopt
import re

def usage():
    print('''
          Usage: python3 script.py [option] [patameter]
          -i/--keg            input a hetxt file
          -o/--outfile        input outfile name
          -h/--help           show possible options
          ''')
#Copyright(C) 2020 by hujianbing@webmail.hzau.edu.cn
    
opts,args = getopt.getopt(sys.argv[1:], 'hf:i:o:', ['help', 'keg=', 'outfile='])
for opt,val in opts:
    if opt == '-i' or opt == '--keg':
        keg = val 
    elif opt == '-o' or opt == '--outfile':
        outfile = val 
    elif opt == '-h' or opt == '--help':
        usage()
        sys.exit(1)

outf = open(outfile, 'w')

from collections import OrderedDict
pathway=OrderedDict()
with open(keg) as f:
        for line in f:
                if line.startswith('A'):
                        line = line.strip().split(' ')
                        className=line[0].split('A')[1]+'\t'
                        pathway[className]=OrderedDict()
                elif line.startswith('B') and len(line)>2:
                        line = line.strip().split('  ')
                        subclass=line[1]+'\t'
                        pathway[className][subclass]=OrderedDict()
                elif line.startswith('C'):
                        line = line.strip().split()
                        pathName=line[1]+'\t'+' '.join(line[2:-1])+'\t'
                        pathway[className][subclass][pathName]=[]
                elif line.startswith('D'):
                        line = line.strip().split(';')
                        geneName=line[0].split()[1]+'\t'+line[1].split()[0]+'\n' 
                        pathway[className][subclass][pathName].append(geneName)

for k,v in pathway.items():
        for subk,subv in v.items():
                for ptwy,genes in subv.items():
                        for geneID in genes:
                                outf.write(k+subk+ptwy+geneID)
outf.close()
