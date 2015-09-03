load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;purpose:   
;write observed/hdrt/hdgf/hdrf  mid-nest synthetic satellite images to one single netcdf file
;hdrt grid comes from the UPP generated m-grid
;obs used this m-grid too.
;hdrf and hdgf used their own m-grid.

print("lat is "+lat+" lon is "+lon)
; lat and lon must be used; they are from best tracks.
gridfile1=getenv("gridfile1")
gridfile1_mid=getenv("gridfile1_mid")
gridfile2=getenv("gridfile2")
gridfile3=getenv("gridfile3")
gridfile4=getenv("gridfile4")
gridfile5=getenv("gridfile5")
case_info=getenv("case_info")


 satellite_hdrt= addfile(gridfile1,"r")
 satellite_hdrt_grid=addfile(gridfile1_mid,"r")
 satellite_hdrf= addfile(gridfile2,"r")
 satellite_hdgf= addfile(gridfile3,"r")
 satellite_obs= addfile(gridfile4,"r")
; satellite_obs_vp= addfile(gridfile5,"r")



;process hdrt channel 2
 
   sat_hdrt=satellite_hdrt->IMGR_tb_b04
   lat2d = satellite_hdrt->lat
   lon2d = satellite_hdrt->lon
   sat_hdrt@lon2d=lon2d  
   sat_hdrt@lat2d=lat2d
   sat_hdrt=where(isnan_ieee(sat_hdrt) .eq. True, -999., sat_hdrt)

  hdrt_vnames=getfilevarnames(satellite_hdrt_grid)
  if (hdrt_vnames(1).eq."SBT122_P0_L8_GLL0") then 
    sat_hdrt_grid=satellite_hdrt_grid->SBT124_P0_L8_GLL0
  else
    sat_hdrt_grid=satellite_hdrt_grid->SBT114_P0_L8_GLL0
  end if

  lat_0_hdrt=satellite_hdrt_grid->lat_0
  lon_0_hdrt=satellite_hdrt_grid->lon_0
  

  hdrt_lat_size=dimsizes(lat_0_hdrt)
  hdrt_lon_size=dimsizes(lon_0_hdrt)


  sat_hdrt_grid@lon2d=conform_dims((/hdrt_lat_size,hdrt_lon_size/),lon_0_hdrt,1)
  sat_hdrt_grid@lat2d=conform_dims((/hdrt_lat_size,hdrt_lon_size/),lat_0_hdrt,0)

  skip=3

;process obs

  sat_obs=satellite_obs->calibratedData
  lat_0=satellite_obs->lat
  lon_0=satellite_obs->lon
  sat_obs@lon2d=conform_dims((/275,800/),lon_0,1)
  sat_obs@lat2d=conform_dims((/275,800/),lat_0,0)
  sat_obs=where(isnan_ieee(sat_obs) .eq. True, 99999., sat_obs)

  obs_lat=lat_0_hdrt-(lat-dim_median(lat_0_hdrt))
  obs_lon=lon_0_hdrt-(lon-dim_median(lon_0_hdrt)+360)




  regrid_obs=rcm2rgrid(sat_obs@lat2d ,sat_obs@lon2d,sat_obs(0,:,:),obs_lat(::-skip),obs_lon(::skip)-360,1)
;  regrid_obs_vp=rcm2rgrid(sat_obs@lat2d,sat_obs@lon2d,sat_obs_vp(0,:,:),merge_lat,merge_lon,1)

  regrid_hdrt=rcm2rgrid(sat_hdrt@lat2d,sat_hdrt@lon2d,sat_hdrt,lat_0_hdrt(::-skip),lon_0_hdrt(::skip)-360,1) 

