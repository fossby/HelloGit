
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
shp_p = "/mnt/c/Users/Administrator/Desktop/national_map/yunnan.shp"
f_uvq = addfile("/mnt/e/workwork/20211031/data/vaporflux.nc", "r")
filepath = "/mnt/e/workwork/index_set1/pre/pre.txt"
dimensions = -1
datatype = "float"
pre = asciiread(filepath, dimensions, datatype)
;定义经纬度以及高度
lat1 = 0.
lat2 = 40.
lon1 = 40.
lon2 = 140.
p_value = 0.05
;修改区
windspeed = 95		  ;基准风速
id_left = "a"		  ;左图号
id_right = "b"		  ;右图号
; opacity = 0.5
vector_dist = 0.01
style = "eps"
;提取变量
u = f_uvq->$"p71.162"$
v = f_uvq->$"p72.162"$
z0 = f_uvq->$"p84.162"$
z = z0 *100000
copy_VarMeta(z0, z)
dims = dimsizes(z)
;计算气候态
u_clm = dim_avg_n_Wrap(u, 0)
v_clm = dim_avg_n_Wrap(v, 0)
z_clm = dim_avg_n_Wrap(z, 0)                                   ;[month | 12] x [latitude | 161] x [longitude | 401]
;定义容器，选出强弱年
;选出强年
diff_us = dim_avg_n_Wrap(u(ind(pre.ge.1),:,:), 0) - u_clm
diff_vs = dim_avg_n_Wrap(v(ind(pre.ge.1),:,:), 0) - v_clm
diff_divs = dim_avg_n_Wrap(z(ind(pre.ge.1),:,:), 0) - z_clm
;选出弱年
diff_uw = dim_avg_n_Wrap(u(ind(pre.le.-1),:,:), 0) - u_clm
diff_vw = dim_avg_n_Wrap(v(ind(pre.le.-1),:,:), 0) - v_clm
diff_divw = dim_avg_n_Wrap(z(ind(pre.le.-1),:,:), 0) - z_clm
copy_VarMeta(u_clm, diff_uw)
copy_VarMeta(u_clm, diff_vw)
copy_VarMeta(u_clm, diff_us)
copy_VarMeta(u_clm, diff_vs)	
copy_VarMeta(u_clm, diff_divs)
copy_VarMeta(u_clm, diff_divw)
;-------------------------------------------------检验区域----------------
iflag = False
tval_opt = False							
;强年的检验（散度场）
ave1 = dim_avg_n_Wrap(z(ind(pre.ge.1),:,:), 0)
var1 = dim_variance_n_Wrap(z(ind(pre.ge.1),:,:), 0)
s1 = dimsizes(ind(pre.ge.1))
ave2 = dim_avg_n_Wrap(z, 0)
var2 = dim_variance_n_Wrap(z, 0)
s2 = 60
p_zs = ttest(ave1, var1, s1, ave2, var2, s2, iflag, tval_opt)
copy_VarMeta(z(0,:,:), p_zs)
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
					p_zw = ttest(ave1, var1, s1, ave2, var2, s2, iflag, tval_opt)
					copy_VarMeta(z(0,:,:), p_zw)
					printMinMax(p_zw, True)      ;   
					delete(ave1)
					delete(var1)
					delete(s1)
					delete(ave2)
					delete(var2)
					delete(s2)
;	********************************************绘图要素**********************
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
;绘制过检定的区
res_p = res
res_p@cnFillOn = True
res_p@cnLinesOn = False
res_p@cnFillPalette = "gscyclic"
res_p@cnFillPattern = 17
res_p@cnFillDotSizeF = 0.08
res_p@cnLevelSelectionMode = "ExplicitLevels"
res_p@cnLevels = 0.05
res_p@cnFillColors = (/-1,2/)
res_p@lbLabelBarOn = False
res_p@cnFillDrawOrder = "PreDraw"
res_p@cnInfoLabelOn = False
res_p@cnLineLabelsOn = False
res_p@cnFillOpacityF = 0.7

;绘图
plots = new(2, graphic)
plots_p = new(2, graphic)
plots_h = new(2, graphic)
plots_zp = plots

wks = gsn_open_wks(style, "水汽通量及散度差值场1")
;颜色反转
  cmaq = read_colormap_file("MPL_BrBG")   ; read the color map
  cmap = cmaq(::-1,:) 
