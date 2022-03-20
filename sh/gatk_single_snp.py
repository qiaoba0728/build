#!/usr/bin/python
# -*- coding: UTF-8 -*-
# python gatk_indel.py test.snp.vcf static.txt test.txt
import sys
input = open(sys.argv[1])
datastatic = open(sys.argv[2], 'w')
snps = {}
# indelstatic = {}
for line in input:
        split_line = line.rstrip("\r\n").split("\t")
        if line.startswith("#"):    
        else:
            # 获取indel的颠倒数据
            if split_line[3] != split_line[4] and len(split_line[3]) == 1 and len(split_line[4]) == 1:
                if "{0}->{1}".format(split_line[3], split_line[4]) not in snps:
                    snps["{0}->{1}".format(split_line[3], split_line[4])] = 1
                else:
                    snps["{0}->{1}".format(split_line[3], split_line[4])] += 1
datastatic.write("snps\t val\r\n")
for key, value in snps.items():
    datastatic.write(key+"\t"+str(value)+"\r\n")
datastatic.close()
input.close()
datafile.close()