;process hdrf channel 2 

  hdrf_vnames=getfilevarnames(satellite_hdrf)
  if (hdrf_vnames(1).eq."SBT122_P0_L8_GLL0") then 
    sat_hdrf=satellite_hdrf->SBT124_P0_L8_GLL0
  else
    sat_hdrf=satellite_hdrf->SBT114_P0_L8_GLL0
  end if

  lat_0_hdrf=satellite_hdrf->lat_0
  lon_0_hdrf=satellite_hdrf->lon_0

  hdxf_lat_size=dimsizes(lat_0_hdrf)
  hdxf_lon_size=dimsizes(lon_0_hdrf)



  sat_hdrf@lon2d=conform_dims((/hdxf_lat_size,hdxf_lon_size/),lon_0_hdrf,1)
  sat_hdrf@lat2d=conform_dims((/hdxf_lat_size,hdxf_lon_size/),lat_0_hdrf,0)

;  regrid_hdrt=rcm2rgrid(sat_hdrt@lat2d,sat_hdrt@lon2d,sat_hdrt,lat_0_hdrt(::-skip),lon_0_hdrt(::skip)-360,1) 
;  regrid_hdrf=rcm2rgrid(sat_hdrf@lat2d,sat_hdrf@lon2d,sat_hdrf,lat_0_hdrf(::skip),lon_0_hdrf(::skip)-360,1) 
  regrid_hdrf=linint2(lon_0_hdrf(::skip),lat_0_hdrf(::-skip),sat_hdrf(::-skip,::skip),False,lon_0_hdrf(::skip),lat_0_hdrf(::-skip),0)

wks=gsn_open_wks("x11","test")
;plot=gsn_csm_xy(wks,fspan(0,dimsizes(obs_lon),dimsizes(obs_lon)),obs_lon-360,True)
;sbaoplot=gsn_csm_contour(wks, regrid_hdrt, True)
;sbaoplot=gsn_csm_contour(wks, sat_hdrf@lat2d, True)
;sbaoplot=gsn_csm_contour(wks, sat_hdrf@lon2d, True)
;sbaoplot=gsn_csm_contour(wks, sat_hdrf, True)
;sbaoplot=gsn_csm_xy(wks,fspan(0,dimsizes(lat_0_hdrf),dimsizes(lat_0_hdrf)),lat_0_hdrf,True)
;sbaoplot=gsn_csm_xy(wks,fspan(0,dimsizes(lon_0_hdrf),dimsizes(lon_0_hdrf)),lon_0_hdrf-360,True)


;  if (hdrf_vnames(2).eq."SBT123_P0_L8_GLL0") then 
;    sat_hdrf_vp=satellite_hdrf->SBT123_P0_L8_GLL0
;  else
;    sat_hdrf_vp=satellite_hdrf->SBT113_P0_L8_GLL0
;  end if
;  sat_hdrf_vp@lon2d=conform_dims((/hdxf_lat_size,hdxf_lon_size/),lon_0_hdrf,1)
;  sat_hdrf_vp@lat2d=conform_dims((/hdxf_lat_size,hdxf_lon_size/),lat_0_hdrf,0)



;process hdgf channel 2

  if (hdrf_vnames(1).eq."SBT122_P0_L8_GLL0") then
    sat_hdgf=satellite_hdgf->SBT124_P0_L8_GLL0
  else
    sat_hdgf=satellite_hdgf->SBT114_P0_L8_GLL0
  end if
  lat_0_hdgf=satellite_hdgf->lat_0
  lon_0_hdgf=satellite_hdgf->lon_0
  sat_hdgf@lon2d=conform_dims((/hdxf_lat_size,hdxf_lon_size/),lon_0_hdgf,1)
  sat_hdgf@lat2d=conform_dims((/hdxf_lat_size,hdxf_lon_size/),lat_0_hdgf,0)

  regrid_hdgf=linint2(lon_0_hdgf(::skip),lat_0_hdgf(::-skip),sat_hdgf(::-skip,::skip),False,lon_0_hdgf(::skip),lat_0_hdgf(::-skip),0)

;  if (hdrf_vnames(2).eq."SBT123_P0_L8_GLL0") then
;    sat_hdgf_vp=satellite_hdgf->SBT123_P0_L8_GLL0
;  else
;    sat_hdgf_vp=satellite_hdgf->SBT113_P0_L8_GLL0
;  end if

