#!/usr/bin/python
# -*- coding: UTF-8 -*-
# python gatk_indel.py test.snp.vcf static.txt test.txt
import sys
HETER = "0/1"
HOMO = "1/1"
input = open(sys.argv[1])
datafile = open(sys.argv[2], 'w')
datastatic = open(sys.argv[3], 'w')
item = []
heter = []
homo = []
total = []
# indelstatic = {}
for line in input:
        split_line = line.rstrip("\r\n").split("\t")
        if line.startswith("#"):
            if line.startswith("#CHROM"):
                for i in range(0,len(split_line)):
                    if i > 8:
                        item.append(split_line[i])            
        else:
            # 获取杂合子和纯合子统计
            if len(item) > 0 and len(heter) == 0 and len(homo) == 0 : 
                heter = [0 for i in range(len(item))]
                homo = [0 for i in range(len(item))]
            for i in range(len(item)):
                if split_line[i + 9].startswith(HETER):heter[i] = heter[i] + 1
                if split_line[i + 9].startswith(HOMO):homo[i] = homo[i] + 1
print(item)
print(heter)
print(homo)
# 纯合子杂合子统计
total = [0 for i in range(len(item))]
for i in range(len(item)):
    print("|{}|{}|{}|{}|\r\n".format(item[i],heter[i],homo[i],heter[i]+homo[i]))
    datafile.write("|{}|{}|{}|{}|\r\n".format(item[i],heter[i],homo[i],heter[i]+homo[i]))
input.close()
datafile.close()
