% function [outputStruct] = entrypoint(inputStruct, QNSx, NW, NS, K, T)
function [outputStruct] = entrypoint(simParams, AAF, wop, sp, sh, up, yp, dp, ep, u0, yq, y0, d, u, u1, e, y, dh, eh, mu, w, w0, e0, QNSx, dt)

    T = mytypes(dt);
    AAF = cast(AAF, 'like', T.AAF);
    wop = cast(wop, 'like', T.wop);
    sp  = cast(sp, 'like', T.sp);
    sh  = cast(sh, 'like', T.sh);
    up  = cast(up, 'like', T.up); 
    yp  = cast(yp, 'like', T.yp);
    dp  = cast(dp, 'like', T.dp);
    ep  = cast(ep, 'like', T.ep);
    u0  = cast(u0, 'like', T.u0);
    yq  = cast(yq, 'like', T.yq);
    y0  = cast(y0, 'like', T.y0);
    e0  = cast(e0, 'like', T.e0);
    d   = cast(d, 'like', T.d);
    u   = cast(u, 'like', T.u);
    u1  = cast(u1, 'like', T.u1);
    e   = cast(e, 'like', T.e);
    y   = cast(y, 'like', T.y);
    dh  = cast(dh, 'like', T.dh);
    eh  = cast(eh, 'like', T.eh);
    mu  = cast(mu, 'like', T.mu);
    w   = cast(w, 'like', T.w);
    w0  = cast(w0, 'like', T.w0);


    
%% algorithm 
Li = simParams.Li;
K = simParams.K;
NW = simParams.NW;
NS = simParams.NS;
L = simParams.L;
quantizerType = simParams.quantizerType;
NW0 = simParams.NW0;
NQNS = simParams.NQNS;
n1 = 1;
xqns = zeros(L*K, NQNS);
yqns = zeros(L*K, NQNS);
q = zeros(L*K, NQNS);

for n0=Li*K:L*K
    % discrete
    u0(n0) = step(QNSx{1}, up(n0), quantizerType);
    
    yq(n0) = - w0'*u0(n0:-1:n0-NW0+1); % this is (step=1/K)*(step=2)
    y0(n0) = step(QNSx{3}, yq(n0), quantizerType);

    % physical
    % [yp,dp,ep] = physical_sig_update_mex(n0,wop,up,sp,yp,dp,y0,ep,NW,K);
    [yp,dp,ep] = sharedmex('physical_sig_update', n0,wop,up,sp,yp,dp,y0,ep,NW,K);
    
    % discrete
    e0(n0) = step(QNSx{4}, ep(n0), quantizerType);
    
    if mod(n0, K)==0
        n = n0/K;
        % [d, e, u] = u_e_d_update_mex(n, n0, u, AAF, u0, e, e0, dp, d);
        % [w, eh, dh, y, u1] = LMSupdate_mex(n, u, w, y, e, sh, dh, eh, u1, NW, NS, mu);
        [d, e, u] = sharedmex("u_e_d_update", n, n0, u, AAF, u0, e, e0, dp, d);
        [w, eh, dh, y, u1] = sharedmex("LMSupdate", n, u, w, y, e, sh, dh, eh, u1, NW, NS, mu);
    end
    
    if n1 > NW0
        n1 = 1;
        reset(QNSx{2});
    end
    w0(n1) = step(QNSx{2}, w(floor((n1-1)/K+0.5)+1)/K, quantizerType);
    n1 = n1 + 1;

    for i=1:NQNS
      xqns(n0,i) = QNSx{i}.x;
      yqns(n0,i) = QNSx{i}.yd;
      q(n0,i) = QNSx{i}.q;
    end
end

outputStruct.w0 = w0;
outputStruct.w  = w;
outputStruct.eh = eh;
outputStruct.dh = dh;
outputStruct.y  = y;
outputStruct.u1 = u1;
outputStruct.yp = yp;
outputStruct.dp = dp;
outputStruct.ep = ep;
outputStruct.e0 = e0;
outputStruct.y0 = y0;
outputStruct.yq = yq;
outputStruct.u0 = u0;
outputStruct.xqns = xqns;
outputStruct.yqns = yqns;
outputStruct.q = q;
outputStruct.d = d; 
outputStruct.e = e;
outputStruct.u = u;

end
