function [mantissa, fp_info] = fp_conv(h_q, x_q, N1, R1, N2, R2, N3, R3)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
% k = 1:length(fp_in1);
% j = max(1,k+1-n):1:min(k,m);


N = length(x_q);
M = length(h_q);

padzeros = abs(N-M);
responselength = N + M - 1; 

% xqpad = [zeros(1,padzeros) x_q];
y_q = zeros(1,responselength);

X = 3;
MultWidth = N1 + N2 + 1;
MultPrecision = R1 + R2;
AddPrecision = R1 + R2;

for k = 1:responselength % for each output sample
%    if n > M
%         start = n - M;
%     else
%         start = 1;
%     end
%     if n < N
%         nd = n;
%     else
%         nd = N;
%     end
    
%     for k = start:nd
    for i = 1:M
        j = k - i + 1; % position in x_q
        if j >= 1 
            if j <= N
%                 sprintf("n:%d\tk:%d\txqindx:%d\thqindx:%d",k,i,j,i)
                [prod, fp_info_mult] = fp_mult(h_q(i),x_q(j),N1,R1,N2,R2,MultWidth,MultPrecision);
                [y_q(k), fp_info_sum] = fp_add(prod, y_q(k), MultWidth,MultPrecision,MultWidth,MultPrecision,MultWidth+1,AddPrecision);
            end
        end
%         h_q_idx = k;
%         x_q_idx = n-k+1;
%         sprintf("n:%d\tk:%d\txqindx:%d\thqindx:%d",n,k,x_q_idx,h_q_idx)
%         [prod, fp_info_mult] = fp_mult(h_q(h_q_idx),x_q(x_q_idx),N1,R1,N2,R2,MultWidth,MultPrecision);
%         [y_q(n), fp_info_sum] = fp_add(prod, y_q(n), MultWidth,MultPrecision,MultWidth,MultPrecision,MultWidth+1,AddPrecision);
    end
    % for each filter weight
    % sum the above products together to one number
end

r3_shift = R3 - (R1 + R2); % R of result is R1+R2.
mantissa = round(y_q * 2^r3_shift);

fp_info.max_n3_mantissa = 2^(N3-1)-1;
fp_info.min_n3_mantissa = -2^(N3-1);

gti = y_q > fp_info.max_n3_mantissa;
lti = y_q < fp_info.min_n3_mantissa;

% mantissa(gti) = fp_info.max_n3_mantissa;
% mantissa(lti) = fp_info.min_n3_mantissa;


fp_info.add = fp_info_sum;
fp_info.mult = fp_info_mult;

end

