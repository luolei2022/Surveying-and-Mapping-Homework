%% ������֪���������ݴ򿪡����롢�ر�
[fn,fp]=uigetfile('*.txt','��ѡ����֪������');
fpn=strcat(fp,fn);
fid=fopen(fpn,'r');
if fid==-1
    disp('��������֪�����ݳ�������');
    return;
end
known_dat=fscanf(fid,'%f',[1,3]);%x,y����λ��
known_dat=known_dat';%���ļ����ݸ�ʽһ��
fclose(fid);
%% �۲�Ƕ����ݴ򿪡����롢�ر�
[fn,fp]=uigetfile('*.txt','��ѡ��۲�Ƕ�����');
fpn=strcat(fp,fn);
fid=fopen(fpn,'r');
if fid==-1
    disp('�������۲�Ƕ����ݳ�������');
    return;
end
obs_angles=fscanf(fid,'%f');%������
obs_angles=obs_angles';%������
obs_angles_rad=dms2rad(obs_angles);%�ȷ����ʽתΪ����
obs_angles_count=length(obs_angles);
fclose(fid);
%% �۲�������ݴ򿪡����롢�ر�
[fn,fp]=uigetfile('*.txt','��ѡ��۲��������');
fpn=strcat(fp,fn);
fid=fopen(fpn,'r');
if fid==-1
    disp('�������۲�������ݳ�������');
    return;
end
obs_dis=fscanf(fid,'%f');%������
obs_dis=obs_dis';%������
obs_dis_count=length(obs_dis);
fclose(fid);
%% �жϽǶȹ۲�ֵ�����۲�ֵ�ĸ����Ƿ�һ��
if obs_angles_count==obs_dis_count
    obs_count=obs_dis_count;
else
    disp('�������۲�ǶȺ͹۲���������������');
    return;
end
%% ������ʼ�ߵķ�λ��
%alfaǰ=alfa��+���-180
%alfaǰ=alfa��-�ҽ�+180
alfa_AB=known_dat(3);
alfa_AB_rad=dms2rad(alfa_AB);%��ʼ��λ��
alfa_rad(obs_count)=0;%Ԥ�����ڴ�
alfa_rad(1)= alfa_AB_rad+obs_angles_rad(1)-pi;%��һ�����귽λ��,������Ϊ���
for count=2:1:obs_count
   alfa_rad(count) =alfa_rad(count-1)+obs_angles_rad(count)-pi;
end
%% ������������
vx=obs_dis.*cos(alfa_rad);
vy=obs_dis.*sin(alfa_rad);
%% ����δ֪�������
cal_points(1,1)=known_dat(1)+vx(1);
cal_points(1,2)=known_dat(2)+vy(1);
for count=2:1:obs_count
    cal_points(count,1)= cal_points(count-1,1)+vx(count);
    cal_points(count,2)=cal_points(count-1,2)+vy(count);
end
%% ������
dlmwrite('֧���߼�����.txt',cal_points,'delimiter','\t','precision','%.2f');