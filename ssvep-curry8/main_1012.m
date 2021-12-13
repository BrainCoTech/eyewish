 close all;clear all;clc;
% -------------------------------------------------------------------------
Screen('Preference', 'SkipSyncTests', 1);
% �����Ļ��ˢ��Ƶ���Ƿ�Ϊ60Hz
if Screen('FrameRate',0)~=60
    disp('��Ļˢ��Ƶ�ʲ���60Hz');
    return;
end
frame_rate = 60;

% chanum = 9; %����ͨ����(�������¼�ͨ��MGFP)��c3,c4,p3,p4,o1,o2,ʱ��ͨ����
% -------------------------------------------------------------------------
% ��Ŀ��Ĵ̼�Ƶ��
freq = [7,9,11,13];
% -------------------------------------------------------------------------
% �̼����ֵ�ʱ��
displayTime = 2;
restDelay = 0.4;
trialnum = 2;
index_code = randperm(trialnum);
% wavdata = zeros(10000,4);
% for ii = 1:4
%     filename = [num2str(ii),'.wav'];
%     [y,fs] = audioread(filename);
%     leny(ii) = length(y);
%     wavdata(1:leny(ii),ii) = y;
% end
%channels = 1;
% InitializePsychSound;
% Handle = PsychPortAudio('Open', [], [], [], fs, channels);
% -------------------------------------------------------------------------
% ʵʱ���ݴ���ʱ�Ĳ�������
% params.chanNum = chanum;%ͨ����
% params.sampleRate = 1000;%������
% params.dataLength = displayTime + restDelay;
% params.serverPort = 4455;
% params.ipAddress ='172.19.1.241';% '192.168.31.113';%һ̨���ԣ�����ip��ַ����̨����ʱ���޸�Ϊ�ɼ�����ip��ַ
% 
% buffSize = round(params.sampleRate*params.dataLength);
% circBuff = zeros(buffSize,chanum+1);
%%��Ҫע��
%dataBuffer = ((chanum+1)*4*(200*params.sampleRate/1000)+20);
% -------------------------------------------------------------------------
%��ʼ��������ָ��
% startheader = initHeader('CTRL',...
%     controlCode('CTRL_FromClient'),...
%     requestType('RequestStreamingStart'),...
%     0,0,0);
% -------------------------------------------------------------------------
%ֹͣ��������ָ��
% stopheader = initHeader('CTRL',...
%     controlCode('CTRL_FromClient'),...
%     requestType('RequestStreamingStop'),...
%     0,0,0);
% -------------------------------------------------------------------------
%tcpip�˿�����
% con = tcpip(params.ipAddress, params.serverPort);
% set(con,'InputBufferSize',dataBuffer);
% set(con,'ByteOrder','littleEndian');
% fopen(con);
% -------------------------------------------------------------------------
try
    % ---------------------------------------------------------------------
    AssertOpenGL;
    % ---------------------------------------------------------------------
    % ��screen
    Screens = Screen('Screens');
    ScreenNum = max(Screens);
    [w, rect] = Screen('OpenWindow', ScreenNum);
    Screen('Preference', 'SkipSyncTests', 1);
    % ���˴̼�������CPUִ�ж����е����ȼ���ߵ���߼���
    Priority(MaxPriority(w));
    % �õ���Ļ�Ĵ�ֱ�ֱ���
    params.vertical = rect(4);
    % �õ���Ļ��ˮƽ�ֱ���
    params.horiz = rect(3);
    % ---------------------------------------------------------------------
    black = BlackIndex(w);
    white = WhiteIndex(w);
   % HideCursor;
    Screen('TextColor', w,white);
    % ---------------------------------------------------------------------
    Screen('FillRect',w, black);
    % ---------------------------------------------------------------------
    % ��ʾ��ͼƬ
    stim_represent = imread('target.bmp');
    texturetarget = Screen('MakeTexture', w, stim_represent);
    stim_represent = imread('frame_12.jpg');
    textureGUI = Screen('MakeTexture', w, stim_represent);
    % ---------------------------------------------------------------------
    rectp = [0 0 240 240];
    rectp1 = [180 360];
    % ͼƬ��ļ��
    interd = 50;
    % ͼƬ1����Ļ�ϵ�λ��
    p1horiz = params.horiz/2 - rectp1(1)/2;
    p1verti = params.vertical/2 - rectp1(2)/2 - 260;
    rect1 = [p1horiz p1verti p1horiz+rectp1(1) p1verti+rectp1(2)];
    %
    p2horiz = params.horiz/2 - rectp1(1)/2;
    p2verti = params.vertical/2 - rectp1(2)/2 + 260;
    rect2 = [p2horiz p2verti p2horiz+rectp1(1) p2verti+rectp1(2)];
    %
    p3horiz = params.horiz/2 - rectp1(1)/2 - 260;
    p3verti = params.vertical/2 - rectp1(2)/2;
    rect3 = [p3horiz p3verti p3horiz+rectp1(1) p3verti+rectp1(2)];
    %
    p4horiz = params.horiz/2 - rectp1(1)/2 + 260;
    p4verti = params.vertical/2 - rectp1(2)/2;
    rect4 = [p4horiz p4verti p4horiz+rectp1(1) p4verti+rectp1(2)];
    cond_horiz = {'p1horiz','p2horiz','p3horiz','p4horiz'};
    cond_verti = {'p1verti','p2verti','p3verti','p4verti'};
    recti = {'rect1','rect2','rect3','rect4'};
    % ---------------------------------------------------------------------
    Screen('DrawTextures',w,textureGUI);
    Screen('Flip',w);
    WaitSecs(3);
    %----------------------------------------------------------------------
    %��ʱ���ж�
