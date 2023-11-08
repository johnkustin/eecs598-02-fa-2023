%% simulation setups. don't change
clear; close all;
global P M;

% simulation parameters
L = 3000;         % main simulation samples (at 44 kHz)
Li = 400;         % initial wait to fill the filter buffers
NW = 32;          % controler filter size
NS = 32;          % secondary path filter size
fs = 44100;       % lower sampling frequency
K = 32;           % oversample
P = 2;            % sigma delta order
M = 2^P;          % number of levels do the quantitizer
NW0 = NW*K-K/2;   % oversampled filter length
NbufFill = Li*K;
NFFT = L * K - NbufFill;
NQNS = 4;          % number of QNS blocks

simParams.L         = L;
simParams.Li        = Li;
simParams.NW        = NW;
simParams.NS        = NS;
simParams.fs        = fs;
simParams.K         = K;
simParams.P         = P;
simParams.M         = M;
simParams.NbufFill  = NbufFill;
simParams.NFFT      = NFFT;
simParams.quantizerType = "orig"; %options: "mid-tread", "mid-riser", "orig"
simParams.NW0       = NW0; 
simParams.NQNS      = NQNS;


rng(7283723);

load AAF.mat
AAF = conv(AAF,AAF);
N_AAF = length(AAF);

w_delays = [3.7, 2.2, 5.3];
w_amplitudes = [1.1, -0.7, 0.5]/2;
wop = sinc((0:NW*K-1)'-w_delays*K)*w_amplitudes';

s_delays = [5.2, 7.2, 3.7];
s_amplitudes = [-1.3, 0.9, -0.5];
sp = sinc((0:NS*K-1)'-s_delays*K)*s_amplitudes';
sp1 = conv(sp, ones(K,1)/K);
sp1 = sp1(K/2+K/4:end); % with secondary path modeling error
%sp1 = sp1(K/2:end); % no secondary path modeling error
sh = conv(sp1, AAF);
sh = K*sh(1+(N_AAF-1)/2:K:end);
sh = sh(1:NS)';

% simulation signals
up = randn(K*L,1); % up=conv(up, ones(4,1)/4); up=up(1:end-3);
yp = zeros(K*L,1);
dp = zeros(K*L,1);
ep = zeros(K*L,1);

% algorithm signals
u0 = zeros(K*L,1);
yq = zeros(K*L,1);
y0 = zeros(K*L,1);
e0 = zeros(K*L,1);

d = zeros(L,1);
u = zeros(L,1);
u1 = zeros(L,1);
e = zeros(L,1);
y = zeros(L,1);
dh = zeros(L,1);
eh = zeros(L,1);

% algorithm parameters
mu = 0.2;

% algorithm inicilizations
w = zeros(NW,1);
w0 = zeros(NW0,1);

QNSx = cell(NQNS,1);
Levels = [2 1/K 4 10];
for i=1:NQNS
    QNSx{i} = QNS(Levels(i));
end

% logs
% xqns = zeros(L*K, NQNS);
% yqns = zeros(L*K, NQNS);
% q = zeros(L*K, NQNS);
% 
% inputStruct.AAF = AAF;
% inputStruct.wop = wop;
% inputStruct.sp  = sp;
% inputStruct.sh  = sh;
% inputStruct.up  = up;
% inputStruct.yp  = yp;
% inputStruct.dp  = dp;
% inputStruct.ep  = ep;
% inputStruct.u0  = u0;
% inputStruct.yq  = yq;
% inputStruct.y0  = y0;
% inputStruct.e0  = e0;
% inputStruct.d   = d;
% inputStruct.u   = u;
% inputStruct.u1  = u1;
% inputStruct.e   = e;
% inputStruct.y   = y;
% inputStruct.dh  = dh;
% inputStruct.eh  = eh;
% inputStruct.mu  = mu;
% inputStruct.w   = w;
% inputStruct.w0  = w0;

%% fixed piont entry point
n=max(NW,NS); %% for buildinstrumentmedmex
n0 = 0;

F = fimath('RoundingMethod','Floor',...
           'OverflowAction','Saturate',...
           'ProductMode','KeepMSB',...
           'ProductWordLength',32,...
           'SumMode','KeepMSB',...
           'SumWordLength',32);
% buildInstrumentedMex LMSupdate -coder -args {n,u,w,y,e,sh,dh,eh,u1,NW,NS,mu} -histogram;
% buildInstrumentedMex u_e_d_update -coder -args {n, n0, u, AAF, u0, e, e0, dp, d} -histogram;
% buildInstrumentedMex physical_sig_update -coder -args {n0,wop,up,sp,yp,dp,y0,ep,NW,K} -histogram;

buildInstrumentedMex -o sharedmex...
LMSupdate -args {n,u,w,y,e,sh,dh,eh,u1,NW,NS,mu} ...
u_e_d_update -args {n, n0, u, AAF, u0, e, e0, dp, d} ...
physical_sig_update -args {n0,wop,up,sp,yp,dp,y0,ep,NW,K} ...
-histogram -coder

fipref('DataTypeOverride','ScaledDoubles');

outputStructDouble = entrypoint(simParams, AAF, wop, sp, sh, up, yp, dp, ep, u0, yq, y0, d, u, u1, e, y, dh, eh, mu, w, w0, e0, QNSx, 'double');
%% results, analysis
save("manual_fxpt_conv_NAIP_ANC_double_dt.mat", "outputStructDouble")
pause(1)
% showInstrumentationResults sharedmex -defaultDT numerictype(1,16) ...
%     -proposeFL -optimizeWholeNumbers -printable

% pause(1)
showInstrumentationResults sharedmex -defaultDT numerictype(1,32) ...
    -proposeFL -optimizeWholeNumbers -printable


% showInstrumentationResults LMSupdate_mex ...
%     -defaultDT numerictype(1,16) -proposeFL -optimizeWholeNumbers
% -defaultDT numerictype(1,16) -proposeFL
% pause(1)
% showInstrumentationResults physical_sig_update_mex ...
%     -defaultDT numerictype(1,16) -proposeFL -optimizeWholeNumbers
% pause(1)

figure(314123)
for i = 1:4
    subplot(4,1,i)
    [counts, groupnames] = groupcounts(outputStructDouble.yqns(NbufFill:end,i));
    stem(groupnames, counts)
    title(sprintf('QNS %d',i))
    xlabel('QNS output')
end

fprintf(1,'QNS: u w y e\n');
for i=1:NQNS
    m = sqrt(max(conv(outputStructDouble.xqns(:,i).^2,ones(K,1))/K));
    fprintf(1, 'QNS(%d) -- max input signal RMS: %f\n', i, m);
    
    x = conv(AAF,outputStructDouble.xqns(:,i)); x=x(length(AAF):end);
    y = conv(AAF,outputStructDouble.yqns(:,i)); y=y(length(AAF):end);
    normalized_mse = mean((y-x).^2)/(QNSx{i}.L)^2;
    fprintf(1,'QNS(%d) -- nmse: %f dB bits: %f\n', i, ...
        10*log10(normalized_mse),(-10*log10(3)-10*log10(normalized_mse))/(20*log10(2)));
end

figure(1);
ep_filtered = conv(outputStructDouble.ep, AAF);
ep_down_sampled = ep_filtered(K:K:end);
plot((0:length(outputStructDouble.e)-1)/fs*1e3-Li/fs*1e3, outputStructDouble.e); hold on;
plot((0:length(ep_down_sampled)-1)/fs*1e3-Li/fs*1e3, ep_down_sampled); hold off;
legend('e','e_p')
set(gca,'XLim',[0 (L-Li)/fs*1e3]);
xlabel('Time (ms)'); ylabel('Level');
saveas(gcf, './figures/fig1.png')

figure(2);
[hw0, f_hw0] = freqz(outputStructDouble.w0,1,1024*K,fs*K);
[hw1, f_hw1] = freqz(outputStructDouble.w,1,1024,fs);
hsh = freqz(ones(K,1)/K,1,1024*K,fs*K)./...
    freqz([zeros(1,K/2),1],1,1024*K,fs*K);

plot(f_hw0/1e3, 20*log10(abs(hw0./hsh))); hold on;
plot(f_hw1/1e3, 20*log10(abs(hw1))); hold off;
set(gca,'XLim', [0, fs/2/1e3]);
set(gca,'YLim', [-15, 5]);
set(gcf,'Name','Frequency Responce of W1 and W0');
grid on;
legend('w_0 filter', 'w filter','Location','southwest');
ylabel('Frequency Response Ampltitude (dB)');
xlabel('Frequency (kHz)');
set(gcf,'Name','Residual error PSD');
saveas(gcf, './figures/fig2.png')

figure(3);
[Pd, f_pd] = pwelch(outputStructDouble.dp(end/2:end), [], [], K*128, K*fs);
[Pe, f_pe] = pwelch(outputStructDouble.ep(end/2:end), [], [], K*128, K*fs);
plot(f_pd/1e3, 10*log10(Pd)); hold on;
plot(f_pe/1e3, 10*log10(Pe)); hold off;
set(gca, 'XLim', [0 fs/1e3]);
grid on;
legend('ANC off', 'ANC on','Location','southeast');
ylabel('Noise power spectral density (dB)');
xlabel('Frequency (kHz)');
set(gcf,'Name','Residual error PSD');
saveas(gcf, './figures/fig3.png')

fprintf('Residual Noise Power: %f\n', mean(outputStructDouble.e(end*3/4:end).^2));
fprintf('Noise Power: %f\n', mean(outputStructDouble.d(end*3/4:end).^2));
fprintf('Atenuation (dB): %f\n', ...
    10*log10(mean(outputStructDouble.d(end*3/4:end).^2)) - 10*log10(mean(outputStructDouble.e(end*3/4:end).^2)));

