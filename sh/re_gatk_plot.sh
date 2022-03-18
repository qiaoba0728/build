#!/bin/sh

for file in `ls /data/output/gatk_single_result/*.indel.filter.vcf.gz`
do
{
	echo ${file}
    gunzip ${file}
    filename=${file%.gz}
    echo ${filename}
	name=`basename ${filename}`
	python pipe.py Insertions ${name%.indel.vcf}.txt ${filename}
	Rscript graph.r ${name%.indel.vcf}.txt /data/output/gatk_single_result/${name%.indel.vcf} Insertions
}
done
for file in `ls /data/output/gatk_single_result/*.snp.filter.vcf.gz`
do
{
        echo $file
        gunzip ${file}
        filename=${file%.gz}
        echo ${filename}
        name=`basename ${filename}`
        python pipe.py SNPs ${name%.snp.vcf}.txt ${file}
        Rscript graph.r ${name%.snp.vcf}.txt /data/output/gatk_single_result/${name%.snp.vcf} SNPs
}
done