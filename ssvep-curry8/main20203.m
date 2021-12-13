  close all;clear all;clc;clear mex;
% -------------------------------------------------------------------------
%改造成连续刺激，from 2020 timer run
Screen('Preference', 'SkipSyncTests', 1);
% 检测屏幕的刷新频率是否为60Hz
if Screen('FrameRate',0)~=60
    disp('屏幕刷新频率不是60Hz');
    return;
end
frame_rate = 60;

%刺激参数
% -------------------------------------------------------------------------
% 各目标的刺激频率
global freq;
freq = [7,9,11,13];
% 刺激呈现的时间
displayTime = 240;
restDelay = 0.4;
trialnum = 1;

%反应步长和处理窗口,数据积累到窗口长度才开始处理结果和开始滑动步长。
inter=0.4;
global win;
win=1;
global point;%记录当前位置。 在timer中给出反馈结果。并且反馈结果要刺激程序实时获取到。
point=0;
% -------------------------------------------------------------------------
% 实时数据传输时的设备参数设置
global chanum;
chanum = 8; %所有通道数(枕区8导+1导光电trigger）
sampleRate = 1000;%采样率

dataLength = displayTime + restDelay;

%dataBuffer =33*15;
global buffSize;
buffSize = round(sampleRate*dataLength); %这是数据总长，全程记录数据
global data_received;
data_received = zeros(buffSize,chanum+1);
global winnum;
winnum=win*sampleRate;
global circBuff;
circBuff = zeros(winnum,chanum+1);
global internum;
internum=inter*sampleRate;
global x;
x=0;
global step;
step=15;
global interfaceObject;


%tcpip端口设置
interfaceObject=tcpip('127.0.0.1',12345,'NetworkRole','client');%与第一个请求连接的客户机建立连接，端口号为10008，类型为服务器。
interfaceObject.InputBuffersize=33*15;%缓存
interfaceObject.RemoteHost='127.0.0.1';%客户端ip
% 设置一次读取的字节数
global bytesToRead;
bytesToRead = 33*15;
fopen(interfaceObject);%打开服务器，直到建立一个TCP连接才返回；
%打开后就已经在传输数据了。
%pause(2);

% -------------------------------------------------------------------------
try
    % ---------------------------------------------------------------------
    AssertOpenGL;
    % ---------------------------------------------------------------------
    % 打开screen
    Screens = Screen('Screens');
    ScreenNum = max(Screens); 
    [w, rect] = Screen('OpenWindow', ScreenNum);
    Screen('Preference', 'SkipSyncTests', 1);%跳过帧同步检测，避免受显卡和驱动的影响
    Priority(MaxPriority(w)); % 将此刺激程序在CPU执行队列中的优先级提高到最高级别
    params.vertical = rect(4); % 得到屏幕的垂直分辨率
    params.horiz = rect(3); % 得到屏幕的水平分辨率
    black = BlackIndex(w);
    white = WhiteIndex(w);
    Screen('TextColor', w,white);%白色字
    Screen('FillRect',w, white/2);%黑色底
   
    % 显示的图片 读取矩阵 制作纹理
    stim_represent = imread('target.bmp');
    texturetarget = Screen('MakeTexture', w, stim_represent);%用来标记识别目标
    stim_represent = imread('frame_1.jpg');
    textureGUI = Screen('MakeTexture', w, stim_represent);%第一帧
     stim_represent = imread('frame_3.jpg');
    textureGUI2 = Screen('MakeTexture', w, stim_represent);%源图帧
    
     rectp1 = [180 180];%刺激块大小
    % ---------------------------------------------------------------------
global changex;
    changex=0;
global changey;
    changey=0;
    % 图片1在屏幕上的位置
    p1horiz = params.horiz/2 - rectp1(1)/2 *3 - 100-100+changex;
    p1verti = params.vertical/2 - rectp1(2)/2+changey;
    rect1 = [p1horiz p1verti p1horiz+rectp1(1) p1verti+rectp1(2)];
    %
    p2horiz = params.horiz/2 - rectp1(1)/2 - 100-50+changex;
    p2verti = params.vertical/2 - rectp1(2)/2+changey;
    rect2 = [p2horiz p2verti p2horiz+rectp1(1) p2verti+rectp1(2)];
    %
    p3horiz = params.horiz/2 + rectp1(1)/2- 100+changex;
    p3verti = params.vertical/2 - rectp1(2)/2+changey;
    rect3 = [p3horiz p3verti p3horiz+rectp1(1) p3verti+rectp1(2)];
    %
    p4horiz = params.horiz/2 + rectp1(1)/2 *3 -50+changex;
    p4verti = params.vertical/2 - rectp1(2)/2+changey;
    rect4 = [p4horiz p4verti p4horiz+rectp1(1) p4verti+rectp1(2)];
    cond_horiz = {'p1horiz','p2horiz','p3horiz','p4horiz'};
    cond_verti = {'p1verti','p2verti','p3verti','p4verti'};
    recti = {'rect1','rect2','rect3','rect4'};
    % ---------------------------------------------------------------------
    Screen('DrawTextures',w,textureGUI);%初始帧
    Screen('Flip',w);
 %   pause(3);
 
%设置定时器，用于连续读取缓冲区的脑电信号
t=timer('Name','geteegdata','TimerFcn',{@read},'Period',0.005,'ExecutionMode','fixedSpacing');
t2=timer('Name','controlfb','TimerFcn',{@move},'Period',0.4,'ExecutionMode','fixedSpacing');
pause(2);
%计时器开始工作，记录脑电
move();
start(t);
start(t2);
     % ---------------------------------------------------------------------
    waitframes = 1;
    % ---------------------------------------------------------------------
    for ii = 1:trialnum
        % -----------------------------------------------------------------
        % SSVEP任务
        count1 = 0;
        ifi = Screen('GetFlipInterval', w);
        vbl = Screen('Flip', w);
        vblendtime = vbl + displayTime;
        while(vbl < vblendtime)
            % -------------------------------------------------------------
         %   Screen('DrawTexture',w,textureGUI,[],[],[],0);%初始帧
            % -------------------------------------------------------------
            count1 = count1 + 1;
            for jj = 1:4
                str = 'rectx';
                eval([str,'=',recti{jj},';']);
                 rectx=rectx+[changex changey changex changey];%位置实时变化
                weight = (1+sin(2*pi*freq(jj)*count1/frame_rate))/2;%频率调制
                Screen('DrawTextures',w,textureGUI2,[],rectx,[],0,[],weight*[255 255 255]);%在同一个画布上控制不同的局部纹理的亮度

            end
            % -------------------------------------------------------------
            Screen('DrawingFinished', w);
            % -------------------------------------------------------------
            if count1==1            
                % 开始准备数据，如果需要重新来过
             x=0;
            data_received = zeros(buffSize, 9);       
             circBuff = zeros(winnum, 9);      
            end
            % -------------------------------------------------------------
            vbl = Screen('Flip', w, vbl + (waitframes - 0.5) * ifi);
        end
        % -----------------------------------------------------------------
         start2 = GetSecs();
        now2 = GetSecs();
        while(now2 < start2 + restDelay)
        %    Screen('DrawTextures',w,textureGUI);%初始帧
            Screen('Flip',w);
            now2 = GetSecs();
        end
        % -----------------------------------------------------------------
        % 停止发送数据
      %     circBuff = reshape(data_received,buffSize, 9);
        % -----------------------------------------------------------------
        Screen('DrawTextures',w,textureGUI);       
      
    end
    % ---------------------------------------------------------------------

    Screen('CloseAll');
    %停止计时器
stop(t);
stop(t2);
%删除计时器
delete(t);
delete(t2);

    % 恢复到此程序运行的原有优先级别
    Priority(0);
    
    %关闭与服务端连接，停止接收脑电数据
     fclose(interfaceObject);
     delete(interfaceObject);

%     % 释放mex可执行文件在内存中所占的空间
     clear mex;
    disp('the experiment is over');
catch ME

%     ShowCursor;
    Screen('CloseAll');
    %停止计时器
stop(t);
stop(t2);
%删除计时器
delete(t);
delete(t2);
    Priority(0);
    %关闭与服务端连接，停止接收脑电数据
     fclose(interfaceObject);%关闭连接
     delete(interfaceObject);%删除连接
     clear mex;
    psychrethrow(psychlasterror);
    rethrow(ME);
end


function read(~,~)
global x;
global interfaceObject;
global bytesToRead;
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

%每一次传输取到的数据在data_channel（9，15）
%积累数据。
global buffSize;
global data_received;
global x;
global step;

if  x+ step< buffSize||x+ step == buffSize
    %装载 
    data_received((x + 1) : (x + step), :) = data_channel';
    x = x + step;
end


end



 function move(~,~)

global x;
global changex;
global changey;
global data_received;
global circBuff;
global internum;
global win;
global winnum;
global chanum;
global point;
global freq;

%获取待处理数据
if x> point+winnum-1
    circBuff = zeros(winnum, 9);
    circBuff =data_received(point+1:point+winnum,:);
    point=point+internum;
    
     %------------------------------------------------------------------
%         % remove baseline
         circBuff = circBuff';
         circBuff = circBuff - repmat(median(circBuff,2),1,winnum);
         circBuff = circBuff';
        %------------------------------------------------------------------
         resultnum = onlineAnalysis(circBuff,win,chanum,freq);
 %resultnum=3;
 %pause(0.1);
      switch resultnum
            case 1 
                changex=changex-10;%left
            case 2
                 changey=changey+10;%down
            case 3
                 changey=changey-10;%up
            case 4
                 changex=changex+10;%right
      end    
    
end

end
