close all;clear all;clc;clear mex;
 PsychDefaultSetup(2);
 % -------------------------------------------------------------------------
Screen('Preference', 'SkipSyncTests', 1);
% �����Ļ��ˢ��Ƶ���Ƿ�Ϊ60Hz
if Screen('FrameRate',0)~=60
    disp('��Ļˢ��Ƶ�ʲ���60Hz');
    return;
end
frame_rate = 60;
 % -------------------------------------------------------------------------
%�̼�����
% -------------------------------------------------------------------------
freq = [7,9,11,13];
displayTime = 2;
restDelay = 0.4;
trialnum = 4;
 % -------------------------------------------------------------------------

%��Ϊ�õ�timer����ʼ��ȫ�ֱ���
global gds_interface        
global samples_acquired
samples_acquired = 0;

chanum = 16; %����ͨ����
sampleRate = 250;%������
dataLength = displayTime + restDelay;
global buffSize;
buffSize = round(sampleRate*dataLength);
global circBuff;
circBuff = zeros(buffSize,18);
global data_received;
data_received = zeros(buffSize,18);


 % -------------------------------------------------------------------------
% create gtecDeviceInterface object��1�� ��ʼ��gtec�ӿ�
gds_interface = gtecDeviceInterface();
% define connection settings (loopback)��2�� �������ݴ���˿�
gds_interface.IPAddressHost = '127.0.0.1';
gds_interface.IPAddressLocal = '127.0.0.1';
gds_interface.LocalPort = 50224;
gds_interface.HostPort = 50223;
% get connected devices ��3�� �����豸
connected_devices = gds_interface.GetConnectedDevices();
% create g.Nautilus configuration object��4�� ��ʼ��gtec����
gnautilus_config = gNautilusDeviceConfiguration();
% set serial number in g.Nautilus device configuration ȷ���豸Ϊ g.Nautilus
gnautilus_config.Name = connected_devices(1,1).Name;
% set configuration to use functions in gds interface which require device
% connection
gds_interface.DeviceConfigurations = gnautilus_config;
% get available channels ��ȡ����ͨ����
available_channels = gds_interface.GetAvailableChannels();
% get supported sensitivities
supported_sensitivities = gds_interface.GetSupportedSensitivities();
% get supported input sources
supported_input_sources = gds_interface.GetSupportedInputSources();
% edit configuration to have a sampling rate of 250Hz, 4 scans,all
% available analog channels as well as ValidationIndicator and Counter.
% Acquire the internal test signal of g.Nautilus ��5�������ò���Ƶ�ʺ�ɨ����Ŀ
gnautilus_config.SamplingRate = 250;%250
gnautilus_config.NumberOfScans = 4;
%gnautilus_config.InputSource = supported_input_sources(3).Value;
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
for i=1:size(gnautilus_config.Channels,2) %%ͨ�����ã��˲���
    if (available_channels(1,i))
    	gnautilus_config.Channels(1,i).Available = true;
        gnautilus_config.Channels(1,i).Acquire = true;
        % set sensitivity to 187.5 mV
        gnautilus_config.Channels(1,i).Sensitivity = supported_sensitivities(6);
        % do not use channel for CAR and noise reduction
        gnautilus_config.Channels(1,i).UsedForNoiseReduction = false;
        gnautilus_config.Channels(1,i).UsedForCAR = false;
        % do not use filters ��6�����ô�ͨ�˲��� �� �����˲���
        gnautilus_config.Channels(1,i).BandpassFilterIndex = -1;
        gnautilus_config.Channels(1,i).NotchFilterIndex = -1;
        % do not use a bipolar channel
        gnautilus_config.Channels(1,i).BipolarChannel = -1;
    end
end
% apply configuration to the gds interface Ӧ����������
gds_interface.DeviceConfigurations = gnautilus_config;
% set configuration provided in DeviceConfigurations
gds_interface.SetConfiguration();

% ---------------------------------------------------------------------

 %���ö�ʱ��������������ȡ���������Ե��ź�
%t=timer('Name','mytimer','TimerFcn',{@geteegdata},'Period',2,'ExecutionMode','FixedRate','busymode','queue');
% start data acquisition ��ʼ�ɼ�����������ʼ��ȡ��
%gds_interface.StartDataAcquisition();

%�̼�׼��
% ---------------------------------------------------------------------
 try 
