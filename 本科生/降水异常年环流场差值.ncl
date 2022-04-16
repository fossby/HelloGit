begin
;选定区域
lat1 = 0.0
lat2 = 45.0
lon1 = 60.0
lon2 = 140.0                            
shp_p = "C:\Users\Administrator\Desktop\national_map\yunnan.shp"

f_uv = addfile("E:\workwork\20210731\data\0.25bigmap\x.nc", "r")          ;[time | 720] x [level | 12] x [latitude | 81] x [longitude | 161]
time = f_uv->time
uwnd_0 = f_uv->u(:,:,{lat1:lat2},{lon1:lon2})
vwnd_0 = f_uv->v(:,:,{lat1:lat2},{lon1:lon2})
;公用维度数据
dims = dimsizes(uwnd_0)
;选出5月数据
        ;定义月份
        mon = 5
        ;选出(u风场)特定月份
        uwnd_time_1 = cd_calendar(time, -1)
        uwnd_time_2 = uwnd_time_1 - (uwnd_time_1/100)*100
        uwnd_time_3 = ind(uwnd_time_2.eq.mon)
        ;选出(v风场)特定月份
        vwnd_time_1 = cd_calendar(time, -1)
        vwnd_time_2 = vwnd_time_1 - (vwnd_time_1/100)*100
        vwnd_time_3 = ind(vwnd_time_2.eq.mon)
        ;选出数据
        uwnd_1 = uwnd_0(uwnd_time_3,:,:,:)
        vwnd_1 = vwnd_0(vwnd_time_3,:,:,:)
        printVarSummary(uwnd_1)            ;[time | 60] x [level | 12] x [latitude | 81] x [longitude | 161]
        printVarSummary(vwnd_1)

;定义容器，选出异常强年                             
        s = (/12,14,15,17,20,29,40,41,43/); 
        s_u = new((/dimsizes(s),dims(1),dims(2),dims(3)/),float)
            do j = 0, dimsizes(s)-1
                s_u(j,:,:,:) = uwnd_1(s(j),:,:,:)  
            end do  

            printMinMax(s_u,True)
        s_v = new((/dimsizes(s),dims(1),dims(2),dims(3)/),float)    
            do j = 0, dimsizes(s)-1
                s_v(j,:,:,:) = vwnd_1(s(j),:,:,:)
            end do
            printMinMax(s_v,True)  
;选出异常若年                                      
        w = (/2,8,18,21,22,26,36,44,58/); 

        w_u = new((/dimsizes(w),dims(1),dims(2),dims(3)/),float)
            do i = 0, dimsizes(w)-1
                w_u(i,:,:,:) = uwnd_1(w(i),:,:,:)
            end do  

            printMinMax(w_u,True)
        w_v = new((/dimsizes(w),dims(1),dims(2),dims(3)/),float)    
            do i = 0, dimsizes(w)-1
                w_v(i,:,:,:) = vwnd_1(w(i),:,:,:)
            end do
            printMinMax(w_v, True)
;异常强年：s_u,s_v        异常弱年 w_u,w_v
;=========================================对协同年的要求========================
;不能单纯对 u 或 v 求检验，而应该对风速综合检验
s_wind = wind_speed(s_u, s_v)
w_wind = wind_speed(w_u, w_v)
;显著性检验
x = dim_avg_n_Wrap(s_wind, 0)
y = dim_avg_n_Wrap(w_wind, 0)
var1 = dim_variance_n_Wrap(s_wind, 0)
var2 = dim_variance_n_Wrap(w_wind, 0)
n1 = dimsizes(s)
n2 = dimsizes(w)
df = n1 + n2 -2
;计算t统计量，p概率值
t = (x-y)/(sqrt(((n1-1)*var1 + (n2-1)*var2)*1.0/(n1+n2-2))*sqrt(1.0/n1 + 1.0/n2))
p = student_t(t, df)    
copy_VarMeta(x, p)
printMinMax(p, True)
;绘图
plot = new(4, graphic)
wks = gsn_open_wks("eps", "滇南降水异常年差值")
;主属性
res = True
res@gsnAddCyclic = False
res@gsnFrame = False
res@gsnDraw = False
res@pmTickMarkDisplayMode = True
res@tmXTOn = False
res@tmYROn = False
res@mpMinLatF = lat1
res@mpMaxLatF = lat2
res@mpMinLonF = lon1
res@mpMaxLonF = lon2
res@gsnLeftString = ""
res@gsnRightString = ""
;设置风矢量
;地图
res@mpDataBaseVersion = "MediumRes"
res@mpDataSetName = "Earth..4"
res@mpOutlineOn = True
res@mpOutlineSpecifiers = (/"China:Yunnan"/)

;子图属性，画 200
res1 = res
res1@vcRefAnnoOn = True
res1@vcRefMagnitudeF = 8       ;
res1@vcGlyphStyle = "CurlyVector"
res1@vcRefAnnoOrthogonalPosF = -1.13
res1@vcRefAnnoPerimOn = False
res1@vcRefLengthF = 0.045
res1@vcRefAnnoString2On = True
res1@vcRefAnnoString2 = "8 m/s"
res1@vcRefAnnoString1On = False

