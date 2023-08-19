function Tm =nc2tm(lat_in,lon_in,elevation,doy)
    Tm_17 = nc2tm_oneyear(lat_in,lon_in,elevation,doy,'D:\develop\TAM1\data\2017.nc');
    Tm_18 = nc2tm_oneyear(lat_in,lon_in,elevation,doy,'D:\develop\TAM1\data\2017.nc');
    Tm_19 = nc2tm_oneyear(lat_in,lon_in,elevation,doy,'D:\develop\TAM1\data\2017.nc');
    Tm_20 = nc2tm_oneyear(lat_in,lon_in,elevation,doy,'D:\develop\TAM1\data\2017.nc');
    Tm_21 = nc2tm_oneyear(lat_in,lon_in,elevation,doy,'D:\develop\TAM1\data\2017.nc');
    Tm = 1/5 *(Tm_17 + Tm_18 + Tm_19 + Tm_20 + Tm_21);
end

function Tm = nc2tm_oneyear(lat_in,lon_in,elevation,doy,filename)

% 读取nc文件信息
% filename = 'D:\develop\TAM1\data\NEED\2017.nc';
% ncdisp(filename)

% 经纬度范围获取
lon = ncread(filename,'longitude');
lat = ncread(filename,'latitude');

% 读取相对湿度、位势、温度
r = ncread(filename,'r');    
z = ncread(filename,'z');              % 位势转位势高
t = ncread(filename,'t');              % 温度
%-------------------------------------------------------------3.6070s------

% 根据DOY筛选时间
DOY = doy;
% 应加入四个格网点坐标，避免重复读取
[lat_a,lat_b,lon_a,lon_b] = Grid_4(lat_in,lon_in);

% 当站点就在网格点上需要分情况进行计算
if (lat_a == lat_b && lon_a == lon_b)
    Tm = cal_nc(lon_a,lat_a,DOY,elevation,z,r,t,lon,lat);
    return
end
if (lat_a == lat_b)
    Tm_a = cal_nc(lon_a,lat_a,DOY,elevation,z,r,t,lon,lat);
    Tm_b = cal_nc(lon_b,lat_b,DOY,elevation,z,r,t,lon,lat);
    Tm = ((lon_in-lon_a)/(lon_b-lon_a).*Tm_a + (lon_b-lon_in)/(lon_b-lon_a).*Tm_b);
    return
end
if (lon_a == lon_b)
    Tm_a = cal_nc(lon_a,lat_a,DOY,elevation,z,r,t,lon,lat);
    Tm_b = cal_nc(lon_b,lat_b,DOY,elevation,z,r,t,lon,lat);
    Tm = ((lat_b-lat_in)/(lat_b-lat_a).*Tm_b + (lat_in-lat_a)/(lat_b-lat_a).*Tm_a);
    return
end

% 计算每个格网点的Tm值，并插值至站点位置
Tm_aa = cal_nc(lon_a,lat_a,DOY,elevation,z,r,t,lon,lat);
Tm_ab = cal_nc(lon_a,lat_b,DOY,elevation,z,r,t,lon,lat);
Tm_ba = cal_nc(lon_b,lat_a,DOY,elevation,z,r,t,lon,lat);
Tm_bb = cal_nc(lon_b,lat_b,DOY,elevation,z,r,t,lon,lat);

Tm_1 = ((lon_in-lon_a)/(lon_b-lon_a).*Tm_aa + (lon_b-lon_in)/(lon_b-lon_a).*Tm_ab);
Tm_2 = ((lon_in-lon_a)/(lon_b-lon_a).*Tm_ba + (lon_b-lon_in)/(lon_b-lon_a).*Tm_bb);
Tm = ((lat_b-lat_in)/(lat_b-lat_a).*Tm_2 + (lat_in-lat_a)/(lat_b-lat_a).*Tm_1);
end

% 获取目标点周围4个坐标
function [lat_a,lat_b,lon_a,lon_b] = Grid_4(lat,lon)
% 读取ERA5格网数据，计算所在四个格网点坐标
era5_lon=(72:0.25:113); 
era5_lat=(50:-0.25:30);

% 纬度格网范围计算
for n = 1:length(era5_lat)
    if lat==era5_lat(n)
        lat_a = era5_lat(n);lat_b = era5_lat(n);
    end
    if (lat<era5_lat(n) && lat>era5_lat(n+1))
        lat_b = era5_lat(n);lat_a = era5_lat(n+1);
    end