%     fixTime= timer( 'Period', 0.02);
%     set(fixTime, 'ExecutionMode', 'FixedRate');
%     set(fixTime,'TimerFcn',['newset=pGetData_curry8(con,dataBuffer,chanum,params.sampleRate);','if ~isempty(newset)',...
%         'circBuff =[circBuff(0.2*params.sampleRate+1:end,:);newset];','end']);
%     start(fixTime);
%     % ---------------------------------------------------------------------
    waitframes = 1;
    % ---------------------------------------------------------------------
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
            for jj = 1:4
                str = 'rectx';
                eval([str,'=',recti{jj},';']);
                weight = (1+sin(2*pi*freq(jj)*count1/frame_rate))/2;
                Screen('DrawTextures',w,textureGUI,rectx,rectx,[],0,[],weight*[255 255 255]);
            end
            % -------------------------------------------------------------
            Screen('DrawingFinished', w);
            % -------------------------------------------------------------
            if count1==1            
                % ��ʼ��������
%                 fwrite(con, startheader,'uchar');
                
            end
            % -------------------------------------------------------------
            vbl = Screen('Flip', w, vbl + (waitframes - 0.5) * ifi);
        end
        aa(ii) = count1;
        % -----------------------------------------------------------------
        start2 = GetSecs();
        now2 = GetSecs();
        while(now2 < start2 + restDelay)
            Screen('DrawTextures',w,textureGUI);
            Screen('Flip',w);
            now2 = GetSecs();
        end
        % -----------------------------------------------------------------
        % ֹͣ��������
%         fwrite(con, stopheader,'uchar');
        
        
        % -----------------------------------------------------------------
        Screen('DrawTextures',w,textureGUI);       
        %------------------------------------------------------------------
%         % remove baseline
%         circBuff = circBuff';
%         circBuff = circBuff - repmat(median(circBuff,2),1,buffSize);
%         circBuff = circBuff';
        %------------------------------------------------------------------
%         resultnum = onlineAnalysis(circBuff,displayTime,chanum,freq);
%         circBufflist(ii,:,:)=circBuff;
%         y1 = wavdata(1:leny(resultnum),resultnum);
%         PsychPortAudio('FillBuffer', Handle, y1');
%         PsychPortAudio('Start', Handle);
%         str = 'rectx';
%         eval([str,'=',recti{resultnum},';']);
%         Screen('DrawTextures',w,texturetarget,rectp,rectx);
%         Screen('TextSize', w, 30);
%         for jj = 1:4
%             eval(['xi=',cond_horiz{jj},';']);
%             eval(['yi=',cond_verti{jj},';']);
%             DrawFormattedText(w,num2str(jj),xi+rectp1(1)/2-15,yi+rectp1(2)/2-20,[0,0,0]);
%         end
        Screen('Flip',w);
        WaitSecs(1);
    end
    % ---------------------------------------------------------------------
%     PsychPortAudio('Stop',Handle);
%     PsychPortAudio('Close',Handle);
%    ShowCursor
    Screen('CloseAll');
    % �ָ����˳������е�ԭ�����ȼ���
    Priority(0);
 %   stop(fixTime);
    
    %�ر����������ӣ�ֹͣ�����Ե�����
%     fclose(con);
%     delete(con);
%     % �ͷ�mex��ִ���ļ����ڴ�����ռ�Ŀռ�
     clear mex;
    disp('the experiment is over');
catch ME
%     PsychPortAudio('Stop',Handle);
%     PsychPortAudio('Close',Handle);
%     ShowCursor;
    Screen('CloseAll');
    Priority(0);
%     stop(fixTime);
    %�ر����������ӣ�ֹͣ�����Ե�����
%     fclose(con);
%     delete(con);
%     clear mex;
    psychrethrow(psychlasterror);
    rethrow(ME);
end