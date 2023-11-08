function [mantissa, fp_info] = fp_mult(fp_in1, fp_in2, N1, R1, N2, R2, N3, R3)
%floating point subtraction of fp_in1-fp_in2
%   Detailed explanation goes here


mantissa = fp_in1 .* fp_in2; % (N1+N2,R1+R2)

fp_info.max_n3_mantissa = 2^(N3-1)-1; % do saturation in case
fp_info.min_n3_mantissa = -2^(N3-1);
gti = mantissa > fp_info.max_n3_mantissa;
lti = mantissa < fp_info.min_n3_mantissa;

mantissa(gti) = fp_info.max_n3_mantissa;
mantissa(lti) = fp_info.min_n3_mantissa;

r3_shift = R3 - (R1 + R2); % R of result is R1+R2.
mantissa = round(mantissa * 2^r3_shift);

fp_info.out_res = 2^-R3;
fp_info.mantissa = mantissa;
fp_info.real = fp_info.out_res * mantissa;
fp_info.min_real = fp_info.out_res * fp_info.min_n3_mantissa;
fp_info.max_real = fp_info.out_res * fp_info.max_n3_mantissa;

fp_info.in1_res = 2^-R1;
fp_info.in2_res = 2^-R2;
fp_info.inter_res = 2^(-(R1+R2));
end

