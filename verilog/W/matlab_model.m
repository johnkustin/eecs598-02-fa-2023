clear; close all;
%%
N = 2^16;
Fn = 44.1e3; OSR = 32; Fs = OSR * Fn;
Nint = 32; R = 31;

b = firpm(31, [0 10e3 20e3 Fs/2]./(Fs/2), [1 1 0 0]);
b_dec = fp_quantizer(b, Nint, R); % 
b_shaped = reshape(b_dec, [], 4);
f = fopen("data/weights.txt", "w");

fprintf(f,"={\n");
for i = 1:(size(b_shaped,1)-1)
    fprintf(f, "%d'h%s,%d'h%s,%d'h%s,%d'h%s,\n",Nint,...
        string(ndec2hex(b_shaped(i,1),Nint)), Nint,...
        string(ndec2hex(b_shaped(i,2),Nint)), Nint, ...
        string(ndec2hex(b_shaped(i,3),Nint)), Nint, ...
        string(ndec2hex(b_shaped(i,4),Nint)));
end
fprintf(f, "%d'h%s,%d'h%s,%d'h%s,%d'h%s\n",Nint,...
        string(ndec2hex(b_shaped(i+1,1),Nint)), Nint,...
        string(ndec2hex(b_shaped(i+1,2),Nint)), Nint, ...
        string(ndec2hex(b_shaped(i+1,3),Nint)), Nint, ...
        string(ndec2hex(b_shaped(i+1,4),Nint)));
fprintf(f,"};");
fclose(f);

figure(1)
freqz(b)

f = 1e3;
t = (0:(N*OSR-1))/N/OSR;
x = sin(2*pi*f*t);
noise = 0.3*randn(1,N*OSR);
% noise = noise ./ (sum(abs(noise).^2));

xn = x + noise;
xn = xn ./ max(abs(xn));

xn_dec = fp_quantizer(xn', Nint, R);

writematrix(ndec2hex(xn_dec,Nint), "data/xnoise.txt");


XN = abs(fft(xn));
XN = [XN(1) 2*XN(2:floor(end/2))];
XN = XN ./ max(XN);
F = (0:(N*OSR-1))/N/OSR;


y = conv(xn, b, "same");
writematrix(ndec2hex(fp_quantizer(y', Nint, R), Nint), "data/ynoise.txt")
YN = abs(fft(y));
YN = [YN(1) 2*YN(2:floor(end/2))];
YN = YN ./ max(YN);
figure(214); clf;
plot(t, x, 'b'); hold on
plot(t, xn, 'y'); plot(t, y, 'r'); hold off

figure(3); clf;
subplot(311)
semilogx(F(1:floor(end/2)), 20*log10(XN))
subplot(312)
semilogx(F(1:floor(end/2)), 20*log10(YN))
%%
hw_results = readmatrix("hw_results.txt","OutputType","string" );
% hw_results = hw_results(hw_results ~= "xxxxxxxx");
hw_results_crop = hw_results(1:length(xn));
hw_y = nhex2dec(hw_results_crop, Nint);
hw_y_real = hw_y./2^R;

MSE = mean((hw_y_real - y').^2)
figure(231)
subplot(211)
stem(hw_y_real); hold on
stem(y)
legend('hw_y', 'y matlab')
xlim([1e6 1.01e6])
subplot(212)
stem(hw_y_real - y')
xlim([1e6 1.01e6])
title(sprintf("MSE: %E", MSE))

figure(3)
subplot(313)
YrN = abs(fft(hw_y_real));
YrN = [YrN(1) 2*YrN(2:floor(end/2))];
YrN = YrN ./ max(YrN);
semilogx(F(1:floor(end/2)), 20*log10(YrN))