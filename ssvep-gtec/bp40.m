function  y=bp40(x,fs)
fs=fs/2;

% 
%Wp=[35/fs];%25Hz
%Ws=[50/fs];%10
%Wp=[5/fs];%25Hz
%Ws=[1/fs];%10

 %Wp=[4/fs 50/fs];%3 7
 %Ws=[1/fs 60/fs];%1 1
 
%  Wp=[5/fs 70/fs];
%  Ws=[3/fs 80/fs];

 Wp=[7/fs 70/fs];%3 7
 Ws=[5/fs 80/fs];%1 1
 
  %Wp=[4/fs 55/fs];%3 7
  %Ws=[1/fs 65/fs];%1 1
% Wp=[8/fs 15/fs];%12
% Ws=[2/fs 20/fs];%10

% Wp=[0.5/fs 35/fs];%12
% Ws=[0.05/fs 120/fs];%10
% 
% Wp=[2/fs 25/fs];%12
% Ws=[.05/fs 60/fs];%10
% % 


Wn=0;
%[N,Wn]=cheb1ord(Wp,Ws,5,30);
[N,Wn]=cheb1ord(Wp,Ws,3,40);
[B,A] = cheby1(N,0.5,Wn);
y = filtfilt(B,A,x);
%y = filter(B,A,x);
%y=x;
%figure
%FREQZ(B,A)

 