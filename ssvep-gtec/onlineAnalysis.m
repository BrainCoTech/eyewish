function result = onlineAnalysis(rawdata,stimTime,chanum,freq)
%
% -------------------------------------------------------------------------
% 参数
condition = length(freq);
lDelay = 0.14;
N1 = 250*(stimTime + lDelay);
% -------------------------------------------------------------------------
for chan = 1:chanum
   % markData = rawdata(:,10);
   % Diffmark = diff(markData,1);
   % indexsMin = find(Diffmark~=0);
   % iMin = max(indexsMin);
   % downsdata = downsample(rawdata(round(iMin+1):round(iMin+N1),chan),4);
%    downsdata = downsample(rawdata(1:N1,chan),4);
%     bpdata(:,chan) = bp40(downsdata,250);
   bpdata(:,chan)=rawdata(1:N1,chan);
end
% -------------------------------------------------------------------------
rfs = 250;%降采样后的采样率
latencyDelay = lDelay*rfs;%延时采样点数
N = round(stimTime*rfs);
% -------------------------------------------------------------------------
%freq = [7,9,11,13];
n = [1:N]/rfs;
for ii = 1:condition
    s1 = sin(2*pi*freq(ii)*n);
    s2 = cos(2*pi*freq(ii)*n);
  %  s3 = sin(2*pi*2*freq(ii)*n);
   % s4 = cos(2*pi*2*freq(ii)*n);
   % s5 = sin(2*pi*3*freq(ii)*n);
  %  s6 = cos(2*pi*3*freq(ii)*n);
  %  condY(:,:,ii) = cat(2,s1',s2',s3',s4',s5',s6');
  condY(:,:,ii) = cat(2,s1',s2');
  
    condY(:,:,ii) = condY(:,:,ii) - repmat(mean(condY(:,:,ii),1), N, 1);% remove mean
end
X = bpdata(1+latencyDelay:N+latencyDelay,:);
for cond = 1:condition
    [A,B,r,U,V] = canoncorr(X,condY(:,:,cond));
    rr(cond) = max(r);
end
maxindex = find(rr==max(rr));
result = maxindex;