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

load AAF.mat
AAF_n16r15 = fp_quantizer(conv(AAF,AAF), 16, 15);
rmse(conv(AAF,AAF),AAF_n16r15./2^15)
N_AAF = length(AAF_n16r15);

w_delays = [3.7, 2.2, 5.3];
w_amplitudes = [1.1, -0.7, 0.5]/2;
wop_n17r15 = fp_quantizer(sinc((0:NW*K-1)'-w_delays*K)*w_amplitudes', 17,15);
rmse(sinc((0:NW*K-1)'-w_delays*K)*w_amplitudes',wop_n17r15./2^15)

s_delays = [5.2, 7.2, 3.7];
s_amplitudes = [-1.3, 0.9, -0.5];
sp_n17r15 = fp_quantizer(sinc((0:NS*K-1)'-s_delays*K)*s_amplitudes',17,15);
rmse(sinc((0:NS*K-1)'-s_delays*K)*s_amplitudes',sp_n17r15./2^15)

sp1 = conv(sp_n17r15./2^15, ones(K,1)/K);
sp1 = sp1(K/2+K/4:end); % with secondary path modeling error
%sp1 = sp1(K/2:end); % no secondary path modeling error
sh_n17r15 = fp_quantizer(conv(sp1, AAF_n16r15./2^15), 17, 15);
rmse(conv(sp1, AAF_n16r15./2^15),sh_n17r15./2^15)

sh_n22r15 = K*sh_n17r15(1+(N_AAF-1)/2:K:end); % K is OSR = 2^5
sh_n22r15 = sh_n22r15(1:NS)';

% simulation signals
up = randn(K*L,1);
up_n18r15 = fp_quantizer(up, 19 ,15); % up=conv(up, ones(4,1)/4); up=up(1:end-3);
rmse(up,up_n18r15./2^15)

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
mu_n17r16 = fp_quantizer(0.25,17,16);
rmse(0.25,mu_n17r16./2^16)

% algorithm inicilizations
w = zeros(NW,1);

NW0 = NW*K-K/2;
w0 = zeros(NW0,1);

NQNS = 4;
QNSx = cell(NQNS,1);
% Levels(1) quantizes up. (2) quants w. (3) is yq. (4) is ep.
Levels = [fp_quantizer(2, 17,15) fp_quantizer(1/K, 16, 15) fp_quantizer(4, 18+16+1, 15+15) 10]; 
for i=1:NQNS
    QNSx{i} = QNS(Levels(i));
% QNSx{i} = QNS_efm(Levels(i), );
end
n1 = 1;

% logs
xqns = zeros(L*K, NQNS);
yqns = zeros(L*K, NQNS);
q = zeros(L*K, NQNS);

for n0=Li*K:L*K
    % discrete
    u0(n0) = step(QNSx{1}, up_n18r15(n0), quantizerType); % level matches input precision

%     u0(n0) = u0(n0) * 2^15;
%     w0(n0) = w0(n0) * 2^15;

    yq(n0) = - w0'*u0(n0:-1:n0-NW0+1); % u0 has 18,15 (not (17,15), becuase +/-1.5xLevel is possible output)
    y0(n0) = step(QNSx{3}, yq(n0), quantizerType); % quantizer needs bits for w0*u0. n35r30

    % physical
    yp(n0) = wop_n17r15' * up_n18r15(n0:-1:n0-NW*K+1)./2^30;
    dp(n0) = sp_n17r15'./2^15 * yp(n0:-1:n0-NW*K+1);
    ep(n0) = dp(n0) + sp_n17r15'./2^15*y0(n0:-1:n0-NW*K+1)./2^30; %y0 is n35r30. 
    
    % discrete
    e0(n0) = step(QNSx{4}, ep(n0), quantizerType); % leaving this unquantized because its coming from many fixed pt signals but is also an input to the overall model
    
    e0(n0) = fp_quantizer(e0(n0), 4, 0); % ceil(log2(Levels(4))) = 4. 10 is integer, so R=0

    if mod(n0, K)==0
        n = n0/K;
        u(n) = fp_dot(AAF_n16r15', u0(n0:-1:n0-length(AAF_n16r15)+1), 16, 15, 18, 15, 35, 30); % 15 + 15 = 30
        e(n) = fp_dot(AAF_n16r15', e0(n0:-1:n0-length(AAF_n16r15)+1), 16, 15, 4, 0, 20, 15); % 15 + 0 = 0
        d(n) = AAF_n16r15./2^15*dp(n0:-1:n0-length(AAF_n16r15)+1); % just for debug
        

        
%         u1(n) = sh_n22r15'*u(n:-1:n-NS+1);
        u1(n) = fp_dot(sh_n22r15, u(n:-1:n-NS+1), 22, 15, 35, 30, 22, 15);

%         y(n) = w'*u(n:-1:n-NW+1);
        y(n) = fp_dot(w, u(n:-1:n-NW+1), 16, 15, 22, 15, 22, 15);
        sh_y = fp_dot(sh_n22r15, y(n:-1:n-NS+1), 22, 15, 22, 15, 45, 30);
%         dh(n) = e(n) + sh_n22r15'*y(n:-1:n-NS+1);
        dh(n) = fp_add(e(n), sh_y, 20, 15, 45, 30, 45, 30);

        w_u1 = fp_dot(w, u1(n:-1:n-NW+1), 16, 15, 22, 15, 22, 15);
%         eh(n) = dh(n) - w'*u1(n:-1:n-NW+1);
        eh(n) = fp_sub(dh(n), w_u1, 45, 30, 22, 15, 45, 30);

        u1v = u1(n:-1:n-NW+1);

        u1v_sqr = fp_dot(u1v, u1v, 22, 15, 22, 15, 30, 15);
        u1v_norm = fp_quantizer(round(u1v/u1v_sqr), 20, 15); % we should quantize the division and implement it as a LUT, choosing index which is closest to approx division
%         w = w + mu_n17r16*eh(n)*u1v/(u1v'*u1v+1e-2); % mu is pow2 number
        mu_eh = fp_mult(mu_n17r16, eh(n), 17, 16, 45, 30, 45, 30);
        mu_eh_u1v_norm  = fp_mult(mu_eh, u1v_norm, 45, 30, 20, 15, 30, 15);
        w = fp_add(w, mu_eh_u1v_norm, 16, 15, 30, 15, 30, 15);
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

figure(314123)
for i = 1:4
    subplot(4,1,i)
    [counts, groupnames] = groupcounts(yqns(NbufFill:end,i));
    stem(groupnames, counts)
    title(sprintf('QNS %d',i))
    xlabel('QNS output')
end

fprintf(1,'QNS: u w y e\n');
for i=1:NQNS
    m = sqrt(max(conv(xqns(:,i).^2,ones(10,1))/10));
    fprintf(1, 'QNS(%d) -- max input signal RMS: %f\n', i, m);
    
    x = conv(AAF_n16r15,xqns(:,i)); x=x(length(AAF_n16r15):end);
    y = conv(AAF_n16r15,yqns(:,i)); y=y(length(AAF_n16r15):end);
    normalized_mse = mean((y-x).^2)/(QNSx{i}.L)^2;
    fprintf(1,'QNS(%d) -- nmse: %f dB bits: %f\n', i, ...
        10*log10(normalized_mse),(-10*log10(3)-10*log10(normalized_mse))/(20*log10(2)));
end

figure(314123)
for i = 1:4
    subplot(4,1,i)
    [counts, groupnames] = groupcounts(yqns(NbufFill:end,i));
    stem(groupnames, counts)
    title(sprintf('QNS %d',i))
    xlabel('QNS output')
end

fprintf(1,'QNS: u w y e\n');
for i=1:NQNS
    m = sqrt(max(conv(xqns(:,i).^2,ones(10,1))/10));
    fprintf(1, 'QNS(%d) -- max input signal RMS: %f\n', i, m);
    
    x = conv(AAF,xqns(:,i)); x=x(length(AAF):end);
    y = conv(AAF,yqns(:,i)); y=y(length(AAF):end);
    normalized_mse = mean((y-x).^2)/(QNSx{i}.L)^2;
    fprintf(1,'QNS(%d) -- nmse: %f dB bits: %f\n', i, ...
        10*log10(normalized_mse),(-10*log10(3)-10*log10(normalized_mse))/(20*log10(2)));
end

figure(1);
ep_filtered = conv(ep, AAF);
ep_down_sampled = ep_filtered(K:K:end);
plot((0:length(e)-1)/fs*1e3-Li/fs*1e3, e); hold on;
plot((0:length(ep_down_sampled)-1)/fs*1e3-Li/fs*1e3, ep_down_sampled); hold off;
legend('e','e_p')
set(gca,'XLim',[0 (L-Li)/fs*1e3]);
xlabel('Time (ms)'); ylabel('Level');
saveas(gcf, './figures/fig1.png')

figure(2);
[hw0, f_hw0] = freqz(w0,1,1024*K,fs*K);
[hw1, f_hw1] = freqz(w,1,1024,fs);
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
[Pd, f_pd] = pwelch(dp(end/2:end), [], [], K*128, K*fs);
[Pe, f_pe] = pwelch(ep(end/2:end), [], [], K*128, K*fs);
plot(f_pd/1e3, 10*log10(Pd)); hold on;
plot(f_pe/1e3, 10*log10(Pe)); hold off;
set(gca, 'XLim', [0 fs/1e3]);
grid on;
legend('ANC off', 'ANC on','Location','southeast');
ylabel('Noise power spectral density (dB)');
xlabel('Frequency (kHz)');
set(gcf,'Name','Residual error PSD');
saveas(gcf, './figures/fig3.png')

fprintf('Residual Noise Power: %f\n', mean(e(end*3/4:end).^2));
fprintf('Noise Power: %f\n', mean(d(end*3/4:end).^2));
fprintf('Atenuation (dB): %f\n', ...
    10*log10(mean(d(end*3/4:end).^2)) - 10*log10(mean(e(end*3/4:end).^2)));

figure(4)
subplot(221)
histogram(up_n18r15); title('up')
subplot(222)
histogram(w); title('w')
subplot(223); histogram(yq); title('yq')
subplot(224); histogram(ep); title('ep')

figure(5)
delE = abs(fft(e0(NbufFill:end)-ep(NbufFill:end)));
delE = [delE(1) ; 2*delE(2:end/2)];
f = (0:(NFFT-1))./NFFT * fs * K;
semilogx(f(1:end/2), 20*log10(delE))
grid on