;子图属性，画 500
res2 = res
res2@vcRefAnnoOn = True
res2@vcRefMagnitudeF = 5     ;
res2@vcGlyphStyle = "CurlyVector"
res2@vcRefAnnoOrthogonalPosF = -1.13
res2@vcRefAnnoPerimOn = False
res2@vcRefLengthF = 0.045
res2@vcRefAnnoString2On = True
res2@vcRefAnnoString2 = "5 m/s"
res2@vcRefAnnoString1On = False

;子图属性，画 700
res3 = res
res3@vcRefAnnoOn = True
res3@vcRefMagnitudeF = 3     ;
res3@vcGlyphStyle = "CurlyVector"
res3@vcRefAnnoOrthogonalPosF = -1.13
res3@vcRefAnnoPerimOn = False
res3@vcRefLengthF = 0.045
res3@vcRefAnnoString2On = True
res3@vcRefAnnoString2 = "3 m/s"
res3@vcRefAnnoString1On = False
;子图属性，画 850
res4 = res
res4@vcRefAnnoOn = True
res4@vcRefMagnitudeF = 3     ;
res4@vcGlyphStyle = "CurlyVector"
res4@vcRefAnnoOrthogonalPosF = -1.13
res4@vcRefAnnoPerimOn = False
res4@vcRefLengthF = 0.045
res4@vcRefAnnoString2On = True
res4@vcRefAnnoString2 = "3 m/s"
res4@vcRefAnnoString1On = False
;;做差值
;level1
        diffu_level = dim_avg_n_Wrap(s_u(:,:,:,:), 0) - dim_avg_n_Wrap(w_u(:,:,:,:), 0);
        copy_VarMeta(dim_avg_n_Wrap(s_u(:,:,:,:), 0), diffu_level)

        diffv_level = dim_avg_n_Wrap(s_v(:,:,:,:), 0) - dim_avg_n_Wrap(w_v(:,:,:,:), 0);
        copy_VarMeta(dim_avg_n_Wrap(s_v(:,:,:,:), 0), diffv_level) 
                                    ;画相关图
                                        psig = 0.05
                                        sres = res
                                        sres@cnFillColor = "red"
                                        sres@cnLinesOn = False
                                        sres@cnInfoLabelOn = False
                                        sres@cnFillOn = False
                                        sres@lbLabelBarOn = False
                                        sres@cnFillDotSizeF = 0.003
                                        opt = True
                                        opt@gsnShadeFillType = "pattern";color patten
                                        opt@gsnShadeMid =  17                                       
                                        ;
                                        t_student_u = where(p.le.psig,p,p@_FillValue)   ;若概率小于某个值，则把风场放入                                       
                                        copy_VarMeta(diffu_level,t_student_u) 
                                                                            ;
    ;绘制 200 hPa  
                                        t_max_u0 = max(t_student_u({200},:,:))
                                        t_min_u0 = min(t_student_u({200},:,:))
                                     
     plot_u0 = gsn_csm_contour(wks, t_student_u({200},::8,::8), sres)
     plot_u0 = gsn_contour_shade(plot_u0, t_min_u0, t_max_u0, opt)
plot(0) = gsn_csm_vector_map(wks, diffu_level({200},::8,::8), diffv_level({200},::8,::8), res1)
     overlay(plot(0), plot_u0)
    
    ;绘制 500 hPa  
                                        t_max_u1 = max(t_student_u({500},:,:))
                                        t_min_u1 = min(t_student_u({500},:,:))
     plot_u1 = gsn_csm_contour(wks, t_student_u({500},::8,::8), sres)
     plot_u1 = gsn_contour_shade(plot_u1, t_min_u1, t_max_u1, opt)
plot(1) = gsn_csm_vector_map(wks, diffu_level({500},::8,::8), diffv_level({500},::8,::8), res2)
     overlay(plot(1), plot_u1)
    
    ;绘制 700 hPa  
                                        t_max_u2 = max(t_student_u({700},:,:))
                                        t_min_u2 = min(t_student_u({700},:,:))
     plot_u2 = gsn_csm_contour(wks, t_student_u({700},::8,::8), sres)
     plot_u2 = gsn_contour_shade(plot_u2, t_min_u2, t_max_u2, opt)
plot(2) = gsn_csm_vector_map(wks, diffu_level({700},::8,::8), diffv_level({700},::8,::8), res3)
     overlay(plot(2), plot_u2)

    ;绘制 850 hPa  
                                        t_max_u3 = max(t_student_u({850},:,:))
                                        t_min_u3 = min(t_student_u({850},:,:))
     plot_u3 = gsn_csm_contour(wks, t_student_u({850},::8,::8), sres)
     plot_u3 = gsn_contour_shade(plot_u3, t_min_u3, t_max_u3, opt)
plot(3) = gsn_csm_vector_map(wks, diffu_level({850},::8,::8), diffv_level({850},::8,::8), res4)
     overlay(plot(3), plot_u3)
;组图
pres = True
pres@gsnPanelFigureStrings = (/"200 hPa","500 hPa","700 hPa","850 hPa"/)
pres@gsnPanelFigureStringsFontHeightF = 0.012
gsn_panel(wks, plot, (/4,1/), pres)

draw(plot)
frame(wks)
end