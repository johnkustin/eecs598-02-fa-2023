function [w, eh, dh, y, u1] = LMSupdate(n, u, w, y, e, sh, dh, eh, u1, NW, NS, mu)
%LMSUPDATE Summary of this function goes here
%   Detailed explanation goes here
    
    u1(n) = sh'*u(n:-1:n-NS+1);
    u1v = u1(n:-1:n-NW+1);

    y(n) = w'*u(n:-1:n-NW+1);
    dh(n) = e(n) + sh'*y(n:-1:n-NS+1);
    eh(n) = dh(n) - w'*u1v;

    w(:) = w + mu*eh(n)*u1v/(u1v'*u1v+1e-2);
end

