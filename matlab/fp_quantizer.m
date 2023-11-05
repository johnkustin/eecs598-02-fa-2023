function [mantissa, fp_info] = fp_quantizer(input_signal,N,R)
%FP_QUANTIZER Summary of this function goes here
%   Detailed explanation goes here

fp_info.N = N;
fp_info.R = R;
fp_info.input_signal = input_signal;

fp_info.max_mantissa = 2^(N-1)-1;
fp_info.min_mantissa = -2^(N-1);
mantissa = round(input_signal * 2^R);
gti = mantissa > fp_info.max_mantissa;
lti = mantissa < fp_info.min_mantissa;
mantissa(gti) = fp_info.max_mantissa;
mantissa(lti) = fp_info.min_mantissa;

fp_info.mantissa = mantissa;
fp_info.res = 2^-R;
fp_info.min_real = fp_info.res * fp_info.min_mantissa;
fp_info.max_real = fp_info.res * fp_info.max_mantissa;
fp_info.real = fp_info.res * mantissa;

end