;  sat_hdgf_vp@lon2d=conform_dims((/hdxf_lat_size,hdxf_lon_size/),lon_0_hdgf,1)
;  sat_hdgf_vp@lat2d=conform_dims((/hdxf_lat_size,hdxf_lon_size/),lat_0_hdgf,0)

;  hdgf_min_lat=min(sat_hdgf@lat2d)
;  hdgf_max_lat=max(sat_hdgf@lat2d)
;  hdgf_min_lon=min(sat_hdgf@lon2d)
;  hdgf_max_lon=max(sat_hdgf@lon2d)
;
;; what are the boundary
;  minlat=max((/hdrt_min_lat,hdrf_min_lat,obs_min_lat/))	
;  matlat=min((/hdrt_max_lat,hdrf_max_lat,obs_max_lat/))
;  minlon=max((/hdrt_min_lon,hdrf_min_lon-360,obs_min_lon/))
;  maxlon=min((/hdrt_max_lon,hdrf_max_lon-360,obs_max_lon/))
;  merge_lat=fspan(minlat+0,matlat-0,300)
;  merge_lon=fspan(minlon+0,maxlon-0,300)

; project all hdrt hdrf and obs to same grid
;  skip=1
;;  regrid_obs=rcm2rgrid(sat_obs@lat2d,sat_obs@lon2d,sat_obs(0,:,:),merge_lat,merge_lon,1)
;;  regrid_obs_vp=rcm2rgrid(sat_obs@lat2d,sat_obs@lon2d,sat_obs_vp(0,:,:),merge_lat,merge_lon,1)
;
;;  regrid_hdrt=rcm2rgrid(sat_hdrt@lat2d,sat_hdrt@lon2d,sat_hdrt,merge_lat,merge_lon,1) 
;;  regrid_hdrt=linint2(lon_0_hdrt(::skip),lat_0_hdrt(::-skip),sat_hdrt(::-skip,::skip),False,merge_lon+360,merge_lat,0)
;  regrid_hdrf=linint2(lon_0_hdrf(::skip),lat_0_hdrf(::-skip),sat_hdrf(::-skip,::skip),False,merge_lon+360,merge_lat,0)
;  regrid_hdgf=linint2(lon_0_hdgf(::skip),lat_0_hdgf(::-skip),sat_hdgf(::-skip,::skip),False,merge_lon+360,merge_lat,0)
 
;  regrid_hdrt_vp=rcm2rgrid(sat_hdrt@lat2d,sat_hdrt@lon2d,sat_hdrt_vp,merge_lat,merge_lon,1) 
;  regrid_hdrt_vp=linint2(lon_0_hdrt(::skip) ,lat_0_hdrt(::-skip),sat_hdrt_vp(::-skip,::skip),False,merge_lon+360,merge_lat,0)
;  regrid_hdrf_vp=linint2(lon_0_hdrf(::skip) ,lat_0_hdrf(::-skip),sat_hdrf_vp(::-skip,::skip),False,merge_lon+360,merge_lat,0)
;  regrid_hdgf_vp=linint2(lon_0_hdgf(::skip) ,lat_0_hdgf(::-skip),sat_hdgf_vp(::-skip,::skip),False,merge_lon+360,merge_lat,0)
 
 

