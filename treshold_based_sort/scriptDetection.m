load('BOU_JO_Localizer6Hz_sessions','femicro','micros2');

sess=1; % choose one of the two sessions
file_name = "datasets_15"
file_load_name = file_name  + ".npy"
micros2 = readNPY("/home/vtpc/Documents/Alvils/spike-sorting/data/recording_datasets/" + file_load_name);

% Band-Pass filtering in the range 300-6000Hz
Fb=300;
Fh=6000;
[b,a]=butter(1,[2*Fb/femicro 2*Fh/femicro]); % femicro: sampling frequency (24kHz)

% filtrage du signal:
LFPh=filtfilt(b,a,micros2(:, :, sess)')';

Y = fft(LFPh(1, 1:20000) - mean(LFPh(1, 1:20000)));
Fs = 30000;            % Sampling frequency                    
T = 1/Fs;             % Sampling period       
L = 20000;             % Length of signal
t = (0:L-1)*T; 
P2 = abs(Y/L);
P1 = P2(1:L/2+1);
P1(2:end-1) = 2*P1(2:end-1);

f = Fs*(0:(L/2))/L;
plot(f,P1) 
title('Single-Sided Amplitude Spectrum of X(t)')
xlabel('f (Hz)')
ylabel('|P1(f)|')

s = spectrogram(LFPh(1,  1:10000) - mean(LFPh(1,  1:10000)));
spectrogram(LFPh(1, 1:10000) - mean(LFPh(1, 1:10000)),256,250,256,30000,'yaxis')

%% spike count all: detection � la Quiroga + art detection
Fa=5;
sigmas=mad(LFPh',1)/0.6745;
thQ=Fa*sigmas;

troplong=2*femicro/1000;
tropgrand=20*sigmas;


deltas=zeros(size(LFPh));
Ns=zeros(size(LFPh,1),1);
for imicro=1:size(LFPh,1)
    irastMUA=abs(LFPh(imicro,:))>thQ(imicro);
    tmp=diff(irastMUA);
    inpic=find(tmp==1)+1;
    outpic=find(tmp==-1);
    itmp=(outpic-inpic)<troplong;
    inpic=inpic(itmp);
    outpic=outpic(itmp);
    npics=length(inpic);
    timemax=zeros(1,npics);
    clear tmp2 timemax indmax
    for ipics=1:npics
        [tmp2(ipics),indmax(ipics)]=max(abs(LFPh(imicro,inpic(ipics):outpic(ipics))));
        timemax(ipics)=inpic(ipics)+indmax(ipics)-1;
    end
    itmp2=tmp2<tropgrand(imicro);
    deltas(imicro,timemax(itmp2))=1;
%     figure, plot(LFPh(imicro,:)); 
%     hold, plot(timemax(itmp2),LFPh(imicro,timemax(itmp2)),'*g');
    Ns(imicro)=sum(itmp2);
    
end
result = find(deltas == 1);
%clearvars -except result file_name

save(file_name+ "_result5_sc1.mat")
