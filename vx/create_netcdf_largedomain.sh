#!/bin/bash
#
#PBS -S /bin/bash
#PBS -A dtc-hurr
#PBS -l partition=ujet:tjet:sjet:vjet:njet
#PBS -j oe
#PBS -l procs=1
#PBS -l vmem=1Gb
#PBS -e error.txt
#PBS -o output.txt
#PBS -l walltime=03:59:00
#PBS -N met_seranl
#PBS -v file_to_process="2011082500/09L/upp_workdir/synthSat_2011082500_f000.nc"

# when submitted to PBS, pass the case info thru "#PBS -v file_to_process="
# when run interactively, set "line=2014101700/08L/upp_workdir/synthSat_2014101800_f024.nc" (see below)
# note "mnt_c" is the diretory containing the model satellite images for hdrf hdgf.
export NCARG="/apps/ncl/6.1.2"
export NCARG_ROOT="/apps/ncl/6.1.2"

hdrt_syn_dir=/lfs2/projects/dtc-hurr/Shaowu.Bao/HDRT/pytmp/HDRT/com/
observed_sat_dir=/lfs2/projects/dtc-hurr/Shaowu.Bao/Satellite_Observed
hdgf_syn_dir=/lfs2/projects/dtc-hurr/Shaowu.Bao/HDRT/pytmp/HDRT/HDGF_com
hdrf_syn_dir=/lfs2/projects/dtc-hurr/Shaowu.Bao/HDRT/pytmp/HDRT/HDRF_com
cd /lfs2/projects/dtc-hurr/Shaowu.Bao/Satellite_Observed
#line=$file_to_process
line=2014101700/08L/upp_workdir/synthSat_2014101800_f024.nc
echo "hello"

     export gridfile1=${hdrt_syn_dir}/"$line"
     date=$(echo $line |cut -c1-10)
     echo $date
     sid=$(echo $line |cut -c12-14 | tr '[:upper:]' '[:lower:]')
     fcst_time=$(echo $line |cut -c37-46 ) 
     valid_time=$(echo $line | cut -c49-51)
 if [ $valid_time -gt 000 ]; then
     valid_time=$(echo $valid_time | sed 's/^0//')
     export case_info=${date}_${sid}_${fcst_time}
     rm *${case_info}*.ascii
     rm *${case_info}*.png
 fi
     echo $date, $sid, $fcst_time ,$valid_time
     

     export gridfile2=$(find ${hdrf_syn_dir}/mnt_c/* -name "*${sid}.${date}.hwrfsat_c.grb2f${valid_time}").grib
     export gridfile3=$(find ${hdgf_syn_dir}/mnt_c/* -name "*${sid}.${date}.hwrfsat_c.grb2f${valid_time}").grib
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
     export gridfile5=$(echo $gridfile4 |sed "s|BAND_04|BAND_03|g")
     echo $gridfile4
     echo $gridfile5

     /apps/ncl/6.1.2/intel.bin/ncl ./create_netcdf_largedomain.ncl
 



