function [d, e, u] = u_e_d_update(n, n0, u, AAF, u0, e, e0, dp, d)
%LMSUPDATE Summary of this function goes here
%   Detailed explanation goes here
    
    u(n) = AAF*u0(n0:-1:n0-length(AAF)+1);
    e(n) = AAF*e0(n0:-1:n0-length(AAF)+1);
    d(n) = AAF*dp(n0:-1:n0-length(AAF)+1); % just for debug
end

