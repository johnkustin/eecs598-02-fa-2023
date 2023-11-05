fs = 44.1e3; ts = 1/fs;
OSR = 64;
fBW = 20e3;

in1 = 1; in2 = ~in1;
if in1
    u = readlines('../verilog/modulator/up_n16r15.txt');
    u = nhex2dec(u(1:end-1), 16);
    t = 0:ts/OSR: length(u)/fs - ts/OSR;
elseif in2
    f = 1e3;
    t = (0:ts/OSR:OSR*1/f - ts/OSR)';
    u = fp_quantizer(1/2 * sin(2*pi*1e3*t), 16, 15);
end

% u = fi(1/2 * sin(2*pi*1e3*t), true, 16, 15);

N = length(u);


% fb = fi(zeros(1,N), true, 3, 1);
fb = zeros(1,N);
% fb.dec(1) = '3'; % 
delta1adder = zeros(1,N);%fi(zeros(1,N), true, 16, 15);
sigma1reg = zeros(1,N);%fi(zeros(1,N), true, 17, 15);

delta2adder = zeros(1,N);%fi(zeros(1,N), true, 17, 15);
sigma2reg = zeros(1,N);%fi(zeros(1,N), true, 18, 15);

out = zeros(1,N);%fi(zeros(1,N), true, 3, 1);
level_i = zeros(1,N);
% out = zeros(1,N);

LSB = 2^14;

e = zeros(1,N); y = zeros(1,N); reg1=zeros(1,N); reg2=zeros(1,N);
v = zeros(1,N);

% NFS = -(2^15 - 1); PFS = 2^15 - 1; % not 2's comp
FS = 2^15 - 1;
reg1(1) = FS/2;%NFS/2; 
reg2(1) = FS/2;%PFS/2;
for n = 1:N-1 % in cycle 1, the system was reset to I.C
    if rem(n, 2000) == 0
        fprintf("%.2f %%\n",n/N * 100)
    end
    
    y(n) = u(n) - 2 * reg1(n) + reg2(n);
    y_dith = y(n) + sign(1/2 - rand()) * round(rand());
    if y_dith > 0 % random LSB
            v(n) = 2^(-1);
        if y_dith > FS % pos full scale
            v(n) = 2^0;
        end
    elseif y_dith < 0
        v(n) = -2^(-1);
        if y_dith < -FS % neg full scale
            v(n) = -2^0;
        end
    else
        v(n) = 0;
    end

    v_scaled = v(n) * FS; 
    e(n) = y(n) - v_scaled;
    if n > 1
        if e(n) > e(n-1)
            e(n) - e(n-1);
%             figure; stem(20*log10(abs(e(1:end/2)./FS)))
        end
    end
    reg1(n+1) = -e(n);
    reg2(n+1) = reg1(n);

%       delta1adder(n) = u(n) - (fb(n-1) * 2^(16-3));
% %     delta1adder(n)
%     sigma1reg(n) = sigma1reg(n-1) + delta1adder(n);
% %     sigma1reg(n+1)
%     delta2adder(n) = sigma1reg(n-1) - (fb(n-1) * 2^(17-3));
% %     delta2adder(n)
%     sigma2reg(n) = sigma2reg(n-1) + delta2adder(n);
% %     sigma2reg(n+1)
% 
% %     out(n) = bpquantizer(sigma2reg(n), 4, 2^15 - 1, -2^15);
% if sigma2reg(n) > 1/4 * 2^16 - 1
%     if sigma2reg(n) < 3/4 * 2^15 - 1
%         out(n) = 1/2 *(2^15 - 1);
%     end
%     out(n) = 2^15 - 1;
% end
% if sigma2reg(n) < -1/4 * 2^15 - 1
%     if sigma2reg(n) < -3/4 * 2^15 - 1
%         out(n) = -2^15;
%     end
%     out(n) = -2^15/2;
% end
% %     level_i(n) = min(max(round((sigma2reg(n)/LSB + 2)-1/2),0),4-1);
% %     out(n) = LSB*((level_i(n)'+1/2)-2);
% %     out(n+1)
% %     out(n+1) = out(n+1) * LSBhalfstep;
%     fb(n) = out(n);
%     fb(n)
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
    writematrix(out./floatingptLSB , 'quantizer_level_output_sine_fin_1k_0p5VFS_OSR_64_fs_44p1k.txt')

    fbin = ceil(f * N ./ fs ./ OSR) + 1;
    fBWbin = ceil(fBW * N ./ fs ./ OSR) + 1;
    sigpwr = OUT(fbin).^2;
    noisepwr = sum(OUT(setdiff((1:fBWbin), fbin)).^2);
    snr = 10*log10(sigpwr./noisepwr)

else
    writematrix(out./floatingptLSB , 'quantizer_level_output_QNS1_u_rand_input.txt')
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