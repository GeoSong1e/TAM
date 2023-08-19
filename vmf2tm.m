function Tm = vmf2tm(lat_in,lon_in,elevation,doy)
    % 读vmf_Tm
    Tm_v = load("D:\develop\TAM1\data\vmf_5_year.mat").Tm;
    % 读取格网椭球高ell
    filename = "D:\develop\TAM1\data\ell.csv";
    ell = readmatrix(filename);
    
    % 读取周围四个格网点
    [lat_a,lat_b,lon_a,lon_b] = Grid_4(lat_in,lon_in);

    % 双线性插值
    if (lat_a == lat_b && lon_a == lon_b)
        Tm = vmf(lat_a,lon_a,elevation,doy,Tm_v,ell);
        return
    end
    if (lat_a == lat_b)
        Tm_a = vmf(lat_a,lon_a,elevation,doy,Tm_v,ell);
        Tm_b = vmf(lat_b,lon_b,elevation,doy,Tm_v,ell);
        Tm = ((lon_in-lon_a)/(lon_b-lon_a).*Tm_a + (lon_b-lon_in)/(lon_b-lon_a).*Tm_b);
        return
    end
    if (lon_a == lon_b)
        Tm_a = vmf(lat_a,lon_a,elevation,doy,Tm_v,ell);
        Tm_b = vmf(lat_b,lon_b,elevation,doy,Tm_v,ell);
        Tm = ((lat_b-lat_in)/(lat_b-lat_a).*Tm_b + (lat_in-lat_a)/(lat_b-lat_a).*Tm_a);
        return
    end
    
    % 计算每个格网点的Tm值，并插值至站点位置
    Tm_aa = vmf(lat_a,lon_a,elevation,doy,Tm_v,ell);
    Tm_ab = vmf(lat_a,lon_b,elevation,doy,Tm_v,ell);
    Tm_ba = vmf(lat_b,lon_a,elevation,doy,Tm_v,ell);
    Tm_bb = vmf(lat_b,lon_b,elevation,doy,Tm_v,ell);
    
    Tm_1 = ((lon_in-lon_a)/(lon_b-lon_a).*Tm_aa + (lon_b-lon_in)/(lon_b-lon_a).*Tm_ab);
    Tm_2 = ((lon_in-lon_a)/(lon_b-lon_a).*Tm_ba + (lon_b-lon_in)/(lon_b-lon_a).*Tm_bb);
    Tm = ((lat_b-lat_in)/(lat_b-lat_a).*Tm_2 + (lat_in-lat_a)/(lat_b-lat_a).*Tm_1);

end

% 获取目标点周围4个坐标
function [lat_a,lat_b,lon_a,lon_b] = Grid_4(lat,lon)
% 读取VMF格网数据，计算所在四个格网点坐标
vmf_lat=(90:-2:-90); 
vmf_lon=(0:2.5:360);

% 纬度格网范围计算
for n = 1:length(vmf_lat)
    if lat==vmf_lat(n)
        lat_a = vmf_lat(n);lat_b = vmf_lat(n);
    end
    if (lat<vmf_lat(n) && lat>vmf_lat(n+1))
        lat_b = vmf_lat(n);lat_a = vmf_lat(n+1);
    end
end
% 经度格网范围计算
for n = 1:length(vmf_lon)
    if lon==vmf_lon(n)
        lon_a = vmf_lon(n);lon_b = vmf_lon(n);
    end
    if (lon>vmf_lon(n) && lon<vmf_lon(n+1))
        lon_a = vmf_lon(n);lon_b = vmf_lon(n+1);
    end
end

end


function Tm = vmf(lat_in,lon_in,h,doy,Tm_v,ell)    
    lat = (90:-2:-90); 
    lon = (0:2.5:360);
    Tm_un(:,:) = Tm_v(lat ==lat_in,lon ==lon_in,:);
    h_grid = ell(lat ==lat_in,lon ==lon_in)/1000;
    
    % 读取P值,并扩成四倍长度
    filename = strcat('D:\develop\TAM1\data\P值\',num2str(lon_in),'_',num2str(lat_in),'_','p1p2p3p4.csv');
    p = readmatrix(filename);P = p(doy,:);
    % 获取p1、p2、p3值
    p1 = P(:,2);p2 = P(:,3);p3 = P(:,4);  
    Tm_doy = (1/20) * (Tm_un(4*doy)+Tm_un(4*doy-1)+Tm_un(4*doy-2)+Tm_un(4*doy-3) ...
        + Tm_un(1460+4*doy)+Tm_un(1460+4*doy-1)+Tm_un(1460+4*doy-2)+Tm_un(1460+4*doy-3) ...
        + Tm_un(2920+4*doy)+Tm_un(2920+4*doy-1)+Tm_un(2920+4*doy-2)+Tm_un(2920+4*doy-3) ...
        + Tm_un(4380+4*doy)+Tm_un(4380+4*doy-1)+Tm_un(4380+4*doy-2)+Tm_un(4380+4*doy-3) ...
        + Tm_un(5844+4*doy)+Tm_un(5844+4*doy-1)+Tm_un(5844+4*doy-2)+Tm_un(5844+4*doy-3));
    clear P PP PPP ell Tm_v p Tm_un
    h = h / 1000;
    Tm = Tm_doy + p1*(h^3 - h_grid^3) + p2*(h^2 - h_grid^2) + p3*(h - h_grid);
end