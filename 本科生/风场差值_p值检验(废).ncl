;	---		要求：依据 WMI指数绘制高度场风场的差值场,先选择出 5 月的风场，位势高度场
;	---			  1.使用纬向 u 风做检定（虽然觉得不应该太正确，但确实先这么做，如果做完后，可以研究如何编辑李建平的公式） 
 begin          
;   ---------------------------地形相关------------
;增大工作空间
  setvalues NhlGetWorkspaceObjectId()    
  "wsMaximumSize": 600000000
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
f_uv = addfile("/mnt/e/workwork/20211025/data/uv_5.nc", "r")
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
level = 850           ;高度
windspeed = 2		  ;基准风速
vector_dist = 0.05
style = "eps"
;提取变量
u = f_uv->u(:,{level},:,:)
v = f_uv->v(:,{level},:,:)
;计算气候态
dims = dimsizes(u)
u_clm = dim_avg_n_Wrap(u, 0)
v_clm = dim_avg_n_Wrap(v, 0)                           ;[month | 12] x [latitude | 161] x [longitude | 401]
;选出强年
diff_us = dim_avg_n_Wrap(u(ind(pre.ge.1),:,:), 0) - dim_avg_n_Wrap(u, 0)
diff_vs = dim_avg_n_Wrap(v(ind(pre.ge.1),:,:), 0) - dim_avg_n_Wrap(v, 0)
;选出弱年
diff_uw = dim_avg_n_Wrap(u(ind(pre.le.-1),:,:), 0) - dim_avg_n_Wrap(u, 0)
diff_vw = dim_avg_n_Wrap(v(ind(pre.le.-1),:,:), 0) - dim_avg_n_Wrap(v, 0)
copy_VarMeta(u_clm, diff_uw)
copy_VarMeta(u_clm, diff_vw)
copy_VarMeta(u_clm, diff_us)
copy_VarMeta(u_clm, diff_vs)	
;-------------------------------------------------检验区域----------------
iflag = False
tval_opt = False
;强年的检验（u风速）
ave1 = dim_avg_n_Wrap(u(ind(pre.ge.1),:,:), 0)
var1 = dim_variance_n_Wrap(u(ind(pre.ge.1),:,:), 0)
s1 = dimsizes(ind(pre.ge.1))
ave2 = dim_avg_n_Wrap(u, 0)
var2 = dim_variance_n_Wrap(u, 0)
s2 = 60
p_s = ttest(ave1, var1, s1, ave2, var2, s2, iflag, tval_opt)
copy_VarMeta(ave1, p_s)
delete(ave1)
delete(var1)
delete(s1)
delete(ave2)
delete(var2)
delete(s2)
					;弱年的检验（风速）
					ave1 = dim_avg_n_Wrap(u(ind(pre.le.-1),:,:), 0)
					var1 = dim_variance_n_Wrap(u(ind(pre.le.-1),:,:), 0)
					s1 = dimsizes(ind(pre.le.-1))
					ave2 = dim_avg_n_Wrap(u, 0)
					var2 = dim_variance_n_Wrap(u, 0)
					s2 = 60
					p_w = ttest(ave1, var1, s1, ave2, var2, s2, iflag, tval_opt)
					copy_VarMeta(ave1, p_w)
					printMinMax(p_w, True)     
					delete(ave1)
					delete(var1)
					delete(s1)
					delete(ave2)
					delete(var2)
					delete(s2)
;********************************************绘图要素**********************
;强年
;绘图
plots = new(2, graphic)         ;绘制风场
plots_vp = new(2, graphic)      ;绘制风场显著性
plots_p = new(2, graphic)		;绘制省界
plots_g = new(2, graphic)       ;地形
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
; ;轴坐标向内
;   res@tmXBMajorOutwardLengthF = -0.0
;   res@tmYLMajorOutwardLengthF = -0.0
;   res@gsnLeftStringOrthogonalPosF = 0.0
;上坐标、右坐标轴去刻度
  res@tmXTOn = False
  res@tmYROn = False
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
res_g@lbLabelBarOn    = False
;res_g@cnFillOpacityF  = 0
res_g@gsnDraw = False
res_g@gsnFrame = False
;叠加shp文件,画省界限
shpp = True
shpp@gsLineColor = "black"
shpp@gsLineThicknessF = 1.0
;;绘制矢量
res_vec = res
res_vec@vcRefAnnoOn = True
res_vec@vcRefMagnitudeF = windspeed       ;600画12m/s ，850hpa画 8m/s
res_vec@vcGlyphStyle = "FillArrow"
res_vec@vcRefAnnoOrthogonalPosF = -1.25
res_vec@vcRefAnnoPerimOn = False
res_vec@vcRefLengthF = 0.045

res_vec@vcRefAnnoString2On = True
res_vec@vcRefAnnoString2 = tostring(windspeed)+" m/s"
res_vec@vcRefAnnoString1On = False
res_vec@vcMinDistanceF  = vector_dist
res_vec@mpMinLatF = lat1
res_vec@mpMaxLatF = lat2
res_vec@mpMinLonF = lon1
res_vec@mpMaxLonF = lon2
res_vec@mpFillOn = False
res_vec@gsnLeftStringOrthogonalPosF = -0.22
;绘制过检定的风速区
res_vp0 = res
res_vp0@cnFillOn = True
res_vp0@cnLinesOn = False
res_vp0@cnFillPalette = "gscyclic"
res_vp0@cnLevelSelectionMode = "ExplicitLevels"
res_vp0@cnLevels = p_value
res_vp0@cnFillColors = (/5,-1/)
res_vp0@lbLabelBarOn = False
res_vp0@cnFillDrawOrder = "PreDraw"
res_vp0@cnInfoLabelOn = False
res_vp0@cnLineLabelsOn = False
res_vp0@cnFillOpacityF = 0.7
;res_vp0@trGridType = "TriangularMesh"

res_vp1 = res_vp0
res_vec0 = res_vec
res_vec0@gsnLeftString = "(e)"
;绘制强年过显区

plots(0) = gsn_csm_vector_map(wks, diff_us(:,:), diff_vs(:,:), res_vec0)
			;加省界
			plots_p(0) = gsn_add_shapefile_polylines(wks, plots(0), shp_p, shpp)
			;加地形
			plots_g(0) = gsn_csm_contour(wks, var, res_g)
;绘制强年风场过检定区（灰色）
plots_vp(0) = gsn_csm_contour(wks, p_s, res_vp0)
;叠图
	overlay(plots(0), plots_vp(0))	     ;叠风场显著区域
    overlay(plots(0), plots_g(0))			 ;叠地形
;绘制弱年
res_vec1 = res_vec
res_vec1@gsnLeftString = "(f)"
plots(1) = gsn_csm_vector_map(wks, diff_uw(:,:), diff_vw(:,:),  res_vec1)
			;加省界
			plots_p(1) = gsn_add_shapefile_polylines(wks, plots(1), shp_p, shpp)
			;加地形
			plots_g(1) = gsn_csm_contour(wks, var, res_g)
plots_vp(1) = gsn_csm_contour(wks, p_w, res_vp1)
;叠图
	overlay(plots(1), plots_vp(1))	         ;叠风场检定区
    overlay(plots(1), plots_g(1))			 ;叠地形
;组图
pres = True
gsn_panel(wks, plots, (/1,2/), pres)
draw(plots)
end
