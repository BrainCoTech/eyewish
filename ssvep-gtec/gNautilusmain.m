% This is a demo script for the use of g.Nautilus in the g.NEEDaccess
% MATLAB API.
% It records data for 10 seconds from all analog channels available using
% the internal test signal and plots it offline after acquisition.
 close all;clear all;clc;
% -------------------------------------------------------------------------
Screen('Preference', 'SkipSyncTests', 1);
% 检测屏幕的刷新频率是否为60Hz
if Screen('FrameRate',0)~=60
    disp('屏幕刷新频率不是60Hz');
    return;
end
frame_rate = 60;

% -------------------------------------------------------------------------
% 各目标的刺激频率
freq = [8,9,11,12];
% -------------------------------------------------------------------------
% 刺激呈现的时间
displayTime = 4;
restDelay = 0.4;
trialnum = 12;


% create gtecDeviceInterface object
global gds_interface
gds_interface = gtecDeviceInterface();

% define connection settings (loopback)
gds_interface.IPAddressHost = '127.0.0.1';
gds_interface.IPAddressLocal = '127.0.0.1';
gds_interface.LocalPort = 50224;
gds_interface.HostPort = 50223;

% get connected devices
connected_devices = gds_interface.GetConnectedDevices();

% create g.Nautilus configuration object
gnautilus_config = gNautilusDeviceConfiguration();
% set serial number in g.Nautilus device configuration
gnautilus_config.Name = connected_devices(1,1).Name;

% set configuration to use functions in gds interface which require device
% connection
gds_interface.DeviceConfigurations = gnautilus_config;

% get available channels
available_channels = gds_interface.GetAvailableChannels();
% get supported sensitivities
supported_sensitivities = gds_interface.GetSupportedSensitivities();
% get supported input sources
supported_input_sources = gds_interface.GetSupportedInputSources();

% edit configuration to have a sampling rate of 250Hz, 4 scans,all
% available analog channels as well as ValidationIndicator and Counter.
% Acquire the internal test signal of g.Nautilus
gnautilus_config.SamplingRate = 250;
gnautilus_config.NumberOfScans = 4;
%gnautilus_config.InputSignal = supported_input_sources(3).Value;
gnautilus_config.NoiseReduction = false;
gnautilus_config.CAR = false;
% acquire additional channels counter and validation indicator
gnautilus_config.Counter = true;
gnautilus_config.ValidationIndicator = true;
% do not acquire other additional channels
gnautilus_config.AccelerationData = false;
gnautilus_config.LinkQualityInformation = false;
gnautilus_config.BatteryLevel = false;
gnautilus_config.DigitalIOs = false;
for i=1:size(gnautilus_config.Channels,2)
    if (available_channels(1,i))
    	gnautilus_config.Channels(1,i).Available = true;
        gnautilus_config.Channels(1,i).Acquire = true;
        % set sensitivity to 187.5 mV
        gnautilus_config.Channels(1,i).Sensitivity = supported_sensitivities(6);
        % do not use channel for CAR and noise reduction
        gnautilus_config.Channels(1,i).UsedForNoiseReduction = false;
        gnautilus_config.Channels(1,i).UsedForCAR = false;
        % do not use filters
        gnautilus_config.Channels(1,i).BandpassFilterIndex = -1;
        gnautilus_config.Channels(1,i).NotchFilterIndex = -1;
        % do not use a bipolar channel
        gnautilus_config.Channels(1,i).BipolarChannel = -1;
    end
end

% apply configuration to the gds interface
gds_interface.DeviceConfigurations = gnautilus_config;
% set configuration provided in DeviceConfigurations
gds_interface.SetConfiguration();

chanum=8;%使用8导数据
sampleRate = 250;%采样率
dataLength = displayTime + restDelay;
global buffSize;
buffSize = round(sampleRate*dataLength);
global samples_acquired
samples_acquired = 0;
global data_received
data_received = single(zeros(buffSize, 18));%16导联的帽子
global circBuff
circBuff = single(zeros(buffSize, 9));%使用8导数据进行算法计算


 try
         AssertOpenGL;
%     % ---------------------------------------------------------------------
%     % 打开screen
     Screens = Screen('Screens');
     ScreenNum = max(Screens);
     [w, rect] = Screen('OpenWindow', ScreenNum);
     Screen('Preference', 'SkipSyncTests', 1);
%     % 将此刺激程序在CPU执行队列中的优先级提高到最高级别
     Priority(MaxPriority(w));
     % 得到屏幕的垂直分辨率
     params.vertical = rect(4);
%     % 得到屏幕的水平分辨率
     params.horiz = rect(3);
%     % ---------------------------------------------------------------------
     black = BlackIndex(w);
     white = WhiteIndex(w);
%    % HideCursor;
     Screen('TextColor', w,white);
%     % ---------------------------------------------------------------------
     Screen('FillRect',w, black);
%     % ---------------------------------------------------------------------
%     % 显示的图片
     stim_represent = imread('target.bmp');
     texturetarget = Screen('MakeTexture', w, stim_represent);
     stim_represent = imread('frame_1.jpg');
     textureGUI = Screen('MakeTexture', w, stim_represent);
     stim_represent = imread('frame_2.jpg');
     textureGUI2 = Screen('MakeTexture', w, stim_represent);
    
