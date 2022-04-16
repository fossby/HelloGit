;	---		要求：依据 WMI指数绘制高度场的差值(异常强年与异常弱年)
 begin          
;   ---------------------------地形相关------------
;增大工作空间
  setvalues NhlGetWorkspaceObjectId()    
  "wsMaximumSize": 300000000
  end setvalues
  ;读取地形
  f_geo =  addfile("/mnt/g/data/geo_data/ETOPO2v2g_f4.nc", "r")
  var  =  f_geo->z(:,:)              
  lon = f_geo->x(:)
  lon@units = "degrees_east"
  lat = f_geo->y(:)
  lat@units = "degrees_north"
  var!0 = "lat" ;
  var&lat = lat ;
  var!1 = "lon" ;
  var&lon = lon  ;
;读取 shapefile以及变量
filepath = "/mnt/e/workwork/index_set1/pre/pre.txt"
dimensions = -1
datatype = "float"
pre = asciiread(filepath, dimensions, datatype)
shp_p = "/mnt/c/Users/Administrator/Desktop/national_map/yunnan.shp"
f_z = addfile("/mnt/e/workwork/20211025/data/z_5.nc", "r")
;定义经纬度以及高度
lat1 = 0.
lat2 = 40.
lon1 = 40.
lon2 = 140.
p_value =0.05
;修改区
level = 850     ;高度
style = "eps"
;提取变量
z_0 = f_z->z(:,{level},:,:)
;测试数据正常(这里注意)
z = z_0*1.0/9.80665
copy_VarCoords(z_0,z)
dims = dimsizes(z)
;计算气候态
z_clm = dim_avg_n_Wrap(z, 0)                                   ;[month | 12] x [latitude | 161] x [longitude | 401]
;选出强弱年
diff_zs = dim_avg_n_Wrap(z(ind(pre.ge.1),:,:), 0) - dim_avg_n_Wrap(z, 0)
diff_zw = dim_avg_n_Wrap(z(ind(pre.le.-1),:,:), 0) - dim_avg_n_Wrap(z, 0)
copy_VarMeta(z(0,:,:), diff_zs)
copy_VarMeta(z(0,:,:), diff_zw)	
;-------------------------------------检验区域----------------
iflag = False
tval_opt = False
;-------------------------------------------------------------
;强年的检验（高度场）
ave1 = dim_avg_n_Wrap(z(ind(pre.ge.1),:,:), 0)
var1 = dim_variance_n_Wrap(z(ind(pre.ge.1),:,:), 0)
s1 = dimsizes(ind(pre.ge.1))
ave2 = dim_avg_n_Wrap(z, 0)
var2 = dim_variance_n_Wrap(z, 0)
s2 = 60
p_zs = ttest(ave1, var1, s1, ave2, var2, s2, iflag, tval_opt)
copy_VarCoords(z(0,:,:), p_zs)
delete(ave1)
delete(var1)
delete(s1)
delete(ave2)
delete(var2)
delete(s2)
					;弱年的检验（高度场）
					ave1 = dim_avg_n_Wrap(z(ind(pre.le.-1),:,:), 0)
					var1 = dim_variance_n_Wrap(z(ind(pre.le.-1),:,:), 0)
					s1 = dimsizes(ind(pre.le.-1))
					ave2 = dim_avg_n_Wrap(z, 0)
					var2 = dim_variance_n_Wrap(z, 0)
					s2 = 60
					printVarSummary(ave1)

					p_zw = ttest(ave1, var1, s1, ave2, var2, s2, iflag, tval_opt)
					copy_VarCoords(z(0,:,:), p_zw)    
					delete(ave1)
					delete(var1)
					delete(s1)
					delete(ave2)
					delete(var2)
					delete(s2)
