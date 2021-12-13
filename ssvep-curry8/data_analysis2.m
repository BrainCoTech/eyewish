close;clear;clc;warning off
%%
% 全局变量
n=15;%一次读入的点数，1个点33个字节
global x;
global step;
step=n;%坐标轴补偿，   应该和读入字节数相同
x = 0;

%%
% TCPIP连接设置
interfaceObject=tcpip('127.0.0.1',12345,'NetworkRole','client');%与第一个请求连接的客户机建立连接，端口号为10008，类型为服务器。
interfaceObject.InputBuffersize=33*n;%缓存
interfaceObject.RemoteHost='127.0.0.1';%客户端ip
% 设置一次读取的字节数
bytesToRead = 33*n;

%  定义当输入缓冲区中达到所需字节数时要执行的回调函数  注意：回调函数必须在开启服务之前
interfaceObject.BytesAvailableFcn = {@read,bytesToRead};%可读字节数回调函数，当可读取字节数超过一定范围或者接收特定的结束符时候才调用
interfaceObject.BytesAvailableFcnMode = 'byte';%设置BytesAvailableFcn的函数调用模式
interfaceObject.BytesAvailableFcnCount = bytesToRead;%调用BytesAvailableFcn的字节数
fopen(interfaceObject);%打开服务器，直到建立一个TCP连接才返回；


function read(interfaceObject,~,bytesToRead)
global x;
global ch1;
global ch2;
global ch3;
global ch4;
global ch5;
global ch6;
global ch7;
global ch8;
global ch9;
global step;

global sp1;
global sp2;

global Client;

data_recv = fread(interfaceObject,bytesToRead);
data_recv1=reshape(data_recv,[33,bytesToRead/33]);
data_recv2=data_recv1;
road=data_recv1([3:3:27],:);
data_recv2([3+0:3:27+0],:)=data_recv2([3:3:27],:)*2^16;
data_recv2([3+1:3:27+1],:)=data_recv2([3+1:3:27+1],:)*2^8;
data_recv2([3+2:3:27+2],:)=data_recv2([3+2:3:27+2],:)*2^0;
% 通道
data_channel=ones(9,bytesToRead/33);
for i=1:9
    data_channel(i,:)=sum(data_recv2(3*i:3*i+2,:),1);
end
%查找小于等于2^7的
idx_chn=find(road>=2^7);
%小于等于2^7减去2^24
data_channel(idx_chn)=data_channel(idx_chn)-2^24;

%每一次传输取到的数据在data_channel


ch1 = [ch1 data_channel(1,:)];
ch2 = [ch2 data_channel(2,:)];
ch3 = [ch3 data_channel(3,:)];
ch4 = [ch4 data_channel(4,:)];
ch5 = [ch5 data_channel(5,:)];
ch6 = [ch6 data_channel(6,:)];
ch7 = [ch7 data_channel(7,:)];
ch8 = [ch8 data_channel(8,:)];

ch9 = [ch9 data_channel(9,:)];

x = x + step;
if  x<5000
    title(num2str(x))
%      set(plotHandle1, 'YData',ch1(1:end));
%     %     axis(sp1,[x-5000 x+50 -1*10^3 1*10^3]);
%     xlim(sp1,[x-5000 x+50])
%     
%     set(plotHandle2, 'YData',ch9(1:end));
%     %     axis(sp2,[x-5000 x+50 -1*10^3 1*10^3]);
%     xlim(sp2,[x-5000 x+50])
    
    drawnow
else
%      set(plotHandle1, 'YData',ch1(x-5000:x));
%     %     axis(sp1,[0 5000+50 -1*10^3 1*10^3]);
%     xlim(sp1,[0 5000+50])
%     
%     set(plotHandle2, 'YData',ch9(x-5000:x));
%     %     axis(sp2,[0 5000+50 -1*10^3 1*10^3]);
%     xlim(sp2,[0 5000+50])
    drawnow
    
end
% if  x<5000
% localCloseFigure(,,);
% end

end

%% 关闭回调函数：连接、窗口
function localCloseFigure(figureHandle,~,interfaceObject)
% 清理接口对象
global Client;
fprintf(interfaceObject,'K');%关闭服务
fclose(interfaceObject);%关闭连接
delete(interfaceObject);%删除连接
clear interfaceObject;%清楚连接
% 关闭图像窗口
delete(figureHandle);
% stop(t);
% fclose(Client);
disp("关闭");
end
