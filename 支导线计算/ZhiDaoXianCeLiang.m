%% 两个已知点坐标数据打开、读入、关闭
[fn,fp]=uigetfile('*.txt','请选择已知点数据');
fpn=strcat(fp,fn);
fid=fopen(fpn,'r');
if fid==-1
    disp('！！！已知点数据出错！！！');
    return;
end
known_dat=fscanf(fid,'%f',[1,3]);%x,y，方位角
known_dat=known_dat';%与文件数据格式一致
fclose(fid);
%% 观测角度数据打开、读入、关闭
[fn,fp]=uigetfile('*.txt','请选择观测角度数据');
fpn=strcat(fp,fn);
fid=fopen(fpn,'r');
if fid==-1
    disp('！！！观测角度数据出错！！！');
    return;
end
obs_angles=fscanf(fid,'%f');%列向量
obs_angles=obs_angles';%行向量
obs_angles_rad=dms2rad(obs_angles);%度分秒格式转为弧度
obs_angles_count=length(obs_angles);
fclose(fid);
%% 观测距离数据打开、读入、关闭
[fn,fp]=uigetfile('*.txt','请选择观测距离数据');
fpn=strcat(fp,fn);
fid=fopen(fpn,'r');
if fid==-1
    disp('！！！观测距离数据出错！！！');
    return;
end
obs_dis=fscanf(fid,'%f');%列向量
obs_dis=obs_dis';%行向量
obs_dis_count=length(obs_dis);
fclose(fid);
%% 判断角度观测值与距离观测值的个数是否一致
if obs_angles_count==obs_dis_count
    obs_count=obs_dis_count;
else
    disp('！！！观测角度和观测距离个数出错！！！');
    return;
end
%% 计算起始边的方位角
%alfa前=alfa后+左角-180
%alfa前=alfa后-右角+180
alfa_AB=known_dat(3);
alfa_AB_rad=dms2rad(alfa_AB);%起始方位角
alfa_rad(obs_count)=0;%预分配内存
alfa_rad(1)= alfa_AB_rad+obs_angles_rad(1)-pi;%第一个坐标方位角,本案例为左角
for count=2:1:obs_count
   alfa_rad(count) =alfa_rad(count-1)+obs_angles_rad(count)-pi;
end
%% 计算坐标增量
vx=obs_dis.*cos(alfa_rad);
vy=obs_dis.*sin(alfa_rad);
%% 计算未知点的坐标
cal_points(1,1)=known_dat(1)+vx(1);
cal_points(1,2)=known_dat(2)+vy(1);
for count=2:1:obs_count
    cal_points(count,1)= cal_points(count-1,1)+vx(count);
    cal_points(count,2)=cal_points(count-1,2)+vy(count);
end
%% 输出结果
dlmwrite('支导线计算结果.txt',cal_points,'delimiter','\t','precision','%.2f');