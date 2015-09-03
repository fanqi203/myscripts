load "/apps/ncl/6.1.2/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "/apps/ncl/6.1.2/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
;load "/apps/ncl/6.1.2/lib/ncarg/nclscripts/csm/contributed.ncl"

f=addfile(fss_output_file,"r")
fss=f->fss_data
scale=f->scale
thres=f->threshhold

dimsiz=dimsizes(fss)
print(dimsizes(dimsiz))
if (dimsizes(dimsiz).eq.4) then
tmp=dim_avg_n(fss,0)
else
tmp=fss
end if
tmp!1="scale"
tmp!2="thres"
tmp&scale=scale
tmp&thres=thres
printVarSummary(tmp)
print(thres)

thres_N=0
plot=new(4,graphic)
wks  = gsn_open_wks("png",fss_output_file+".fss")                  ; open a ps plot

do while (thres_N .lt. 4)

res                 = True                         ; make plot mods
res@gsnDraw  = False                          ; don't draw
res@gsnFrame = False                          ; don't advance frame
res@xyLineColors      = (/"red","black","blue"/)
;res@gsLineDashPattern  = 0    
res@xyDashPattern      = 0   
res@xyDashPatterns     = (/0,0,0/) 
res@xyLineThicknesses = (/4.0,4.0,4.0/)  
if(thres_N .eq. 0) then
res@tiYAxisString            = "FSS for BT< "+thres(thres_N)
else
res@tiYAxisString            = thres(thres_N-1)+"< FSS for BT< "+thres(thres_N)
end if
res@tiXAxisString            = "scale 10000 km^2"
res@trYMinF  = 0.0                   ; min value on y-axis
res@trYMaxF  =  1.0 

;res@xyLineThicknessF = (/1, 1, 1, 3/)
 res@pmLegendDisplayMode    = "Always"              ; turn on legend
 
 res@pmLegendSide           = "Top"                 ; Change location of 
 res@pmLegendParallelPosF   = 0.20                   ; move units right
 res@pmLegendOrthogonalPosF = -0.8                  ; more neg = down
 
 res@pmLegendWidthF         = 0.12                  ; Change width and
 res@pmLegendHeightF        = 0.12                  ; height of legend.
 res@lgLabelFontHeightF     = .02                   ; change font height
 res@lgPerimOn              = False                 ; no box around
; labels for the legend
 res@xyExplicitLegendLabels = (/"HDRT","HDRF","HDGF"/)
 res@lgLabelFontHeightF=0.1

;  res@cnFillOn         = True               ; color Fill 
;  res@cnFillMode       = "RasterFill"       ; Raster Mode
;  res@cnLinesOn        =  False             ; Turn off contour lines
;  res@tiMainString    = "37.7N 180E vs 23.72S 149W"  ; title
;  res@tiXAxisString   = "LAG"                        ; x-axis label
  
  data=((/tmp(0,:,thres_N), tmp(1,:,thres_N), tmp(2,:,thres_N)/))
  print(scale)
  plot(thres_N) = gsn_xy(wks,(scale*2+1)^2*(50*111/300.0)*(77*111/300)/10000.0,data,res)      
  thres_N=thres_N+1
  print(thres_N)
;  plot = gsn_contour(wks,tmp(0,:,:), res)

;plot=gsn_csm_xy(fss_ave)
end do
printVarSummary(plot)

resP            = True
gsn_panel(wks,plot,(/2,2/),resP) 


