fs = 44.1e3; ts = 1/fs;
OSR = 32;
K = OSR;
L = 3000;
fBW = 20e3;
rng(7283723);

doNoiseInput = 0; doSineInput = ~doNoiseInput;
if doNoiseInput
    u = fp_quantizer(randn(K*L,1)', 19, 15);
    t = (0:(length(u)-1))*(ts/OSR);
    fname = sprintf('../verilog/QNS/sim/rand_7283723_n19r15_OSR_%d_fs_44p1k_%d_pts.txt',OSR,length(u));
elseif doSineInput
    f = 1e3;
    t = (0:ts/OSR:L/fs - ts/OSR)';
    u = fp_quantizer(1/2 * sin(2*pi*1e3*t), 19, 15);
    fname = sprintf('../verilog/QNS/sim/sine_n19r15_fin_1k_0p5VFS_OSR_%d_fs_44p1k_%d_pts.txt',OSR,length(u));
end
writematrix(ndec2hex(u,19), fname)

N = length(u);


level_i = zeros(1,N);

e = zeros(1,N); y = zeros(1,N); reg1=zeros(1,N); reg2=zeros(1,N);
v = zeros(1,N);

scaling = 2^14;
reg1(1) = 0;
reg2(1) = 0;
for n = 1:N-1 % in cycle 1, the system was reset to I.C
    if rem(n, 2000) == 0
        fprintf("%.2f %%\n",n/N * 100)
    end
    
    y(n) = u(n) - 2 * reg1(n) + reg2(n);
    y_dith = y(n); %+ sign(1/2 - rand()) * round(rand()); % this is called dithering
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
wnorm = wc / (ws/2);
%b = fir1(OSR-1, wnorm); % normalized frequency. mult by fs to get real radians
load AAF.mat
AAF = conv(AAF,AAF);
figure(5); clf;
freqz(AAF, 1, 1024*OSR);
% [h,w] = freqz(b, 1, 1024*OSR,"whole");


%% making AAF filter in hdl
firAAF = dsp.FIRFilter;
firAAF.Numerator = AAF;
firAAF.CoefficientsDataType = "Custom";
firAAF.CustomCoefficientsDataType = numerictype(true, 32, 36);

test = firAAF(out);
test = downsample(test, OSR);
%%


out_filt = conv(out, AAF);
out_decim = downsample(out_filt, OSR);
u_filt = conv(u, AAF);
u_decim = downsample(u_filt, OSR);
u_normfs = u_decim./max(abs(u_decim));
out_normfs = out_decim./max(abs(out_decim));
floatingptLSB = min(abs(out(out~=0)));

figure(1); clf
subplot(211)
out_normfs = reshape(out_normfs, size(u_normfs));
plot(10*log10((out_normfs - u_normfs).^2)); hold on
grid on
root_mse = rmse(u_normfs,out_normfs);
title(sprintf("rms error: %E",root_mse))
subplot(212)
plot(out_normfs, '*'); hold on
plot(u_normfs, '--')
title('decimated output vs decimated input')
legend('output', 'input')

if doSineInput
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
    fname = sprintf('../verilog/QNS/sim/quantizer_level_output_sine_fin_1k_0p5VFS_OSR_%d_fs_44p1k.txt',OSR);

    fbin = ceil(f * N ./ fs ./ OSR) + 1;
    fBWbin = ceil(fBW * N ./ fs ./ OSR) + 1;
    sigpwr = OUT(fbin).^2;
    noisepwr = sum(OUT(setdiff((1:fBWbin), fbin)).^2);
    snr = 10*log10(sigpwr./noisepwr)

else
    fname = sprintf('../verilog/QNS/sim/quantizer_level_output_QNS1_u_rand_input_OSR_%d.txt',OSR);
end 
writematrix(out'./floatingptLSB , fname)

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
%% compare with verilog
if doSineInput  
    verilogData = readmatrix("../verilog/QNS/sim/test_mod2_sine_n19r15_fin_1k_0p5VFS_OSR_64_fs_44p1k.txt");
else
    verilogData = readmatrix("../verilog/QNS/sim/test_mod2_rand_7283723_n19r15_OSR_%d_fs_44p1k.txt");
end
verilogModulatorOut = rmmissing(verilogData(:,2));
verilogCICout = rmmissing(verilogData(:,3));
verilogCICdecimated = downsample(verilogCICout, OSR);
verilogInput = rmmissing(verilogData(:,1));

verilog_out_filt = conv(verilogModulatorOut, b);
verilog_out_decim = downsample(verilog_out_filt, OSR);
verilog_out_normfs = verilog_out_decim./max(abs(verilog_out_decim));
% u_filt = conv(u, b);
% u_decim = downsample(u_filt, OSR);
% u_normfs = u_decim./max(abs(u_decim));
% out_normfs = out_decim./max(abs(out_decim));
% floatingptLSB = min(abs(out(out~=0)));

figure(6); clf
subplot(211)
verilog_out_normfs = reshape(verilog_out_normfs, size(u_normfs));
plot(10*log10((verilog_out_normfs - u_normfs).^2)); hold on
grid on
root_mse = rmse(verilog_out_normfs,out_normfs);
title(sprintf("rms error: %.4E",root_mse))
subplot(212)
plot(verilog_out_normfs, '*'); hold on
plot(u_normfs, '--')
title('decimated output vs decimated input')
legend('output', 'input')
