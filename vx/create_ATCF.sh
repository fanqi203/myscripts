#!/bin/bash

#purpose: read in adeck file for ONE CYCLE and generate NCL-required format track files and a list of them.

#input: $1 is the atcf-format a-deck files containing "HDRT","HDGF" and/or "HDRF" items merged.

#output: 
#1) a file $1.ATCF that contain the list of $1.ATCF.HDRT...
#2) the files $1.ATCF.HDRT/HDGF/HDRF that contains the actual NCL-required format track

#usage: create_ATCF.sh daniel04e.2012070800.trak.hwrf.atcfunix

#a-deck files containing "HDRT","HDGF" and/or "HDRF" items.
declare -a exp=("HDRT" "HDGF" "HDRF")


########################################################################################

for i in "${exp[@]}"
do
    cat $1 |grep $i > $1.$i
    while read line; 
    do 
	
	init_time=$(echo $line |cut -c8-18)
	fcst_time=$(echo $line |cut -d"," -f6)
	current_time=$(date -u --date="${init_time:1:8} ${init_time:9:2} +${fcst_time} hour" +%Y%m%d%H)

	yy=${current_time:0:4}
	mm=${current_time:4:2}
	dd=${current_time:6:2}
	hh=${current_time:8:2}
	latx10=$(echo $line|cut -d"," -f7)
	lonx10=$(echo $line|cut -d"," -f8)
	lat=${latx10:0:${#latx10}-2}.${latx10:${#latx10}-2:2}
	lon=${lonx10:0:${#lonx10}-2}.${lonx10:${#lonx10}-2:2}
	wind=$(echo $line|cut -d"," -f9)
	press=$(echo $line|cut -d"," -f10)
	type=$(echo $line|cut -d"," -f11)
	
	
	if [ ${lon:${#lon}-1:1} == "W" ];then lonsign=-$(echo -e "$lon"|sed -e 's/^[[:space:]]*//'); else lonsign=$lon; fi
	if [ ${lat:${#lat}-1:1} == "S" ];then latsign=-$(); else latsign=$lat; fi


	echo "ATCF" $yy-$mm-${dd}_$hh:00:00 ${latsign:0:${#latsign}-1} ${lonsign:0:${#lonsign}-1}  $press $wind 
done < $1.$i >> $1.ATCF.$i
    awk -F" " '!_[$2]++' $1.ATCF.$i > tmp.$1.ATCF.$i; mv tmp.$1.ATCF.$i $1.ATCF.$i
    rm $1.$i
done

for i in $1.ATCF.*
do 
echo $i >> $1.ATCF
done