;; make sure apple-to-apple comparison: remove points on all outputs from they are NAN on any one output. 
;regrid_obs=where(regrid_hdrf.eq.1.e+20.or.regrid_hdrt.eq.-999.or.regrid_hdgf.eq.1.e+20, 99999., regrid_obs)
;;regrid_obs_vp=where(regrid_hdrf.eq.1.e+20.or.regrid_hdrt.eq.-999.or.regrid_hdgf.eq.1.e+20, 99999., regrid_obs_vp)
;
;regrid_hdrt=where(regrid_hdrf.eq.1.e+20.or.regrid_hdgf.eq.1.e+20.or.regrid_obs.eq.99999, -999., regrid_hdrt)
;;regrid_hdrt_vp=where(regrid_hdrf.eq.1.e+20.or.regrid_hdgf.eq.1.e+20.or.regrid_obs.eq.99999, -999., regrid_hdrt_vp)
;
;regrid_hdgf=where(regrid_hdrf.eq.1.e+20.or.regrid_hdrt.eq.-999.or.regrid_obs.eq.99999, 1.e+20, regrid_hdgf)
;;regrid_hdgf_vp=where(regrid_hdrf.eq.1.e+20.or.regrid_hdrt.eq.-999.or.regrid_obs.eq.99999, 1.e+20, regrid_hdgf_vp)
;
;regrid_hdrf=where(regrid_hdrt.eq.-999.or.regrid_hdgf.eq.1.e+20.or.regrid_obs.eq.99999, 1.e+20, regrid_hdrf)
;;regrid_hdrf_vp=where(regrid_hdrt.eq.-999.or.regrid_hdgf.eq.1.e+20.or.regrid_obs.eq.99999, 1.e+20, regrid_hdrf_vp)

output_file_name=case_info+"OBS_RT_RF_GF.middle.nc"
system("/bin/rm -f "+output_file_name)   ; remove any pre-existing file
ncdf = addfile(output_file_name ,"c")  ; open output netCDF file
regrid_obs!0="obs_lat"
regrid_obs!1="obs_lon"
regrid_obs&obs_lat=obs_lat(::-skip)
regrid_obs&obs_lon=obs_lon(::skip)

;regrid_rt!0="merge_lat"
;regrid_rt!1="merge_lon"
;regrid_rt&merge_lat=merge_lat
;regrid_rt&merge_lon=merge_lon
;
;regrid_obs!0="merge_lat"
;regrid_obs!1="merge_lon"
;regrid_obs&merge_lat=merge_lat
;regrid_obs&merge_lon=merge_lon
;
;regrid_obs!0="merge_lat"
;regrid_obs!1="merge_lon"
;regrid_obs&merge_lat=merge_lat
;regrid_obs&merge_lon=merge_lon

 copy_VarCoords(regrid_obs,regrid_hdgf)
 copy_VarCoords(regrid_obs,regrid_hdrf)
 copy_VarCoords(regrid_obs,regrid_hdrt)

ncdf->OBS=regrid_obs
ncdf->RT=regrid_hdrt
ncdf->RF=regrid_hdrf
ncdf->GF=regrid_hdgf

exit
;  asciiwrite ("obs_ir_"+case_info+".ascii" , regrid_obs)
;  asciiwrite ("obs_vp_"+case_info+".ascii" , regrid_obs_vp)
;  asciiwrite ("hdrt_ir_"+case_info+".ascii" , regrid_hdrt)
;  asciiwrite ("hdrt_vp_"+case_info+".ascii" , regrid_hdrt_vp)
;  asciiwrite ("hdgf_ir_"+case_info+".ascii" , regrid_hdgf)
;  asciiwrite ("hdgf_vp_"+case_info+".ascii" , regrid_hdgf_vp)
;  asciiwrite ("hdrf_ir_"+case_info+".ascii" , regrid_hdrf)
;  asciiwrite ("hdrf_vp_"+case_info+".ascii" , regrid_hdrf_vp)
;

;to do 2d histogram; use matlab script 
;load ascii_regrid_obs and ascii_regrid_obs_vp
;xx=ascii_regrid_obs_vp(find(ascii_regrid_obs_vp < 1000))
;yy=ascii_regrid_obs(find(ascii_regrid_obs < 1000))
;ndhist(yy,xx-yy)


