#!/bin/bash
#purpose: given adeck and bdeck files do tc verification
#inputs:
#1) adeck file ($1)
#2) bdeck file ($2)
#output plots of verifications

#note: TCPairsConfig_default must exist and the ATCF names  specified in in must exist in the adeck file

Adeck=$1
Bdeck=$2

export PATH=$PATH:/lfs2/projects/dtc-hurr/MET/MET_releases/met-5.0/bin



 /lfs2/projects/dtc-hurr/MET/MET_releases/met-5.0/bin/tc_pairs -adeck $Adeck  -bdeck $Bdeck -config TCPairsConfig_default
 
  Rscript  /lfs2/projects/dtc-hurr/MET/MET_releases/met-5.0/scripts/Rscripts/plot_tcmpr.R -title "max wind: model-besttrack"       -dep "AMAX_WIND-BMAX_WIND" -lookin out_tcmpr.tcst  -plot "MEAN"
  mv AMAX_WIND-BMAX_WIND_mean.png ${Adeck}.AMAX_WIND-BMAX_WIND_mean.png
  Rscript  /lfs2/projects/dtc-hurr/MET/MET_releases/met-5.0/scripts/Rscripts/plot_tcmpr.R -title "max wind: absolute error"       -dep "ABS(AMAX_WIND-BMAX_WIND)" -lookin out_tcmpr.tcst  -plot "MEAN"
  mv ABS_AMAX_WIND-BMAX_WIND_mean.png ${Adeck}.ABS_AMAX_WIND-BMAX_WIND_mean.png
  Rscript  /lfs2/projects/dtc-hurr/MET/MET_releases/met-5.0/scripts/Rscripts/plot_tcmpr.R -title "max wind: absolute error rank"       -dep "ABS(AMAX_WIND-BMAX_WIND)" -lookin out_tcmpr.tcst  -plot "RANK"
  mv ABS_AMAX_WIND-BMAX_WIND_rank.png ${Adeck}.ABS_AMAX_WIND-BMAX_WIND_rank.png
  Rscript  /lfs2/projects/dtc-hurr/MET/MET_releases/met-5.0/scripts/Rscripts/plot_tcmpr.R -title "track error"       -dep "TK_ERR" -lookin out_tcmpr.tcst  -plot "MEAN"
  mv TK_ERR_mean.png ${Adeck}.TK_ERR_mean.png
  Rscript  /lfs2/projects/dtc-hurr/MET/MET_releases/met-5.0/scripts/Rscripts/plot_tcmpr.R -title "along track error"       -dep "ALTK_ERR" -lookin out_tcmpr.tcst  -plot "MEAN"
  mv ALTK_ERR_mean.png ${Adeck}.ALTK_ERR_mean.png
  Rscript  /lfs2/projects/dtc-hurr/MET/MET_releases/met-5.0/scripts/Rscripts/plot_tcmpr.R -title "cross track error"       -dep "CRTK_ERR" -lookin out_tcmpr.tcst  -plot "MEAN"
  mv CRTK_ERR_mean.png ${Adeck}.CRTK_ERR_mean.png
  Rscript  /lfs2/projects/dtc-hurr/MET/MET_releases/met-5.0/scripts/Rscripts/plot_tcmpr.R -title "track error rank"       -dep "TK_ERR" -lookin out_tcmpr.tcst  -plot "RANK"
  mv TK_ERR_rank.png ${Adeck}.TK_ERR_rank.png


#total:::
exit

