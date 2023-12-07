% Anex to the Paper:
% Low Delay and Low Cost Sigma-Delta Adaptive Controller for Active Noise Control
% Paulo Lopes

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
NbufFill = Li*K;
NFFT = L * K - NbufFill;
quantizerType = "orig"; %options: "mid-tread", "mid-riser", "orig"

rng(7283723);

load data/AAF.mat
AAF = conv(AAF,AAF);
% AAF(abs(AAF) <= 1e-5) = 0;
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
R = 28; Nint = 32;
writematrix(ndec2hex(fp_quantizer(up, Nint, R), Nint), "data/upg.txt")
% up = up ./max(abs(up));
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

NW0 = NW*K-K/2;
w0 = zeros(NW0,1);

NQNS = 4;
QNSx = cell(NQNS,1);
% Levels = [1.5 1/K/2 0.5 2.5]; % each is a quantizer step 
Levels = [2 1/K 4 10];
% iterative process for choosing levels
% the first qns, for up, dominates the quality of performance
% ingeneral, the distribution of quantization levels should be adjusted
% so all levels are exercised as much as possible (as equal distr as
% possible)
% for normalized unity up % Levels = [0.25 1/K 1.5 1]; % each is a quantizer step 
for i=1:NQNS
%     QNSx{i} = QNS(Levels(i));
QNSx{i} = QNS_efm(Levels(i), Levels(i));
end
n1 = 1;

% logs
xqns = zeros(L*K, NQNS);
yqns = zeros(L*K, NQNS);
q = zeros(L*K, NQNS);

