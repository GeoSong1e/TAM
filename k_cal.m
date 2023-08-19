% 计算K值
function k = k_cal(lon,lat)
    id = chose_area(lon,lat);
    if isnan(id)
        disp("您输入的经纬度有误！请重新输入")
        k = nan;
        return
    end
    file = strcat('D:\develop\TAM1\area\', num2str(id),'.shp');  
    Map = shaperead(file);            %读取.shp文件  
    xb = Map.X;                          %边界点的经度坐标
    yb = Map.Y;                          %边界点的纬度坐标
    filename = "D:\develop\TAM1\data\站点.csv";station = readmatrix(filename);
    index = find(station(:,1)== id);
    lat_s = station(index,3);lon_s = station(index,4);
    % 构建shp区域多边形
    poly_shp = polyshape(xb,yb);
    % 构建点与站点的线段
    if lon - lon_s ==0
        k = 1;
        return
    end
    k = (lat - lat_s)/(lon - lon_s);
    b = lat - lon*k;
    if (lon - lon_s) > 0
        lineseg = [lon_s lat_s ;lon_s+5,k*(lon_s+5)+b];
    else
        lineseg = [lon_s lat_s ;lon_s-5,k*(lon_s-5)+b];
    end
    [in,~] = intersect(poly_shp,lineseg);
    % 得到交点
    j_lon = in(2,1);j_lat = in(2,2);
    % 计算K值
    %distance = norm([j_lat j_lon]-[lat_s lon_s]);
    %dis = norm([lat lon]-[lat_s lon_s]);
    %k = 1 - dis/distance;    
    dis1 = distance(j_lat,j_lon,lat_s,lon_s);
    dis2 = distance(lat,lon,lat_s,lon_s);
    k = 1 - dis2/dis1;

    % 画图
%     plot(poly_shp)
%     hold on
%     scatter(lon_s,lat_s,100,"r","pentagram","filled")
%     hold on 
%     scatter(lon,lat,50,"blue","filled")
%     hold on
%     plot(in(:,1),in(:,2),'b',out(:,1),out(:,2),'r')
end