;:obsolote.
;  regrid_obs=where(regrid_hdrf.eq.1.e+20, 99999., regrid_obs)
;  regrid_hdrt=where(regrid_hdrf.eq.1.e+20, -999., regrid_hdrt)
;  regrid_hdgf=where(regrid_hdrf.eq.1.e+20, 1.e+20, regrid_hdgf)
;
;  regrid_obs=where(regrid_hdrt.eq.-999, 99999., regrid_obs)
;  regrid_hdgf=where(regrid_hdrt.eq.-999, 1.e+20, regrid_hdgf)
;  regrid_hdrf=where(regrid_hdrt.eq.-999, 1.e+20, regrid_hdrf)
;
;  regrid_obs=where(regrid_hdgf.eq.1.e+20, 99999., regrid_obs)
;  regrid_hdrt=where(regrid_hdgf.eq.1.e+20, -999., regrid_hdrt)
;  regrid_hdrf=where(regrid_hdgf.eq.1.e+20, 1.e+20, regrid_hdrf)
;
;  regrid_hdrf=where(regrid_obs.eq.99999, 1.e+20, regrid_hdrf)
;  regrid_hdrt=where(regrid_obs.eq.99999, -999., regrid_hdrt)
;  regrid_hdgf=where(regrid_obs.eq.99999, 1.e+20, regrid_hdgf)


;calculate 6.5-10.7 area
 
   diff_hdrt=regrid_hdrt_vp-regrid_hdrt
   diff_hdrt=where(diff_hdrt.le.-10.0.and.diff_hdrt.ge.-30.0,1,0)
   area_diff_hdrt=sum(diff_hdrt)
 
   diff_hdrf=regrid_hdrf_vp-regrid_hdrf
   diff_hdrf=where(diff_hdrf.le.-10.0.and.diff_hdrf.ge.-30.0,1,0)
   area_diff_hdrf=sum(diff_hdrf)

   diff_hdgf=regrid_hdgf_vp-regrid_hdgf
   diff_hdgf=where(diff_hdgf.le.-10.0.and.diff_hdgf.ge.-30.0,1,0)
   area_diff_hdgf=sum(diff_hdgf)
 
   diff_obs=regrid_obs_vp-regrid_obs
   diff_obs=where(diff_obs.le.-10.0.and.diff_obs.ge.-30.0,1,0)
   area_diff_obs=sum(diff_obs)
;sbao print("area diffs")
;sbao print(area_diff_hdrt)
;sbao print(area_diff_hdrf)
;sbao print(area_diff_hdgf)
;sbao print(area_diff_obs)
 area_diff=(/area_diff_obs,area_diff_hdrt,area_diff_hdrf,area_diff_hdgf/)
 asciiwrite ("area_diff_"+case_info+".ascii" , area_diff)

;  data=(/obs_pdf,hdrt_pdf,hdrf_pdf, hdgf_pdf/)

;
;

;calculate RMSE MAE and bias

;  rmse_hdrt_hdrf=wgt_arearmse(regrid_hdrt, regrid_hdrf, 1.0, 1.0, 0) 
  rmse_hdrt_obs=wgt_arearmse(regrid_hdrt, regrid_obs, 1.0, 1.0, 0) 
  rmse_hdrf_obs=wgt_arearmse(regrid_hdrf, regrid_obs, 1.0, 1.0, 0) 
  rmse_hdgf_obs=wgt_arearmse(regrid_hdgf, regrid_obs, 1.0, 1.0, 0) 


;  mae_hdrt_hdrf=sum(abs(regrid_hdrt-regrid_hdrf))/(dimsizes(merge_lat)*dimsizes(merge_lon))
  mae_hdrt_obs=sum(abs(regrid_hdrt-regrid_obs))/(dimsizes(merge_lat)*dimsizes(merge_lon))
  mae_hdrf_obs=sum(abs(regrid_hdrf-regrid_obs))/(dimsizes(merge_lat)*dimsizes(merge_lon))
  mae_hdgf_obs=sum(abs(regrid_hdgf-regrid_obs))/(dimsizes(merge_lat)*dimsizes(merge_lon))
