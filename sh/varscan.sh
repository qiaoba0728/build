#!/bin/bash

prefix="/data/output/varscan_result"
fa=`find /data/input/references/ -name *.fa`
echo "fa:$fa"
if [ ! -d "/data/output/varscan" ];then
	echo "build dir varscan"
	mkdir -p /data/output/varscan_result
fi

start_time=`date +%s`              #定义脚本运行的开始时间
[ -e /tmp/fd1 ] || mkfifo /tmp/fd1 #创建有名管道
exec 3<>/tmp/fd1                   #创建文件描述符，以可读（<）可写（>）的方式关联管道文件，这时候文件描述符3就有了有名管道文件的所有特性
rm -rf /tmp/fd1                    #关联后的文件描述符拥有管道文件的所有特性,所以这时候管道文件可以删除，我们留下文件描述符来用就可以了
thread=4
if [ ! -n "$1" ];then
        echo "default 4 thread"
else
        thread=$1
fi

for ((i=1;i<=$thread;i++))
do
        echo >&3                   #&3代表引用文件描述符3，这条命令代表往管道里面放入了一个"令牌"
done

for file in `ls /data/output/sorted_result/*.sorted.bam`
do
read -u3
{
    echo $file
    name=`basename ${file}`
    echo $prefix $name
    echo "samtools mpileup -q 1 -d 30000 -f $fa $file 1>${prefix}/${name%.sorted.bam}.mpileup 2>mpileup.log"
    samtools mpileup -q 1 -d 30000 -f ${fa} ${file} 1>${prefix}/${name%.sorted.bam}.mpileup 2>mpileup.log
    echo >&3
} &
done
wait

echo "samtools finished"
for file in `ls /data/output/varscan_result/*.mpileup`
do
read -u3
{
	name=`basename ${file}`
        echo $prefix $name
        echo "java -jar VarScan.v2.4.2.jar mpileup2snp ${prefix}/${name} --output-vcf 1 >${prefix}/${name%.mpileup}.snp.vcf"
        java -jar VarScan.v2.4.2.jar mpileup2snp ${prefix}/${name} --output-vcf 1 >${prefix}/${name%.mpileup}.snp.vcf
	echo >&3
} &
done
wait
echo "varscan work finished"


for file in `ls /data/output/varscan_result/*.mpileup`
do
read -u3
{
        name=`basename ${file}`
        echo $prefix $name
        echo "java -jar VarScan.v2.4.2.jar mpileup2indel ${prefix}/${name} --output-vcf 1 >${prefix}/${name%.mpileup}.snp.vcf"
        java -jar VarScan.v2.4.2.jar mpileup2indel ${prefix}/${name} --output-vcf 1 >${prefix}/${name%.mpileup}.indel.vcf
        echo >&3
} &
done
wait
echo "varscan work finished"
#for file in `ls /data/output/varscan_result/*.indel.vcf`
#do
#{
#        echo $file
#        name=`basename ${file}`
#        python pipe.py Insertions ${name%.indel.vcf}.txt ${file}
#        Rscript graph.r ${name%.indel.vcf}.txt /data/output/varscan_result/${name%.indel.vcf} Insertions
#}
#done
#for file in `ls /data/output/varscan_result/*.snp.vcf`
#do
#{
#        echo $file
#        name=`basename ${file}`
#        python pipe.py SNPs ${name%.snp.vcf}.txt ${file}
#        Rscript graph.r ${name%.snp.vcf}.txt /data/output/varscan_result/${name%.snp.vcf} SNPs
#}
#done


stop_time=`date +%s`  #定义脚本运行的结束时间
 
echo "TIME:`expr $stop_time - $start_time`"
exec 3<&-                       #关闭文件描述符的读
exec 3>&- 
