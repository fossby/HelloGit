; olr 向上为负，向下为正
begin
;读取 shapefile以及变量
shp_p = "/mnt/c/Users/Administrator/Desktop/national_map/yunnan.shp"
f_olr = addfile("/mnt/e/workwork/20220316/data/olr.nc", "r")
olr0 = f_olr->mtnlwrfcs
olr = olr0*(-1)
copy_VarMeta(olr0, olr)
;读取
filepath = "/mnt/e/workwork/index_set1/pre/pre.txt"
dimensions = -1
datatype = "float"
pre = asciiread(filepath, dimensions, datatype)
;定义经纬度以及高度
lat1 = 0.
lat2 = 40.
lon1 = 40.
lon2 = 140.
;计算气候态
olr_clm = dim_avg_n_Wrap(olr, 0)                                   ;[month | 12] x [latitude | 161] x [longitude | 401]
;选出强弱年
diff_olrs = dim_avg_n_Wrap(olr(ind(pre.ge.1),:,:), 0) - olr_clm
diff_olrw = dim_avg_n_Wrap(olr(ind(pre.le.-1),:,:), 0) - olr_clm
copy_VarMeta(olr(0,:,:), diff_olrs)
copy_VarMeta(olr(0,:,:), diff_olrw)	
;绘图
plot_mp = new(3, graphic)
plot_olr = plot_mp
plot_olrp = plot_olr
plot_shp = plot_olr
;-------------------------------------检验区域----------------
iflag = False
tval_opt = False
;-------------------------------------------------------------
;强年的检验（高度场）
ave1 = dim_avg_n_Wrap(olr(ind(pre.ge.1),:,:), 0)
var1 = dim_variance_n_Wrap(olr(ind(pre.ge.1),:,:), 0)
s1 = dimsizes(ind(pre.ge.1))
ave2 = dim_avg_n_Wrap(olr, 0)
var2 = dim_variance_n_Wrap(olr, 0)
s2 = 60
p_olrs = ttest(ave1, var1, s1, ave2, var2, s2, iflag, tval_opt)
copy_VarCoords(olr(0,:,:), p_olrs)
delete(ave1)
delete(var1)
delete(s1)
delete(ave2)
delete(var2)
delete(s2)
					;弱年的检验（高度场）
					ave1 = dim_avg_n_Wrap(olr(ind(pre.le.-1),:,:), 0)
					var1 = dim_variance_n_Wrap(olr(ind(pre.le.-1),:,:), 0)
					s1 = dimsizes(ind(pre.le.-1))
					ave2 = dim_avg_n_Wrap(olr, 0)
					var2 = dim_variance_n_Wrap(olr, 0)
					s2 = 60

					p_olrw = ttest(ave1, var1, s1, ave2, var2, s2, iflag, tval_opt)
					copy_VarCoords(olr(0,:,:), p_olrw)    
					delete(ave1)
					delete(var1)
					delete(s1)
					delete(ave2)
					delete(var2)
					delete(s2)

wks = gsn_open_wks("eps", "olr")
;基准
res = True
res@gsnFrame = False
res@gsnDraw = False
res@gsnLeftString = ""
res@gsnRightString = "" 
;地图
res_mp = res
res_mp@mpMinLatF = lat1
res_mp@mpMaxLatF = lat2
res_mp@mpMinLonF = lon1
res_mp@mpMaxLonF = lon2
res_mp@tmXTOn    =  False
res_mp@tmYROn    =  False
res_mp@mpFillOn  = False
;调整地图边框
res_mp@mpPerimOn = True
; res_mp@mpPerimLineThicknessF=6
	;Y轴坐标设置
	res_mp@tmYLMinorOn = False
	res_mp@tmYLMode = "Explicit"
	res_mp@tmYLValues = (/0, 10, 20, 30,40/)
	res_mp@tmYLLabelFontHeightF = 0.02
	res_mp@tmYLLabels = (/"0~S~o~N~N","10~S~o~N~N","20~S~o~N~N","30~S~o~N~N","40~S~o~N~N"/)
	res_mp@tmYLLabelFont = 25   ;设置为罗马字体
	; res_mp@tmYLMajorThicknessF = 4
	;X轴坐标设置
	res_mp@tmXBMinorOn = False
	res_mp@tmXBMode = "Explicit"
	res_mp@tmXBValues = (/40, 60, 80, 100, 120, 140/)
	res_mp@tmXBLabelFontHeightF = 0.02
	res_mp@tmXBLabelFont = 25    ;设置为罗马字体
	res_mp@tmXBLabels = (/"40~S~o~N~E","60~S~o~N~E","80~S~o~N~E","100~S~o~N~E","120~S~o~N~E","140~S~o~N~E"/)
	; res_mp@tmXBMajorThicknessF = 4
	; ;轴坐标向内
	; res_mp@tmXBMajorOutwardLengthF = -0.0
	; res_mp@tmYLMajorOutwardLengthF = -0.0
	; res_mp@gsnLeftStringOrthogonalPosF = 0.0	
