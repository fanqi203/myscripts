load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
   
; purpose: given a netcdf of hdrt hdrf hdgf and obs satellite images, 
;calculate pdf and fss and write results into a netcdf 

;f_name="2012070706_04e_2012071012OBS_RT_RF_GF.nc"
;f=addfile("2014_OBS_RT_RF_GF.nc","r")
;open image files
f=addfile(f_name,"r")

HDRT=f->RT
OBS=f->OBS
HDRF=f->RF
HDGF=f->GF

hdrt=HDRT(:,:)
hdrf=HDRF(:,:)
hdgf=HDGF(:,:)
obs=OBS(:,:)
hdrt_vnames=getfilevarnames(f)
print(hdrt_vnames)

if (hdrt_vnames(1).eq."obs_lat") then
obs_lat=f->obs_lat
obs_lon=f->obs_lon
else
obs_lat=f->merge_lat
obs_lon=f->merge_lon
end if


;calculate fss

;fss calculation from 230 to 310 K
min_threshold=230
max_threshold=310
d_threshold=20
max_Nthreshold=(max_threshold-min_threshold)/d_threshold+1
;fss window length from 0 (single pixel) to 6
min_windows=0
max_windows=6
d_windows=1
max_Nwindows=(max_windows-min_windows)/d_windows+1


fss_data=new((/3,max_Nwindows,max_Nthreshold/),float)

print(max_Nwindows+" "+max_Nthreshold)
Nthreshold=0
do while (Nthreshold .lt. max_Nthreshold)

threshold=min_threshold+Nthreshold*d_threshold

 Nwindows=0
 do while (Nwindows .lt. max_Nwindows)
  
 windows=Nwindows*d_windows

 print("windows and threshold "+Nwindows+" "+Nthreshold)

 fss_hdrt=new((/dimsizes(obs_lat)-2*windows,dimsizes(obs_lon)-2*windows/),float)
 fss_hdrf=new((/dimsizes(obs_lat)-2*windows,dimsizes(obs_lon)-2*windows/),float)
 fss_hdgf=new((/dimsizes(obs_lat)-2*windows,dimsizes(obs_lon)-2*windows/),float)
 fss_obs =new((/dimsizes(obs_lat)-2*windows,dimsizes(obs_lon)-2*windows/),float)

 fss_hdrt=0.0
 fss_hdrf=0.0
 fss_hdgf=0.0
 fss_obs=0.0
 
 unit_hdrt=where(hdrt.le.threshold.and.hdrt.ge.threshold-d_threshold,1,0)
 unit_obs=where(obs.le.threshold.and.obs.ge.threshold-d_threshold,1,0)
 unit_hdrf=where(hdrf.le.threshold.and.hdrf.ge.threshold-d_threshold, 1, 0)
 unit_hdgf=where(hdgf.le.threshold.and.hdgf.ge.threshold-d_threshold, 1, 0)
     
 i=0
 do while(i.le.dimsizes(obs_lat)-2*windows-1)
 j=0
   do while(j.le.dimsizes(obs_lon)-2*windows-1)
     fss_hdrt(i,j)=sum(unit_hdrt(i:i+2*windows,j:j+2*windows))/(1+2*windows)^2
     fss_obs(i,j)=sum(unit_obs(i:i+2*windows,j:j+2*windows))/(1+2*windows)^2
     fss_hdrf(i,j)=sum(unit_hdrf(i:i+2*windows,j:j+2*windows))/(1+2*windows)^2
     fss_hdgf(i,j)=sum(unit_hdgf(i:i+2*windows,j:j+2*windows))/(1+2*windows)^2 
     j=j+1
   end do
   i=i+1
 end do
;plot a demonstrative fss field 
;if (Nwindows .eq. 5)
if (Nwindows .eq. 9999)
print("test "+threshold)
wks=gsn_open_wks("png", "test_"+threshold+"_Nw=5")
res=True
res@gsnDraw=False
res@gsnFrame=False
res@cnFillOn=True
res@tiMainString    = "T < "+threshold+" and scale count= "+Nwindows 
plot=new(4,graphic)
plot(0)=gsn_csm_contour(wks, fss_obs, res)
plot(1)=gsn_csm_contour(wks, fss_hdrt, res)
plot(2)=gsn_csm_contour(wks, fss_hdrf, res)
plot(3)=gsn_csm_contour(wks, fss_hdgf, res)
res_p=True
res_p@gsnFrame=False
gsn_panel(wks,plot,(/2,2/), res_p)
frame(wks)
end if

 FSS_hdrt=1-(sum((fss_obs-fss_hdrt)^2))/((sum(fss_obs^2)+sum(fss_hdrt^2)))
 FSS_hdrf=1-(sum((fss_obs-fss_hdrf)^2))/((sum(fss_obs^2)+sum(fss_hdrf^2)))
 FSS_hdgf=1-(sum((fss_obs-fss_hdgf)^2))/((sum(fss_obs^2)+sum(fss_hdgf^2)))

   fss_data(0,Nwindows,Nthreshold)=FSS_hdrt  
   fss_data(1,Nwindows,Nthreshold)=FSS_hdrf
   fss_data(2,Nwindows,Nthreshold)=FSS_hdgf

 delete([/fss_obs,fss_hdrt,fss_hdrf,fss_hdgf/])
 Nwindows=Nwindows+1
end do
Nthreshold=Nthreshold+1
end do 
; save data to netcdf files

 output_file_name=f_name+".width1to6_thresholdrange.fss.nc"
 system("/bin/rm -f "+output_file_name)
 ncdf = addfile(output_file_name ,"c")  ; open output netCDF file
 filedimdef(ncdf,"time",-1,True)
  fss_data!1="scale"
  fss_data&scale=fspan(min_windows,max_windows,Nwindows)
  fss_data!2="threshhold"
  fss_data&threshhold=fspan(min_threshold, max_threshold, Nthreshold)
 
  ncdf->fss_data = fss_data


; calculat pdf
   option=True
   option@bin_min=180
   option@bin_max=310
   obs_pdf =  pdfx(obs, 50, option)   ; default is 25
   hdrt_pdf = pdfx(hdrt,50, option)   ; default is 25
   hdrf_pdf = pdfx(hdrf,50, option)   ; default is 25
   hdgf_pdf = pdfx(hdgf,50, option)   ; default is 25
 obs_pdf!0="bin"
 obs_pdf&bin=fspan(1,50,50)
 copy_VarCoords(obs_pdf,hdrt_pdf)
 copy_VarCoords(obs_pdf,hdrf_pdf)
 copy_VarCoords(obs_pdf,hdgf_pdf)
 ncdf->obs_pdf=obs_pdf
 ncdf->hdrt_pdf=hdrt_pdf
 ncdf->hdrf_pdf=hdrf_pdf
 ncdf->hdgf_pdf=hdgf_pdf

  exit