;公共属性
res = True
res@pmTickMarkDisplayMode = "Always"
res@gsnLeftString = ""
res@gsnRightString = ""
res@gsnDraw = False
res@gsnFrame = False
res@gsnAddCyclic = False
res@lbLabelBarOn  = False
;设置地形
res_g                       =  res                
res_g@cnFillPalette = "topo_15lev" 
res_g@cnFillOn              =  True              ;
res_g@cnLinesOn             =  False             ;
res_g@cnLevelSelectionMode  = "ExplicitLevels"   ;
res_g@cnLevels              = (/3000/)
res_g@cnFillColors          = (/-1,11/)
res_g@cnInfoLabelOn   = False
res_g@cnFillDrawOrder = "PostDraw"
res_g@cnFillOpacityF  = 0.5
res_g@cnLineLabelsOn = False
;叠加shp文件,画省界限
shpp = True
shpp@gsLineColor = "black"
shpp@gsLineThicknessF = 1.0
;设置等值线(以填充的形式绘制)
res_h = res
res_h@cnFillOn  = True
res_h@cnLinesOn = False
res_h@cnLineLabelsOn = False
res_h@cnFillMode = "RasterFill"
res_h@cnInfoLabelOn = False
res_h@cnFillPalette = cmap
res_h@cnLineLabelAngleF =0.
;打点
res_zs = res
res_zs@cnFillOn = True
res_zs@cnLinesOn = False
res_zs@cnFillPalette = "GMT_ocean"
res_zs@cnFillDotSizeF = 0.004
res_zs@cnLevelSelectionMode = "ExplicitLevels"
res_zs@cnLevels = 0.05
res_zs@cnFillPattern = (/17,17/)
res_zs@cnFillColors = (/2,-1/)
res_zs@cnLineLabelsOn = False
res_zs@cnInfoLabelOn = False
res_zs@cnFillDrawOrder = "PostDraw"
res_zw = res_zs

;;绘制矢量
res_vec = res
res_vec@vcRefAnnoOn = True
res_vec@vcRefMagnitudeF = 50       
res_vec@vcGlyphStyle = "CurlyVector"
res_vec@vcRefAnnoOrthogonalPosF = -1.25
res_vec@vcRefAnnoPerimOn = False
res_vec@vcRefLengthF = 0.045
res_vec@vcRefAnnoString2On = True
res_vec@vcRefAnnoString2 = 50
res_vec@vcRefAnnoString1On = False
res_vec@vcMinDistanceF  = 0.025
res_vec@vcVectorDrawOrder = "PostDraw"
res_vec@mpOutlineOn = True
res_vec@mpOutlineDrawOrder = "PostDraw"
res_vec@vcLineArrowHeadMinSizeF = 0.01
res_vec@mpMinLatF = lat1
res_vec@mpMaxLatF = lat2
res_vec@mpMinLonF = lon1
res_vec@mpMaxLonF = lon2
;绘制强年
plots(0) = gsn_csm_vector_map(wks, diff_us(:,:), diff_vs(:,:),  res_vec)
			;加省界
			plots_p(0) = gsn_add_shapefile_polylines(wks, plots(0), shp_p, shpp)
			;加地形
			; plots_g(0) = gsn_csm_contour(wks, var1, res_g)
;绘制高度场
plots_h(0) = gsn_csm_contour(wks, diff_divs(:,:), res_h)
;加高度场过检定区
plots_zp(0) = gsn_csm_contour(wks, p_zs, res_zs)
;叠图
    overlay(plots(0), plots_h(0))
    ; overlay(plots(0), plots_g(0))
    overlay(plots(0), plots_zp(0))
;绘制弱年
plots(1) = gsn_csm_vector_map_ce(wks, diff_uw(:,:), diff_vw(:,:),  res_vec)
			;加省界
			plots_p(1) = gsn_add_shapefile_polylines(wks, plots(1), shp_p, shpp)
			;加地形
			; plots_g(1) = gsn_csm_contour(wks, var1, res_g)
;绘制高度场
plots_h(1) = gsn_csm_contour(wks, diff_divw(:,:), res_h)
;加高度场过检定区
plots_zp(1) = gsn_csm_contour(wks, p_zw, res_zw)


;叠图
    overlay(plots(1), plots_h(1))
    ; overlay(plots(1), plots_g(1))
	overlay(plots(1), plots_zp(1))
;	*******************************************************************************
;组图
pres = True
pres@gsnPanelFigureStringsFontHeightF = 0.015
pres@gsnPanelLabelBar = True
gsn_panel(wks, plots, (/1,2/), pres)

draw(plots)
end