for n0=Li*K:L*K
    % discrete
    u0(n0) = step(QNSx{1}, up(n0), quantizerType);
    
    yq(n0) = - w0'*u0(n0:-1:n0-NW0+1);
    y0(n0) = step(QNSx{3}, yq(n0), quantizerType);

    % physical
    yp(n0) = wop'*up(n0:-1:n0-NW*K+1);
    dp(n0) = sp'*yp(n0:-1:n0-NW*K+1);
    ep(n0) = dp(n0) + sp'*y0(n0:-1:n0-NW*K+1);
    
    % discrete
    e0(n0) = step(QNSx{4}, ep(n0 - 5), quantizerType); % 5 cycle rtl delay from qns1 -> w0 -> qns4
    
    if mod(n0, K)==0
        n = n0/K;
        u(n) = AAF*u0(n0:-1:n0-length(AAF)+1);
        e(n) = AAF*e0(n0:-1:n0-length(AAF)+1);
        d(n) = AAF*dp(n0:-1:n0-length(AAF)+1); % just for debug
        
        u1(n) = sh'*u(n:-1:n-NS+1);

        y(n) = w'*u(n:-1:n-NW+1);
        dh(n) = e(n) + sh'*y(n:-1:n-NS+1);
        eh(n) = dh(n) - w'*u1(n:-1:n-NW+1);

        u1v = u1(n:-1:n-NW+1);
        w = w + mu*eh(n)*u1v/(u1v'*u1v+1e-2);
    end
    
    if n1 > NW0
        n1 = 1;
        reset(QNSx{2});
    end
    w0(n1) = step(QNSx{2}, w(floor((n1-1)/K+0.5)+1)/K, quantizerType);
    n1 = n1 + 1;

    for i=1:NQNS
      xqns(n0,i) = QNSx{i}.x;
      yqns(n0,i) = QNSx{i}.yd;
      q(n0,i) = QNSx{i}.q;
    end
end

%% glue with rtl
rtl = readlines("../../python/TOP/data/y0_results.txt");
rtl_num = cellfun(@str2num,rtl(1:end-1));
y0_rtl = rtl_num;

qns1 = readlines("./data/qns1.txt");
qns2 = readlines("./data/qns2.txt");
qns3 = readlines("./data/qns3.txt");
qns4 = readlines("./data/qns4.txt");
qns1rtl = cellfun(@str2num,split(strip(qns1(1:end-1))));
qns2rtl = cellfun(@str2num,split(strip(qns2(1:end-1))));
qns3rtl = cellfun(@str2num,split(strip(qns3(1:end-1))));
qns4rtl = cellfun(@str2num,split(strip(qns4(1:end-1))));

Q1=abs(fft(qns1rtl(:,2)));
Q2=abs(fft(qns2rtl(:,2)));
Q3=abs(fft(qns3rtl(:,2)));
Q4=abs(fft(qns4rtl(:,2)));
Q1=[Q1(1) ; 2*Q1(2:(end/2))];
Q2=[Q2(1) ; 2*Q2(2:(end/2))];
Q3=[Q3(1) ; 2*Q3(2:(end/2))];
Q4=[Q4(1) ; 2*Q4(2:(end/2))];
F1=(0:length(Q1)-1)/length(Q1);
F2=(0:length(Q2)-1)/length(Q2);
F3=(0:length(Q3)-1)/length(Q3);
F4=(0:length(Q4)-1)/length(Q4);
figure(675); semilogx(F1,20*log10(Q1./max(abs(Q1))))
figure(676); semilogx(F2,20*log10(Q2./max(abs(Q2))))
figure(677); semilogx(F3,20*log10(Q3./max(abs(Q3))))
figure(678); semilogx(F4,20*log10(Q4./max(abs(Q4))))
%% data processing rtl
yp_rtl = zeros(size(y0_rtl));
dp_rtl = zeros(size(y0_rtl));
ep_rtl = zeros(size(y0_rtl));

for n0=NW*K:size(y0_rtl)
    yp_rtl(n0) = wop' * up(n0:-1:n0-NW*K+1);
    dp_rtl(n0) = sp' * yp_rtl(n0:-1:n0-NW*K+1);
    ep_rtl(n0) = dp_rtl(n0) + sp' * y0_rtl(n0:-1:n0-NW*K+1);
end
%%
figure(21312)
ep_filtered = conv(ep, AAF);
ep_down_sampled = ep_filtered(K:K:end);
ep_filtered_rtl = conv(ep_rtl, AAF);
ep_down_sampled_rtl = ep_filtered_rtl(K:K:end);
subplot(211)
plot((0:length(ep_down_sampled)-1)/fs*1e3-Li/fs*1e3, ep_down_sampled, 'LineWidth', 2);
legend('e_p')
subplot(212)
plot((0:length(ep_down_sampled_rtl)-1)/fs*1e3-Li/fs*1e3, ep_down_sampled_rtl, 'LineWidth', 2); 
legend('e_p_rtl')
set(gca,'XLim',[0 (L-Li)/fs*1e3]);
xlabel('Time (ms)'); ylabel('Level');
% saveas(gcf, './figures/fig1.png')


%%


% 
% figure(314123)
% for i = 1:4
%     subplot(4,1,i)
%     [counts, groupnames] = groupcounts(yqns(NbufFill:end,i));
%     stem(groupnames, counts)
%     title(sprintf('QNS %d',i))
%     xlabel('QNS output')
% end
% 
% fprintf(1,'QNS: u w y e\n');
% for i=1:NQNS
%     m = sqrt(max(conv(xqns(:,i).^2,ones(10,1))/10));
%     fprintf(1, 'QNS(%d) -- max input signal RMS: %f\n', i, m);
% 
%     x = conv(AAF,xqns(:,i)); x=x(length(AAF):end);
%     y = conv(AAF,yqns(:,i)); y=y(length(AAF):end);
%     normalized_mse = mean((y-x).^2)/(QNSx{i}.L)^2;
%     fprintf(1,'QNS(%d) -- nmse: %f dB bits: %f\n', i, ...
%         10*log10(normalized_mse),(-10*log10(3)-10*log10(normalized_mse))/(20*log10(2)));
% end
% 
% figure(1);
% ep_filtered = conv(ep, AAF);
% ep_down_sampled = ep_filtered(K:K:end);
% plot((0:length(e)-1)/fs*1e3-Li/fs*1e3, e, 'LineWidth', 2); hold on;
% plot((0:length(ep_down_sampled)-1)/fs*1e3-Li/fs*1e3, ep_down_sampled, 'LineWidth', 2); hold off;
% legend('e','e_p')
% set(gca,'XLim',[0 (L-Li)/fs*1e3]);
% xlabel('Time (ms)'); ylabel('Level');
% saveas(gcf, './figures/fig1.png')

% figure(2);
% [hw0, f_hw0] = freqz(w0,1,1024*K,fs*K);
% [hw1, f_hw1] = freqz(w,1,1024,fs);
% hsh = freqz(ones(K,1)/K,1,1024*K,fs*K)./...
%     freqz([zeros(1,K/2),1],1,1024*K,fs*K);
% 
% plot(f_hw0/1e3, 20*log10(abs(hw0./hsh)), 'LineWidth', 3); hold on;
% plot(f_hw1/1e3, 20*log10(abs(hw1)), 'LineWidth', 3); hold off;
% set(gca,'XLim', [0, fs/2/1e3]);
% set(gca,'YLim', [-15, 5]);
% set(gcf,'Name','Frequency Responce of W1 and W0');
% grid on;
% legend('w_0 filter (oversampled)', 'w filter (Nyquist)','Location','southwest');
% ylabel('Frequency Response Ampltitude (dB)');
% xlabel('Frequency (kHz)');
% title("Frequency Response of W_0 and W")
% saveas(gcf, './figures/fig2.png')
% 
% figure(3);
% [Pd, f_pd] = pwelch(dp(end/2:end), [], [], K*128, K*fs);
% [Pe, f_pe] = pwelch(ep(end/2:end), [], [], K*128, K*fs);
% plot(f_pd/1e3, 10*log10(Pd), 'LineWidth', 3); hold on;
% plot(f_pe/1e3, 10*log10(Pe), 'LineWidth', 3); hold off;
% set(gca, 'XLim', [0 fs/1e3]);
% grid on;
% legend('ANC off', 'ANC on','Location','southeast');
% ylabel('Power Spectral Density (dB)');
% xlabel('Frequency (kHz)');
% title("Power of Residual Noise e_p")
% set(gcf,'Name','Residual error PSD');
% saveas(gcf, './figures/fig3.png')
% 
% fprintf('Residual Noise Power: %f\n', mean(e(end*3/4:end).^2));
% fprintf('Noise Power: %f\n', mean(d(end*3/4:end).^2));
% fprintf('Atenuation (dB): %f\n', ...
%     10*log10(mean(d(end*3/4:end).^2)) - 10*log10(mean(e(end*3/4:end).^2)));
% 
% figure(4)
% subplot(221)
% histogram(up); title('up')
% subplot(222)
% histogram(w); title('w')
% subplot(223); histogram(yq); title('yq')
% subplot(224); histogram(ep); title('ep')
% 
% figure(5)
% delE = abs(fft(e0(NbufFill:end)-ep(NbufFill:end)));
% % delE = abs(abs(hw0./hsh) - abs(hw1));
% delE = [delE(1) ; 2*delE(2:floor(end/2))];
% f = (0:(NFFT-1))./NFFT * fs * K;
% % f = (0:(1024*K -1))./(1024*K-1) * fs*K;
% semilogx(f(1:floor(end/2)), 20*log10(delE))
% grid on