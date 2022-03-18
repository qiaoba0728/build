#!/bin/sh
prefix="/home/biodocker/bin/snpEff"
output="/data/output/report_result/note"
if [ ! -d "${output}" ];then
    mkdir -p ${output}
fi
fa=`ls /data/input/references/*.fa`
gff=`ls /data/input/references/*.gtf`
echo "$fa,$gff"
mkdir -p ${prefix}/data
mkdir -p ${prefix}/data/AT_10
cp -r /data/input/references/*.gtf ${prefix}/data/AT_10/genes.gtf
cp -r /data/input/references/*.fa ${prefix}/data/AT_10/sequences.fa
mkdir -p ${prefix}/data/genomes
cp -r /data/input/references/*.fa ${prefix}/data/genomes/sequences.fa
cp -r /data/input/references/*.gtf ${prefix}/data/genomes/genes.gtf
echo "AT_10.genome: AT" >> ${prefix}/snpEff.config
echo "start build snpeff db note"
# 建库
java -jar ${prefix}/snpEff.jar build -c ${prefix}/snpEff.config -gtf22 -v AT_10
# 注释
cp -r /data/output/gatk_vcf_result/merge.snp.filter.vcf.gz ./
echo "unzip snp"
gunzip merge.snp.filter.vcf.gz
java -Xmx10G -jar ${prefix}/snpEff.jar eff -c ${prefix}/snpEff.config AT_10 merge.snp.filter.vcf > ${output}/positive.snp.eff.vcf -csvStats ${output}/positive.snp.csv -stats ${output}/positive.snp.html
echo "note snp success!"
cp -r /data/output/gatk_vcf_result/merge.indel.filter.vcf.gz ./
echo "unzip indel"
gunzip merge.indel.filter.vcf.gz
java -Xmx10G -jar ${prefix}/snpEff.jar eff -c ${prefix}/snpEff.config AT_10 merge.indel.filter.vcf > ${output}/positive.indel.eff.vcf -csvStats ${output}/positive.indel.csv -stats ${output}/positive.indel.html
echo "note indel success!"
python snpeff_bsa.py