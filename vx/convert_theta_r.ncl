load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"   
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin
; fields to plot

; radial profile:
; 850 hpa tangential wind profile 
; mslp 
;
; cross section:
; hydrometeors
; total condensate 
;
; and the differences 
;
;  test_file=addfile("/lfs2/projects/dtc-hurr/Shaowu.Bao/HDRT/pytmp/HDRT/com//2011082218/09L/upp_workdir/synthSat_2011082700_f102.nc","r")
; save data to netcdf files


  test_file_name=getenv("file_name")
  output_file_name=getenv("output_name")
  test_file=addfile(test_file_name, "r")

  skip=6

  hdrt_vnames=getfilevarnames(test_file) ; vars=getvarnam
  print(hdrt_vnames)

  hdrt_u3d=test_file->UGRD_P0_L100_GLL0  
  hdrt_v3d=test_file->VGRD_P0_L100_GLL0

  hdrt_u=hdrt_u3d(39,:,:)
  hdrt_v=hdrt_v3d(39,:,:)
  hdrt_w=sqrt(hdrt_u3d(39,:,:)^2+hdrt_v3d(39,:,:))



  hdrt_u=where(isnan_ieee(hdrt_u) .eq. True, 1.e+20, hdrt_u) 
  hdrt_v=where(isnan_ieee(hdrt_v) .eq. True, 1.e+20, hdrt_v)
  hdrt_w=where(isnan_ieee(hdrt_w) .eq. True, 1.e+20, hdrt_w)

  lat_0_hdrt=test_file->lat_0
  lon_0_hdrt=test_file->lon_0

  mslp = test_file->PRMSL_P0_L101_GLL0
  xMin = min(mslp)
 
  x1D = ndtooned(mslp)     ; only do this once
  indMin = ind_resolve(ind(x1D.eq.xMin),dimsizes(mslp))  ; locations of min
  delete (x1D)
  xlat=lat_0_hdrt(indMin(0,0))
  xlon=lon_0_hdrt(indMin(0,1))

  Tcon=test_file->TCOND_P0_L100_GLL0
  printVarSummary(Tcon)

  Temp=test_file->TMP_P0_L100_GLL0
  Qv=test_file->SPFH_P0_L100_GLL0  
  TV  = (1 + 0.61*Qv) * Temp
  copy_VarCoords(Temp, TV)

  ice=test_file->CICE_P0_L100_GLL0
  cld=test_file->CLWMR_P0_L100_GLL0
  rain=test_file->RWMR_P0_L100_GLL0
  snow=test_file->SNMR_P0_L100_GLL0


; _c_: /901,1101/ _m_ /401,501 _p_ 361 441  
  lon2d=conform_dims((/401,501/),lon_0_hdrt,1)
  lat2d=conform_dims((/401,501/),lat_0_hdrt,0)

  dimsat=dimsizes(lat2d)

  
  reflat=(/xlat, xlat/)
  reflon=(/xlon, xlon+10.0/)
  angle_z=new((/dimsat(0),dimsat(1)/),float)
  r_z=new((/dimsat(0),dimsat(1)/),float)

  angle_p=new((/101,37/),float)
  r_p=new((/101,37/),float)

  j=0
  do while (j.lt.101)
  angle_p(j,:)=fspan(0.,360.,37)
  j=j+1
  end do
  j=0
  do while (j.lt.37)
  r_p(:,j)=fspan(0.,1000.,101)
  j=j+1
  end do

;  angle_p=new((/101,37/), float)
;  r_p=new((/101,37/),float)

  j=0
  do while (j .le. dimsat(0)-1)
    i=0
    do while (i .le. dimsat(1)-1)
      lat=(/reflat(0), reflat(1), lat2d(j,i)/)
      lon=(/reflon(0), reflon(1), lon2d(j,i)/)
      angle_z(j,i) = gc_dangle(lat, lon)
      r_z(j,i)=gc_latlon(reflat(0),reflon(0),lat2d(j,i),lon2d(j,i),2,4)
      i=i+1
    end do
    j=j+1
  end do
  angle_z=where(angle_z.lt.0.0,angle_z+360,angle_z)
  pi=3.1415926


  hdrt_u_z=-sqrt(hdrt_u^2+hdrt_v^2)*cos(-atan2(hdrt_u,hdrt_v)+pi-angle_z/180.0*pi)
  hdrt_v_z=sqrt(hdrt_u^2+hdrt_v^2)*sin(-atan2(hdrt_u,hdrt_v)+pi-angle_z/180.0*pi)


