fs = 44.1e3; ts = 1/fs;
OSR = 64;
K = OSR;
L = 3000;
fBW = 20e3;
rng(7283723);

in1 = 0; in2 = ~in1;
if in1
    u = fp_quantizer(randn(K*L,1), 19, 15)
    t = 0:ts/OSR: length(u)/fs - ts/OSR;
    writematrix(ndec2hex(u,19), '../verilog/QNS/sim/rand_7283723_n19r15_OSR_64_fs_44p1k.txt')

elseif in2
    f = 1e3;
    t = (0:ts/OSR:OSR*1/f - ts/OSR)';
    u = fp_quantizer(1/2 * sin(2*pi*1e3*t), 19, 15);
    writematrix(ndec2hex(u, 19), '../verilog/QNS/sim/sine_n19r15_fin_1k_0p5VFS_OSR_64_fs_44p1k.txt')
end

N = length(u);


% fb = fi(zeros(1,N), true, 3, 1);
fb = zeros(1,N);
% fb.dec(1) = '3'; % 
delta1adder = zeros(1,N);%fi(zeros(1,N), true, 16, 15);
sigma1reg = zeros(1,N);%fi(zeros(1,N), true, 17, 15);

delta2adder = zeros(1,N);%fi(zeros(1,N), true, 17, 15);
sigma2reg = zeros(1,N);%fi(zeros(1,N), true, 18, 15);

out = zeros(1,N);
level_i = zeros(1,N);

e = zeros(1,N); y = zeros(1,N); reg1=zeros(1,N); reg2=zeros(1,N);
v = zeros(1,N);

% NFS = -(2^15 - 1); PFS = 2^15 - 1; % not 2's comp
scaling = 2^14;
reg1(1) = 0;%;scaling/2;%NFS/2; 
reg2(1) = 0;%;scaling/2;%PFS/2;
for n = 1:N-1 % in cycle 1, the system was reset to I.C
    if rem(n, 2000) == 0
        fprintf("%.2f %%\n",n/N * 100)
    end
    
    y(n) = u(n) - 2 * reg1(n) + reg2(n);
    y_dith = y(n); %+ sign(1/2 - rand()) * round(rand());
    if y_dith > 0 % random LSB
            v(n) = 1;%2^(-1);
        if y_dith > scaling % fx pt resolution scali
            v(n) = 3;%2^0;
        end
    elseif y_dith < 0
        v(n) = -1;%-2^(-1);
        if y_dith < -scaling % neg full scale
            v(n) = -3;%-2^0;
        end
    end

    v_scaled = v(n) * scaling; 
    e(n) = y(n) - v_scaled;
    reg2(n+1) = reg1(n);
    reg1(n+1) = -e(n);



end
out = v;

wc = 2*pi*15e3; % cutoff frequency
ws = 2*pi*fs*OSR;
b = fir1(OSR-1, wc/(ws/2)); % normalized frequency. mult by fs to get real radians
figure(5); clf;
freqz(b, 1, 1024*OSR);
% [h,w] = freqz(b, 1, 1024*OSR,"whole");

out_filt = conv(out, b);
out_decim = downsample(out_filt, OSR);
u_filt = conv(u, b);
u_decim = downsample(u_filt, OSR)';
u_normfs = u_decim./max(abs(u_decim));
out_normfs = out_decim./max(abs(out_decim));
floatingptLSB = min(abs(out(out~=0)));

figure(1); clf
subplot(211)
plot(10*log10((out_normfs - u_normfs).^2)); hold on
grid on
root_mse = rmse(u_normfs,out_normfs);
title(sprintf("rms error: %E",root_mse))
subplot(212)
plot(out_normfs, '*'); hold on
plot(u_normfs, '--')
title('decimated output vs decimated input')
legend('output', 'input')

if in2
    figure(2); clf;
    F = (0:(N-1))/N * fs * OSR;
    OUT = abs(fft(out));
    OUT = [OUT(1) OUT(2:floor(N/2)) * 2];
    OUT = OUT ./ max(OUT);
    semilogx(F(1:floor(N/2)), 20*log10(OUT))
    xlabel('Frequency (Hz)')
    ylabel('Magnitude (dBFS)')
    title(sprintf("%d pt FFT", N))
    grid on
    writematrix(out'./floatingptLSB , '../verilog/QNS/sim/quantizer_level_output_sine_fin_1k_0p5VFS_OSR_64_fs_44p1k.txt')

    fbin = ceil(f * N ./ fs ./ OSR) + 1;
    fBWbin = ceil(fBW * N ./ fs ./ OSR) + 1;
    sigpwr = OUT(fbin).^2;
    noisepwr = sum(OUT(setdiff((1:fBWbin), fbin)).^2);
    snr = 10*log10(sigpwr./noisepwr)

else
    writematrix(out'./floatingptLSB , '../verilog/QNS/sim/quantizer_level_output_QNS1_u_rand_input.txt')
end 


figure(3);clf
numLSBs = out./floatingptLSB;
bits = dec2bin(numLSBs); % this is doing (out * 2^R)
% out is a 2-bit bipolar number, so needs 3 bits.
bitslice = bits(:,end-2:end);
% bsMatBool = [bitslice=='110' bitslice=='111' bitslice=='0' bitslice=='001' bitslice=='010' ];
% bsMatName = ["110" "111" "0" "001" "010" ];
% 
% bsMat = arrayfun(@())
[g,c] = groupcounts(numLSBs');
stem(c,g, 'LineWidth',3, 'MarkerSize',3)
xlabel('Quantizer Level')
title(sprintf("LSB = %.2f", floatingptLSB))
% histogram(out./floatingptLSB)
% xlabel('step index')