;============================================================================	
;叠加shp文件,画省界限
shpp0 = True
shpp0@gsLineColor = "black"
shpp0@gsLineThicknessF = 2.0
;绘制高度场
res_olr0 = res 
	;等值线
	res_olr0@cnFillOn = True
	res_olr0@cnLinesOn = False
	res_olr0@cnFillDrawOrder = "PreDraw"
	res_olr0@cnFillPalette = "BlueDarkRed18"
    res_olr0@cnLevelSelectionMode = "ManualLevels"
	res_olr0@cnMinLevelValF = -8
	res_olr0@cnMaxLevelValF = 8
	res_olr0@lbLabelBarOn = False
	res_olr0@cnInfoLabelOn = False
	res_olr0@gsnAddCyclic = False
	res_olr0@pmLabelBarOrthogonalPosF = 0.15
	res_olr0@cnLineLabelsOn = False
	;色标相关
	res_olr0@lbLabelBarOn = False
	res_olr0@lbLabelFont = 25               ;设为新罗马字体
	res_olr0@lbBoxLineThicknessF = 6

;绘制高度场打点区
res_olr0p = res
res_olr0p@cnFillOn = True
res_olr0p@cnLinesOn = False
res_olr0p@cnInfoLabelOn = False
res_olr0p@lbLabelBarOn = False
res_olr0p@cnFillPalette = "GMT_gray"
res_olr0p@cnFillDrawOrder = "PostDraw"
res_olr0p@cnFillPattern = (/17,17/)
res_olr0p@cnLevelSelectionMode = "ExplicitLevels"
res_olr0p@cnLineLabelsOn = False
res_olr0p@cnLevels = (/0.05/)
res_olr0p@cnFillColors = (/2,-1/)	
res_olr0p@cnFillScaleF =2.0
res_olr0p@cnFillDotSizeF = 0.005
res_olr0p@gsnLeftString = "(a)"
res_olr0p@gsnLeftStringOrthogonalPosF = 0.02
res_olr0p@gsnLeftStringParallelPosF = 0.48
res_olr0p@gsnStringFont = 25
res_olr0p@gsnLeftStringFontHeightF = 0.05
;其他
res_olr1 = res_olr0
res_olr2 = res_olr0
res_olr1p = res_olr0p
res_olr2p = res_olr0p
shpp1 = shpp0
shpp2 = shpp0
;补充
res_olr1p@gsnLeftString = "(b)"
;强
plot_mp(0) = gsn_csm_map(wks, res_mp)
plot_olr(0) = gsn_csm_contour(wks, diff_olrs, res_olr0)
plot_olrp(0) = gsn_csm_contour(wks, p_olrs , res_olr0p)
plot_shp(0) = gsn_add_shapefile_polylines(wks, plot_mp(0), shp_p, shpp0)
overlay(plot_mp(0), plot_olr(0))
overlay(plot_mp(0), plot_olrp(0))
;弱
plot_mp(1) = gsn_csm_map(wks, res_mp)
plot_olr(1) = gsn_csm_contour(wks, diff_olrw, res_olr1)
plot_olrp(1) = gsn_csm_contour(wks, p_olrw , res_olr1p)
plot_shp(1) = gsn_add_shapefile_polylines(wks, plot_mp(1), shp_p, shpp1)
overlay(plot_mp(1), plot_olr(1))
overlay(plot_mp(1), plot_olrp(1))

;组图
resp = True
resp@gsnPanelRowSpec = True 
resp@gsnPanelLabelBar = True
gsn_panel(wks, plot_mp, (/2,1/),resp)

draw(plot_mp)


end
