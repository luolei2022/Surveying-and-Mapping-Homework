%% 打开已知数据文件，读入，关闭
[fn,fp]=uigetfile('*.txt','请选择水准网数据文件'); %用UI界面选择文件
infile=strcat(fp,fn);%infile——文件路径
fid=fopen(infile,'r');%打开文件
%判断文件是否打开
if fid==-1
    disp('！！！无法打开已知数据！！！');
    return;
end
%读入头文件参数
n=fscanf(fid,'%d',1);%观测总数
t=fscanf(fid,'%d',1);%必要观测个数
y=fscanf(fid,'%d',1); %已知点个数
%读入已知高程点
yzds(y)=struct('id',[],'h',[]);%给已知高程点结构体预分配内存
for num=1:1:y
    yzds(num).id=fscanf(fid,'%s',1);%已知点编号
    yzds(num).h=fscanf(fid,'%f',1);%已知点对应的高程
end
%读入未知点编号
wzds_id=fscanf(fid,'%s',[t,1]);
%读入观测值数据
obs_num=0;
dis=[];%%距离向量
obs(n)=struct('qd',[],'zd',[],'h',[],'s',[]);%给观测值结构体预分配内存
while ~feof(fid)
    obs_num=obs_num+1;
    obs(obs_num).qd=fscanf(fid,'%s',1);%起点id
    obs(obs_num).zd=fscanf(fid,'%s',1);%终点id
    obs(obs_num).h=fscanf(fid,'%f',1);%高差
    obs(obs_num).s=fscanf(fid,'%f',1);%距离
    dis=[ dis, obs(obs_num).s];
  
end
%关闭已知数据文件
fclose(fid);
%% 计算未知点高程近似值
H0(t)=struct('id',[],'h',[]);%给已知高程点结构体预分配内存
for wzdcount=1:1:t%最外层循环未知点，限定循环次数，方便后续判断
    H0(wzdcount).id=wzds_id(wzdcount);
    for obscount=1:1:n%中层循环观测值个数
        for yzdcount=1:1:y%内层循环已知点，用上一层的观测值去匹配已知点
            if obs(obscount).qd==yzds(yzdcount).id && obs(obscount).zd== wzds_id(wzdcount)
                temp=yzds(yzdcount).h+obs(obscount).h;%起点为已知点，终点为最外层未知点，+
                break;
            elseif obs(obscount).zd==yzds(yzdcount).id && obs(obscount).qd== wzds_id(wzdcount)
                temp=yzds(yzdcount).h-obs(obscount).h;%终点为已知点，起点为最外层未知点，-
                break;                
            end
        end    
    end
    H0(wzdcount).h=temp;
end
%% 计算系数矩阵B
B=zeros(n,t);
for num=1:1:n
    for count=1:1:t
        if obs(num).qd==wzds_id(count)
            B(num,count)=-1;
            break;
        end
    end %起点=未知点，系数矩阵赋值-1
    for count=1:1:t
        if obs(num).zd==wzds_id(count)
            B(num,count)=1;
            break;
        end
    end %终点=未知点， 系数矩阵赋值+1
end
%% 计算权阵P
P=eye(n)./dis;
%% 计算常数项矩阵L
l=zeros(n,1);%先全部赋值为0，之后就只看不为0的一项
for num=1:1:n
    qd=obs(num).qd;
    zd=obs(num).zd;
    for count=1:1:t
       for count2=1:1:t
           if qd==H0(count).id && zd==H0(count2).id
               l(num,1)=obs(num).h+H0(count).h-H0(count2).h;
           end
       end
    end %没有已知点，赋值->观测值高差-（终点高程-起点高程）   
end
%% 计算系数矩阵B的转置BT
BT=B';
%% 计算NBB=BT*P*B
NBB=BT*P*B;
%% 计算x=NBB_1*BT*P*l,NBB\BT=inv(NBB)*BT
x=NBB\BT*P*l;
%% 计算平差后的高程点
jieguo(t)=struct('id',[],'h',[]);%给结果结构体预分配内存
for num=1:1:t
    jieguo(num).id=H0(num).id;
    jieguo(num).h=H0(num).h+x(num);
end
%% 精度评价
V=B*x-l;
d02=V'*P*V/(n-t);
D=d02*inv(P);
%% 输出结果
fid=fopen('水准网平差结果.txt','w');
for num=1:1:t
    fprintf(fid,'%s\t',jieguo(num).id);
    fprintf(fid,'%.3f\n',jieguo(num).h);
end
fclose(fid);
%% 输出精度评价
dlmwrite('精度评价.txt',D,'\t');