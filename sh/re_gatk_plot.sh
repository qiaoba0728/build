#!/bin/sh

for file in `ls /data/output/report_result/*_indel.report`
do
{
	echo ${file}
	name=`basename ${file}`
	Rscript gatk_indel_plot.R ${file} /data/output/report_result/${name%_indel.report}
}
done
for file in `ls /data/output/report_result/*_snp.report`
do
{
    echo ${file}
	name=`basename ${file}`
	Rscript gatk_snp_plot.R ${file} /data/output/report_result/${name%_snp.report}
}
done