;print(rmse_hdrt_hdrf)
;sbaoprint(rmse_hdrt_obs)
;sbaoprint(rmse_hdrf_obs)
;sbaoprint(rmse_hdgf_obs)
;sbao
;sbao;print(mae_hdrt_hdrf)
;sbaoprint(mae_hdrt_obs)
;sbaoprint(mae_hdrf_obs)
;sbaoprint(mae_hdgf_obs)

rmse_mae=(/rmse_hdrt_obs,rmse_hdrf_obs,rmse_hdgf_obs,mae_hdrt_obs,mae_hdrf_obs,mae_hdgf_obs/)
asciiwrite ("rmse_mae_"+case_info+".ascii" , rmse_mae)

;calculate 

 
;  regrid_obs=where(ismissing(regrid_hdrt).eq.True,99999,regrid_obs)
;  regrid_hdrf=where(ismissing(regrid_hdrt).eq.True,1.0e20,regrid_hdrf)


;sbao   regrid_obs=regrid_obs(::-1,::-1)
; first calculate and plot  pdf
   option=True
   option@bin_min=180
   option@bin_max=310
   obs_pdf =  pdfx(regrid_obs, 50, option)   ; default is 25
   hdrt_pdf = pdfx(regrid_hdrt,50, option)   ; default is 25
   hdrf_pdf = pdfx(regrid_hdrf,50, option)   ; default is 25
   hdgf_pdf = pdfx(regrid_hdgf,50, option)   ; default is 25

;   hdrf_pdf=(hdrt_pdf+hdrf_pdf)/2.0
;sbao  print(obs_pdf)
;sbao  print(hdrt_pdf)
;sbao  print(hdrf_pdf)
;sbao  print(hdgf_pdf)

  data=(/obs_pdf,hdrt_pdf,hdrf_pdf, hdgf_pdf/)
  asciiwrite ("pdf_"+case_info+".ascii" , data)
  printVarSummary(data)

;  wks1  = gsn_open_wks ("png","pdf_goes13")
;  res_pdf  = True
;  res_pdf@xyLineColors      = (/"blue","red","green","black"/) 
;  res_pdf@gsnCenterString = "default 25 bins"
;  plot = gsn_csm_xy (wks1, hdrf_pdf@bin_center,data, res_pdf)
   
 ; second calculate FSS


;sbao print(dimsizes(merge_lat)+" "+dimsizes(merge_lon))

 windows=20
 
 fss_hdrt=new((/dimsizes(merge_lat)-2*windows,dimsizes(merge_lon)-2*windows/),float)
 fss_hdrf=new((/dimsizes(merge_lat)-2*windows,dimsizes(merge_lon)-2*windows/),float)
 fss_hdgf=new((/dimsizes(merge_lat)-2*windows,dimsizes(merge_lon)-2*windows/),float)
 fss_obs =new((/dimsizes(merge_lat)-2*windows,dimsizes(merge_lon)-2*windows/),float)
 fss_hdrt=0.0
 fss_hdrf=0.0
 fss_hdgf=0.0
 fss_obs=0.0
 
 
 unit_hdrt=where(regrid_hdrt.le.270.0,1,0)
 unit_obs=where(regrid_obs.le.270.0,1,0)
 unit_hdrf=where(regrid_hdrf.le.270.0, 1, 0)
 unit_hdgf=where(regrid_hdgf.le.270.0, 1, 0)
 