/lfs2/projects/dtc-hurr/MET/MET_releases/met-5.0/bin/tc_pairs -adeck $Adeck  -bdeck $Bdeck -config TCPairsConfig_default -out out_total_tcmpr
 Rscript  /lfs2/projects/dtc-hurr/MET/MET_releases/met-5.0/scripts/Rscripts/plot_tcmpr.R -title "max wind: model-besttrack"       -dep "ANE_WIND_50-BNE_WIND_50" -lookin out_total_tcmpr.tcst  -plot "MEAN"
 Rscript  /lfs2/projects/dtc-hurr/MET/MET_releases/met-5.0/scripts/Rscripts/plot_tcmpr.R -title "max wind: model-besttrack"       -dep "ASE_WIND_50-BSE_WIND_50" -lookin out_total_tcmpr.tcst  -plot "MEAN"
 Rscript  /lfs2/projects/dtc-hurr/MET/MET_releases/met-5.0/scripts/Rscripts/plot_tcmpr.R -title "max wind: model-besttrack"       -dep "ASW_WIND_50-BSW_WIND_50" -lookin out_total_tcmpr.tcst  -plot "MEAN"
 Rscript  /lfs2/projects/dtc-hurr/MET/MET_releases/met-5.0/scripts/Rscripts/plot_tcmpr.R -title "max wind: model-besttrack"       -dep "ANW_WIND_50-BNW_WIND_50" -lookin out_total_tcmpr.tcst  -plot "MEAN"

 Rscript  /lfs2/projects/dtc-hurr/MET/MET_releases/met-5.0/scripts/Rscripts/plot_tcmpr.R -title "max wind: model-besttrack"       -dep "ANE_WIND_34-BNE_WIND_34" -lookin out_total_tcmpr.tcst  -plot "MEAN"
 Rscript  /lfs2/projects/dtc-hurr/MET/MET_releases/met-5.0/scripts/Rscripts/plot_tcmpr.R -title "max wind: model-besttrack"       -dep "ASE_WIND_34-BSE_WIND_34" -lookin out_total_tcmpr.tcst  -plot "MEAN"
 Rscript  /lfs2/projects/dtc-hurr/MET/MET_releases/met-5.0/scripts/Rscripts/plot_tcmpr.R -title "max wind: model-besttrack"       -dep "ASW_WIND_34-BSW_WIND_34" -lookin out_total_tcmpr.tcst  -plot "MEAN"
 Rscript  /lfs2/projects/dtc-hurr/MET/MET_releases/met-5.0/scripts/Rscripts/plot_tcmpr.R -title "max wind: model-besttrack"       -dep "ANW_WIND_34-BNW_WIND_34" -lookin out_total_tcmpr.tcst  -plot "MEAN"

 Rscript  /lfs2/projects/dtc-hurr/MET/MET_releases/met-5.0/scripts/Rscripts/plot_tcmpr.R -title "max wind: model-besttrack"       -dep "ANE_WIND_64-BNE_WIND_64" -lookin out_total_tcmpr.tcst  -plot "MEAN"
 Rscript  /lfs2/projects/dtc-hurr/MET/MET_releases/met-5.0/scripts/Rscripts/plot_tcmpr.R -title "max wind: model-besttrack"       -dep "ASE_WIND_64-BSE_WIND_64" -lookin out_total_tcmpr.tcst  -plot "MEAN"
 Rscript  /lfs2/projects/dtc-hurr/MET/MET_releases/met-5.0/scripts/Rscripts/plot_tcmpr.R -title "max wind: model-besttrack"       -dep "ASW_WIND_64-BSW_WIND_64" -lookin out_total_tcmpr.tcst  -plot "MEAN"
 Rscript  /lfs2/projects/dtc-hurr/MET/MET_releases/met-5.0/scripts/Rscripts/plot_tcmpr.R -title "max wind: model-besttrack"       -dep "ANW_WIND_64-BNW_WIND_64" -lookin out_total_tcmpr.tcst  -plot "MEAN"



## Rscript  /lfs2/projects/dtc-hurr/MET/MET_releases/met-5.0/scripts/Rscripts/plot_tcmpr.R -title "max wind: model-besttrack"       -dep "AMAX_WIND-BMAX_WIND" -lookin out_total_tcmpr.tcst  -plot "MEAN"
## mv AMAX_WIND-BMAX_WIND_mean.png ${Adeck}.total.AMAX_WIND-BMAX_WIND_mean.png
# Rscript  /lfs2/projects/dtc-hurr/MET/MET_releases/met-5.0/scripts/Rscripts/plot_tcmpr.R -title "max wind: absolute error"       -dep "ABS(AMAX_WIND-BMAX_WIND)" -lookin out_total_tcmpr.tcst  -plot "MEAN"
# mv ABS_AMAX_WIND-BMAX_WIND_mean.png ${Adeck}.total.ABS_AMAX_WIND-BMAX_WIND_mean.png
# Rscript  /lfs2/projects/dtc-hurr/MET/MET_releases/met-5.0/scripts/Rscripts/plot_tcmpr.R -title "max wind: absolute error rank"       -dep "ABS(AMAX_WIND-BMAX_WIND)" -lookin out_total_tcmpr.tcst  -plot "RANK"
# mv ABS_AMAX_WIND-BMAX_WIND_rank.png ${Adeck}.total.ABS_AMAX_WIND-BMAX_WIND_rank.png
# Rscript  /lfs2/projects/dtc-hurr/MET/MET_releases/met-5.0/scripts/Rscripts/plot_tcmpr.R -title "track error"       -dep "TK_ERR" -lookin out_total_tcmpr.tcst  -plot "MEAN"
# mv TK_ERR_mean.png ${Adeck}.total.TK_ERR_mean.png
# Rscript  /lfs2/projects/dtc-hurr/MET/MET_releases/met-5.0/scripts/Rscripts/plot_tcmpr.R -title "along track error"       -dep "ALTK_ERR" -lookin out_total_tcmpr.tcst  -plot "MEAN"
# mv ALTK_ERR_mean.png ${Adeck}.total.ALTK_ERR_mean.png
# Rscript  /lfs2/projects/dtc-hurr/MET/MET_releases/met-5.0/scripts/Rscripts/plot_tcmpr.R -title "cross track error"       -dep "CRTK_ERR" -lookin out_total_tcmpr.tcst  -plot "MEAN"
# mv CRTK_ERR_mean.png ${Adeck}.total.CRTK_ERR_mean.png
# Rscript  /lfs2/projects/dtc-hurr/MET/MET_releases/met-5.0/scripts/Rscripts/plot_tcmpr.R -title "track error rank"       -dep "TK_ERR" -lookin out_total_tcmpr.tcst  -plot "RANK"
# mv TK_ERR_rank.png ${Adeck}.total.TK_ERR_rank.png

















