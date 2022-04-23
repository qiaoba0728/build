#!/bin/bash


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
    if [ ! -d "/data/output/report_result/${name%.sorted.bam}" ];then
        echo "build dir varscan"
        mkdir -p /data/output/report_result/${name%.sorted.bam}
    fi
    /work/bamdst -p /data/input/references/gtf.bed12 -o /data/output/report_result/${name%.sorted.bam}
    echo >&3
} &
done
wait

echo "build coverage finished"