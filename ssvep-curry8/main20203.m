  close all;clear all;clc;clear mex;
% -------------------------------------------------------------------------
%����������̼���from 2020 timer run
Screen('Preference', 'SkipSyncTests', 1);
% �����Ļ��ˢ��Ƶ���Ƿ�Ϊ60Hz
if Screen('FrameRate',0)~=60
    disp('��Ļˢ��Ƶ�ʲ���60Hz');
    return;
end
frame_rate = 60;

%�̼�����
% -------------------------------------------------------------------------
% ��Ŀ��Ĵ̼�Ƶ��
global freq;
freq = [7,9,11,13];
% �̼����ֵ�ʱ��
displayTime = 240;
restDelay = 0.4;
trialnum = 1;

%��Ӧ�����ʹ�������,���ݻ��۵����ڳ��Ȳſ�ʼ��������Ϳ�ʼ����������
inter=0.4;
global win;
win=1;
global point;%��¼��ǰλ�á� ��timer�и���������������ҷ������Ҫ�̼�����ʵʱ��ȡ����
point=0;
% -------------------------------------------------------------------------
% ʵʱ���ݴ���ʱ���豸��������
global chanum;
chanum = 8; %����ͨ����(����8��+1�����trigger��
sampleRate = 1000;%������

dataLength = displayTime + restDelay;

%dataBuffer =33*15;
global buffSize;
buffSize = round(sampleRate*dataLength); %���������ܳ���ȫ�̼�¼����
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


%tcpip�˿�����
interfaceObject=tcpip('127.0.0.1',12345,'NetworkRole','client');%���һ���������ӵĿͻ����������ӣ��˿ں�Ϊ10008������Ϊ��������
interfaceObject.InputBuffersize=33*15;%����
interfaceObject.RemoteHost='127.0.0.1';%�ͻ���ip
% ����һ�ζ�ȡ���ֽ���
global bytesToRead;
bytesToRead = 33*15;
fopen(interfaceObject);%�򿪷�������ֱ������һ��TCP���Ӳŷ��أ�
%�򿪺���Ѿ��ڴ��������ˡ�
%pause(2);

% -------------------------------------------------------------------------
try
    % ---------------------------------------------------------------------
    AssertOpenGL;
    % ---------------------------------------------------------------------
    % ��screen
    Screens = Screen('Screens');
    ScreenNum = max(Screens); 
    [w, rect] = Screen('OpenWindow', ScreenNum);
    Screen('Preference', 'SkipSyncTests', 1);%����֡ͬ����⣬�������Կ���������Ӱ��
    Priority(MaxPriority(w)); % ���˴̼�������CPUִ�ж����е����ȼ���ߵ���߼���
    params.vertical = rect(4); % �õ���Ļ�Ĵ�ֱ�ֱ���
    params.horiz = rect(3); % �õ���Ļ��ˮƽ�ֱ���
    black = BlackIndex(w);
    white = WhiteIndex(w);
    Screen('TextColor', w,white);%��ɫ��
    Screen('FillRect',w, white/2);%��ɫ��
   
    % ��ʾ��ͼƬ ��ȡ���� ��������
    stim_represent = imread('target.bmp');
    texturetarget = Screen('MakeTexture', w, stim_represent);%�������ʶ��Ŀ��
    stim_represent = imread('frame_1.jpg');
    textureGUI = Screen('MakeTexture', w, stim_represent);%��һ֡
     stim_represent = imread('frame_3.jpg');
    textureGUI2 = Screen('MakeTexture', w, stim_represent);%Դͼ֡
    
     rectp1 = [180 180];%�̼����С
    % ---------------------------------------------------------------------
global changex;
    changex=0;
global changey;
    changey=0;
    % ͼƬ1����Ļ�ϵ�λ��
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
    Screen('DrawTextures',w,textureGUI);%��ʼ֡
    Screen('Flip',w);
 %   pause(3);
 
%���ö�ʱ��������������ȡ���������Ե��ź�
t=timer('Name','geteegdata','TimerFcn',{@read},'Period',0.005,'ExecutionMode','fixedSpacing');
t2=timer('Name','controlfb','TimerFcn',{@move},'Period',0.4,'ExecutionMode','fixedSpacing');
pause(2);
%��ʱ����ʼ��������¼�Ե�
move();
start(t);
start(t2);
     % ---------------------------------------------------------------------
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
         %   Screen('DrawTexture',w,textureGUI,[],[],[],0);%��ʼ֡
            % -------------------------------------------------------------
            count1 = count1 + 1;
            for jj = 1:4
                str = 'rectx';
                eval([str,'=',recti{jj},';']);
                 rectx=rectx+[changex changey changex changey];%λ��ʵʱ�仯
                weight = (1+sin(2*pi*freq(jj)*count1/frame_rate))/2;%Ƶ�ʵ���
                Screen('DrawTextures',w,textureGUI2,[],rectx,[],0,[],weight*[255 255 255]);%��ͬһ�������Ͽ��Ʋ�ͬ�ľֲ�����������

            end
            % -------------------------------------------------------------
            Screen('DrawingFinished', w);
            % -------------------------------------------------------------
            if count1==1            
                % ��ʼ׼�����ݣ������Ҫ��������
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
        %    Screen('DrawTextures',w,textureGUI);%��ʼ֡
            Screen('Flip',w);
            now2 = GetSecs();
        end
        % -----------------------------------------------------------------
        % ֹͣ��������
      %     circBuff = reshape(data_received,buffSize, 9);
        % -----------------------------------------------------------------
        Screen('DrawTextures',w,textureGUI);       
      
    end
    % ---------------------------------------------------------------------

    Screen('CloseAll');
    %ֹͣ��ʱ��
stop(t);
stop(t2);
%ɾ����ʱ��
delete(t);
delete(t2);

    % �ָ����˳������е�ԭ�����ȼ���
    Priority(0);
    
    %�ر����������ӣ�ֹͣ�����Ե�����
     fclose(interfaceObject);
     delete(interfaceObject);

%     % �ͷ�mex��ִ���ļ����ڴ�����ռ�Ŀռ�
     clear mex;
    disp('the experiment is over');
catch ME

%     ShowCursor;
    Screen('CloseAll');
    %ֹͣ��ʱ��
stop(t);
stop(t2);
%ɾ����ʱ��
delete(t);
delete(t2);
    Priority(0);
    %�ر����������ӣ�ֹͣ�����Ե�����
     fclose(interfaceObject);%�ر�����
     delete(interfaceObject);%ɾ������
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
% ͨ��
data_channel=ones(9,bytesToRead/33);
for i=1:9
    data_channel(i,:)=sum(data_recv2(3*i:3*i+2,:),1);
end
%����С�ڵ���2^7��
idx_chn=find(road>=2^7);
%С�ڵ���2^7��ȥ2^24
data_channel(idx_chn)=data_channel(idx_chn)-2^24;

%ÿһ�δ���ȡ����������data_channel��9��15��
%�������ݡ�
global buffSize;
global data_received;
global x;
global step;

if  x+ step< buffSize||x+ step == buffSize
    %װ�� 
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

%��ȡ����������
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