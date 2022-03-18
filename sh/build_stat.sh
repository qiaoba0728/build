#!/bin/sh
echo "start build stat"
rm -rf /data/output/report_result/stat.csv
touch /data/output/report_result/stat.csv
echo "Group,Percentage" >> /data/output/report_result/stat.csv
oStat=`cat /data/output/report_result/gffcmp.annotated.gtf| grep '"o";' | wc -l`
echo "${oStat}"
echo "o,${oStat}" >> /data/output/report_result/stat.csv
iStat=`cat /data/output/report_result/gffcmp.annotated.gtf| grep '"i";' | wc -l`
echo "i,${iStat}" >> /data/output/report_result/stat.csv
jStat=`cat /data/output/report_result/gffcmp.annotated.gtf| grep '"j";' | wc -l`
echo "j,${jStat}" >> /data/output/report_result/stat.csv
xStat=`cat /data/output/report_result/gffcmp.annotated.gtf| grep '"x";' | wc -l`
echo "x,${xStat}" >> /data/output/report_result/stat.csv
uStat=`cat /data/output/report_result/gffcmp.annotated.gtf| grep '"u";' | wc -l`
echo "u,${uStat}" >> /data/output/report_result/stat.csv
echo "build success!"
python get-pip.py
pip install matplotlib
python build_down_up.py

echo "build all down_up success"
