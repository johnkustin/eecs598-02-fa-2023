function [yp,dp,ep] = physical_sig_update(n0,wop,up,sp,yp,dp,y0,ep,NW,K)
%PHYSICAL_SIG_UPDATE Summary of this function goes here
%   Detailed explanation goes here
% physical
    yp(n0) = wop'*up(n0:-1:n0-NW*K+1);
    dp(n0) = sp'*yp(n0:-1:n0-NW*K+1);
    ep(n0) = dp(n0) + sp'*y0(n0:-1:n0-NW*K+1);
end

