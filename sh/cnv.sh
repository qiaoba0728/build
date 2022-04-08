#!/bin/sh
fa=`ls  /data/input/references/*.fa`
if [ ! -d "./gene" ];then
	mkdir -p gene
fi
if [ ! -d "/data/output/cnv_result" ];then
	mkdir -p /data/output/cnv_result
fi
cd gene
awk '/^>/{s=++num}{print > "Rs_"s".fa"}' $fa
cd ..
ls -l /data/output/sorted_result/*.sorted.bam |awk -F' ' '{print $9}' > sample.info


cat sample.info |while read id;do
{   
   sample=`basename $id |sed 's/.sorted.bam//'`
   echo $sample
   mkdir -p $sample
   cnvnator -root $sample/file.root -tree $id
   cnvnator -root $sample/file.root -his 1000 -d ./gene
   cnvnator -root $sample/file.root -stat 1000
   cnvnator -root $sample/file.root -partition 1000
   cnvnator -root $sample/file.root -call 1000  > /data/output/cnv_result/${sample}.cnv.call.txt
   /home/biodocker/CNVnator_v0.3.3/cnvnator2VCF.pl /data/output/cnv_result/${sample}.cnv.call.txt /data/input/cnv_result > /data/output/cnv_result/${sample}.cnv.vcf
   #sed  -i "22s/cnv/${sample}/" /data/output/cnv_result/${sample}.cnv.vcf
   #bgzip ${sample}.cnv.vcf
   #tabix -p vcf ${sample}.cnv.vcf.gz
} 
done

if [ ! -d "/data/output/cnv_result/stat.csv" ];then
        touch /data/output/cnv_result/stat.csv
fi
ls -l /data/output/cnv_result/*.cnv.call.txt |awk -F' ' '{print $9}' > cnv.info

cat cnv.info |while read id;do
   sample=`basename $id |sed 's/.cnv.call.txt//'`
   oStat=`cat /data/output/cnv_result/${sample}.cnv.call.txt | wc -l`
   echo "${oStat}"
   echo "|${sample}|${oStat}|" >> /data/output/cnv_result/stat.csv
done