;noplot  wks  = gsn_open_wks("png","conwomap")    ; open a ncgm file
;noplot  gsn_define_colormap(wks,"gui_default")  ; choose a colormap
;noplot
;noplot  res                     = True          ; plot mods desired
;noplot
;noplot  res@cnFillOn            = True          ; turn on color
;noplot
;noplot;---This resource not needed in NCL V6.1.0
;noplot  res@gsnSpreadColors     = True          ; use full range of colormap
;noplot 
;noplot  res@vpWidthF            = 0.5           ; change aspect ratio of plot
;noplot  res@vpHeightF           = 0.3
;noplot  plot1 = gsn_csm_contour(wks,hdrt_u_z,res)
;noplot  plot1 = gsn_csm_contour(wks,hdrt_v_z,res)
;noplot
;noplot
;noplot
;noplot
  angle_z_1d=ndtooned(angle_z(::skip,::skip))
  r_z_1d=ndtooned(r_z(::skip,::skip))
  hdrt_u_1d=ndtooned(hdrt_u_z(::skip,::skip))
  mslp_1d=ndtooned(mslp(::skip,::skip))
  hdrt_v_1d=ndtooned(hdrt_v_z(::skip,::skip))
  hdrt_w_1d=ndtooned(hdrt_w(::skip,::skip))
;noplot
;noplot  wks  = gsn_open_wks("png","conwomap")    ; open a ncgm file
;noplot  gsn_define_colormap(wks,"gui_default")  ; choose a colormap
;noplot
;noplot  res                     = True          ; plot mods desired
;noplot
;noplot  res@cnFillOn            = True          ; turn on color
;noplot
;noplot;---This resource not needed in NCL V6.1.0
;noplot  res@gsnSpreadColors     = True          ; use full range of colormap
;noplot 
;noplot  res@vpWidthF            = 0.5           ; change aspect ratio of plot
;noplot  res@vpHeightF           = 0.3
;noplot  plot1 = gsn_csm_contour(wks,angle_z,res)
;noplot  plot2 = gsn_csm_contour(wks,r_z,res)
;noplot
  dim3d=dimsizes(Tcon)
  Nlev=dim3d(0)
  k=0
  Tcon_p=new((/Nlev,101,37/),float)
  TV_p=new((/Nlev,101,37/),float)
  ice_p=new((/Nlev,101,37/),float)
  rain_p=new((/Nlev,101,37/),float)
  snow_p=new((/Nlev,101,37/),float)
  spd_p=new((/101,37/),float)
  

  if(any(ismissing(Tcon))) then
    print("Your data contains some missing values. Beware.")
  else
    print("no missing data")
  end if

  do while (k.lt.Nlev)

    Tcon_1d=ndtooned(Tcon(k,::skip,::skip))
    print(max(Tcon_1d))
    print(min(Tcon_1d))

    Tcon_p_k=triple2grid2d(angle_z_1d,r_z_1d,Tcon_1d, angle_p, r_p, False)
    Tcon_p(k,:,:)=Tcon_p_k


    TV_1d=ndtooned(TV(k,::skip,::skip))
    TV_p_k=triple2grid2d(angle_z_1d,r_z_1d,TV_1d, angle_p, r_p, False)
    TV_p(k,:,:)=TV_p_k

    ice_1d=ndtooned(ice(k,::skip,::skip))
    ice_p_k=triple2grid2d(angle_z_1d,r_z_1d,ice_1d, angle_p, r_p, False)
    ice_p(k,:,:)=ice_p_k

    rain_1d=ndtooned(rain(k,::skip,::skip))
    rain_p_k=triple2grid2d(angle_z_1d,r_z_1d,rain_1d, angle_p, r_p, False)
    rain_p(k,:,:)=rain_p_k

    snow_1d=ndtooned(snow(k,::skip,::skip))
    snow_p_k=triple2grid2d(angle_z_1d,r_z_1d,snow_1d, angle_p, r_p, False)
    snow_p(k,:,:)=snow_p_k

    k=k+1
    print("k= "+k)

  end do
  hdrt_T= triple2grid2d(angle_z_1d,r_z_1d,hdrt_u_1d, angle_p,r_p, False)
  mslp_p= triple2grid2d(angle_z_1d,r_z_1d,mslp_1d, angle_p, r_p, False)
  spd_p=triple2grid2d(angle_z_1d, r_z_1d, hdrt_w_1d, angle_p, r_p, False)

  hdrt_T!0="distance"
  hdrt_T!1="angle"  
  hdrt_T&distance=fspan(0.,1000.,101)
  hdrt_T&angle=fspan(0.,360.,37)
  copy_VarCoords(hdrt_T, mslp_p)
  copy_VarCoords(hdrt_T, spd_p)
