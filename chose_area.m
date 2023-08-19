% 功能：利用shp文件，根据经纬度坐标判读其在某个区域中
function id = chose_area(x,y)

%读取当前文件夹下全部csv文档
file=dir('D:\develop\TAM1\area\*.shp');  
Num=length(file);

for n = 1:Num
    name = file(n).name;
    folder = file(n).folder;
    shp_path = strcat(folder,'\',name);   %.shp文件路径 
    Map = shaperead(shp_path);            %读取.shp文件  
    xb = Map.X;                          %边界点的经度坐标
    yb = Map.Y;                          %边界点的纬度坐标
    
    %mapshow(Map);%把地图画出来
    %title(Map.x0xE70xAB0x990xE50x900x8D,Map.x0xE70xAB0x990xE70x820xB90xE50x8F0xB7)
    in = inpolygon(x,y,xb,yb);
    id = nan;
    if in
        id = str2double(name(1:5));
        % name = name(7:end-4);
        break
    end
end







