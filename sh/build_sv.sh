#!/bin/bash
prefix="/data/output/sv_result"
if [ ! -d "$prefix" ];then
	echo "build dir sv_result"
	mkdir -p $prefix
fi

for file in `ls /data/output/sorted_result/*.sorted.bam`
do
{
    echo $file
    name=`basename ${file} |sed 's/.sorted.bam//'`
    echo $file $name
    bam2cfg.pl $file > $name.txt
    breakdancer-max $name.txt > /data/output/sv_result/$name.txt
    del=`cat /data/output/sv_result/${name}.txt | grep DEL | wc -l`
    ins=`cat /data/output/sv_result/${name}.txt | grep INS | wc -l`
    inv=`cat /data/output/sv_result/${name}.txt | grep INV | wc -l`
    itx=`cat /data/output/sv_result/${name}.txt | grep ITX | wc -l`
    ctx=`cat /data/output/sv_result/${name}.txt | grep CTX | wc -l`
    echo "${name}|${del}|${ins}|${inv}|${itx}|${ctx}|"
    echo "${name}|${del}|${ins}|${inv}|${itx}|${ctx}|">>${prefix}/result.txt
} 
done