function Tm_Ts = ts2tm(id,doy,Ts)

% 读取nc文件信息
filename = 'D:\develop\TAM1\data\rsme.csv';
line = readmatrix(filename);

for n = 1:24
    if (line(n,1) == id)
        a = line(n,3);b = line(n,4);c = line(n,5);d = line(n,6);e = line(n,7);f = line(n,8);
        break
    end
end

Tm_Ts = a * Ts + b*cos(2*pi*doy/365.25) + c*sin(2*pi*doy/365.25) + d*cos(4*pi*doy/365.25) + e*sin(4*pi*doy/365.25) + f;

end