% This is a demo script for the use of g.Nautilus in the g.NEEDaccess
% MATLAB API.
% It records data for 10 seconds from all analog channels available using
% the internal test signal and plots it offline after acquisition.
 close all;clear all;clc;
% -------------------------------------------------------------------------
Screen('Preference', 'SkipSyncTests', 1);
% �����Ļ��ˢ��Ƶ���Ƿ�Ϊ60Hz
if Screen('FrameRate',0)~=60
    disp('��Ļˢ��Ƶ�ʲ���60Hz');
    return;
end
frame_rate = 60;

% -------------------------------------------------------------------------
% ��Ŀ��Ĵ̼�Ƶ��
freq = [8,9,11,12];
% -------------------------------------------------------------------------
% �̼����ֵ�ʱ��
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

chanum=8;%ʹ��8������
sampleRate = 250;%������
dataLength = displayTime + restDelay;
global buffSize;
buffSize = round(sampleRate*dataLength);
global samples_acquired
samples_acquired = 0;
global data_received
data_received = single(zeros(buffSize, 18));%16������ñ��
global circBuff
circBuff = single(zeros(buffSize, 9));%ʹ��8�����ݽ����㷨����


 try
         AssertOpenGL;
%     % ---------------------------------------------------------------------
%     % ��screen
     Screens = Screen('Screens');
     ScreenNum = max(Screens);
     [w, rect] = Screen('OpenWindow', ScreenNum);
     Screen('Preference', 'SkipSyncTests', 1);
%     % ���˴̼�������CPUִ�ж����е����ȼ���ߵ���߼���
     Priority(MaxPriority(w));
     % �õ���Ļ�Ĵ�ֱ�ֱ���
     params.vertical = rect(4);
%     % �õ���Ļ��ˮƽ�ֱ���
     params.horiz = rect(3);
%     % ---------------------------------------------------------------------
     black = BlackIndex(w);
     white = WhiteIndex(w);
%    % HideCursor;
     Screen('TextColor', w,white);
%     % ---------------------------------------------------------------------
     Screen('FillRect',w, black);
%     % ---------------------------------------------------------------------
%     % ��ʾ��ͼƬ
     stim_represent = imread('target.bmp');
     texturetarget = Screen('MakeTexture', w, stim_represent);
     stim_represent = imread('frame_1.jpg');
     textureGUI = Screen('MakeTexture', w, stim_represent);
     stim_represent = imread('frame_2.jpg');
     textureGUI2 = Screen('MakeTexture', w, stim_represent);
    
%     % ---------------------------------------------------------------------
     rectp1 = [180 180];
%     % ͼƬ1����Ļ�ϵ�λ��
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

     %��ʼ�ɼ�����������ʼ��ȡ��
     gds_interface.StartDataAcquisition();

     %     % ---------------------------------------------------------------------
     Screen('Preference', 'SkipSyncTests', 1);
     Screen('DrawTextures',w,textureGUI);
     Screen('Flip',w);
  %   WaitSecs(3);

%���ö�ʱ��������������ȡ���������Ե��ź�
t=timer('Name','geteegdata','TimerFcn',{@geteegdata},'Period',0.005,'ExecutionMode','fixedSpacing');%,'busymode','queue');
%��ʱ����ʼ��������¼�Ե�
start(t);
%WaitSecs(6);%4s

% ---------------------------------------------------------------------
     waitframes = 1; %ͦ�ؼ��ģ�������Ϣ����Ҫ����һ����Ļ�������
     
         for ii = 1:trialnum
         % -----------------------------------------------------------------
         % SSVEP����
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
              % ��ʼ��������
                 samples_acquired=0;
                 data_received = zeros(buffSize, 18);       
                 circBuff = zeros(buffSize, 9);
             end
             for jj = 1:4
                 str = 'rectx';
                 eval([str,'=',recti{jj},';']);
                 weight = (1+sin(2*pi*freq(jj)*count1/frame_rate))/2;
                 Screen('DrawTextures',w,textureGUI2,[],rectx,[],0,[],weight*[255 255 255]);%��ͬһ�������Ͽ��Ʋ�ͬ�ľֲ�����������

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
           %%  ��ȡ���ݺ�����㷨
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
      
%ֹͣ��ʱ��
stop(t);
%ɾ����ʱ��
delete(t);
 
 catch
 end
 
 Screen('CloseAll');

%������ֹͣ��ȡ����
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
ylabel('Amplitude [��]');
subplot(3,1,2);

plot(rec_time, data_received(1:length(rec_time),2));
ylabel('Counter');
subplot(3,1,3);

plot(rec_time, data_received(1:length(rec_time),3));
ylabel('Valid');
xlabel('Seconds');

% clean up