;	********************************************绘图要素**********************
plots_p = new(2, graphic)     ;省界
plots_h = new(2, graphic)	  ;高度场
plots_g = new(2, graphic)	  ;地形
plots_zp = new(2, graphic)	  ;高度场的检验
wks = gsn_open_wks(style, tostring(level)+" hPa")
;公共属性
res = True
res@gsnLeftString = ""
res@gsnRightString = ""
res@gsnDraw = False
res@gsnFrame = False
res@gsnAddCyclic = False
;Y轴坐标设置
res@tmYLMinorOn = False
res@tmYLMode = "Explicit"
res@tmYLValues = (/0, 10, 20, 30,40/)
res@tmYLLabels = (/"0~S~o~N~N","10~S~o~N~N","20~S~o~N~N","30~S~o~N~N","40~S~o~N~N"/)
res@tmXBLabelFontHeightF = 0.02
;X轴坐标设置
res@tmXBMinorOn = False
res@tmXBMode = "Explicit"
res@tmXBValues = (/40, 60, 80, 100,120,140/)
res@tmXBLabels = (/"40~S~o~N~E","60~S~o~N~E","80~S~o~N~E","100~S~o~N~E","120~S~o~N~E","140~S~o~N~E"/)
res@tmYLLabelFontHeightF = 0.02
;轴坐标向内
; res@tmXBMajorOutwardLengthF = -0.0
; res@tmYLMajorOutwardLengthF = -0.0
; res@gsnLeftStringOrthogonalPosF = 0.0
;上坐标、右坐标轴去刻度
res@tmXTOn = False
res@tmYROn = False
res@mpMinLatF = 0
res@mpMaxLatF = 40
res@mpMinLonF = 40
res@mpMaxLonF = 140
res@mpFillOn = False
;设置地形
res_g                       =  res                
res_g@cnFillPalette = "GMT_gray" 
res_g@cnFillOn              =  True              ;
res_g@cnLinesOn             =  False             ;
res_g@cnLevelSelectionMode  = "ExplicitLevels"   ;
res_g@cnLevels              = (/3000/)
res_g@cnFillColors          = (/-1,2/)
res_g@cnInfoLabelOn   = False
res_g@cnFillDrawOrder = "PostDraw"
res_g@cnLineLabelsOn  = False
res_g@lbLabelBarOn    = False
res_g@cnFillOpacityF  = 2
;叠加shp文件,画省界限
shpp = True
shpp@gsLineColor = "black"
shpp@gsLineThicknessF = 1.0
;设置等值线
res_h = res
res_h@cnFillOn  = False
res_h@cnLinesOn = True
res_h@cnInfoLabelOn = True
res_h@cnLineLabelsOn = True
res_h@cnLineThicknesses = 2.5
res_h@gsnContourPosLineDashPattern = 0
res_h@gsnContourNegLineDashPattern = 16
res_h@cnInfoLabelOn = False
res_h@cnLineDrawOrder = "PostDraw"
res_h@cnLabelMasking           = True
res_h@cnLabelDrawOrder         = "Postdraw"
;设置高度场的过检
res_zsp = res
res_zsp@cnFillOn  = True
res_zsp@cnLinesOn = False
res_zsp@cnInfoLabelOn = False
res_zsp@cnFillPalette = "gscyclic"
res_zsp@cnLevelSelectionMode = "ExplicitLevels"
res_zsp@cnLevels = p_value
res_zsp@cnFillColors = (/4,-1/)
res_zsp@lbLabelBarOn = False
res_zsp@cnLineLabelsOn = False
res_zsp@cnFillDrawOrder = "Draw"
res_zwp = res_zsp
;绘制强年过显区
				;优化间隔
				res_h0 = res_h
				; res_h@cnLineLabelPlacementMode = "Randomzied"			
				res_h0@cnLineLabelDensityF      =1.5
				res_h0@cnLineLabelFontHeightF   = 0.02
				res_h0@cnLineLabelInterval      = 1
				res_h0@cnLineLabelAngleF        = 0.		
				res_h0@cnLineLabelBackgroundColor = -1
				res_h0@gsnLeftString = "(e)"
				res_h0@gsnLeftStringOrthogonalPosF = 0.02
				; res_h0@cnLevelSpacingF = 5

			;绘制高度场
            plots_h(0) = gsn_csm_contour_map(wks, diff_zs({lat1:lat2},{lon1:lon2}), res_h0)
			plots_p(0) = gsn_add_shapefile_polylines(wks, plots_h(0), shp_p, shpp)
			;加地形
			plots_g(0) = gsn_csm_contour(wks, var, res_g)
			;加高度场过检定区
			plots_zp(0) = gsn_csm_contour(wks, p_zs, res_zsp)
			;叠图
				overlay(plots_h(0), plots_g(0))			 ;叠地形
				overlay(plots_h(0), plots_zp(0))            ;叠高度场

;绘制弱年
				;优化间隔
				res_h1 = res_h
				; res_h1@cnLineLabelPlacementMode = "Randomzied"			
				res_h1@cnLineLabelDensityF      = 1.5
				res_h1@cnLineLabelFontHeightF   = 0.02
				res_h1@cnLineLabelInterval      = 1
				res_h1@cnLineLabelAngleF        = 0.		
				res_h1@cnLineLabelBackgroundColor = -1
				; res_h1@cnLevelSpacingF = 5
				
				; dmin_w   = min(diff_zw(:,:))
				; dmax_w   = max(diff_zw(:,:))
				; maxlev_w  = 9
				; mnmxint_w = nice_mnmxintvl( dmin_w, dmax_w, maxlev_w, False)
				; res_h1@cnLevelSelectionMode = "ManualLevels"
				; res_h1@cnMinLevelValF       = mnmxint_w(0)
				; res_h1@cnMaxLevelValF       = mnmxint_w(1)
				; res_h1@cnLevelSpacingF      = mnmxint_w(2)
				res_h1@gsnLeftString = "(f)"
				res_h1@gsnLeftStringOrthogonalPosF = 0.02
;先
            
			plots_h(1) = gsn_csm_contour_map(wks, diff_zw({lat1:lat2},{lon1:lon2}), res_h1)
			plots_p(1) = gsn_add_shapefile_polylines(wks, plots_h(1), shp_p, shpp)
			;加地形
			plots_g(1) = gsn_csm_contour(wks, var, res_g)
;加高度场过检定区
            plots_zp(1) = gsn_csm_contour(wks, p_zw, res_zwp)
;叠图
            overlay(plots_h(1),plots_g(1))			 ;叠地形
			overlay(plots_h(1), plots_zp(1))         ;叠高度场
			
;	*******************************************************************************
;组图
pres = True
gsn_panel(wks, plots_h, (/1,2/), pres)
draw(plots_h)
end
