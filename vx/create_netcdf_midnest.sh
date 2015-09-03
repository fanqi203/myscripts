#!/bin/bash
#purpose: create a netcdf files that contain HDRT HDGF HDRF synthetic GOES images as well as the observed.
#input: $1: case; "2014101418/08L/upp_workdir/synthSat_2014101612_f042.nc"
#output: a netcdf file that contain synthetic GOES images as well as the observed.
#note: make sure "mnt" is where the data is. may need to modify.
#usage: ./create_netcdf_midnest.sh 2014101418/08L/upp_workdir/synthSat_2014101612_f042.nc


export NCARG="/apps/ncl/6.1.2"
export NCARG_ROOT="/apps/ncl/6.1.2"

BT=/lfs2/projects/dtc-hurr/Shaowu.Bao/HDRT/noscrub/atcf/HDRT/bdeck_total.dat
hdrt_syn_dir=/lfs2/projects/dtc-hurr/Shaowu.Bao/HDRT/pytmp/HDRT/com/
hdgf_syn_dir=/lfs2/projects/dtc-hurr/Shaowu.Bao/HDRT/pytmp/HDRT/HDGF_com
hdrf_syn_dir=/lfs2/projects/dtc-hurr/Shaowu.Bao/HDRT/pytmp/HDRT/HDRF_com
observed_sat_dir=/lfs2/projects/dtc-hurr/Shaowu.Bao/Satellite_Observed
existing_dir=/lfs2/projects/dtc-hurr/Shaowu.Bao/Satellite_Observed/OBS_RT_RF_GF_MID_NC
file_to_process=$1
#file_to_process=2014101418/08L/upp_workdir/synthSat_2014101612_f042.nc
cd /lfs2/projects/dtc-hurr/Shaowu.Bao/Satellite_Observed



#############################################################################################

line=$file_to_process


     export gridfile1=${hdrt_syn_dir}/"$line"     
     if [ -z $gridfile1 ]; then exit; fi
     date=$(echo $line |cut -c1-10)
     sid=$(echo $line |cut -c12-14 | tr '[:upper:]' '[:lower:]')

     if [ ${sid:${#sid}-1:1} == "e" ]; then basin="EP"; fi
     if [ ${sid:${#sid}-1:1} == "l" ]; then basin="AL"; fi
     storm_number=${sid:0:2}
     fcst_time=$(echo $line |cut -c37-46 ) 
     valid_time=$(echo $line | cut -c49-51)
 #if [ $valid_time -gt 000 ]; then
     valid_time=$(echo $valid_time | sed 's/^0//')
     export case_info=${date}_${sid}_${fcst_time}
     if [ -z $case_info ]; then exit; fi
     rm *${case_info}*.ascii
     rm *${case_info}*.png

#2012083118_12l_2012090318OBS_RT_RF_GF.middle.nc

     if [ -e ${existing_dir}/${date}_${sid}_${fcst_time}OBS_RT_RF_GF.middle.nc ]; then 
	 echo "exist"; exit
else
	 echo "not exist"
 fi

 #fi
     echo '$date, $sid, $basin, $storm_number, $fcst_time ,$valid_time'
     echo $date, $sid, $basin, $storm_number, $fcst_time ,$valid_time

     echo ${hdrt_syn_dir} "*${sid}.${date}.hwrfsat_m.grb2f${valid_time}"
     echo ${hdrf_syn_dir}/mnt/* "*${sid}.${date}.hwrfsat_m.grb2f${valid_time}"
     echo ${hdgf_syn_dir}/mnt/* "*${sid}.${date}.hwrfsat_m.grb2f${valid_time}"

     find ${hdrt_syn_dir}/* -name "*${sid}.${date}.hwrfsat_m.grb2f${valid_time}" | egrep '.*'
     if [ $? -eq 0 ];then     
	 export gridfile1_mid=$(find ${hdrt_syn_dir}/* -name "*${sid}.${date}.hwrfsat_m.grb2f${valid_time}").grib
     else
	 exit
     fi
     find ${hdrf_syn_dir}/mnt/* -name "*${sid}.${date}.hwrfsat_m.grb2f${valid_time}" |egrep '.*'
     if [ $? -eq 0 ];then     
	 export gridfile2=$(find ${hdrf_syn_dir}/mnt/* -name "*${sid}.${date}.hwrfsat_m.grb2f${valid_time}").grib
     else
	 exit
     fi

     find ${hdgf_syn_dir}/mnt/* -name "*${sid}.${date}.hwrfsat_m.grb2f${valid_time}" |egrep '.*'
     if [ $? -eq 0 ];then     
	 export gridfile3=$(find ${hdgf_syn_dir}/mnt/* -name "*${sid}.${date}.hwrfsat_m.grb2f${valid_time}").grib
     else
	 exit
     fi
     echo "gridfile1 is ", $gridfile1 
     echo "gridfile2 is ", $gridfile2
     echo "gridfile3 is ", $gridfile3


     today_GOES=$(ls GOES13/GOES13_BAND_04_${fcst_time:0:8}_*.nc)
     min_minutes_off=$(echo 24*60|bc)
     for i in ${today_GOES}
     do 
 
 	d1=$(date -d "${fcst_time:0:8} ${fcst_time:8:2} hour" +%s)
 	d2=$(date -d "${i:22:8} ${i:31:2} hour" +%s)
 
 
 	minutes_off=$(( (d1 - d2) / 60 )); if [ $minutes_off -lt 0 ]; then minutes_off=$(echo -1*${minutes_off}|bc); fi
 	if [ $minutes_off -le $min_minutes_off ];then min_minutes_off=$minutes_off; nearest_sate=$i; fi
     done
     export gridfile4=$nearest_sate
     if [ ! -e  $gridfile4 ]; then exit; fi
     export gridfile5=$(echo $gridfile4 |sed "s|BAND_04|BAND_03|g")
     if [ ! -e $gridfile5 ]; then exit; fi
     echo $gridfile4
     echo $gridfile5

     echo "now get bdeck", $BT
     thisline=$(cat $BT |grep $fcst_time |grep "${basin}, ${storm_number}")
     echo "this line is", $thisline

     if [ -z $thisline ]; then exit; fi
     obs_lat_BT=$(echo $thisline |awk '{print $7}')
     obs_lon_BT=$(echo $thisline |awk '{print $8}')
     obs_lat=$(echo "scale=3; ${obs_lat_BT:0:${#obs_lat_BT}-2}/10" | bc)
     obs_lon=$(echo "scale=3; ${obs_lon_BT:0:${#obs_lon_BT}-2}/(-10.0)" | bc)
     echo $obs_lat, $obs_lon     

     /apps/ncl/6.1.2/intel.bin/ncl "lat=$obs_lat" "lon=$obs_lon" ./plot_sate.ncl
 
     echo "succuessful tested ", $file_to_process



