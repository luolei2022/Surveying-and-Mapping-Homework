%% ����֪�����ļ������룬�ر�
[fn,fp]=uigetfile('*.txt','��ѡ��ˮ׼�������ļ�'); %��UI����ѡ���ļ�
infile=strcat(fp,fn);%infile�����ļ�·��
fid=fopen(infile,'r');%���ļ�
%�ж��ļ��Ƿ��
if fid==-1
    disp('�������޷�����֪���ݣ�����');
    return;
end
%����ͷ�ļ�����
n=fscanf(fid,'%d',1);%�۲�����
t=fscanf(fid,'%d',1);%��Ҫ�۲����
y=fscanf(fid,'%d',1); %��֪�����
%������֪�̵߳�
yzds(y)=struct('id',[],'h',[]);%����֪�̵߳�ṹ��Ԥ�����ڴ�
for num=1:1:y
    yzds(num).id=fscanf(fid,'%s',1);%��֪����
    yzds(num).h=fscanf(fid,'%f',1);%��֪���Ӧ�ĸ߳�
end
%����δ֪����
wzds_id=fscanf(fid,'%s',[t,1]);
%����۲�ֵ����
obs_num=0;
dis=[];%%��������
obs(n)=struct('qd',[],'zd',[],'h',[],'s',[]);%���۲�ֵ�ṹ��Ԥ�����ڴ�
while ~feof(fid)
    obs_num=obs_num+1;
    obs(obs_num).qd=fscanf(fid,'%s',1);%���id
    obs(obs_num).zd=fscanf(fid,'%s',1);%�յ�id
    obs(obs_num).h=fscanf(fid,'%f',1);%�߲�
    obs(obs_num).s=fscanf(fid,'%f',1);%����
    dis=[ dis, obs(obs_num).s];
  
end
%�ر���֪�����ļ�
fclose(fid);
%% ����δ֪��߳̽���ֵ
H0(t)=struct('id',[],'h',[]);%����֪�̵߳�ṹ��Ԥ�����ڴ�
for wzdcount=1:1:t%�����ѭ��δ֪�㣬�޶�ѭ����������������ж�
    H0(wzdcount).id=wzds_id(wzdcount);
    for obscount=1:1:n%�в�ѭ���۲�ֵ����
        for yzdcount=1:1:y%�ڲ�ѭ����֪�㣬����һ��Ĺ۲�ֵȥƥ����֪��
            if obs(obscount).qd==yzds(yzdcount).id && obs(obscount).zd== wzds_id(wzdcount)
                temp=yzds(yzdcount).h+obs(obscount).h;%���Ϊ��֪�㣬�յ�Ϊ�����δ֪�㣬+
                break;
            elseif obs(obscount).zd==yzds(yzdcount).id && obs(obscount).qd== wzds_id(wzdcount)
                temp=yzds(yzdcount).h-obs(obscount).h;%�յ�Ϊ��֪�㣬���Ϊ�����δ֪�㣬-
                break;                
            end
        end    
    end
    H0(wzdcount).h=temp;
end
%% ����ϵ������B
B=zeros(n,t);
for num=1:1:n
    for count=1:1:t
        if obs(num).qd==wzds_id(count)
            B(num,count)=-1;
            break;
        end
    end %���=δ֪�㣬ϵ������ֵ-1
    for count=1:1:t
        if obs(num).zd==wzds_id(count)
            B(num,count)=1;
            break;
        end
    end %�յ�=δ֪�㣬 ϵ������ֵ+1
end
%% ����Ȩ��P
P=eye(n)./dis;
%% ���㳣�������L
l=zeros(n,1);%��ȫ����ֵΪ0��֮���ֻ����Ϊ0��һ��
for num=1:1:n
    qd=obs(num).qd;
    zd=obs(num).zd;
    for count=1:1:t
       for count2=1:1:t
           if qd==H0(count).id && zd==H0(count2).id
               l(num,1)=obs(num).h+H0(count).h-H0(count2).h;
           end
       end
    end %û����֪�㣬��ֵ->�۲�ֵ�߲�-���յ�߳�-���̣߳�   
end
%% ����ϵ������B��ת��BT
BT=B';
%% ����NBB=BT*P*B
NBB=BT*P*B;
%% ����x=NBB_1*BT*P*l,NBB\BT=inv(NBB)*BT
x=NBB\BT*P*l;
%% ����ƽ���ĸ̵߳�
jieguo(t)=struct('id',[],'h',[]);%������ṹ��Ԥ�����ڴ�
for num=1:1:t
    jieguo(num).id=H0(num).id;
    jieguo(num).h=H0(num).h+x(num);
end
%% ��������
V=B*x-l;
d02=V'*P*V/(n-t);
D=d02*inv(P);
%% ������
fid=fopen('ˮ׼��ƽ����.txt','w');
for num=1:1:t
    fprintf(fid,'%s\t',jieguo(num).id);
    fprintf(fid,'%.3f\n',jieguo(num).h);
end
fclose(fid);
%% �����������
dlmwrite('��������.txt',D,'\t');