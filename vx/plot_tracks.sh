#!/bin/bash
#purpose: plot tracks  

#input: #1 : name of the NCL-required format track file "list"
#an example:
#daniel04e.2012070818.trak.hwrf.atcfunix.ATCF
#the content of this file is a list of the actual track files in NCL-required  format

#input: #2: name of the best track files
#example: bep042012.dat  

#output: a png format plot of the model tracks and best track.

#Note the NCL-required format is like:
#ATCF 2012-07-08_18:00:00 15.1 -124.4 967 89
#ATCF 2012-07-08_21:00:00 15.2 -125.0 967 82
#ATCF 2012-07-09_00:00:00 15.3 -125.6 968 81
#ATCF 2012-07-09_03:00:00 15.5 -126.2 970 78
#ATCF 2012-07-09_06:00:00 15.6 -126.9 973 78
# this file is generated with 

#requirement: besttrack file should exist in the same directory

#usage: plot_tracks.sh  daniel04e.2012070818.trak.hwrf.atcfunix.ATCF bep042012.dat
#prerequisite:  run creat_ATCF.sh first.
i=$1
BT=$2
# get sid num yyyy mm end-date
    echo $i
    sid=$(echo $i|cut -d"." -f1)
    echo $sid
    if [ ${sid:${#sid}-1:1} == "e" ]; then basin="ep"; fi
    if [ ${sid:${#sid}-1:1} == "l" ]; then basin="al"; fi
    num=${sid:${#sid}-3:2}
    echo $basin
    mydate=$(echo $i|cut -d"." -f2)
    mm=${mydate:4:2}
    yyyy=${mydate:0:4}
    ADECK=$i.HDRT
    echo $ADECK
    while read line
    do
	myenddate=${line:5:4}${line:10:2}${line:13:2}${line:16:2}
	done<${ADECK}

#best track:
# convert atcf best track file to NCL_required format
#    BT=b${basin}${num}${yyyy}.dat
#    BT_in=b${basin}${num}${yyyy}.dat.BT.in
    BT_in=${BT}.BT.in
    rm ${BT_in}
    echo ${BT}
    while read line
    do
	BT_yy=$(echo $line|cut -c9-12)
	BT_mm=$(echo $line|cut -c13-14)
	BT_dd=$(echo $line|cut -c15-16)
	BT_hh=$(echo $line|cut -c17-18)
	latx10=$(echo $line|cut -d"," -f7)
	lonx10=$(echo $line|cut -d"," -f8)
	lat=${latx10:0:${#latx10}-2}.${latx10:${#latx10}-2:2}
	lon=${lonx10:0:${#lonx10}-2}.${lonx10:${#lonx10}-2:2}
	wind=$(echo $line|cut -d"," -f9)
	press=$(echo $line|cut -d"," -f10)
	type=$(echo $line|cut -d"," -f11)
	if [ ${BT_yy}${BT_mm}${BT_dd}${BT_hh} -le $myenddate ] && [ ${BT_yy}${BT_mm}${BT_dd}${BT_hh} -ge $mydate ]
	    then
	    printf "%s GMT %s%7s%7s%7s%11s%24s\n" ${BT_hh} ${BT_mm}/${BT_dd}/${BT_yy:2:2}  $lat  $lon    $wind        $press     $type >> ${BT_in}	    
	fi
	
	done<${BT}
    export TITLE=$(echo $i |cut -d"." -f1-2)


    ncl CreateTracks.ncl inputFILE=\"${i}\" 'wksTYPE="png"' bestTRACK=True btFILE=\"${BT_in}\" plotTYPE=4
    mv hur_track.png $TITLE.track.png

