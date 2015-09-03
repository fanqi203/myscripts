load "/apps/ncl/6.1.2/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "/apps/ncl/6.1.2/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "/apps/ncl/6.1.2/lib/ncarg/nclscripts/csm/contributed.ncl"



f=addfile(fss_output_file,"r")
obs_pdf=f->obs_pdf
hdrt_pdf=f->hdrt_pdf
hdrf_pdf=f->hdrf_pdf
hdgf_pdf=f->hdgf_pdf
dimsiz=dimsizes(obs_pdf)
print(dimsizes(dimsiz))
if (dimsizes(dimsiz).eq.2) then
data=(/dim_avg_n(obs_pdf,0),dim_avg_n(hdrt_pdf,0),dim_avg_n(hdrf_pdf,0), dim_avg_n(hdgf_pdf,0)/)
else
data=(/obs_pdf,hdrt_pdf,hdrf_pdf, hdgf_pdf/)
end if

wks_pdf  = gsn_open_wks ("png","pdf_goes13"+fss_output_file)
res_pdf  = True
res_pdf@xyLineColors      = (/"red","black","blue","brown"/)
res_pdf@gsLineDashPattern  = 0    
res_pdf@xyDashPattern      = 0   
res_pdf@xyDashPatterns     = (/0,0,0,0/) 
res_pdf@xyLineThicknesses = (/4.0,4.0,4.0,4.0/)  
res_pdf@tiYAxisString            = "PDF (%)"
res_pdf@tiXAxisString            = "Brightness Temperature (degK)"
;res_pdf@xyLineThicknessF = (/1, 1, 1, 3/)
 res_pdf@pmLegendDisplayMode    = "Always"              ; turn on legend
 
 res_pdf@pmLegendSide           = "Top"                 ; Change location of 
 res_pdf@pmLegendParallelPosF   = 0.20                   ; move units right
 res_pdf@pmLegendOrthogonalPosF = -0.8                  ; more neg = down
 
 res_pdf@pmLegendWidthF         = 0.12                  ; Change width and
 res_pdf@pmLegendHeightF        = 0.25                  ; height of legend.
 res_pdf@lgLabelFontHeightF     = .02                   ; change font height
 res_pdf@lgPerimOn              = False                 ; no box around
; labels for the legend
 res_pdf@xyExplicitLegendLabels = (/"OBS","HDRT","HDRF","HDGF"/)
 res_pdf@pmLegendWidthF = 0.1
 res_pdf@pmLegendHeightF = 0.12
 res_pdf@lgLabelFontHeightF=0.02
;res_pdf@gsnCenterString = ""
plot = gsn_csm_xy (wks_pdf, fspan(180,310,50) ,data, res_pdf)