;  mslp_p!0="distance"
;  mslp_p!1="angle"  
;  mslp_p&distance=fspan(0.,1000.,101)
;  mslp_p&angle=fspan(0.,360.,37)

  Tcon_p!0="lev"
  Tcon_p!1="distance"
  Tcon_p!2="angle"
  
  p_levels=test_file->lv_ISBL0
  p_levels@unit="pa"

  Tcon_p&lev=p_levels
  Tcon_p&distance=fspan(0.,1000.,101)
  Tcon_p&angle=fspan(0.,360.,37)
  copy_VarCoords(Tcon_p,TV_p)
  copy_VarCoords(Tcon_p,ice_p)
  copy_VarCoords(Tcon_p,snow_p)
  copy_VarCoords(Tcon_p,rain_p)

  system("/bin/rm -f "+output_file_name)   ; remove any pre-existing file
  ncdf = addfile(output_file_name ,"c")  ; open output netCDF file

    ;===================================================================
    ; create global attributes of the file (optional)
    ;===================================================================
;       fAtt               = True            ; assign file attributes
;       fAtt@title         = "NCL Simple Approach to netCDF Creation"
;       fAtt@source_file   =  "original-file.nc"
;       fAtt@Conventions   = "None"
;       fAtt@creation_date = systemfunc ("date")
;       fileattdef( ncdf, fAtt )            ; copy file attributes

    ;===================================================================
    ; make time an UNLIMITED dimension; recommended  for most applications
    ;===================================================================
       filedimdef(ncdf,"time",-1,True) 

    ;===================================================================
    ; output variables directly; NCL will call appropriate functions
    ; to write the meta data associated with each variable
    ;===================================================================
       ncdf->VT  = hdrt_T                          ; 4D               
       ncdf->PS =  mslp_p                         ; 3D 
       ncdf->Tcon = Tcon_p
       ncdf->TV = TV_p
       ncdf->ice= ice_p
       ncdf->snow=snow_p
       ncdf->rain=rain_p
       spd_p@_FillValue = rain_p@_FillValue
       ncdf->SPD=spd_p
                                             ; say ORO(:,:)
;  hdrt_R= triple2grid2d(angle_z_1d,r_z_1d,hdrt_v_1d, angle_p,r_p, False)
;  plot4 = gsn_csm_contour(wks,Tcon_p(39,:,:),res)


  hdrt_T_ave=dim_avg_n(hdrt_T,1)
  mslp_p_ave=dim_avg_n(mslp_p,1)
  Tcon_p_ave=dim_avg_n(Tcon_p,2)
  TV_p_ave=dim_avg_n(TV_p,2)
  ice_p_ave=dim_avg_n(ice_p,2)
  snow_p_ave=dim_avg_n(snow_p,2)
  rain_p_ave=dim_avg_n(rain_p,2)

  Tcon_p_ave!0="lev"
  Tcon_p_ave!1="distance"

  Tcon_p_ave&lev=p_levels
  Tcon_p_ave&distance=fspan(0.,1000.,101)

  copy_VarCoords(Tcon_p_ave, TV_p_ave)
  copy_VarCoords(Tcon_p_ave, ice_p_ave)
  copy_VarCoords(Tcon_p_ave, snow_p_ave)
  copy_VarCoords(Tcon_p_ave, rain_p_ave)

  ncdf->Tcon_ave = Tcon_p_ave
   
;noplot  res_line=True
;noplot  plot  = gsn_csm_xy (wks,fspan(0.,1000.,101),hdrt_T_ave,res_line) ; create plot
;noplot  plot  = gsn_csm_xy (wks,fspan(0.,1000.,101),mslp_p_ave,res_line) ; create plot
;noplot  plot  = gsn_csm_pres_hgt(wks, TV_p_ave(11:,0:30), res )
end