#!/bin/bash

for file in `ls /data/output/varscan_result/*.indel.vcf`
do
{
	echo $file
	name=`basename ${file}`
	python pipe.py Insertions ${name%.indel.vcf}.indel.txt ${file}
	Rscript graph.r ${name%.indel.vcf}.indel.txt /data/output/varscan_result/${name%.indel.vcf} Insertions
}
done
for file in `ls /data/output/varscan_result/*.snp.vcf`
do
{
        echo $file
        name=`basename ${file}`
        python pipe.py SNPs  ${name%.snp.vcf}.snp.txt ${file}
        Rscript graph.r ${name%.snp.vcf}.snp.txt /data/output/varscan_result/${name%.snp.vcf} SNPs
}
done
cp -r *.txt /data/output/varscan_result/
