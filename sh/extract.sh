#!/bin/bash

target_file="/data/output/report_result/compare.txt"
if [ -e $target_file ]
then
	rm $target_file
else 
	mkdir -p "$(dirname "$target_file")" && touch "$target_file"
fi	

function extract_data()
{
	dir=$1
	arr=($(cat $dir"/compare.log" | awk 'BEGIN{i=0}match($2,/(.*)/){if(NR==1) {s[i++]=$1;}if(NR==4||NR==14){s[i++]=2*$1;s[i++]=substr($2,RSTART+1,RLENGTH-3)}}END{for(i=0;i<5;i++)print s[i]}'))
	lable=${dir: -1}
	echo "|$lable|${arr[0]}|${arr[1]}|${arr[2]}|${arr[3]}|${arr[4]}|"
	echo "|$lable|${arr[0]}|${arr[1]}|${arr[2]}|${arr[3]}|${arr[4]}|" >>$target_file
}

#echo `ls $1| grep -E "bsa_hisat*"`
for dir in `ls $1| grep -E "bsa_hisat*"`
do
	if test -d $1"/"$dir
	then
		#echo $1"/"$dir
		extract_data $1"/"$dir
	fi
done
#extract_data $1