%     % ---------------------------------------------------------------------
     rectp1 = [180 180];
%     % 图片1在屏幕上的位置
     p1horiz = params.horiz/2 - rectp1(1)/2;
     p1verti = params.vertical/2 - rectp1(2)/2 - 260;
     rect1 = [p1horiz p1verti p1horiz+rectp1(1) p1verti+rectp1(2)];
%     %
     p2horiz = params.horiz/2 - rectp1(1)/2;
     p2verti = params.vertical/2 - rectp1(2)/2 + 260;
     rect2 = [p2horiz p2verti p2horiz+rectp1(1) p2verti+rectp1(2)];
%     %
     p3horiz = params.horiz/2 - rectp1(1)/2 - 260;
     p3verti = params.vertical/2 - rectp1(2)/2;
     rect3 = [p3horiz p3verti p3horiz+rectp1(1) p3verti+rectp1(2)];
%     %
     p4horiz = params.horiz/2 - rectp1(1)/2 + 260;
     p4verti = params.vertical/2 - rectp1(2)/2;
     rect4 = [p4horiz p4verti p4horiz+rectp1(1) p4verti+rectp1(2)];
     cond_horiz = {'p1horiz','p2horiz','p3horiz','p4horiz'};
     cond_verti = {'p1verti','p2verti','p3verti','p4verti'};
     recti = {'rect1','rect2','rect3','rect4'};

     %开始采集（缓冲区开始读取）
     gds_interface.StartDataAcquisition();

     %     % ---------------------------------------------------------------------
     Screen('Preference', 'SkipSyncTests', 1);
     Screen('DrawTextures',w,textureGUI);
     Screen('Flip',w);
  %   WaitSecs(3);

%设置定时器，用于连续读取缓冲区的脑电信号
t=timer('Name','geteegdata','TimerFcn',{@geteegdata},'Period',0.005,'ExecutionMode','fixedSpacing');%,'busymode','queue');
%计时器开始工作，记录脑电
start(t);
%WaitSecs(6);%4s

% ---------------------------------------------------------------------
     waitframes = 1; %挺关键的，有用信息，需要调研一下屏幕缓冲情况
     
         for ii = 1:trialnum
         % -----------------------------------------------------------------
         % SSVEP任务
          count1 = 0;
          ifi = Screen('GetFlipInterval', w);
          vbl = Screen('Flip', w);
          vblendtime = vbl + displayTime;
          while(vbl < vblendtime)
         % -------------------------------------------------------------
             Screen('DrawTexture',w,textureGUI,[],[],[],0);
         % -------------------------------------------------------------
              count1 = count1 + 1;
                if count1==1            
              % 开始积累数据
                 samples_acquired=0;
                 data_received = zeros(buffSize, 18);       
                 circBuff = zeros(buffSize, 9);
             end
             for jj = 1:4
                 str = 'rectx';
                 eval([str,'=',recti{jj},';']);
                 weight = (1+sin(2*pi*freq(jj)*count1/frame_rate))/2;
                 Screen('DrawTextures',w,textureGUI2,[],rectx,[],0,[],weight*[255 255 255]);%在同一个画布上控制不同的局部纹理的亮度

             end
            % -------------------------------------------------------------
             Screen('DrawingFinished', w);
          %   Screen('Flip',w);
             vbl = Screen('Flip', w, vbl + (waitframes - 0.5) * ifi);
          
          end
          % -----------------------------------------------------------------
          start2 = GetSecs();
          now2 = GetSecs();
          while(now2 < start2 + restDelay)
             Screen('DrawTextures',w,textureGUI);
             Screen('Flip',w);
             now2 = GetSecs();
          end 
          % -----------------------------------------------------------------
           %%  读取数据后进入算法
              circBuff = data_received(:,1:9);
       %     WaitSecs(2);
        % -----------------------------------------------------------------
            Screen('DrawTextures',w,textureGUI);       
         %------------------------------------------------------------------
         % remove baseline
          circBuff = circBuff';
          circBuff = circBuff - repmat(median(circBuff,2),1,buffSize);
          circBuff = circBuff';
%         %------------------------------------------------------------------
          resultnum = onlineAnalysis(circBuff,displayTime,chanum,freq);
 %      resultnum =4;
           rectx=eval(recti{resultnum});
         Screen('DrawTextures',w,texturetarget,[],rectx); 
        Screen('Flip',w);
         WaitSecs(1);
      end
      
%停止计时器
stop(t);
%删除计时器
delete(t);
 
 catch
 end
 
 Screen('CloseAll');

%缓冲区停止获取数据
gds_interface.StopDataAcquisition();


% delete gds_interface to close connection to device
delete(gds_interface)
clear gds_interface;
clear gnautilus_config;
% 

% plot data (analog channel 1, counter and validation indicator)
rec_time = (1:double(samples_acquired))/250;
%rec_time=reshape(rec_time,1,600);
subplot(3,1,1);
plot(rec_time, data_received(1:length(rec_time),1));
ylabel('Amplitude [抵]');
subplot(3,1,2);

plot(rec_time, data_received(1:length(rec_time),2));
ylabel('Counter');
subplot(3,1,3);

plot(rec_time, data_received(1:length(rec_time),3));
ylabel('Valid');
xlabel('Seconds');

% clean up