%     AssertOpenGL; 
%     Screens = Screen('Screens');% ��screen
%     ScreenNum = max(Screens);
%     [w, rect] = Screen('OpenWindow', ScreenNum);
%     Screen('Preference', 'SkipSyncTests', 1);
%     Priority(MaxPriority(w)); % ���˴̼�������CPUִ�ж����е����ȼ���ߵ���߼���
%     params.vertical = rect(4);% �õ���Ļ�Ĵ�ֱ�ֱ���
%     params.horiz = rect(3);% �õ���Ļ��ˮƽ�ֱ���
%     black = BlackIndex(w);
%     white = WhiteIndex(w);
%     Screen('TextColor', w,white);
%     Screen('FillRect',w, black);
%     stim_represent = imread('target.bmp');% ��ʾ��ͼƬ ��ȡ���� ��������
%     texturetarget = Screen('MakeTexture', w, stim_represent);
%     stim_represent = imread('frame_1.jpg');
%     textureGUI = Screen('MakeTexture', w, stim_represent);
%     rectp1 = [180 360];%�̼����С
%     % ͼƬ1����Ļ�ϵ�λ��
%     p1horiz = params.horiz/2 - rectp1(1)/2;
%     p1verti = params.vertical/2 - rectp1(2)/2 - 260;
%     rect1 = [p1horiz p1verti p1horiz+rectp1(1) p1verti+rectp1(2)];
%     %
%     p2horiz = params.horiz/2 - rectp1(1)/2;
%     p2verti = params.vertical/2 - rectp1(2)/2 + 260;
%     rect2 = [p2horiz p2verti p2horiz+rectp1(1) p2verti+rectp1(2)];
%     %
%     p3horiz = params.horiz/2 - rectp1(1)/2 - 260;
%     p3verti = params.vertical/2 - rectp1(2)/2;
%     rect3 = [p3horiz p3verti p3horiz+rectp1(1) p3verti+rectp1(2)];
%     %
%     p4horiz = params.horiz/2 - rectp1(1)/2 + 260;
%     p4verti = params.vertical/2 - rectp1(2)/2;
%     rect4 = [p4horiz p4verti p4horiz+rectp1(1) p4verti+rectp1(2)];
%     cond_horiz = {'p1horiz','p2horiz','p3horiz','p4horiz'};
%     cond_verti = {'p1verti','p2verti','p3verti','p4verti'};
%     recti = {'rect1','rect2','rect3','rect4'};
% 
%     % ---------------------------------------------------------------------
%     Screen('DrawTextures',w,textureGUI);
%     Screen('Flip',w);
% %    WaitSecs(3);
% start(t);
% Screen('Preference', 'SkipSyncTests', 1);
% 
% %     % ---------------------------------------------------------------------
%  waitframes = 1;
%     % ---------------------------------------------------------------------
%     for ii = 1:trialnum
%         % -----------------------------------------------------------------
%         % SSVEP����
%         count1 = 0;
%         ifi = Screen('GetFlipInterval', w);
%         vbl = Screen('Flip', w);
%         vblendtime = vbl + displayTime;
%         while(vbl < vblendtime)
%             % -------------------------------------------------------------
%             Screen('DrawTexture',w,textureGUI,[],[],[],0);
%             % -------------------------------------------------------------
%             count1 = count1 + 1;
%             for jj = 1:4
%                 str = 'rectx';
%                 eval([str,'=',recti{jj},';']);
%                 weight = (1+sin(2*pi*freq(jj)*count1/frame_rate))/2;
%                 Screen('DrawTextures',w,textureGUI,rectx,rectx,[],0,[],weight*[255 255 255]);
%             end
%             % -------------------------------------------------------------
%             Screen('DrawingFinished', w);
%             % -------------------------------------------------------------
%             if count1==1            
%              %��ʱ����ʼ��������¼�Ե�
%              samples_acquired=0;
%              data_received = zeros(buffSize, chanum+1);       
%              circBuff = zeros(buffSize, chanum+1);        
%             end
%             % -------------------------------------------------------------
%             vbl = Screen('Flip', w, vbl + (waitframes - 0.5) * ifi);
%         end
%         aa(ii) = count1;
%         % -----------------------------------------------------------------
%         start2 = GetSecs();
%         now2 = GetSecs();
%         while(now2 < start2 + restDelay)
%             Screen('DrawTextures',w,textureGUI);
%             Screen('Flip',w);
%             now2 = GetSecs();
%         end
%         % -----------------------------------------------------------------
%         % ֹͣ��������     
%         circBuff = reshape(data_received,buffSize,chanum +1);
% 
%         % -----------------------------------------------------------------
%         Screen('DrawTextures',w,textureGUI);       
%         %------------------------------------------------------------------
%         % remove baseline
%         circBuff = circBuff';
%         circBuff = circBuff - repmat(median(circBuff,2),1,buffSize);
%         circBuff = circBuff';
%         %------------------------------------------------------------------
%          resultnum = onlineAnalysis(circBuff,displayTime,chanum,freq);
%          circBufflist(ii,:,:)=circBuff;
%           rectx=eval(recti{resultnum});
%         Screen('DrawTextures',w,texturetarget,rectp,rectx);
%         Screen('TextSize', w, 30);
%         for jj = 1:4
%             eval(['xi=',cond_horiz{jj},';']);
%             eval(['yi=',cond_verti{jj},';']);
%             DrawFormattedText(w,num2str(jj),xi+rectp1(1)/2-15,yi+rectp1(2)/2-20,[0,0,0]);
%         end
%         Screen('Flip',w);
%         WaitSecs(1);
%     end
% 
%sca;
WaitSecs(4);%4s

%ֹͣ��ʱ��
% stop(t);
% delete(t);
% % stop data acquisition ������ֹͣ��ȡ����
% gds_interface.StopDataAcquisition();


% delete gds_interface to close connection to device ����豸ռ��
clear gds_interface;

% plot data (analog channel 1, counter and validation indicator)
rec_time = (1:double(samples_acquired))/250;
rec_time2 = rec_time(1:600) ;

subplot(3,1,1);
plot(rec_time, data_received(:,1));
ylabel('Amplitude [�V]');

subplot(3,1,2);
plot(rec_time, data_received(:,2));
ylabel('Amplitude [�V]');

subplot(3,1,3);
plot(rec_time, data_received(:,3));
ylabel('Amplitude [�V]');



% clean up
clear gds_interface;
clear gnautilus_config;
%clear data_received;

    

catch ME

%     ShowCursor;
    Screen('CloseAll');
    Priority(0);
    %�ر����������ӣ�ֹͣ�����Ե�����
    % fclose(gds_interface);%�ر�����
    clear gds_interface;

     clear mex;
    psychrethrow(psychlasterror);
    rethrow(ME);
end