end
% 经度格网范围计算
for n = 1:length(era5_lon)
    if lon==era5_lon(n)
        lon_a = era5_lon(n);lon_b = era5_lon(n);
    end
    if (lon>era5_lon(n) && lon<era5_lon(n+1))
        lon_a = era5_lon(n);lon_b = era5_lon(n+1);
    end
end

end

% 计算Tm
function Tm = cal_nc(lon_in,lat_in,DOY,elevation,z,r,t,lon,lat)
% 读取DOY数据，减少运算时间
z_temp(:,:) = z(lon ==lon_in,lat ==lat_in,:,2*DOY-1:2*DOY);    % 位势
r_temp(:,:) = r(lon ==lon_in,lat ==lat_in,:,2*DOY-1:2*DOY);    % 相对湿度
t_temp(:,:) = t(lon ==lon_in,lat ==lat_in,:,2*DOY-1:2*DOY);    % 温度

% ------------------高度改正--------------------------------
% 位势转为位势 g = 9.80665
z_temp = z_temp / 9.80665;
% 地球有效半径
R_lat = 6778137 / (1.006803 - 0.006706 * sin(lat_in)^2 );
% 旋转椭球正常重力值
Y_lat = 9.780325 * ((1 + 0.00193185 * sin(lat_in)^2) / (1 - 0.0069435 * sin(lat_in)^2))^(1/2);
% Y45 在纬度45°时，海平面位置的重力加速度(m/s2)
Y45 = 9.80665;  
% 位势高转为正高
h_a = (R_lat * Y45 .* z_temp)./(Y_lat * R_lat - Y45 .* z_temp);
% 正高转为正常高，利用EGM2008提供的高程信息进行改正
filename = "D:\develop\TAM1\data\era5_gem.dat";  gem = readmatrix(filename);
for i = 1:length(gem)
    if(gem(i,2) == lat_in && gem(i,1) == lon_in)
        N_08 = gem(i,3);
        break
    end
end
z_temp = h_a + N_08; 
%---------------------------------------------------------------


% 计算饱和水汽压
Es = 6.105 .* exp(25.22 .* (t_temp -273.15)./t_temp - 5.31 .*log(t_temp./273.15));

% 计算水汽压
e = r_temp .* Es ./ 100;

for t = 1:2
    for level =37:-1:1
        if ((elevation > z_temp(level,t)) && (elevation < z_temp(level-1,t)))
            
            level_a = level; level_b = level_a - 1;  level_list(1,t) = level;  
            if level ==37
                level_list = level_list -1;
            end

            z_a = z_temp(level_a,t);z_b = z_temp(level_b,t);
            
            r_a = r_temp(level_a,t);r_b = r_temp(level_b,t);
            t_a = t_temp(level_a,t);t_b = t_temp(level_b,t);
            e_a = e(level_a,t);e_b = e(level_b,t);

            r_elevation = ((z_b-elevation)/(z_b-z_a)) * r_b + ((elevation-z_a)/(z_b-z_a)) * r_a;
            t_elevation = ((z_b-elevation)/(z_b-z_a)) * t_b + ((elevation-z_a)/(z_b-z_a)) * t_a;
            e_elevation = ((z_b-elevation)/(z_b-z_a)) * e_b + ((elevation-z_a)/(z_b-z_a)) * e_a;
            
            z_temp(level_a,t) = elevation;
            r_temp(level_a,t) = r_elevation;
            t_temp(level_a,t) = t_elevation;
            e(level_a,t) = e_elevation;
            continue
        end
    end
end

clear level_a level_b r_a r_b t_a t_b e_a e_b r_elevatio t_elevation e_elevation 
%计算大气平均加权温度Tm%

for m = 1: 2
    for n = 1:level_list(1,t)-1
%     for n = 1:36    
        de_1(n,m) = (e(n,m)./t_temp(n,m) + e(n+1,m)./t_temp(n+1,m))./2 .* abs(z_temp(n,m)-z_temp(n+1,m));
        de_2(n,m) = (e(n,m)./t_temp(n,m).^2 + e(n+1,m)./t_temp(n+1,m).^2)./2 .* abs(z_temp(n,m)-z_temp(n+1,m));
    end
    Tm(m,1) = sum(de_1(:,m))/sum(de_2(:,m));
    clear de_1 de_2
end
    Tm = mean(Tm);
end
