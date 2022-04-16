begin
filepath = "/mnt/e/workwork/index_set1/pre/pre.txt"
dimensions = -1
datatype = "float"
pre = asciiread(filepath, dimensions, datatype)
;----------------   
    f = addfile("/mnt/g/DATA/20211223/out.nc", "r")
    lat1 = 0
	lat2 = 40
    u = f->u(:,{1000:100},{lat1:lat2},:)
        u := dim_avg_n_Wrap(u, 3)
	v = f->v(:,{1000:100},{lat1:lat2},:)
        v := dim_avg_n_Wrap(v, 3)
	w0 = f->w(:,{1000:100},{lat1:lat2},:)
        w0 := dim_avg_n_Wrap(w0, 3)
    w = w0 * (-100)
    copy_VarMeta(w0,w) 
    dims = dimsizes(u)            ; 60x17x121
    u_clm = dim_avg_n_Wrap(u, 0)
    v_clm = dim_avg_n_Wrap(v, 0)
    w_clm = dim_avg_n_Wrap(w, 0)
;协同强年
;选出强年
diff_us = dim_avg_n_Wrap(u(ind(pre.ge.1),:,:), 0) - u_clm
diff_vs = dim_avg_n_Wrap(v(ind(pre.ge.1),:,:), 0) - v_clm
diff_ws = dim_avg_n_Wrap(w(ind(pre.ge.1),:,:), 0) - w_clm
;选出弱年
diff_uw = dim_avg_n_Wrap(u(ind(pre.le.-1),:,:), 0) - u_clm
diff_vw = dim_avg_n_Wrap(v(ind(pre.le.-1),:,:), 0) - v_clm
diff_ww = dim_avg_n_Wrap(w(ind(pre.le.-1),:,:), 0) - w_clm
copy_VarMeta(u_clm, diff_us)
copy_VarMeta(u_clm, diff_vs)
copy_VarMeta(u_clm, diff_ws)
copy_VarMeta(u_clm, diff_uw)	
copy_VarMeta(u_clm, diff_vw)
copy_VarMeta(u_clm, diff_ww)
;检验
iflag = False
tval_opt = False							
;强年的检验（w垂直速度）
ave1 = dim_avg_n_Wrap(w(ind(pre.ge.1),:,:), 0)
var1 = dim_variance_n_Wrap(w(ind(pre.ge.1),:,:), 0)
s1 = dimsizes(ind(pre.ge.1))
ave2 = dim_avg_n_Wrap(w, 0)
var2 = dim_variance_n_Wrap(w, 0)
s2 = 60
p_ws = ttest(ave1, var1, s1, ave2, var2, s2, iflag, tval_opt)
copy_VarMeta(w(0,:,:), p_ws)
delete(ave1)
delete(var1)
delete(s1)
delete(ave2)
delete(var2)
delete(s2)
					;弱年的检验（高度场）
					ave1 = dim_avg_n_Wrap(w(ind(pre.le.-1),:,:), 0)
					var1 = dim_variance_n_Wrap(w(ind(pre.le.-1),:,:), 0)
					s1 = dimsizes(ind(pre.le.-1))
					ave2 = dim_avg_n_Wrap(w, 0)
					var2 = dim_variance_n_Wrap(w, 0)
					s2 = 60
					p_ww = ttest(ave1, var1, s1, ave2, var2, s2, iflag, tval_opt)
					copy_VarMeta(w(0,:,:), p_ww)
					printMinMax(p_ww, True)      ;   
					delete(ave1)
					delete(var1)
					delete(s1)
					delete(ave2)
					delete(var2)
					delete(s2)
;---------------------------------------
plot = new(2, graphic)         ;绘制风场
plotu = plot
wks = gsn_open_wks("eps", "风场合成")
res = True
res@gsnLeftString = ""
res@gsnRightString = ""
res@gsnFrame = False
res@gsnDraw = False
;坐标设置
  ;X轴坐标设置
  res@tmXBMinorOn = False
  res@tmXBMode = "Explicit"
  res@tmXBValues = (/0, 10, 20, 30,40/)
  res@tmXBLabels = (/"0~S~o~N~N","10~S~o~N~N","20~S~o~N~N","30~S~o~N~N","40~S~o~N~N"/)
  res@tmXBLabelFontHeightF = 0.02
  res@tmXBMajorOutwardLengthF = -0.0
  ;y轴坐标设置
  res@tmYLLabelFontHeightF = 0.02 
  ;去掉右侧高度坐标
  res@tiYAxisString = "hPa"
  res@tmYRMode = "Automatic"
;上坐标、右坐标轴去刻度
    res@tmXTOn = False
    res@tmYROn = False
    ;去掉等值线标签信息
    res@cnInfoLabelOn = False
    ;参考矢量
    res@vcRefAnnoOn = True
    res@vcRefMagnitudeF= 4
    res@vcGlyphStyle = "CurlyVector"
    res@vcVectorDrawOrder = "PreDraw"
    res@vcMinDistanceF  = 0.05
    res@vcRefLengthF = 0.1
    res@vcRefAnnoPerimOn = False
    res@vcRefAnnoString1On = False
    res@vcRefAnnoString2On = True
    res@vcRefAnnoString2 = "4 m/s"
    res@vcRefAnnoFontHeightF = 0.02
    res@vcRefAnnoOrthogonalPosF = -1.22
    res@vcLineArrowHeadMaxSizeF= 0.04
    res@vcLineArrowThicknessF = 1.5
   ;
    res0 = res
    res0@cnFillOn = True
    res0@cnLinesOn = False
    res0@cnFillPalette = "gscyclic"
    res0@cnLevelSelectionMode = "ExplicitLevels"
    res0@cnLevels = 0.05
    res0@cnFillColors = (/4,-1/)
    res0@lbLabelBarOn = False
    res0@cnFillDrawOrder = "PreDraw"
    res0@cnLineLabelsOn = False
    ;
    res0@gsnLeftString = "(a)"
    res0@gsnLeftStringFontHeightF = 0.025
    res0@gsnLeftStringOrthogonalPosF = -0.01 
    res1 = res0
    ;绘制等值线纬向风
   resp = True
   plot(0) = gsn_csm_pres_hgt_vector(wks, p_ws, diff_vs(:,:), diff_ws(:,:), res0)

   res_u0 = res
   ;等值线
   res_u0@cnLevelSpacingF = 0.5
   res_u0@cnLineThicknessF = 2.5
   res_u0@gsnContourNegLineDashPattern = 16
   ;等值线标签
   res_u0@cnLineLabelPerimOn = False
   res_u0@cnLineLabelFontHeightF = 0.02
   res_u0@cnLineLabelAngleF =0.0
   res_u0@cnLineLabelBackgroundColor = -1 
   res_u0@cnLineLabelFormat= "@*+^sg"
   res_u0@cnLineLabelInterval = 1
   res_u0@cnLabelDrawOrder = "PostDraw"
   res_u0@cnLineLabelPlacementMode = "Copmuted"

   plotu(0) = gsn_csm_pres_hgt(wks, diff_us, res_u0)
   overlay(plot(0), plotu(0))

   res1 = True
   res1@gsnLeftString = "(b)"
   res1@gsnLeftStringFontHeightF = 0.025
   plot(1) = gsn_csm_pres_hgt_vector(wks, p_ww, diff_vw(:,:), diff_ww(:,:), res1)     
   
   res_u1 = res_u0

   plotu(1) = gsn_csm_pres_hgt(wks, diff_uw, res_u1)
   overlay(plot(1), plotu(1))
   gsn_panel(wks, plot, (/1,2/), resp)
   draw(plot)
end
