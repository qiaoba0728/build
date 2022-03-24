#!/usr/bin/python
# -*- coding: UTF-8 -*-
# python gatk_indel.py test.indel.vcf static.txt test.txt
import sys
input = open(sys.argv[1])
datastatic = open(sys.argv[2], 'w')
insertions = {}
# indelstatic = {}
for line in input:
        split_line = line.rstrip("\r\n").split("\t")
        if line.startswith("#"):
            continue
        else:
            # 获取插入和缺失长度
            last = split_line[4].split(",")
            key = len(split_line[3]) - len(last[0])
            if not insertions.get(key):
                insertions[key] = 1
            else:
                insertions[key] = insertions[key] + 1
datastatic.write("indels\t val\r\n")
for key, value in insertions.items():
    datastatic.write(str(key)+"\t"+str(value)+"\r\n")
datastatic.close()
input.close()