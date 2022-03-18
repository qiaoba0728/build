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
	param0=$(cat $dir/coverage.report | grep -E "\[Target\] Average depth[^()]" | awk -F'[[:space:]%]+' '{print $5}')
	param1=$(cat $dir/coverage.report | grep -E "\[Target\] Coverage \(>=4x\)" | awk -F'[[:space:]%]+' '{print $5}')
	param2=$(cat $dir/coverage.report | grep -E "\[Target\] Coverage \(>=10x\)" | awk -F'[[:space:]%]+' '{print $5}')
	param3=$(cat $dir/coverage.report | grep -E "\[Target\] Coverage \(>=30x\)" | awk -F'[[:space:]%]+' '{print $5}')
	lable=${dir: -1}
	echo "|$lable|${param0}|${param1}|${param2}|${param3}|"
	echo "|$lable|${param0}|${param1}|${param2}|${param3}|" >>$target_file
}

#echo `ls $1| grep -E "bsa_hisat*"`
for dir in `ls $1| grep -E "^report_*"`
do
	if test -d $1"/"$dir
	then
		#echo $1"/"$dir
		extract_data $1"/"$dir
	fi
done
#extract_data $1
