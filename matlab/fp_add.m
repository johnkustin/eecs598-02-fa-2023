function [mantissa, fp_info] = fp_add(fp_in1, fp_in2, N1, R1, N2, R2, N3, R3)
%floating point subtraction of fp_in1-fp_in2
%   Detailed explanation goes here

[max_R12_input, i] = max([R1, R2]);
[min_R_input, j] = min([R1, R2]);
shift_R12_amt = max_R12_input - min_R_input;

if i == 1 % R1 is max
    in1_shifted = fp_in1 * 2^(-shift_R12_amt); % shift it down
    gti = in1_shifted > 2^(N1-1)-1;
    lti = in1_shifted < -2^(N1-1);
    
    in1_shifted(gti) = 2^(N1-1)-1;
    in1_shifted(lti) = -2^(N1-1)-1;

    mantissa = fp_in2 + in1_shifted;
else % R2 is max
    in2_shifted = fp_in2 * 2^(-shift_R12_amt);

    gti = in2_shifted > 2^(N2-1)-1;
    lti = in2_shifted < -2^(N2-1);
    
    in2_shifted(gti) = 2^(N2-1)-1;
    in2_shifted(lti) = -2^(N2-1)-1;

    mantissa = fp_in1 + in2_shifted;
end

shift_R3_amt = R3 - min_R_input;
mantissa = round(mantissa * 2^(shift_R3_amt)); % truncation

fp_info.max_n3_mantissa = 2^(N3-1)-1;
fp_info.min_n3_mantissa = -2^(N3-1);
gti = mantissa > fp_info.max_n3_mantissa;
lti = mantissa < fp_info.min_n3_mantissa;

mantissa(gti) = fp_info.max_n3_mantissa;
mantissa(lti) = fp_info.min_n3_mantissa;

fp_info.out_res = 2^-R3;
fp_info.mantissa = mantissa;
fp_info.real = fp_info.out_res * mantissa;
fp_info.min_real = fp_info.out_res * fp_info.min_n3_mantissa;
fp_info.max_real = fp_info.out_res * fp_info.max_n3_mantissa;
fp_info.max_integer = 2^(N3-R3-1)-1;
fp_info.min_integer = -2^(N3-R3-1);
fp_info.in_res = 2^-max_R12_input;

end

