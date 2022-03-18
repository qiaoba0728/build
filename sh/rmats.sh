#!/bin/sh
prefix="/data/output/rmats_result"
echo "start build rmats"
if [ ! -d "${prefix}/rmats.csv" ];then
       echo "rmats.csv not existed"
else
        rm -rf ${prefix}/rmats.csv
fi
ls  ${prefix}/  > rmats.info
cat rmats.info
touch ${prefix}/rmats.csv
cat rmats.info |while read sample;do
   #sample=`basename $id`
   echo "$sample"
   se=`sed -n "2, 1p" ${prefix}/${sample}/summary.txt | awk '{print $2}'`
   a5=`sed -n "3, 1p" ${prefix}/${sample}/summary.txt | awk '{print $2}'`
   a3=`sed -n "4, 1p" ${prefix}/${sample}/summary.txt | awk '{print $2}'`
   mxe=`sed -n "5, 1p" ${prefix}/${sample}/summary.txt | awk '{print $2}'`
   ri=`sed -n "6, 1p" ${prefix}/${sample}/summary.txt | awk '{print $2}'`
   echo "|${sample}|${se}|${a5}|${a3}|${mxe}|${se}|${ri}"
   echo "|${sample}|${se}|${a5}|${a3}|${mxe}|${se}|${ri}|" >> ${prefix}/rmats.csv
done

echo "build rmats success"