;sbao print("sum_unit_hdrt is "+sum(unit_hdrt))
;sbao print("sum_unit_hdrf is "+sum(unit_hdrf))
;sbao print("sum_unit_obs is "+sum(unit_obs))
;sbao print("sum_unit_hdgf is "+sum(unit_hdgf))
    
 i=0
 
 do while(i.le.dimsizes(merge_lat)-2*windows-1)
 j=0
   do while(j.le.dimsizes(merge_lon)-2*windows-1)
 
 
     fss_hdrt(i,j)=sum(unit_hdrt(i:i+2*windows,j:j+2*windows))/(1+2*windows)^2
     fss_obs(i,j)=sum(unit_obs(i:i+2*windows,j:j+2*windows))/(1+2*windows)^2
     fss_hdrf(i,j)=sum(unit_hdrf(i:i+2*windows,j:j+2*windows))/(1+2*windows)^2
     fss_hdgf(i,j)=sum(unit_hdgf(i:i+2*windows,j:j+2*windows))/(1+2*windows)^2
 
     j=j+1
   end do
   i=i+1
 end do
    
 
 FSS_hdrt=1-(sum((fss_obs-fss_hdrt)^2))/((sum(fss_obs^2)+sum(fss_hdrt^2)))
 FSS_hdrf=1-(sum((fss_obs-fss_hdrf)^2))/((sum(fss_obs^2)+sum(fss_hdrf^2)))
 FSS_hdgf=1-(sum((fss_obs-fss_hdgf)^2))/((sum(fss_obs^2)+sum(fss_hdgf^2)))

  fss_data=(/FSS_hdrt,FSS_hdrf,FSS_hdgf/)
  asciiwrite ("fss_"+case_info+".ascii" , fss_data)



 
;---Start the graphics
  wks = gsn_open_wks("png" ,"satellite")
  gsn_define_colormap(wks,"rainbow")

;---Set some resources
  res              = True
  res@gsnMaximize  = True               ; Maximize size of plot
  res@gsnDraw      = False
  res@gsnFrame     = False
  res@sfXArray        = merge_lon
  res@sfYArray        = merge_lat
  res@gsnAddCyclic    = False
  res@cnFillOn        = True   
  res@cnFillMode = "RasterFill"
  res@cnRasterSmoothingOn = True


  res@cnLinesOn       = False
   res@cnLevelSelectionMode        = "ManualLevels"   ; set manual contour levels
;   res@cnMinLevelValF              = min(regrid_hdrt) ;difftemp_min                ; set min contour level
;   res@cnMaxLevelValF              = max(regrid_hdrt) ; difftemp_max               ; set max contour level
   res@cnMinLevelValF              = 180  ;difftemp_min                ; set min contour level
   res@cnMaxLevelValF              = 310 ; difftemp_max               ; set max contour level
   res@cnLevelSpacingF             = 5                ; contour spacing
  res@lbOrientation   = "vertical"
;  res@mpDataBaseVersion    = "HighRes"

  resm=True
  resm@gsnDraw=False
;  resm@mpDataBaseVersion = "MediumRes"
   res@mpMinLatF       = min(merge_lat)
   res@mpMaxLatF       = max(merge_lat)
   res@mpMinLonF       = min(merge_lon)
   res@mpMaxLonF       = max(merge_lon)

;     map=gsn_csm_map(wks,resm)
;     delete(plot)
     plot=new(8,graphic)
     res@tiMainString="OBS"
     plot(0)=gsn_csm_contour_map(wks, regrid_obs(:,:),res)
     res@tiMainString="HDRT"
     plot(1)=gsn_csm_contour_map(wks, regrid_hdrt(:,:), res)
     res@tiMainString="HDRF"
     plot(2)=gsn_csm_contour_map(wks, regrid_hdrf(:,:), res)
     res@tiMainString="HDGF"
     plot(3)=gsn_csm_contour_map(wks, regrid_hdgf(:,:), res)
     res@tiMainString="OBS_VP"
     plot(4)=gsn_csm_contour_map(wks, regrid_obs_vp(:,:),res)
     res@tiMainString="HDRT_VP"
     plot(5)=gsn_csm_contour_map(wks, regrid_hdrt_vp(:,:), res)
     res@tiMainString="HDRF_VP"
     plot(6)=gsn_csm_contour_map(wks, regrid_hdrf_vp(:,:), res)
     res@tiMainString="HDGF_VP"
     plot(7)=gsn_csm_contour_map(wks, regrid_hdgf_vp(:,:), res)

     resP=True
     resP@gsnPanelYWhiteSpacePercent = 5
     resP@gsnPanelXWhiteSpacePercent = 5
     resP@txString   = case_info
     gsn_panel(wks,plot,(/4,2/),resP)
exit
end

