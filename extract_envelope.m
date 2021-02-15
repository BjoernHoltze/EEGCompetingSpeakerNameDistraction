%% Extracts the speech envelope from the audio signal
% requires eeglab path to be added beforehand

f_low=15; %lowpass filter 
f_order=4;%filter order
fs_new=500; %new sampling rate

%load raw audio signal
[sig fs_old]=audioread('');

%hilbert
sig1=abs(hilbert(sig));

%lowpass filter
Wn=[f_low/(fs_old/2)];
a=1;
[b]=firws(f_order,Wn,'lowpass');
sig2=filter(b,a,sig1);

%first order derivative
sig3=diff(sig2);

%half-wave rectified
sig4=sig3; 
sig4(find(sig3<0))=0;

%resample to EEG sampling rate
sig_env=resample([sig4; 0],fs_new,fs_old);
